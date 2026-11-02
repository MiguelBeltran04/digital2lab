module button_debounce #(parameter integer DEBOUNCE_CYCLES=2_500_000)(clk, rst, btn_in, btn_level, btn_pulse);
input clk;
input rst;
input btn_in;
output reg btn_level;
output reg btn_pulse;

reg sync0;
reg sync1;

localparam integer COUNTER_WIDTH = (DEBOUNCE_CYCLES >1) ? $clog2(DEBOUNCE_CYCLES) : 1; //Utilizamos $clog2 para calcular automáticamente cuántos bits necesita el contador

reg [COUNTER_WIDTH-1:0] counter;
always @(posedge clk or posedge rst) 
begin
    if (rst) 
    begin
        sync0 <= 1'b0;
        sync1 <= 1'b0;
        counter <= 0;
        btn_level <= 1'b0;
        btn_pulse <= 1'b0;    
    end
    else begin
        sync0 <= btn_in;
        sync1 <= sync0;
        btn_pulse <= 1'b0;
        if (sync1 == btn_level) 
        begin
            counter <=0;   
        end
        else if (counter == DEBOUNCE_CYCLES-1) 
        begin
            counter <= 0;
            btn_level <= sync1;
            if (sync1) 
            begin
                btn_pulse <=1'b1;    
            end
        end
        else begin
            counter <= counter+1'b1;
        end
    end
end

endmodule