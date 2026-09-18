`timescale 1ns / 1ps

module serial_tx #(
    parameter CLKS_PER_BIT = 8
)(
    input  wire clk,
    input  wire rst,
    input  wire start,
    input  wire [7:0] data_in,
    output wire tx,
    output wire busy,
    output wire done
);

    // Definición de estados de la FSM
    localparam IDLE       = 3'b000;
    localparam LOAD       = 3'b001;
    localparam BIT_HOLD   = 3'b010;
    localparam SHIFT_NEXT = 3'b011;
    localparam DONE_ST    = 3'b100;

    // Registros internos (Control y Datapath)
    reg [2:0] state, next_state;
    reg [7:0] shift_reg;
    reg [2:0] bit_count;
    reg [$clog2(CLKS_PER_BIT)-1:0] tick_cnt;

    // =========================================================
    // 1. Registro de Estado Actual (Secuencial)
    // =========================================================
    always @(posedge clk) begin
        if (rst) 
            state <= IDLE;
        else     
            state <= next_state;
    end

    // =========================================================
    // 2. Lógica de Siguiente Estado (Combinacional)
    // =========================================================
    always @(*) begin
        next_state = state; // Valor por defecto
        
        case (state)
            IDLE: begin
                if (start) 
                    next_state = LOAD;
            end
            
            LOAD: begin
                next_state = BIT_HOLD;
            end
            
            BIT_HOLD: begin
                // Se espera CLKS_PER_BIT - 2 ciclos aquí. 
                // El ciclo restante para completar CLKS_PER_BIT ocurre en SHIFT_NEXT.
                if (tick_cnt == (CLKS_PER_BIT - 2))
                    next_state = SHIFT_NEXT;
            end
            
            SHIFT_NEXT: begin
                if (bit_count == 3'd7) // Si ya se enviaron los 8 bits (0 a 7)
                    next_state = DONE_ST;
                else
                    next_state = BIT_HOLD;
            end
            
            DONE_ST: begin
                next_state = IDLE;
            end
            
            default: next_state = IDLE;
        endcase
    end

    // =========================================================
    // 3. Datapath y Contadores (Secuencial)
    // =========================================================
    always @(posedge clk) begin
        if (rst) begin
            shift_reg <= 8'd0;
            bit_count <= 3'd0;
            tick_cnt  <= 0;
        end else begin
            case (state)
                LOAD: begin
                    shift_reg <= data_in;
                    bit_count <= 3'd0;
                    tick_cnt  <= 0;
                end
                
                BIT_HOLD: begin
                    if (tick_cnt < (CLKS_PER_BIT - 2))
                        tick_cnt <= tick_cnt + 1'b1;
                end
                
                SHIFT_NEXT: begin
                    tick_cnt  <= 0;                         // Reinicia contador de temporización
                    shift_reg <= {1'b0, shift_reg[7:1]};    // Desplaza a la derecha (LSB primero)
                    bit_count <= bit_count + 1'b1;          // Incrementa contador de bits transmitidos
                end
            endcase
        end
    end

    // =========================================================
    // 4. Lógica de Salidas (Combinacional)
    // =========================================================
    // tx transmite el bit actual en BIT_HOLD y SHIFT_NEXT. En reposo es 1.
    assign tx   = (state == BIT_HOLD || state == SHIFT_NEXT) ? shift_reg[0] : 1'b1;
    // busy es alto durante todo el proceso de transmisión
    assign busy = (state == LOAD || state == BIT_HOLD || state == SHIFT_NEXT);
    // done es un pulso de un ciclo al finalizar
    assign done = (state == DONE_ST);

endmodule
