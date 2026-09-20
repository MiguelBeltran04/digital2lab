module secAcc (clk, rst, start, mode, x, acc, done);
input clk;
input rst;
input start;
input [1:0] mode;
input [3:0] x;
output reg [5:0] acc;
output reg done;

parameter IDLE = 2'b00;
parameter LOAD = 2'b01;
parameter ADD = 2'b10;
parameter DONE = 2'b11;

reg [1:0] STATE;
reg [1:0] COUNTER;

always @(posedge clk or posedge rst) 
begin

    if (rst) 
    begin
        STATE <= IDLE;
        COUNTER <= 2'b0;
        acc <= 6'd0;    
        done <=1'b0;
    end
    else begin
        case (STATE)
            IDLE:
            begin
                done=1'b0;
                if (start)
                    STATE <= LOAD;
                else
                    STATE <= IDLE;
            end
            LOAD:
            begin
                acc <= 6'b0;
                COUNTER <= 2'b0;
                STATE <= ADD;
            end
            ADD:
            begin
                acc <= acc+x;
                case (mode)
                    2'b00:
                    begin
                        if (COUNTER == 2'd2)
                            STATE <= DONE;
                        else
                        begin
                            COUNTER <= COUNTER +1'b1;
                            STATE <= ADD;
                        end
                    end
                    2'b01:
                    begin
                        if (COUNTER == 2'd3)
                            STATE <= DONE;
                        else begin
                            COUNTER <= COUNTER +1'b1;
                            STATE <= ADD;
                        end
                    end 
                    2'b10:
                    begin
                        if ((acc+x) >= 6'd20)
                            STATE <= DONE;
                        else
                            STATE <= ADD;
                    end
                    2'b11:
                    begin
                        STATE <= IDLE;
                    end
                    default: 
                    begin
                        STATE <= IDLE;
                    end
                endcase
            end
            DONE:
            begin
                done = 1'b1;
                STATE <= IDLE;
            end
            default: 
            begin
                STATE <= IDLE; 
            end
        endcase
    end
end
endmodule
