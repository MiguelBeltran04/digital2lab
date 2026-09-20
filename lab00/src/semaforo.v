module semaforo (
    input wire clk, //Definición entradas
    input wire rst,

    output reg green, //Definición salidas
    output reg yellow,
    output reg red
);
    
    localparam ESTADO_VERDE    = 2'b00;  //Definción Estados
    localparam ESTADO_AMARILLO = 2'b01;
    localparam ESTADO_ROJO     = 2'b10;

    localparam TIEMPO_VERDE    = 4'd4;  //Definición tiempos duración de luces
    localparam TIEMPO_AMARILLO = 4'd1;
    localparam TIEMPO_ROJO     = 4'd3;

    reg [1:0] estado_actual, estado_siguiente;  //definición de registros internos
    reg [3:0] contador;
    reg       reset_contador;
    reg       direccion;

    // Bloque 1: Contador de flancos y definición de "reg    dirección"
    always @(posedge clk or posedge rst) begin   
        if (rst || reset_contador) begin  // Reset o cuando reset_contador = 1, el regitro contador se reinicia
            contador <= 4'd0;
        end else begin
            contador <= contador + 1'b1;  //Si no, va sumando 1 bit
        end

        if (rst) begin
            direccion <= 1'b0; 
        end 
        
        else if (estado_actual == ESTADO_VERDE) begin
            direccion <= 1'b0;
        end 
        
        else if (estado_actual == ESTADO_ROJO) begin //Definición cambio en valor de dirección para hacer transición a verde o rojo desde amarillo
            direccion <= 1'b1;
        end
    end

    // Bloque 2: Registro de los estados
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            estado_actual <= ESTADO_VERDE;
        end 
        
        else begin
            estado_actual <= estado_siguiente;
        end
    end

    // Bloque 3: Transición de estados
    always @(*) begin
        estado_siguiente = estado_actual;
        reset_contador   = 1'b0;

        case (estado_actual)
            ESTADO_VERDE: begin
                if (contador >= TIEMPO_VERDE) begin
                    estado_siguiente = ESTADO_AMARILLO;
                    reset_contador   = 1'b1;
                end
            end

            ESTADO_AMARILLO: begin
                if (contador >= TIEMPO_AMARILLO) begin
                    reset_contador = 1'b1;
                    if (direccion == 1'b0)
                        estado_siguiente = ESTADO_ROJO;
                    else
                        estado_siguiente = ESTADO_VERDE;
                end
            end

            ESTADO_ROJO: begin
                if (contador >= TIEMPO_ROJO) begin
                    estado_siguiente = ESTADO_AMARILLO;
                    reset_contador   = 1'b1;
                end
            end

            default: begin
                estado_siguiente = ESTADO_VERDE;
                reset_contador   = 1'b1;
            end
        endcase
    end

    // Bloque 4: Lógica de salidas
    always @(*) begin
        green  = 1'b0;  //salidas inician en 0
        yellow = 1'b0;
        red    = 1'b0;

        case (estado_actual)
            ESTADO_VERDE:    green  = 1'b1;
            ESTADO_AMARILLO: yellow = 1'b1;
            ESTADO_ROJO:     red    = 1'b1;
        endcase
    end

endmodule