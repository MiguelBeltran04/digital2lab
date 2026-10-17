module alu ( // En este modulo solo se encaraga de realizar las operaciones de suma, resta y la de las compuertas EN FUNCIÓN DE OP
    input  wire [3:0] A,  //No almacena valores pasados ni sabe el estado de los botones/switches. LA SALIDA CAMBIA ANTE CUALQUIER CAMBIO EN LA ENTRADA.
    input  wire [3:0] B,  //Se mantiene separado de la gestión fisica de la FPGA, al final la ALU solo recibe los datos y opera, no se encarga de las conexiones
    input  wire [1:0] op,
    output wire  [3:0] Result
);
    assign Result = (op == 2'b00) ? (A + B) :
                    (op == 2'b01) ? (A - B) :
                    (op == 2'b10) ? (A & B) :
                    (op == 2'b11) ? (A | B) : 4'b0000;
endmodule
