module top_system (
    input  wire       clk,       // Reloj del sistema (K17)
    input  wire [3:0] sw,        // Switches sw[0] a sw[3] //CAPTURAN LO ACCIONADO EN FPGA
    input  wire [3:0] btn,       // Botones btn[0] a btn[3]
    output wire [3:0] led,       // LEDs led[0] a led[3] (Resultado)
    output reg        led6_r,    // LED RGB 6 - Canal Rojo
    output reg        led6_g,    // LED RGB 6 - Canal Verde
    output reg        led6_b     // LED RGB 6 - Canal Azul
);

    // Registros inicializados para almacenamiento persistente
    reg [3:0] reg_A  = 4'b0000;  //Memorias internas para los dos numeros y para el de operación
    reg [3:0] reg_B  = 4'b0000;
    reg [1:0] reg_op = 2'b00;

    // Detección de flanco de subida para conmutar la operación con btn[2] y btn[3]
    reg btn2_d = 1'b0; //para solucionar lo del relog de MHz, se genera un pulso
    reg btn3_d = 1'b0;
    wire btn2_pulse = btn[2] && !btn2_d;
    wire btn3_pulse = btn[3] && !btn3_d;

    // Control secuencial en cada flanco del reloj
    always @(posedge clk) begin
        btn2_d <= btn[2];
        btn3_d <= btn[3];

        // btn[0] guarda el valor de los switches en el Registro A
        if (btn[0]) reg_A <= sw; //Tanto para A como B no es necesario detectar el flanco de subida

        // btn[1] guarda el valor de los switches en el Registro B
        if (btn[1]) reg_B <= sw;

        // btn[2] modifica el bit 0 del código de operación
        if (btn2_pulse) reg_op[0] <= ~reg_op[0]; //si exige un detector de flanco. Al presionar el boton 2 o 3 cambio la operación, cambiara millones de veces por segundo debido al clock
//Fuerza a que la inversión del bit solo ocurra una vez en el momento en el que pasa de 0 a 1 por ejemplo. El resultado cambiara solo si se deja de pulsar el boton fisicamente
        // btn[3] modifica el bit 1 del código de operación
        if (btn3_pulse) reg_op[1] <= ~reg_op[1];
    end

    // Instanciación del módulo independiente ALU
    alu inst_alu (  //En este caso lo que hace es que los registros de este modulo se guardan en los del primero
        .A(reg_A),
        .B(reg_B),
        .op(reg_op),
        .Result(led)
    );

    // Indicador visual mediante el LED RGB 6
    always @(*) begin
        case (reg_op) //Variación del color dependiendo de la operación
            2'b00: begin led6_r = 1'b0; led6_g = 1'b1; led6_b = 1'b0; end // Suma -> Verde 
            2'b01: begin led6_r = 1'b1; led6_g = 1'b0; led6_b = 1'b0; end // Resta -> Rojo
            2'b10: begin led6_r = 1'b0; led6_g = 1'b0; led6_b = 1'b1; end // AND  -> Azul
            2'b11: begin led6_r = 1'b1; led6_g = 1'b1; led6_b = 1'b0; end // OR   -> Amarillo
            default: begin led6_r = 1'b0; led6_g = 1'b0; led6_b = 1'b0; end
        endcase
    end

endmodule