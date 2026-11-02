module comb_selector_tb;

reg clk;
reg rst;
reg next_comb;

wire [1:0] read_addrA;
wire [1:0] read_addrB;

integer i;

comb_selector uut (
    .clk(clk),
    .rst(rst),
    .next_comb(next_comb),
    .read_addrA(read_addrA),
    .read_addrB(read_addrB)
);

// Reloj de 40 ns
initial begin
    clk = 0;
    forever #20 clk = ~clk;
end

initial begin
    $dumpfile("comb_selector_tb.vcd");
    $dumpvars(0, comb_selector_tb);

    rst = 1;
    next_comb = 0;

    #12 rst = 0;

    // Verificar combinacion inicial
    #1;
    if (read_addrA !== 2'd0 || read_addrB !== 2'd1)
        $fatal(1, "ERROR en reset");

    // Recorrer las 12 combinaciones
    for (i = 0; i < 12; i = i + 1)
    begin
        $display("Indice %0d: R%0d, R%0d",
                 i, read_addrA, read_addrB);

        @(negedge clk);
        next_comb = 1;

        @(negedge clk);
        next_comb = 0;
    end

    // Debe regresar a R0, R1
    #1;
    if (read_addrA !== 2'd0 || read_addrB !== 2'd1)
        $fatal(1, "ERROR: no regreso al inicio");

    // Comprobar que conserva la combinacion
    repeat(3) @(posedge clk);
    #1;

    if (read_addrA !== 2'd0 || read_addrB !== 2'd1)
        $fatal(1, "ERROR: no conserva combinacion");

    $display("PASS: selector de combinaciones");
    $finish;
end

endmodule
