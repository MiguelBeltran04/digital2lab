`timescale 1ns/1ps

module secAcc_tb;

    reg clk;
    reg rst;
    reg start;
    reg [1:0] mode;
    reg [3:0] x;

    wire [5:0] acc;
    wire done;

    secAcc uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .mode(mode),
        .x(x),
        .acc(acc),
        .done(done)
    );

initial begin
    clk = 0;
    forever #20 clk = ~clk;
end

initial begin
    $dumpfile("secAcc_tb.vcd");
    $dumpvars(0, secAcc_tb);
    rst=1;
    start=0;
    mode = 2'b00;
    x=4'd0;
    @(posedge clk);
    rst=0;
    start=1;
    @(posedge clk);
    start=0;
    repeat(5)@(posedge clk);
    x=4'd5;
    start=1;
    @(posedge clk);
    start=0;
    repeat(5)@(posedge clk);
    x=4'd11;
    mode= 2'b01;
    start=1;
    @(posedge clk);
    start=0;
    repeat(6)@(posedge clk);
    x=4'd2;
    mode=2'b10;
    start=1;
    @(posedge clk);
    start=0;
    wait(done==1);
    @(posedge clk);
    x=4'd12;
    mode=2'b00;
    start=1;
    @(posedge clk);
    start=0;
    repeat(2)@(posedge clk);
    mode=2'b11;
    @(posedge clk);
    start=1;
    mode=2'b00;
    @(posedge clk);
    start=0;
    wait(done==1);
    #40;
    
    $finish;

end

endmodule

// correr las simulaciones con: iverilog -o a.out secAcc_tb.v secAcc.v
// vvp a.out
// gtkwave secAcc_tb.vcd