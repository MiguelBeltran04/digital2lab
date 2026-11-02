
`timescale 1ns/1ps

module alu_tb;

reg [3:0] a;
reg [3:0] b;
reg [2:0] op;

wire signed [7:0] result;

reg signed [7:0] expected;

integer i;
integer j;
integer k;
integer tests;

// Instancia de la ALU
alu uut (
    .a(a),
    .b(b),
    .op(op),
    .result(result)
);

initial begin

    $dumpfile("alu_tb.vcd");
    $dumpvars(0, alu_tb);

    a = 0;
    b = 0;
    op = 0;
    tests = 0;

    // Recorrer todos los valores de A
    for (i = 0; i < 16; i = i + 1)
    begin

        // Recorrer todos los valores de B
        for (j = 0; j < 16; j = j + 1)
        begin

            // Recorrer las ocho operaciones
            for (k = 0; k < 8; k = k + 1)
            begin

                a = i;
                b = j;
                op = k;

                // Calcular resultado esperado
                case (op)

                    3'b000: expected = i + j;

                    3'b001: expected = i - j;

                    3'b010: expected = i & j;

                    3'b011: expected = i | j;

                    3'b100: expected = i ^ j;

                    3'b101: expected = (~i) & 15;

                    3'b110: expected = i << 1;

                    3'b111: expected =
                        (i > j) ? 8'sd1 : 8'sd0;

                    default: expected = 0;

                endcase

                #1;

                // Verificar resultado
                if (result !== expected)
                begin
                    $display("ERROR EN ALU");
                    $display("A = %0d", a);
                    $display("B = %0d", b);
                    $display("Operacion = %03b", op);
                    $display("Obtenido = %0d", result);
                    $display("Esperado = %0d", expected);

                    $fatal(1, "Prueba fallida");
                end

                tests = tests + 1;

            end
        end
    end

    $display("PASS: %0d operaciones verificadas", tests);
    $display("PASS: ALU completa");

    $finish;

end

endmodule
