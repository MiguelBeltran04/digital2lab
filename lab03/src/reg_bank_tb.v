
`timescale 1ns/1ps

`timescale 1ns/1ps

module reg_bank_tb;

reg clk;
reg rst;
reg write_enable;
reg [1:0] write_addr;
reg [3:0] write_data;
reg [1:0] read_addrA;
reg [1:0] read_addrB;

wire [3:0] A;
wire [3:0] B;

reg_bank uut (
    .clk(clk),
    .rst(rst),
    .write_enable(write_enable),
    .write_addr(write_addr),
    .write_data(write_data),
    .read_addrA(read_addrA),
    .read_addrB(read_addrB),
    .A(A),
    .B(B)
);

initial begin
    clk = 0;
    forever #20 clk = ~clk;
end

initial begin
    $dumpfile("reg_bank_tb.vcd");
    $dumpvars(0, reg_bank_tb);

    rst = 1;
    write_enable = 0;
    write_addr = 0;
    write_data = 0;
    read_addrA = 0;
    read_addrB = 0;

    repeat(2) @(negedge clk);
    rst = 0;
    repeat(1) @(negedge clk);

    if (A !== 4'd0 || B !== 4'd0)
        $fatal(1, "ERROR: los registros no estan en 0 tras el reset");

    write_addr = 2'd0; write_data = 4'd5; write_enable = 1;
    @(negedge clk);

    write_addr = 2'd1; write_data = 4'd10; write_enable = 1;
    @(negedge clk);

    write_addr = 2'd2; write_data = 4'd15; write_enable = 1;
    @(negedge clk);

    write_addr = 2'd3; write_data = 4'd7; write_enable = 1;
    @(negedge clk);

    write_enable = 0;
    repeat(2) @(negedge clk);

    read_addrA = 2'd0;
    read_addrB = 2'd1;
    repeat(2) @(negedge clk);
    if (A !== 4'd5 || B !== 4'd10)
        $fatal(1, "ERROR: Lectura R0, R1 incorrecta");

    read_addrA = 2'd2;
    read_addrB = 2'd3;
    repeat(2) @(negedge clk);
    if (A !== 4'd15 || B !== 4'd7)
        $fatal(1, "ERROR: Lectura R2, R3 incorrecta");

    write_addr = 2'd0;
    write_data = 4'd12;
    write_enable = 0;
    repeat(2) @(negedge clk);

    read_addrA = 2'd0;
    #1;
    if (A !== 4'd5)
        $fatal(1, "ERROR: Sobrescritura no deseada con write_enable=0");

    repeat(3) @(negedge clk);

    $display("PASS: prueba extendida del banco de registros completada con exito");
    $finish;
end

endmodule