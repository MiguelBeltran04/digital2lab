module comb_selector (clk, rst, next_comb, read_addrA, read_addrB);
input clk;
input rst;
input next_comb;
output reg [1:0] read_addrA;
output reg [1:0] read_addrB;

reg [3:0]comb_index;

always @(posedge clk or posedge rst) 
begin
    if (rst) 
    begin
        comb_index <= 4'd0;
    end
    else if (next_comb) 
    begin
        if (comb_index == 4'd11) 
        begin
            comb_index <= 4'd0;
        end
        else
        begin
            comb_index <= comb_index+4'd1;
        end
    end
end
always @(*) 
begin
    case (comb_index)
        4'd0:  begin read_addrA = 2'd0; read_addrB = 2'd1; end
        4'd1:  begin read_addrA = 2'd0; read_addrB = 2'd2; end
        4'd2:  begin read_addrA = 2'd0; read_addrB = 2'd3; end
        4'd3:  begin read_addrA = 2'd1; read_addrB = 2'd0; end
        4'd4:  begin read_addrA = 2'd1; read_addrB = 2'd2; end
        4'd5:  begin read_addrA = 2'd1; read_addrB = 2'd3; end
        4'd6:  begin read_addrA = 2'd2; read_addrB = 2'd0; end
        4'd7:  begin read_addrA = 2'd2; read_addrB = 2'd1; end
        4'd8:  begin read_addrA = 2'd2; read_addrB = 2'd3; end
        4'd9:  begin read_addrA = 2'd3; read_addrB = 2'd0; end
        4'd10: begin read_addrA = 2'd3; read_addrB = 2'd1; end
        4'd11: begin read_addrA = 2'd3; read_addrB = 2'd2; end
        default: begin
            read_addrA = 2'd0;
            read_addrB = 2'd1;
        end

    endcase
end
endmodule