`timescale 1ns/1ns

module tb_semaforo;

    // Entradas y salidas
    reg clk;
    reg rst;

    wire green;
    wire yellow;
    wire red;

    // Instancia del módulo principal (DUT) en la simulación
    semaforo dut (
        .clk(clk),
        .rst(rst),
        .green(green),
        .yellow(yellow),
        .red(red)
    );

    // Generación del clk
    always #5 clk = ~clk;

    initial begin
        
        $dumpfile("semaforo1.vcd");
        $dumpvars(0, tb_semaforo);

        // 1. Estado inicial con Reset activado
        clk = 0;
        rst = 1;

        // 2. Finalizar el reset tras 20 ns
        #20;
        rst = 0;

        // 3. Dejar la simulación de forma continua durante 300 ns
        #300;

        // 4. Finalizar simulación
        $finish;
    end

endmodule