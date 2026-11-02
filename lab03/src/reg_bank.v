module reg_bank(clk, rst, write_enable, write_addr, write_data, read_addrA, read_addrB, A, B);
input clk;
input rst;
input write_enable;
input [1:0] write_addr;
input [3:0] write_data;
input [1:0] read_addrA;
input [1:0] read_addrB;
output [3:0] A;
output [3:0] B;

reg [3:0] registers [0:3];

integer i;
always @(posedge clk or posedge rst) 
begin
    if (rst) 
    begin
        for (i = 0; i<4; i=i+1) 
        begin
            registers[i] <= 4'b0;    
        end
    end
    else if (write_enable) 
    begin
        registers[write_addr] <= write_data;    
    end
end
    assign A = registers[read_addrA];
    assign B = registers[read_addrB];

endmodule