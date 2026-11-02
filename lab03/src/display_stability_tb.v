
`timescale 1ns/1ps

module display_stability_tb;

reg clk;
reg rst;
reg signed [7:0] value;
reg ack_pull_low;

wire tm_clk;
tri1 tm_dio;

reg [7:0] expected [0:6];

integer transaction_num;
integer bytes_in_transaction;
integer byte_num;
integer bit_num;
integer pos;

assign tm_dio = ack_pull_low ? 1'b0 : 1'bz;

display_tm1637 #(
    .CLK_HZ(1_000_000)
) uut (
    .clk(clk),
    .rst(rst),
    .value(value),
    .tm_clk(tm_clk),
    .tm_dio(tm_dio)
);

// Generacion del reloj
initial begin
    clk = 0;
    forever #500 clk = ~clk;
end

initial begin

    $dumpfile("display_stability_tb.vcd");
    $dumpvars(0, display_stability_tb);

    // Bytes esperados para value = 12
    expected[0] = 8'h40;
    expected[1] = 8'hC0;
    expected[2] = 8'h00;
    expected[3] = 8'h00;
    expected[4] = 8'h06;
    expected[5] = 8'h5B;
    expected[6] = 8'h8A;

    rst = 1;
    value = 12;
    ack_pull_low = 0;
    pos = 0;

    repeat(2) @(negedge clk);
    rst = 0;

    for (transaction_num = 0;
         transaction_num < 3;
         transaction_num = transaction_num + 1)
    begin

        // Verificar START
        @(negedge tm_dio);
        #1;

        if (tm_clk !== 1'b1)
            $fatal(1, "ERROR START");

        // Cambiar value durante la transmision
        if (transaction_num == 0)
        begin
            value = -8'sd5;
            $display("Cambio de value a -5 durante la trama");
        end

        if (transaction_num == 1)
            bytes_in_transaction = 5;
        else
            bytes_in_transaction = 1;

        for (byte_num = 0;
             byte_num < bytes_in_transaction;
             byte_num = byte_num + 1)
        begin

            // Comprobar 8 bits, LSB primero
            for (bit_num = 0;
                 bit_num < 8;
                 bit_num = bit_num + 1)
            begin
                @(posedge tm_clk);
                #1;

                if (tm_dio !== expected[pos][bit_num])
                    $fatal(1,
                        "ERROR byte %0d bit %0d",
                        pos, bit_num);
            end

            // Simular ACK
            @(negedge tm_clk);
            #1;
            ack_pull_low = 1;

            @(posedge tm_clk);
            #1;

            if (tm_dio !== 1'b0)
                $fatal(1, "ERROR ACK");

            @(negedge tm_clk);
            #1;
            ack_pull_low = 0;

            if (uut.ack_received !== 1'b1)
                $fatal(1, "ACK no registrado");

            $display("PASS byte %0d = %h",
                     pos, expected[pos]);

            pos = pos + 1;
        end

        // Verificar STOP
        @(posedge tm_clk);
        #1;

        if (tm_dio !== 1'b0)
            $fatal(1, "ERROR antes de STOP");

        @(posedge tm_dio);
        #1;

        if (tm_clk !== 1'b1)
            $fatal(1, "ERROR STOP");

        $display("PASS transaccion %0d",
                 transaction_num);
    end

    if (pos != 7)
        $fatal(1, "Cantidad de bytes incorrecta");

    $display("PASS: estabilidad durante transmision");
    $finish;
end

// Timeout de seguridad
initial begin
    #3000000;
    $fatal(1, "ERROR: timeout");
end

endmodule
