# Laboratorio 01 
## FPGA (Zybo Z7), Vivado/Vitis y validación de Hardware

---

## Integrantes

- Miguel Esteban Beltrán Silva – 1025524635
- Sebastián Camilo Ortegon Hernandez – 1014861874
- Andres Jacobo Rojas Gonzalez – 1025762831
 
**Semestre:** 2026-1  

---

## Verificación del entorno en FPGA Ejercicio #1

- **Funcionamiento del sistema:** Este ejercicio (Smoke Test) sirve para verificar el funcionamiento básico de la tarjeta Zybo Z7 y la instalación del entorno Vivado. El sistema implementa un semáforo sencillo que utiliza un contador interno de 32 bits alimentado por el reloj de la tarjeta (125 MHz). A medida que el contador incrementa, el sistema cambia progresivamente el estado del LED RGB #6 para alternar entre las luces de un semáforo tradicional: rojo (`3'b001`), amarillo (`3'b011`), verde (`3'b010`) y amarillo de nuevo (`3'b011`), completando el ciclo cada 320,000,000 de pulsos de reloj.

---

## Implementación

- **Explicación código:** Para esta actividad de validación inicial (Smoke Test), el comportamiento se verificó directamente sobre el hardware real (FPGA Zybo Z7). El objetivo principal fue validar el proceso de síntesis, implementación, asignación de pines mediante el archivo `.xdc` y la carga exitosa del *bitstream*.

- **Funcionamiento variables empleadas:**
  * **`clk`:** Señal de reloj principal de la tarjeta Zybo Z7 conectada al pin `K17` con una frecuencia de 125 MHz (periodo de 8.0 ns).
  * **`counter`:** Variable entera de 32 bits empleada como divisor de frecuencia por software para contar los pulsos de reloj y generar los retardos entre cambios de color.
  * **`led[2:0]`:** Vector de 3 bits conectado a las líneas del LED RGB #6 de la tarjeta:
    * `led[0]`: Canal Rojo (Pin `V16`).
    * `led[1]`: Canal Verde (Pin `F17`).
    * `led[2]`: Canal Azul (Pin `M17`).




- **Bloques definidos:**
  * **1. Contador de tiempo / Divisor de frecuencia:** Bloque secuencial que incrementa en cada flanco de subida de `clk` hasta llegar a 320,000,000, punto en el que se reinicia a 0 para mantener la temporización del semáforo.
  * **2. Control del LED RGB (Lógica de estados):** Bloque secuencial que evalúa el valor acumulado en `counter` y asigna las combinaciones de bits a `led[2:0]` para proyectar el color adecuado en cada etapa.

- **Código fuente del módulo:** [`src/semaforo.v`](src/semaforo.v)

### Evidencias

<!-- Espacio reservado para el video o imágenes del funcionamiento en la FPGA -->


https://github.com/user-attachments/assets/19b5d470-90f0-46c6-aab4-b64bdd4be9a0




---

## Conclusiones

### Ejercicio #1

* **Validación del flujo de trabajo:** Logramos confirmar el correcto funcionamiento de las herramientas Vivado y la comunicación con la FPGA Zybo Z7 mediante la generación e implementación exitosa del *bitstream*.
* **Mapeo físico mediante `.xdc`:** Comprobamos que asociar correctamente las señales del diseño HDL con los pines físicos de la tarjeta (como el reloj en `K17` y los canales del LED RGB #6) es indispensable para que el diseño responda en el hardware real como se espera.
* **Manejo de temporización:** Comprendimos cómo usar un contador dentro del código Verilog para reducir la frecuencia del reloj de 125 MHz a tiempos visibles para el ojo humano sin necesidad de modificar el reloj físico de la tarjeta.




##  Ejercicio #2: Test funcional personalizado

Para este ejercicio se decidio implementar la suma de dos numeros de 4 bits. Esto por medio de los 4 switches que cuenta la placa de desarrollo, de 4 botones (Se emplearon los que van a la PL (Programmable logic) de la FPGA) y de 2 "switches" adicionales (los cuales fueron definidos dentro del codigo como **btn[4] y btn[5]** y en la placa desarrollo, se definieron como entradas los pines **T14 y T15**, por medio de los cuales se conectan los interruptores físicos).


Los otros dos botones, el **btn[4] y el btn[5]** (Esto según como aparece físicamente en la FPGA. Además, estos no tienen nada que ver con los switches adicionales, los cuales como se vera mas adelante, se les coloco el mismo nombre) no se emplearon ya que estos van conectados directamente al procesador de la tarjeta de desarrollo. Lo que les da otras funcionalidades como reiniciar la configuración actual que tenga la FPGA o aplicar un reinicio por software al procesador. 


A continuación se muestran los pines empleados para las entradas, salidas y la ubicación del modulo donde se encuentran las dos entradas adicionales previamente mencionadas:

<img width="1068" height="292" alt="image" src="https://github.com/user-attachments/assets/44ff4ad8-4b60-487c-b49f-7ff07ca73d66" />

<img width="1103" height="215" alt="image" src="https://github.com/user-attachments/assets/f46096b7-20b2-4dbc-8e8d-6945845bdb5e" />

<img width="682" height="189" alt="image" src="https://github.com/user-attachments/assets/b661d3e8-7a98-4263-8dc2-87dc03a3aee8" />


En el caso de las salidas se definieron 4 leds verdes (Los cuales reflejaran el resultado de la suma de los dos numeros ya mencionados) y un led RGB (El cual reaccionara dependiendo de las combinaciones que se terminen generando entre los dos numeros de 4 bits). A continuación se muestra la implementación de estas en el .xdc:


<img width="1100" height="125" alt="image" src="https://github.com/user-attachments/assets/68350496-6817-4682-9ce8-654da3dfa444" />
<img width="1067" height="98" alt="image" src="https://github.com/user-attachments/assets/f82e3325-0bd5-496a-902a-89882394ee40" />

* **implementación**
  * **Entradas y salidas** : se definen las entradas y salidas previamente definidas, y teniendo el cuidado de **colocar correctamente el nombre de cada entrada en cada pin del archivo .xdc** escribir correctamente el nombre de la variable en los pines a utilizar del .xdc
  * **Captura de operandos** : En esta parte se definen dos buses de 4 bits cada uno para guardar los dos numeros (sw[3:0] y btn[3:0])
  * **Operaciones lógicas bit a bit** : En esta parte del código se implementan las compuertas AND y XOR exigidas en el diseño:
    *  **compuerta AND**: La forma de uso es comparar primero el operando A y el operando B mediante el operador binario de verilog "&". De esta manera se compara individualmente cada bit de A y B donde el bit[i] de "and_result" será 1 en caso de que los bits de A y B que están en 1 sean iguales.
    * **compuerta XOR**: Se implementa un XOR bit a bit usando el operador binario "^". De esta manera, el bit "i" de "xor_result" será 1 si los bits de A y B son diferentes y será 0 si los bits son iguales.
  * **Condición "todos los bits en 1"** : En esta parte del código se combina la operación AND y OR, dando cumplimiento al uso de todas las compuertas pedidas en el diseño. El proposito de esta parte del código es verificar si todos los bits de A o B o de ambos operandos son 1. La forma de hacerlo es primero hacer un "AND de reducción". En verilog esto equivale a colocar el operador "&" frente a un solo vector que tiene las posiciones de los bits del operando (Ejemplo: (&operand_a)). De esta forma, se realiza un AND entre todos los bits internos del bus y devuelve un único bit que es 1 si todos los 4 bits del bus son 1. Esto se realiza tanto para el operando A como para el operando B.
A continuación se usa la compuerta OR para verificar si los 4 bits de A o de B o ambos son 1. En tal caso, devuelve un 1 lógico. El resultado sale por un bus de datos llamado "all_ones"
  * **Definición suma de números** : Suma los valores de A y B previamente guardados (Si el numero resultante es mayor a 4 bits, el resultado conservara los 4 bits menos significativos e ignorara los valores mas significativas a partir de la quinta posición hacia la izquierda.
  * **Lógica de btn[4] y btn [5]** : Se crea una variable procedural para ir guardando los distintos resultados y se define un **always @(*) begin** para que la FPGA ejecute uno de cuatro casos asignados (mantener el resultado, multiplicar por 2 ese resultado, negar todos los bits del resultado, y negar el resultado multiplicado por 2) dependiendo de los cambios de **btn[4], btn[5]** y **base_sum**. 
  * **Asignación resultado a leds** : Ese resultado final se le asigna bit por bit a cada uno de los 4 leds que vienen en la FPGA.
  * **Asignación al led RGB** :El uso que se decidió darle al led RGB es indicar si se cumplen diferentes condiciones usando compuertas lógicas:
    * **Canal Rojo**: Este led se enciende en caso de que A y B compartan al menos 1 bit en 1. Esto no implica que necesariamente los bits de A y B sean exactamente iguales. Para lograrlo se utiliza un "OR de reducción" implementado de la misma manera que el "AND de reducción".
    *  **Canal verde**: Este led enciende en caso de que A y B sean identicos o en caso de que "all_ones" sea 1. Para lograrlo, se usa el operador de igualdad binaria para verificar que todos los bits de A sean exactamente iguales a los de B.
    *   **Canal azul**: Este canal enciende si A y B son diferentes en al menos 1 bit o si "all_ones" es 1. Se utiliza un OR de reducción a "XOR_result" pues, como la operación XOR da 1 únicamente en las posiciones donde A y B son diferentes entonces aplicar un OR devuelve un 1 si existe al menos una diferencia entre A y B.
    *   **Combinaciones visuales**: Dado el comportamiento de los canales es posible observar los siguientes colores adicionales en el led RGB:
      * **Amarillo**: Ocurre cuando A y B son iguales y distintos de 0, ya que se cumple la condición del canal verde de que A y B son iguales y también la condición del canal rojo ya que comparten al menos 1 bit en 1.
      * **Morado**: Ocurre cuando A y B son diferentes pero comparten al menos 1 bit en 1. Por ejemplo, A=0101 y B=0110
      * **Blanco**: Es de notar que en el código se hace un OR con "all_ones" a la operación principal de cada canal del led RGB. Esto tiene el objetivo de que el color blanco se muestre si todos los bits de A y B son 1 y es la forma de visualizar que el resultado de "all_ones" es correcto.  

 * **Simulaciones**
   * **Explicación del código tb** : En primer lugar se vuelven a definir entradas y salidas para el testbench y se instanciando lo definido en en el código principal. Luego se define el monitoreo y finalmente se definen los cambios en los **btn[4] y btn[5]** de 4 maneras distintas para los mismos dos operandos (A=3 y B=1). Por ultimo esos dos botones se desactivan y se hacen sumas con otros numeros (Para evidenciar que pasa con los leds cuando hay overflow y el comportamiento del led blanco).
   * **Explicación resultados de suma y switches adicionales en GTKWave** : En primer lugar, se ve la suma de 3 y 1, la cual da como resultado el numero 4 (0100). Luego, al tener **btn[4] = 1** el resultado termina siendo el doble, o en este caso 8 (1000). En el caso de **btn[5] = 1**, se invierten los bits del resultado. Lo que termina dando en este caso 11 (1011). Por ultimo, el 8 en binario lo termina invirtiendo y pasa a ser un 7 (0111). Luego se evidencia la suma entre 15 y 2. Lo cual da 17 (10001) y precisamente la salida termina mostrando los 4 bits menos significativos del resultado.
   * **Compuertas lógicas**: Durante los primeros 40 ns de la simulación se observa que las compuertas reaccionan únicamente a los bits de "operand_a" y "operand_b" por lo que los cambios realizados por btn[4] y btn[5] no afectan el resultado de las compuertas. En esta primera prueba con **operand_a=0011** y **operand_b=0001** se observa que la compuerta AND detecta similitudes en la posición [0] de A y B. En cuanto a la compuerta XOR solo se activa si solo únicamente uno de los 2 operandos tiene un 1 en alguna posición. en ese caso fue en la posición [1]. Además reaccionan los leds rojo y azul porque hay bits diferentes que comparten al menos 1 bit. Con **operand_b=0011** y **operand_a=0011** se ve que la compuerta AND encontró similitudes en las posiciones [0] y [1] encendiendo el led verde junto con el led rojo pues ambos numeros son iguales. Con **operand_a=1111** y **operand_a=0010** vemos que a compuerta AND solo encontró similitudes en la posición [1] mientras que la XOR forma el vector 1101. Como en este caso todos los bits de "operand_a" son 1 entonces se cumple la condición "all_ones" activando todos los leds para formar el color blanco. Lo mismo sucede para la siguiente prueba pues todos los bits de "operand_b" son 1 encendiendo todos los leds y activando la condición de "all_ones" a pesar de que el "operand_a" no tiene todos sus bits en 1. En la última prueba como todos los bits son 0 el único led que enciende es el verde porque ambos operandos son iguales, sin embargo como no hay unos en ninguna posición tanto las compuertas como los demás leds permanecen apagados.
  
  
<img width="2000" height="350" alt="image" src="https://github.com/user-attachments/assets/5284c526-8f5f-40f4-bfc9-49e88fe9ccb3" />


* **Video demostrativo del funcionamiento**

  [![Demostración funcionamiento en FPGA del lab001](https://img.youtube.com/vi/ki_n_wmmhyc/0.jpg)](https://youtu.be/ki_n_wmmhyc)


* **Conclusiones**
  * Se logró diseñar e implementar con éxito una ALU elemental que es capaz de sumar dos operandos de 4 bits, multiplicar el resultado por 2 y además realizar operaciones lógicas elementales usando compuertas AND, OR, XOR y mostrar el resultado de las operaciones en binario mediante leds. Todo esto estructurado mediante bloques procedimentales **always@(*)** y sentencias **case**. Esto permitió alternar entre los distintos modos de operación.
  * Se comprobó el correcto funcionamiento de la FPGA y de la instanciación de hardware externo mediante el archivo XDC. Pues los conmutadores de modos de operación (btn[5], btn[6]) respondieron de manera correcta a su uso experimental en el laboratorio.
  * Tanto en la simulación como en el comportamiento físico se verificó el manejo del ancho de bus físico fijo de 4 bits establecido en verilog. Pues al sumar operandos cuyo resultado superaba el rango representable de 4 bits (un bit por led) el sistema conservó únicamente los 4 bits menos significativos. 



## Referencias
* MÁQUINAS DE ESTADO ALGORÍTMICAS (ASM). IN: DISEÑO DE SISTEMAS DIGITALES. CIC, DM, KP. SPRINGER..
