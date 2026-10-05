`timescale 1ns / 1ps

module tb_fouradder();

    // Entradas 
    reg  [3:0] sw;
    reg  [5:0] btn;

    // Salidas 
    wire [3:0] led;
    wire       led6_r;
    wire       led6_g;
    wire       led6_b;

    // Instanciación del módulo 'fouradder'
    fouradder dut (
        .sw(sw),
        .btn(btn),
        .led(led),
        .led6_r(led6_r),
        .led6_g(led6_g),
        .led6_b(led6_b)
    );

    initial begin
        
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_fouradder);

        // Monitoreo por consola
        $monitor("Tiempo = %0t ns | A=%d (%b) | B=%d (%b) | Control (btn[5:4])=%b%b || LED=%d | RGB (R,G,B)=%b%b%b",
                 $time, sw, sw, btn[3:0], btn[3:0], btn[5], btn[4], led, led6_r, led6_g, led6_b);

        
        // PRUEBA 1: Modos de Control de Botones (A = 3, B = 1)
        
        sw = 4'd3;

        // Modo 00: Suma Normal (3 + 1 = 4)
        btn = 6'b00_0001;
        #10;

        // Modo 01: Multiplicar por 2 (4 * 2 = 8)
        btn = 6'b01_0001;
        #10;

        // Modo 10: Invertir bits NOT (~4 = 11)
        btn = 6'b10_0001;
        #10;

        // Modo 11: Multiplicar por 2 e Invertir (~8 = 7)
        btn = 6'b11_0001;
        #10;

        
        // PRUEBA 2: A y B son iguales (A = 3, B = 3) -> Activa Canal Verde (G=1)
        
        sw  = 4'd3;
        btn = 6'b00_0011; // B = 3
        #10;

        
        // PRUEBA 3: Condición ALL_ONES en A (A = 15 / 4'b1111, B = 2)
        // El LED RGB debe forzarse a BLANCO (R=1, G=1, B=1)
        
        sw  = 4'b1111;    // A = 15
        btn = 6'b00_0010; // B = 2
        #10;

        
        // PRUEBA 4: Condición ALL_ONES en B (A = 4, B = 15 / 4'b1111)
        // El LED RGB debe forzarse a BLANCO (R=1, G=1, B=1)
        
        sw  = 4'd4;
        btn = 6'b00_1111; // B = 15
        #10;

        
        // PRUEBA 5: Entradas en Cero (A = 0, B = 0)
        // Como A == B, el Verde se enciende, Rojo=0, Azul=0 -> RGB = 010 (Verde puro)
        
        sw  = 4'd0;
        btn = 6'b00_0000;
        #10;

        #10;
        $display("--- Simulación finalizada correctamente ---");
        $finish;
    end

endmodule