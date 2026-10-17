# Laboratorio 02 
## Diseño, simulación e implementación de una ALU de 4 bits

---

## Integrantes

- Miguel Esteban Beltrán Silva – 1025524635
- Sebastián Camilo Ortegon Hernandez – 1014861874
- Andres Jacobo Rojas Gonzalez – 1025762831
 
**Semestre:** 2026-2  

---

## Funcionamiento del sistema

- **ALU:**  Para este ejercicio se programo la ALU en un modulo completamente aparte al top_system o unidad de control (Básicamente para que esta cumpliera de forma exclusiva la función de realizar operaciones con base a las entradas, y devolver al top el resultado dependiendo de las entradas actuales). En esta parte dependiendo del estado de un par de botones de la FPGA, se realizara una operación entre dos números de 4 bits (Mas adelante se vera con mas detalle como se guardan estos números en el programa). Estas operaciones son; suma (`2'b00`), resta (`2'b01`) y comparación utilizando AND (`2'b10`) y OR (`2'b11`) y al final, el resultado seguirá siendo de 4 bits (Si por ejemplo, el resultado de la suma de los dos números es mayor a 4 bits, se mostraran en los bits de salida los 4 bits menos significativos del resultado).
- **Funcionamiento de interfaz fisica:** Los números se guardaran gracias a la activación física de dos botones (por medio de los cuales el usuario decidirá si guardar el numero en el registro A, en el registro B, en ambos o si decide no guardar el numero previamente seleccionado por medio de los switches de la placa de desarrollo). Finalmente, dependiendo de la operación seleccionada (La cual se debe seleccionar al pulsar una vez el boton y no manteniendolo presionado), el led RGB se encendera y arrojara distintos colores (Verde si se selecciona la suma; Rojo si se selecciona la resta; Azul si se selección la compuerta AND y Amarillo si se selecciona la compuerta OR)

---

## Implementación

### Almacenamiento del código de operación:
Para determinar cuál operación va a realizar la ALU se utilizan los botones físicos de la FPGA "btn[2]" y "btn[3]". En verilog se declara un registro llammado "reg_op" de 2 bits, el cual se actualiza dentro de un bloque secuencial @always. Cuando se declara un registro de esta manera, el compilador implementa flip-flops tipo D en la FPGA, logrando que se conserve el valor retenido en la salida de forma indefinida a menos que se aplique una nueva orden de escritura en un flanco de reloj.
Es esencial durante el diseño notar que, debido a que el reloj de la FPGA es de 125 Mhz, una pulsación rápida real equivale a una pulsación lenta para el reloj. Por tanto, si se cambiara de estado utilizando directamente la pulsación del botón, entonces la operación cambiaría de valor millones de veces mientras el botón permanece presionado. 
Para evitar este efecto, se implementó un detector de flancos de subida que consiste en utilizar un registro de retardo para el botón presionado ('btn2_d' y 'btn3_d'). luego una compuerta AND se encarga de detectar únicamente el instante exacto en el que el botón pasa de estar apagado a encendido y mantenerlo solo durante un ciclo de reloj. La sintaxis en código para la evaluación del flanco de reloj de los botones funciona de la siguiente manera: Se declara un wire llamado btn2/3_pulse cuyo valor lógico es 1 en caso de que en el instante en el que el botón se presiona, durante el ciclo de reloj anterior el botón no haya sido presionado. Es decir, btn[2/3]=1 y btn2/3_d=0. Para que la condición se cumpla con la compuerta AND, se niega la salida de btn2/3_d. Esto equivale a decir que btn2/3_d es 1 si antes el botón no estuvo presionado.

En la tabla se hace un ejemplo del funcionamiento para el botón 2 durante 4 ciclos de reloj:

| ciclo | evento | btn[2] (actual) | btn2_d (anterior) | btn2_pulse |
|-------|--------|-----------------|-------------------|------------|
| 1 | Botón suelto | 0 | 0 | 0 |
| 2 | Botón se presiona | 1 | 0 | 1 |
| 3 | Se mantiene el botón | 1 | 1 | 0 |
| 4 | Se suelta el botón | 0 | 1 | 0 |

Además, dentro del bloque always se declara un 'if (btn2_pulse) reg_op[0] <= ~reg_op[0]' Esto implica que en el momento en el que se suelte el botón, la condición se evalúa como 0. Por tanto, no se le asigna ningún valor nuevo a reg_op[0]. De esta manera, al haber la ausencia de una asignación en el bloque secuencial, se retiene el estado anterior haciendo que los flip-flops mantengan guardado de forma permanente el último bit que se invirtió hasta que la condición vuelva a ser verdadera. Es decir, hasta que se vuelva a presionar el botón.

### Colores utilizados para identificar cada operación utilizando el LED RGB
La ALU cuenta con 4 operaciones. Se asignaron los colores verde, rojo, azul y amarillo a cada una. A continuación se muestra una tabla con la operación realizada y su color correspondiente:

| Operación | Representación binaria | Color | 
|-----------|------------------------|-------|
| Suma | 00 | Verde |
| Resta | 01 | Rojo |
| And | 10 | Azul |
| OR | 11 | Amarillo |
