
module alu (
    input wire [3:0] a,
    input wire [3:0] b,
    input wire [2:0] op,
    output reg signed [7:0] result
);

always @(*)
begin
    case (op)

        // Suma
        3'b000: result = $signed({4'b0000,a}) + $signed({4'b0000,b});

        // Resta
        3'b001: result = $signed({4'b0000,a}) - $signed({4'b0000,b});

        // AND
        3'b010: result = $signed({4'b0000,(a & b)});

        // OR
        3'b011: result = $signed({4'b0000,(a | b)});

        // XOR
        3'b100: result = $signed({4'b0000,(a ^ b)});

        // NOT A
        3'b101: result = $signed({4'b0000,(~a)});

        // Desplazamiento a la izquierda
        3'b110: result = $signed({3'b000, a, 1'b0});

        // Comparacion A > B
        3'b111: result = (a > b) ? 8'sd1 : 8'sd0;

        default: result = 8'sd0;

    endcase
end

endmodule
