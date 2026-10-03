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

Para este ejercicio se decidio implementar la suma de dos numeros de 4 bits. Esto por medio de los 4 switches que cuenta la placa de desarrollo, de 4 botones (Se emplearon los que a la PL (Programmable logic) de la FPGA) y de 2 switches adicionales, a los cuales se les conecto en serie un par de interruptores. (Los otros dos botones **colocar específicamente el nombre de los pines** no se emplearon ya que estos van conectados directamente al procesador de la tarjeta de desarrollo. Lo que les da otras funcionalidades como reiniar la configuración actual que tenga la FPGA o aplicar un reinicio por software al procesador). A continuación se muestran los pines empleados para las entradas y una imagen donde se evidencia la ubicación del modulo donde se encuentran las dos entradas adicionales previamente mencionadas:

<img width="1068" height="292" alt="image" src="https://github.com/user-attachments/assets/44ff4ad8-4b60-487c-b49f-7ff07ca73d66" />

<img width="1103" height="215" alt="image" src="https://github.com/user-attachments/assets/f46096b7-20b2-4dbc-8e8d-6945845bdb5e" />

<img width="682" height="189" alt="image" src="https://github.com/user-attachments/assets/b661d3e8-7a98-4263-8dc2-87dc03a3aee8" />

En el caso de las salidas se definieron 4 leds verdes (Los cuales reflejaran el resultado de la suma de los dos numeros ya mencionados) y un led RGB (El cual reaccionara dependiendo de las combinaciones que se terminen generando entre los dos numeros de 4 bits). A continuación se muestra la implementación de estas en el.xdc:
<img width="1100" height="125" alt="image" src="https://github.com/user-attachments/assets/68350496-6817-4682-9ce8-654da3dfa444" />
<img width="1067" height="98" alt="image" src="https://github.com/user-attachments/assets/f82e3325-0bd5-496a-902a-89882394ee40" />

* **implementación**
  * **Entradas y salidas** : se definen las entradas y salidas previamente definidas, y teniendo el cuidado de **colocar correctamente el nombre de cada entrada en cada pin del archivo .xdc** escribir correctamente el nombre de la variable en los pines a utilizar del .xdc
  * **Captura de operandos** : En esta parte se definen dos buses de 4 bits cada uno para guardar los dos numeros (sw[3:0] y btn[3:0])
  * **Operaciones logicas bit a bit** : 
  * **Condición "todos los bits en 1"** : 
  * **Definición suma de números** : Suma los valores de A y B previamente guardados (Si el numero resultante es mayor a 4 bits, el resultado conservara los 4 bits menos significativos e ignorara los valores mas significativas a partir de la quinta posición hacia la izquierda.
  * **Lógica de btn[4] y btn [5]** : Se crea una variable procedural para ir guardando los distintos resultados y se define un **always @(*) begin** para que la FPGA ejecute uno de cuatro casos asignados (mantener el resultado, multiplicar por 2 ese resultado, negar todos los bits del resultado, y negar el resultado multiplicado por 2) dependiendo de los cambios de **btn[4], btn[5]** y **base_sum**. 
  * **Asignación resultado a leds** : Ese resultado final se le asigna bit por bit a cada uno de los 4 leds que vienen en la FPGA.
  * **Asignación al led RGB** :

 * **Simulaciones**
   * **Explicación del código tb** :En primer lugar se vuelven a definir entradas y salidas para el testbench y se instanciando lo definido en en el código principal. Luego se define el monitoreo y finalmente se definen los cambios en los **btn[4] y btn[5]** de 4 maneras distintas para los mismos dos operandos (A=3 y B=1). Por ultimo esos dos botones se desactivan y se hacen sumas con otros numeros (Para evidenciar que pasa con los leds cuando hay overflow y el comportamiento del led blanco).
   * **Explicación resultados en GTKWave** : En primer lugar, se ve la suma de dos 3 y 1, la cual da como resultado el numero 4 (0100). Luego, al tener **btn[4] = 1** el resultado termina siendo el doble, o en este caso 8. En el caso de **btn[5] = 1**, se invierten los bits del resultado. Lo que termina dando en este caso 11 (1011). Por ultimo, el 8 en binario lo termina inviertiendo y pasa a ser un 7 (0111). Luego se evidencia la suma entre 15 y 2. Lo cual da 17 (10001) y precisamente la salida termina mostrando los 4 bits menos significativos del resultado.
   <img width="1367" height="132" alt="image" src="https://github.com/user-attachments/assets/e060db04-b3f0-4c93-ae08-43af8aa1ede3" />

 * 


## Conclusiones

El desarrollo de este transmisor nos ayudó a entender la ventaja de separar la lógica de control de la ruta de datos (datapath). También vimos que usar contadores internos es una forma muy práctica de controlar cuánto dura cada bit en la transmisión sin necesidad de modificar el reloj principal del sistema.

Finalmente, como punto a mejorar para futuros diseños, nos dimos cuenta de que debimos incluir el diagrama de la máquina de estados (FSM) para la unidad de control, en lugar de poner únicamente el diagrama de flujo y el datapath. Esto no se añadio porque, al momento de hacer el ejercicio, en la clase magistral aún no se había profundizado en el tema de las máquinas algorítmicas (ASM), por lo que creíamos que el diagrama de flujo por sí solo era suficiente para documentar todo el sistema.

## Referencias
* MÁQUINAS DE ESTADO ALGORÍTMICAS (ASM). IN: DISEÑO DE SISTEMAS DIGITALES. CIC, DM, KP. SPRINGER..
