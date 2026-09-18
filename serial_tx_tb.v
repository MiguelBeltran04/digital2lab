`timescale 1ns / 1ps

module serial_tx_tb;

    // Señales de prueba
    reg clk;
    reg rst;
    reg start;
    reg [7:0] data_in;
    
    wire tx;
    wire busy;
    wire done;

    // Instancia del módulo
    serial_tx #(
        .CLKS_PER_BIT(8)
    ) uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .data_in(data_in),
        .tx(tx),
        .busy(busy),
        .done(done)
    );

    // Generación de Reloj (Periodo de 10ns -> 100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Estímulos
    initial begin
        // Generación de archivo VCD para GTKWave
        $dumpfile("wave.vcd");
        $dumpvars(0, serial_tx_tb);

        // Condiciones iniciales
        rst = 1;
        start = 0;
        data_in = 8'h00;

        // Liberar reset en flanco de bajada (para estabilidad)
        @(negedge clk);
        rst = 0;
        @(negedge clk);

        // ==========================================
        // Transmisión 1: 8'hA5 (Binario: 10100101)
        // ==========================================
        $display("Iniciando transmision de 0xA5...");
        data_in = 8'hA5;
        start = 1;
        @(negedge clk); // Pulso de 1 ciclo
        start = 0;

        // Esperar hasta que se active done
        wait(done);
        @(negedge clk); 
        @(negedge clk); // Espacio entre envíos

        // ==========================================
        // Transmisión 2: 8'h3C (Binario: 00111100)
        // ==========================================
        $display("Iniciando transmision de 0x3C...");
        data_in = 8'h3C;
        start = 1;
        @(negedge clk); // Pulso de 1 ciclo
        start = 0;

        // Esperar hasta que se active done
        wait(done);
        
        // Dejar correr un par de ciclos extras y terminar
        #50;
        $display("Simulacion finalizada.");
        $finish;
    end

endmodule