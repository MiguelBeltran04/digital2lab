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



 
* **Funcionamiento del sistema**




## Simulaciones
* **Explicación código testbench:**


* **Funcionamiento variables empleadas:**
  

### Evidencias





---

## Implementación


* **Bloques definidos:**
  * **1:**
  
## Conclusiones




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
   * **Explicación resultados de suma y switches adicionales en GTKWave** : En primer lugar, se ve la suma de dos 3 y 1, la cual da como resultado el numero 4 (0100). Luego, al tener **btn[4] = 1** el resultado termina siendo el doble, o en este caso 8 (1000). En el caso de **btn[5] = 1**, se invierten los bits del resultado. Lo que termina dando en este caso 11 (1011). Por ultimo, el 8 en binario lo termina invirtiendo y pasa a ser un 7 (0111). Luego se evidencia la suma entre 15 y 2. Lo cual da 17 (10001) y precisamente la salida termina mostrando los 4 bits menos significativos del resultado.
  
  
   <img width="1367" height="132" alt="image" src="https://github.com/user-attachments/assets/e060db04-b3f0-4c93-ae08-43af8aa1ede3" />

* **Video demostrativo del funcionamiento**
  [![Demostración funcionamiento en FPGA del lab001](https://img.youtube.com/vi/ki_n_wmmhyc/0.jpg)](https://youtu.be/ki_n_wmmhyc)
* **Conclusiones**



## Referencias
* MÁQUINAS DE ESTADO ALGORÍTMICAS (ASM). IN: DISEÑO DE SISTEMAS DIGITALES. CIC, DM, KP. SPRINGER..
