module display_tm1637 #(parameter CLK_HZ =125_000_000)(clk, rst, value, tm_clk, tm_dio);
input clk;
input rst;
input signed [7:0] value;
output reg tm_clk;
inout wire tm_dio;
localparam integer TICKS_PER_STEP = CLK_HZ/200_000;
reg [31:0] div_count;
reg step_tick;

//conversión 7 segmentos
function [7:0] seg7;
    input[3:0] digit;
    begin
        case (digit)
            4'd0: seg7 = 8'h3F;
            4'd1: seg7 = 8'h06;
            4'd2: seg7 = 8'h5B;
            4'd3: seg7 = 8'h4F;
            4'd4: seg7 = 8'h66;
            4'd5: seg7 = 8'h6D;
            4'd6: seg7 = 8'h7D;
            4'd7: seg7 = 8'h07;
            4'd8: seg7 = 8'h7F;
            4'd9: seg7 = 8'h6F;
            4'hA: seg7 = 8'h40; // Signo negativo
            4'hF: seg7 = 8'h00; // Apagado
            default: seg7 = 8'h00;
        endcase
    end
endfunction

reg negative;
reg [8:0] magnitude;
reg [3:0] hundreds;
reg [3:0] tens;
reg [3:0] units;
reg [3:0] digit0;
reg [3:0] digit1;
reg [3:0] digit2;
reg [3:0] digit3;


// separacion por unidades, decenas, centenas y signo negativo
always @(*) 
begin
    negative = value[7];
    if (negative) 
    begin
        magnitude = -$signed({value[7], value});    
    end
    else
    begin
        magnitude = {1'b0, value};
    end

    //separacion de los dijitos en nibbles
    hundreds = magnitude / 9'd100;
    tens = (magnitude % 9'd100) / 9'd10;
    units = magnitude % 9'd10;
    digit0 = 4'hF;
    digit1 = 4'hF;
    digit2 = 4'hF;
    digit3 = units;

    if (hundreds != 0) 
    begin
        digit1 = hundreds;
        digit2 = tens;    
    end
    else if (tens != 0) 
    begin
        digit2 = tens;    
    end
    if (negative) 
    begin
        if (hundreds != 0) 
            digit0 = 4'hA;
        else if (tens !=0) 
            digit1 = 4'hA;
        else 
            digit2 = 4'hA;    
    end
end
wire [7:0] seg0;
wire [7:0] seg1;
wire [7:0] seg2;
wire [7:0] seg3;
assign seg0 = seg7(digit0);
assign seg1 = seg7(digit1);
assign seg2 = seg7(digit2);
assign seg3 = seg7(digit3);

//contador para generar pulsos de reloj adecuados para el tm1637

always @(posedge clk or posedge rst) 
begin
    if (rst) 
    begin
        div_count <=0;
        step_tick <=0;    
    end
    else begin
        if (div_count == TICKS_PER_STEP-1) 
        begin
            div_count <=0;
            step_tick <=1;    
        end
        else begin
            div_count <= div_count+1;
            step_tick <= 0;
        end
    end
end

reg dio_drive_low;
assign tm_dio = dio_drive_low ? 1'b0 : 1'bz;

//registros de transmisión

reg [7:0] tx_byte;// guarda el byte a transmitir
reg [1:0] transaction;// selecciona las transacciones que indican la transsmision de datos al tm
reg [2:0] byte_index;// indica con qué byte se esta realizando la transacción

reg [7:0] frame_seg0;
reg [7:0] frame_seg1;
reg [7:0] frame_seg2;
reg [7:0] frame_seg3;// guarda los patrones de los 4 digitos durante la transmisión para evitar que un cambio en value modifique los datos a mitad de una transmisión

reg [2:0] bit_index;
reg ack_received;


//maquina de estados para el tm1637

localparam [3:0]
    IDLE         = 4'd0,
    START        = 4'd1,
    START_HOLD   = 4'd2,
    BIT_SETUP    = 4'd3,
    BIT_HIGH     = 4'd4,
    BIT_LOW      = 4'd5,
    ACK_RELEASE  = 4'd6,
    ACK_RISE     = 4'd7,
    ACK_SAMPLE   = 4'd8,
    ACK_FALL     = 4'd9,
    STOP_PREP    = 4'd10,
    STOP_RISE    = 4'd11,
    STOP_RELEASE = 4'd12,
    LOAD_NEXT         = 4'd13;

reg [3:0] state;


always @(posedge clk or posedge rst)
begin
    if (rst)
    begin
        state <= IDLE;
        tm_clk <= 1'b1;
        dio_drive_low <= 1'b0;
        bit_index <= 3'd0;
        ack_received <= 1'b0;

        tx_byte <= 8'h40;
        transaction <= 2'd0;
        byte_index <= 3'd0;
        frame_seg0 <= 8'h00;
        frame_seg1 <= 8'h00;
        frame_seg2 <= 8'h00;
        frame_seg3 <= 8'h00;

    end
    else if (step_tick)
    begin
        case (state)

            IDLE:
            begin
                tm_clk <= 1'b1;
                dio_drive_low <= 1'b0;

                transaction <= 2'd0;
                byte_index <= 3'd0;
                bit_index <= 3'd0;

                tx_byte <= 8'h40;

                frame_seg0 <= seg0;
                frame_seg1 <= seg1;
                frame_seg2 <= seg2;
                frame_seg3 <= seg3;

                state <= START;
            end

            START:
            begin
                dio_drive_low <= 1'b1;
                state <= START_HOLD;
            end

            START_HOLD:
            begin
                tm_clk <= 1'b0;
                state <= BIT_SETUP;
            end

            // Colocar el bit en DIO
            BIT_SETUP:
            begin
                dio_drive_low <= ~tx_byte[bit_index];
                state <= BIT_HIGH;
            end

            // Subir CLK para transmitir el bit
            BIT_HIGH:
            begin
                tm_clk <= 1'b1;
                state <= BIT_LOW;
            end

            // Bajar CLK y avanzar al siguiente bit
            BIT_LOW:
            begin
                tm_clk <= 1'b0;

                if (bit_index == 3'd7)
                    state <= ACK_RELEASE;
                else
                begin
                    bit_index <= bit_index + 3'd1;
                    state <= BIT_SETUP;
                end
            end

            // Liberar DIO para recibir ACK
            ACK_RELEASE:
            begin
                dio_drive_low <= 1'b0;
                state <= ACK_RISE;
            end

            ACK_RISE:
            begin
                tm_clk <= 1'b1;
                state <= ACK_SAMPLE;
            end

            // Leer respuesta del TM1637
            ACK_SAMPLE:
            begin
                ack_received <= (tm_dio == 1'b0);
                state <= ACK_FALL;
            end


            ACK_FALL: // Si estamos en la transacción 1, que contiene C0 y los cuatro dígitos, debemos verificar si faltan bytes por transmitir. Si faltan, avanzamos a LOAD_NEXT. Si ya terminamos, pasamos a preparar STOP.
            begin
                tm_clk <= 1'b0;

                if (transaction == 2'd1 && byte_index < 3'd4)
                begin
                    byte_index <= byte_index + 3'd1;
                    state <= LOAD_NEXT;
                end
                else
                begin
                    state <= STOP_PREP;
                end
            end

            LOAD_NEXT:
            begin
                case (byte_index)
                    3'd1: tx_byte <= frame_seg0;
                    3'd2: tx_byte <= frame_seg1;
                    3'd3: tx_byte <= frame_seg2;
                    3'd4: tx_byte <= frame_seg3;

                    default: tx_byte <= 8'h00;
                endcase

                bit_index <= 3'd0;
                state <= BIT_SETUP;
            end

            STOP_PREP:
            begin
                dio_drive_low <= 1'b1;
                state <= STOP_RISE;
            end

            STOP_RISE:
            begin
                tm_clk <= 1'b1;
                state <= STOP_RELEASE;
            end


            STOP_RELEASE:
            begin
                dio_drive_low <= 1'b0;

                if (transaction == 2'd0)
                begin
                    transaction <= 2'd1;
                    byte_index <= 3'd0;
                    bit_index <= 3'd0;
                    tx_byte <= 8'hC0;
                    state <= START;
                end
                else if (transaction == 2'd1)
                begin
                    transaction <= 2'd2;
                    bit_index <= 3'd0;
                    tx_byte <= 8'h8A;
                    state <= START;
                end
                else
                begin
                    state <= IDLE;
                end
            end

            default:
            begin
                state <= IDLE;
                tm_clk <= 1'b1;
                dio_drive_low <= 1'b0;
            end

        endcase
    end
end




endmodule