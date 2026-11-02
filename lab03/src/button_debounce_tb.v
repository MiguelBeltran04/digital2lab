
`timescale 1ns/1ps

module button_debounce_tb;

reg clk;
reg rst;
reg btn_in;

wire btn_level;
wire btn_pulse;

integer pulse_count;
reg previous_pulse;

button_debounce #(
    .DEBOUNCE_CYCLES(4)
) uut (
    .clk(clk),
    .rst(rst),
    .btn_in(btn_in),
    .btn_level(btn_level),
    .btn_pulse(btn_pulse)
);

// Reloj de 10 ns
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

// Contador de pulsos detectados
always @(posedge clk)
begin
    #1;

    if (rst)
    begin
        pulse_count = 0;
        previous_pulse = 0;
    end
    else
    begin
        if (btn_pulse && previous_pulse)
            $fatal(1, "ERROR: pulso mayor a un ciclo");

        if (btn_pulse)
            pulse_count = pulse_count + 1;

        previous_pulse = btn_pulse;
    end
end

initial begin

    $dumpfile("button_debounce_tb.vcd");
    $dumpvars(0, button_debounce_tb);

    rst = 1;
    btn_in = 0;

    repeat(3) @(negedge clk);
    rst = 0;

    // Simular rebotes al presionar
    @(negedge clk) btn_in = 1;
    @(negedge clk) btn_in = 0;
    @(negedge clk) btn_in = 1;
    @(negedge clk) btn_in = 0;
    @(negedge clk) btn_in = 1;

    // Mantener presionado
    repeat(12) @(negedge clk);
    #2;

    if (btn_level !== 1 || pulse_count != 1)
        $fatal(1, "ERROR en primera pulsacion");

    $display("PASS: rebotes filtrados");

    // Mantener el boton presionado
    repeat(12) @(negedge clk);
    #2;

    if (pulse_count != 1)
        $fatal(1, "ERROR: multiples pulsos");

    $display("PASS: pulsacion prolongada");

    // Simular rebotes al soltar
    @(negedge clk) btn_in = 0;
    @(negedge clk) btn_in = 1;
    @(negedge clk) btn_in = 0;

    repeat(12) @(negedge clk);
    #2;

    if (btn_level !== 0 || pulse_count != 1)
        $fatal(1, "ERROR al liberar");

    $display("PASS: liberacion correcta");

    // Segunda pulsacion
    @(negedge clk) btn_in = 1;

    repeat(12) @(negedge clk);
    #2;

    if (btn_level !== 1 || pulse_count != 2)
        $fatal(1, "ERROR segunda pulsacion");

    $display("PASS: segunda pulsacion");
    $display("PASS: button_debounce completo");

    $finish;
end

endmodule
