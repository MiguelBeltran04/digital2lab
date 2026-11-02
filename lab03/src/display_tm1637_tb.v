
`timescale 1ns/1ps

module display_tm1637_tb;

reg clk;
reg rst;
reg signed [7:0] value;

wire tm_clk;
wire tm_dio;

display_tm1637 uut (
    .clk(clk),
    .rst(rst),
    .value(value),
    .tm_clk(tm_clk),
    .tm_dio(tm_dio)
);

task check;
    input signed [7:0] test_value;
    input [3:0] d0, d1, d2, d3;
    begin
        value = test_value;
        #10;

        if (uut.digit0 !== d0 ||
            uut.digit1 !== d1 ||
            uut.digit2 !== d2 ||
            uut.digit3 !== d3)
        begin
            $fatal(1, "ERROR: value=%0d", value);
        end

        $display("PASS: value=%0d", value);
    end
endtask

initial begin
    clk = 0;
    rst = 0;
    value = 0;

    $dumpfile("display_tm1637_tb.vcd");
    $dumpvars(0, display_tm1637_tb);

    check(8'sd0,    4'hF, 4'hF, 4'hF, 4'd0);
    check(8'sd12,   4'hF, 4'hF, 4'd1, 4'd2);
    check(8'sd30,   4'hF, 4'hF, 4'd3, 4'd0);
    check(-8'sd5,   4'hF, 4'hF, 4'hA, 4'd5);
    check(-8'sd12,  4'hF, 4'hA, 4'd1, 4'd2);
    check(8'sd127,  4'hF, 4'd1, 4'd2, 4'd7);
    check(8'sh80,   4'hA, 4'd1, 4'd2, 4'd8);

    $display("PASS: conversion decimal");
    $finish;
end

endmodule
