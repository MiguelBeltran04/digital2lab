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

* **Tipo de sistema:** SE trata de un acumulador secuencial controlado por una máquina de estados finitos con datapath. Esta además de gestionar la lógica de los estados, también incorpora elementos del procesamiento de datos tales como el uso de contadores, comparadores de magnitudes, registros de almacenamiento y la ejecución de operaciones aritméticas.

* **Estados definidos:**
  * **IDLE** Estado inicial donde el sistema se mantiene en espera de ser activado por una señal de ¨start¨ que provoca una transición al estado ¨LOAD¨
  * **LOAD** En este estado, se reinicia el registro y el contador se inicializa en 0.
  * **ADD** EN este estado se realiza la acumulación sumando el valor de entrada "x" dependiendo de la configuración de la entrada "mode" donde:
    * **mode = 2´b00** Suma 3 veces el valor de entrada
    * **mode = 2´b01** Suma 4 veces el valor de entrada
    * **mode = 2´b10** Suma hasta que el registro sea igual o mayor a 20
    * **mode = 2´b11** Cancela la acumulación y devuelve al estado IDLE.
  * **DONE** Cuando el sistema termina de realizar la acumulación y el resultado esta listo, este estado activa la señal "done" la cuál indica que la operación ha culminado. En el siguiente ciclo de reloj se regresa al estado "IDLE"
  
* **Funcionamiento general:** La construcción del módulo secAcc funciona como un acumulador secuencial regido por una señal de reloj y un reinicio asíncrono. Su proposito es recibir un dato de entrada de 4 bits y sumarlo repetidas veces dependiendo del modo en el que se configure la entrada. Una vez que el sistema detecta el pulso de "start" el sistema limpia los registros internos, carga los valores de entrada, el modo y luego inicializa el contador en 0. Este diseño permite realizar diferentes tipos de acumulaciones sumando 3 o 4 veces la entrada o acumulando hasta que el registro tenga un valor igual o mayor a 20. ES posible además interrumpir la acumulación en cualquier momento configurando la entrada mode en 2'b11.


* **Simulaciones:** El testbench realizado para este módulo comienza con la activación de un reset en la primera señal de reloj. Luego se establece el modo en 2´b00 para probar que el contador funciona y que la transición de estados es correcta.
  * **Prueba #1** Luego de 5 ciclos de reloj se define un valor de entrada x=5 y se mantiene el modo 00. Se esperan 5 ciclos de reloj para observar el resultado del algoritmo y ver la activación de la señal de done.
  * **Prueba #2** Se define la entrada x=11 y el modo 01 para probar la acumulación por 4 veces. SE activa la señal de start durante 1 pulso de reloj y luego se esperan 5 pulsos hasta ver la activacón de la señal de done.
  * **Prueba #3** Se define la entrada x=2 y el modo 10. El proposito de usar un número pequeño consiste en observar si el estado de add es capaz de mantenerse durante más de 4 o 5 iteraciones.
  * **Prueba #4** Se define la entrada x=12 y el modo 00. Se esperan 2 ciclos de reloj y luego se cambia el estado al modo 11. El objetivo es observar el comportamiento al cancelar la acumulación. Acto seguido, se activa la señal de start nuevamente y al mismo tiempo se cambia el modo a 00.


  * **Resultados** La prueba #0 culmina exitosamente, se observa que cuando el contador llega a 3 iteraciones el sistema pasa al estado done y regresa al inicio. El contador se reinicia una vez que se activa un nuevo pulso de start, dejando los registros limpios para la siguiente prueba.
    * En la prueba #1 con un valor esperado de 15 la prueba culmina perfectamente manteniendo el modo 00 y realizando 3 acumulaciones de x=5. Un ciclo de reloj después se observa que al activar un pulso de start tanto el contador como el registro "acc" queda en 0 y listo para la siguiente prueba.
    * La prueba #2 con el modo 01 y x=11 muestra en el registro un valor de 44 para cuando la señal de done se activa, lo cual cumple el comportamiento esperado y además permite observar que la transición al estado done se dió cuando el contador llego a 4 iteraciones.
    * Para la prueba #3 con el modo 10 y una entrada de x=2 se observa que no fue necesario el uso del contador y que el comparador cumplió su funcion de transicionar al estado done una vez que el acumulador alcanzó el valor de 20; Esto demuestra que el estado de add pudo mantenerse durante 10 iteraciones hasta alcanzar su objetivo y terminar la prueba exitosamente.
    * Para la prueba #4 una vez pasados los 2 ciclos de reloj del modo 00 con x=12 y aplicado el modo 11 para la cancelación, esta se comportó como estaba previsto, devolviendo al estado idle y manteniendo a la espera del pulso de start. Cuando el pulso de start fue aplicado, el contador y el registro se reiniciaron y continuaron su funcionamiento normal.
* **implementación**
   * **organización del código** SE trabajó con un único módulo estructurado de manera secuencial y de modo que integre todas las operaciones aritméticas y comparaciones necesarias en un solo archivo. En la cabecera se muestra el nombre del modulo y los puertos de entrada y salida, seguidos por la asignación de los 4 estados necesarios para el funcionamiento. Toda la lógica de control, incluyendo la ruta de datos, sumas, comparaciones y conteos está contenida dentro de un único bloque "always" y el flujo se gestiona utilizando estructuras "case" para evaluar el estado siguiente dependiendo del estado actual. El estado se encuentra guardado en el registro ¨STATE´. Además una subestructura case se encarga de evaluar qué tipo de acumulación se va a realizar y de esta manera se elige qué versión del estado add se va a utilizar.
   * **Manejo de reloj y reset**
      * **Reset (rst)** Al inicio del bloque always se deine la lógica secuencial por flancos. Al declarar ¨posedge clk or posedge rst¨ se garantiza que el sistema responda inmediatamente a una señal de reinicio sin necesidad de que el reloj cambie. Esto provoca que el reset sea asíncrono. Una vez activado, el sistema regresa al estado IDLE
      * **Reloj (clk)** Dentro del bloque always se declara un bloque principal ¨begin¨ la cual en ausencia de un reset se realizan todas las transiciones de estado de forma totalmente síncrona con el flanco de subida de la señal.
   * **Comportamiento esperado del sistema** El sistema debe esperar en el estado IDLE manteniendo la señal de done en 0. Si se activa la señal de start, se pasará al estado de LOAD, donde se delcara el registro acumulador en 0 y el contador inicia en 0 para luego pasar al estado de ADD. Durante el estado ADD un bloque case evalúa qué modo eligió el usuario para la acumulación. Al final de cada iteración se evalúa si la tarea se ha completado y en caso contrario el sistema se mantendra en el estado de ADD a menos que se cambie al estado 11 volviendo al estado inicial o que la tarea culmine exitosamente pasando al estado DONE, donde la señal del mismo nombre se activará devolviendo el sistema al estado IDLE.
* **Conclusiones**
     *  Este diseño muestra la versatilidad de las máquinas de estados con rutas de datos. Pues mediante ellas es posible que un único hardware sea capaz de tener varios modos de operación basadas tanto en iteraciones fijas tales como sumar 3 o 4 veces, y operaciones dinámicas basadas en alcanzar cierta magnitud. Además la implementación de una máquina de estados Moore, donde las actualizaciones del registro acc dependen del estado actual y ocurren sincronizadas con el reloj, aisla las salidas de posibles ruidos o retardos lógicos que podrían presentarse con la variación de las entradas "x" o "mode".
     *  **Dificultades encontradas** En el planteamiento del diagrama de estados se buscó una manera de declarar un único estado ADD que implicitamente mediante algún componente de hardware tomara la decisión de qué tipo de acumulación realizar. Sin embargo para no complificar el entendimiento del diagrama se decidió dejar 3 estados ADD cada uno con su tipo de acumulación.
     *  **Importancia de la simulación en el diseño digital** ES necesario observar la simulación digital antes de la implementación de los algoritmos diseñados en cualquier placa de desarrollo, pues de esta manera se pueden detectar retardos lógicos o problemas con con la sincronización de los estados con los flancos de subida del reloj. Además permite validar de forma preliminar si los resultados mostrados por el sistema coinciden con los esperados. Finalmente, con la simulación también es posible analizar maneras de optimizar los sistemas y algoritmos diseñados antes de que se usen en la placa de desarrollo y de esta manera no consumir hardware innecesario, reduciendo consumo de energía y ahorrando tiempo de ejecución.

## Diseño implementado Ejercicio #3

El diseño consiste en un transmisor serial síncrono de 8 bits controlado por una máquina de estados algorítmica (ASM). Su función principal es recibir un byte en paralelo, serializarlo (enviando el bit menos significativo primero) y controlar con precisión la duración de cada bit en la línea de transmisión utilizando contadores internos.

* **Tipo de sistema:** Transmisor serial síncrono (ASM / Control y datos representado mediante diagrama de flujo)
* **Pasos/Etapas del flujo:** IDLE, LOAD, BIT_HOLD, SHIFT_NEXT, DONE_ST
* **Funcionamiento general:** El sistema reposa en `IDLE` hasta recibir la señal `start`. En `LOAD`, captura el dato de entrada y inicializa los contadores. Durante `BIT_HOLD`, expone el bit actual en la salida `tx` y espera el tiempo parametrizado (`CLKS_PER_BIT - 2`). En `SHIFT_NEXT`, desplaza el registro para preparar el siguiente bit y aumenta el contador de bits enviados. Tras procesar los 8 bits, pasa a `DONE_ST`, activa la bandera `done` por un ciclo y retorna al inicio.




---

## Código

### Ejercicio #3

El diseño del transmisor serial síncrono se estructuró separando claramente la lógica de control de la ruta de datos. Esto facilita la legibilidad del hardware y asegura una correcta sincronización entre las señales de control y el manejo de los bits.

* **Organización del código:** El módulo se divide en 4 bloques funcionales:
  * **Registro de estado:** Actualización secuencial del estado actual.
  * **Lógica de estado siguiente:** Bloque combinacional que evalúa transiciones basadas en `start`, `tick_cnt` y `bit_count`.
  * **Datapath y contadores:** Gestión secuencial de la carga del dato, desplazamiento a la derecha del registro (`shift_reg`) y control de la temporización (`tick_cnt`).
  * **Salidas:** Asignación combinacional continua donde las señales dependen exclusivamente del estado actual.
* **Manejo de reloj y reset:** El sistema es completamente síncrono, operando en los flancos de subida del reloj (`posedge clk`). La señal de reinicio (`rst`) actúa de forma síncrona forzando el estado a `IDLE` y limpiando los registros y contadores de la ruta de datos.
* **Comportamiento esperado del sistema:** La línea `tx` se mantiene estable en `1` lógico durante el reposo. Al iniciar una transmisión, emite los datos comenzando por el LSB, manteniendo cada bit el tiempo definido por `CLKS_PER_BIT`. La señal `busy` permanece en alto durante todo el proceso, y `done` emite un pulso exacto de un ciclo de reloj al finalizar el último bit.
* **Código fuente del módulo:** [`src/serial_tx.v`](src/serial_tx.v)

---
## Simulaciones

### Ejercicio #3

Para validar el funcionamiento del transmisor serial, se diseñó un *testbench* que inyecta datos y señales de control para comprobar el correcto desplazamiento y temporización de los bits.

* **Descripción del testbench:** Se configuró un reloj de 100MHz (periodo de 10ns) y se aplicó un reinicio síncrono inicial (`rst=1`). Posteriormente, se realizaron dos pruebas de transmisión secuenciales enviando los valores hexadecimales `0xA5` (binario: `10100101`) y `0x3C` (binario: `00111100`). En ambas pruebas, la transmisión se activa mediante un pulso de un ciclo en la señal `start`, esperando a que la señal `done` se active antes de proceder con el siguiente dato.
* **Código del testbench:** [`src/serial_tx_tb.v`](src/serial_tx_tb.v)
* **Señales observadas:** 
  * `tx`: Transmite los bits de manera serial iniciando desde el bit menos significativo (LSB).
  * `busy`: Pasa a nivel alto al recibir la señal `start` y se mantiene así durante toda la ráfaga de transmisión.
  * `done`: Emite un pulso de un ciclo exacto al terminar de enviar el octavo bit.
  * `Estado y Contadores`: Se aprecian las transiciones del registro de estado y cómo el contador de temporización asegura el ancho de cada bit, mientras el contador de bits va de 0 a 7.
* **Resultados obtenidos:** El resultado en el visor de ondas es el esperado. Se verificó exitosamente que el módulo mantiene cada bit durante los 8 ciclos de reloj definidos por el parámetro `CLKS_PER_BIT`, serializa los datos de forma impecable y levanta las banderas de control (`busy` y `done`) en los tiempos exactos estipulados por el diseño.

### Evidencias

### Ejercicio #3





---

## Conclusiones

### Ejercicio #3

El desarrollo de este transmisor nos ayudó a entender la ventaja de separar la lógica de control de la ruta de datos (datapath). También vimos que usar contadores internos es una forma muy práctica de controlar cuánto dura cada bit en la transmisión sin necesidad de modificar el reloj principal del sistema.

Finalmente, como punto a mejorar para futuros diseños, nos dimos cuenta de que debimos incluir el diagrama de la máquina de estados (FSM) para la unidad de control, en lugar de poner únicamente el diagrama de flujo y el datapath. Esto no se añadio porque, al momento de hacer el ejercicio, en la clase magistral aún no se había profundizado en el tema de las máquinas algorítmicas (ASM), por lo que creíamos que el diagrama de flujo por sí solo era suficiente para documentar todo el sistema.

## Referencias
* MÁQUINAS DE ESTADO ALGORÍTMICAS (ASM). IN: DISEÑO DE SISTEMAS DIGITALES. CIC, DM, KP. SPRINGER..
