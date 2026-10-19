`timescale 1ns / 1ps

module tb_top_system;

    // Declaración de entradas
    reg        clk;
    reg  [3:0] sw;
    reg  [3:0] btn;

    // Declaración de salidas
    wire [3:0] led;
    wire       led6_r;
    wire       led6_g;
    wire       led6_b;

    // Instanciación del módulo top
    top_system uut (
        .clk(clk),
        .sw(sw),
        .btn(btn),
        .led(led),
        .led6_r(led6_r),
        .led6_g(led6_g),
        .led6_b(led6_b)
    );

    // Generación del reloj de 125 MHz
    always #4 clk = ~clk;

    initial begin
        
        $dumpfile("top_system.vcd");
        $dumpvars(0, tb_top_system);

        
        // 1. ESTADO INICIAL
        
        clk = 0;
        sw  = 4'b0000;
        btn = 4'b0000;
        #20; // Espera 20ns

        
        // 2. CARGANDO OPERANDO A = 9 (4'b1001)
        
        sw = 4'd9;          // Seteamos el valor 9 en los switches
        #10;
        btn[0] = 1;         // Presionamos BTN0 para guardar en Reg A
        #16;                // Mantenemos el botón presionado 2 ciclos de reloj
        btn[0] = 0;         // Soltamos el botón
        #10;
        
        sw = 4'd0;          // Cambiamos los switches a 0 para verificar que Reg A conserve el 9
        #20;

        
        // 3. CARGANDO OPERANDO B = 3 (4'b0011)
        
        sw = 4'd3;          // Se cambia el valor a 3 en los switches
        #10;
        btn[1] = 1;         // Presionamos BTN1 para guardar en Reg B
        #16;                // Mantenemos el botón presionado 2 ciclos de reloj
        btn[1] = 0;         // Soltamos el botón
        #10;
        
        sw = 4'd15;         // Se cambian los switches a 15 para verificar que Reg B conserve el 3
        #20;

        
        // 4. VERIFICACIÓN DE SUMA (Código por defecto = 00)
        
        // Salida esperada en 'led': 9 + 3 = 12 (4'b1100)

        // LED RGB esperado: VERDE (led6_g = 1)
        #30;

        
        // 5. CONMUTAR BIT (btn[2]) -> Cambia op a 01 (RESTA)
        
        btn[2] = 1;         // Presionamos BTN2
        #40;                // Lo dejamos presionado varias ciclos 
        btn[2] = 0;         // Soltamos BTN2
        #20;
        // Salida esperada en 'led': 9 - 3 = 6 (4'b0110)
        // LED RGB esperado: ROJO (led6_r = 1)

        
        // 6. CONMUTAR BIT (btn[3]) -> Cambia op a 11 (OR)
       
        btn[3] = 1;         // Presionamos BTN3
        #24;
        btn[3] = 0;         // Soltamos BTN3
        #20;
        // Salida esperada en 'led': 9 OR 3 (1001 | 0011) = 11 (4'b1011)
        // LED RGB esperado: AMARILLO (led6_r = 1, led6_g = 1)

        
        // 7. CONMUTAR BIT (btn[2]) -> Cambia op a 10 (AND)
        
        btn[2] = 1;         // Presionamos BTN2
        #24;
        btn[2] = 0;         // Soltamos BTN2
        #20;
        // Salida esperada en 'led': 9 AND 3 (1001 & 0011) = 1 (4'b0001)
        // LED RGB esperado: AZUL (led6_b = 1)

        
        #50;
        $finish;
    end

endmodule