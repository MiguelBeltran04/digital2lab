`timescale 1ns / 1ps

module fouradder (
    input  wire [3:0] sw,        // SW[3:0] -> Operando A (4 bits)
    input  wire [5:0] btn,       // BTN[3:0] -> Operando B (4 bits), BTN[4] -> x2, BTN[5] -> Invertir (NOT)
    output wire [3:0] led,       // LED[3:0] -> Resultado final
    output wire       led6_r,    // LED RGB 6 - Canal Rojo
    output wire       led6_g,    // LED RGB 6 - Canal Verde
    output wire       led6_b     // LED RGB 6 - Canal Azul
);

    // 1. Captura de operandos
    wire [3:0] operand_a = sw;
    wire [3:0] operand_b = btn[3:0]; // Operando B

    // 2. Operaciones Lógicas Bit a Bit
    wire [3:0] and_result = operand_a & operand_b;
    wire [3:0] xor_result = operand_a ^ operand_b;

    // 3. Condición de "Todos los bits en 1" (AND de reducción)
    // Devuelve 1 si A == 4'b1111 O si B == 4'b1111
    wire all_ones = (&operand_a) | (&operand_b);

    // 4. Suma Aritmética Base (A + B)
    wire [3:0] base_sum = operand_a + operand_b;

    // 5. Lógica de control evaluando btn[5] y btn[4]
    reg [3:0] final_result;

    always @(*) begin
        case ({btn[5], btn[4]})
            2'b00:   final_result = base_sum;            // Suma normal (A + B)
            2'b01:   final_result = base_sum * 4'd2;     // Multiplica por 2
            2'b10:   final_result = ~base_sum;           // Inversión NOT
            2'b11:   final_result = ~(base_sum * 4'd2);  // Multiplica por 2 e invierte
            default: final_result = base_sum;
        endcase
    end

    // 6. Asignación a los 4 LEDs verdes
    assign led = final_result;

    // 7. Asignación al LED RGB 6 (se agrega 'all_ones' con OR a cada canal)
    assign led6_r = (|and_result)            | all_ones; // ROJO
    assign led6_g = (operand_a == operand_b) | all_ones; // VERDE (se mantiene la condición de igual)
    assign led6_b = (|xor_result)            | all_ones; // AZUL

endmodule