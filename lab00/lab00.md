# Laboratorio 00  
## Introducción a Verilog, Simulación y Máquinas de Estados Finitos (FSM)

---

## Integrantes

- Miguel Esteban Beltrán Silva – 1025524635
- Sebastián Camilo Ortegon Hernandez – 1014861874
- Nombre completo – DNI

**Grupo de trabajo:**  
**Semestre:** 2026-1  

---

## Índice
- [Diseño implementado](#diseño-implementado)
- [Simulaciones](#simulaciones)
- [Implementación](#implementación)
- [Conclusiones](#conclusiones)
- [Referencias](#referencias)

---

## Diseño implementado

### Ejercicio #1

Para este ejercicio se decidió realizar una Maquina de estados de Moore en la cual se definieron 3 estados. El S0 indica que la luz verde del semáforo esta activa, S1 indica que la luz amarilla esta activa y por ultimo el estado S2 indica que la luz roja esta encendida. 

El sistema funciona de la siguiente manera: cada flanco de subida del clock hará que la maquina se mantenga en el mismo estado hasta que se llegue a un punto en donde la variable "contador" llegue a cierto valor (En el caso del estado verde tiene que llegar a 4 para que en el siguiente flanco de subida del clock, el cual seria el quinto, este automáticamente cambie de estado, en el caso del amarillo será 1 y en el caso del rojo será el 3). Un ciclo de reloj después se va a pasar al siguiente estado tal y como se ve en la imagen.

En el momento en el que la maquina se encuentre en el estado S1, esta tiene que saber si tiene que cambiar al estado S0 o S2, es por eso que existe la variable "dirección", la cual será cero si se esta en el Estado S0 y 1 si se encuentra en el estado S2. Mas adelante en el codigo se vera de mejor manera la implementación de esta.

<img width="1600" height="666" alt="WhatsApp Image 2026-09-15 at 8 43 53 PM" src="https://github.com/user-attachments/assets/f7d483d4-c7a3-4b5c-b087-eeaf162ca84d" />

## Simulaciones

### Ejercicio #1

En primer lugar en el testbench se encuentran las señales de entrada las cuales son "clk" y "rst", las cuales terminaran siendo manejadas activamente por el testbench, se colocaron las tres salidas y luego se genero el clk, en este caso va a tener un medio ciclo de 5 ns ya que previamente se definió una escala de 1ns/1ns (De ahí a que coloque el #5), se definio el nombre del nuevo archivo generado, el cual se usara para guardar todos los datos y asi, poder ser usados por GTKWave a la hora de realizar las graficas. Por ultimo se deja en el codigo la activación del reset con una duración de 20 ns, pasado ese tiempo este sera igual a cero y se indica que luego de esos 20 ns, la simulación dure 300 ns mas.

A continuación  se explicara el comportamiento de las señales observadas en GTKWave, iniciando por las salidas. Se puede evidenciar que la maquina arroja las salidas correctamente, ya que hace la secuencia "verde, amarillo, rojo" y "rojo, amarillo, verde" de forma constante y nunca se queda en un bucle (Es decir, no se queda en el mismo estado). 

Se ve la presencia del rst, el cual deja practicamente a todas las señales en 0, y no es hasta que sea igual a cero para que el resto de señales se empiecen a activar. 

En el caso de "contador", vemos que esta opera correctamente, reiniciandose en el momento en el que la maquina cambia de estados y asi volver a contar los flancos de subida para el estado enel que este presente. La variable "dirección" termina siendo igual a cero cuando pasa por ele stado S0 y 1 cuando pasa por S1.

Con respecto a "estado_actual" se evidencia como siempre cambia de estado correctamente, y a la vez cambia la salida. Mientras que "estado_siguietne" un ciclo de reloj antes deja definido ese estado al que necesita pasar una vez se termine ese ciclo de reloj (En la sección de implementación se explicara con mayor profundidad)

Describa las simulaciones realizadas para verificar el funcionamiento del diseño.

Incluya:
- Descripción del testbench.
- Señales observadas.
- Resultados obtenidos.

### Evidencias

### Ejercicio #1

<img width="1622" height="301" alt="image" src="https://github.com/user-attachments/assets/addbd073-711c-433d-b940-66e6d4e39a55" />


(Incluya capturas de pantalla de GTKWave donde se evidencie el correcto funcionamiento.)

---

## Implementación

El codigo se termino organizando en bloques, antes de estos se definieron cuales iban a ser las entradas, salidas, constantes y variables a implementar. Los dos primeros bloques muestran las acciones que tendrian ciertas variables una vez se aplique el reset, despues se coloco un bloque donde se muestra la implementación de los estados y finalmente uno donde se deja el funcionamiento de las salidas dependiendo del esatdo actual.

En el primero se define que si se activa el "rst" o si "reset_contador" es igual a 1 (En la imagen donde se muestra la grafica de "reset_contador" se ve que este se activa un ciclo de reloj antes, básicamente se hace para que la variable sea igual a 1 y cuando por ejemplo, en el estado verde se haya llegado al quinto flanco de subida, el contador se reinicie justo al cambiar al siguiente estado que seria el amarillo). También se define que le pasa a la variable "dirección" cuando se activa el "rst" (será igual a cero), cuando esta el "estado_actual" sea igual al estado S0 (también será igual a cero) y cuando este en el estado S2 (Cambiara a 1).

En el bloque #2, se define que al activarse el "rst", el "estado_actual" sea S0, si no, constantemente se le asignara a "estado_actual" la variable "estado_siguiente".

En el penultimo bloque, siempre se incia igualando "estado_actual" con "estado_siguiente" y con "reset_contador" en cero (Abajo del bloque se deja claro que estado actual tiene que ser si o si S0 por defecto). Posterior a esto una vez este en el Estado verde, se va a esperar a que "contador" sea mayor o igual a 4, se define cual sera el estado siguiente y se indica que se va a reiniciar el contador. Lo mismo pasa para los otros dos estados (En el caso del amarillo, se deja claro que dependiendo del valor de dirección, el siguiente estado sera el verde o el rojo).

Al final, en el ultimo bloque se definen como van a ser las salidas dependiendo del estado ene el que se encuentre la maquina.



Explique cómo se implementó el diseño en Verilog.

Incluya:
- Organización del código.
- Manejo de reloj y reset.
- Comportamiento esperado del sistema.

> El código fuente debe encontrarse en la carpeta `src/`.

---

## Conclusiones

### Ejercicio #1

En este ejercicio se logro realizar una maquina de estado de Moore y se logro implementar en un entorno como GTKWave para poder visualizar si esta cumplia todos los requerimentos y objetivos previamente propuestos. Esto es importante ya que en el momento en el que se quiera implementar en una FPGA, se tiene que tener cuidado con el funcionamiento de las señales de salida por ejemplo o con los clocks, para evitar asi afectaciones en la FPGA y en circuito fisico.

Dentro de las dificultades encontradas, se encuentran el diseño del diagrama de Estados, ya que con base en este se realiza todo el codigo y se tiene que dejar muy en claro bajo que entradas o variables se van a realizar los cambios de Estados y así evitar bucles infinitos o transiciones no deseadas.


- Principales aprendizajes del laboratorio.
- Dificultades encontradas.
- Importancia de la simulación en el diseño digital.

---

## Diseño implementado Ejercicio #2
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
<img width="500" height="500" alt="acumulador" src="https://github.com/user-attachments/assets/4cbead75-ee56-4fdb-8502-ca6a3fbd1802" />

* **Simulaciones:** El testbench realizado para este módulo comienza con la activación de un reset en la primera señal de reloj. Luego se establece el modo en 2´b00 para probar que el contador funciona y que la transición de estados es correcta.
  * **Prueba #1** Luego de 5 ciclos de reloj se define un valor de entrada x=5 y se mantiene el modo 00. Se esperan 5 ciclos de reloj para observar el resultado del algoritmo y ver la activación de la señal de done.
  * **Prueba #2** Se define la entrada x=11 y el modo 01 para probar la acumulación por 4 veces. SE activa la señal de start durante 1 pulso de reloj y luego se esperan 5 pulsos hasta ver la activacón de la señal de done.
  * **Prueba #3** Se define la entrada x=2 y el modo 10. El proposito de usar un número pequeño consiste en observar si el estado de add es capaz de mantenerse durante más de 4 o 5 iteraciones.
  * **Prueba #4** Se define la entrada x=12 y el modo 00. Se esperan 2 ciclos de reloj y luego se cambia el estado al modo 11. El objetivo es observar el comportamiento al cancelar la acumulación. Acto seguido, se activa la señal de start nuevamente y al mismo tiempo se cambia el modo a 00.
<img width="1900" height="300" alt="image" src="https://github.com/user-attachments/assets/4a5aca48-681a-411e-b16e-39e22588c31d" />

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

<img width="300" height="600" alt="_Diagrama algoritmico ej3" src="https://github.com/user-attachments/assets/955f3a62-3de7-4c5d-ba02-fc44b2917ab7" />


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
* **Código fuente del módulo:** [`src/serial_tx.v`](../src/serial_tx.v)

---
## Simulaciones

### Ejercicio #3

Para validar el funcionamiento del transmisor serial, se diseñó un *testbench* que inyecta datos y señales de control para comprobar el correcto desplazamiento y temporización de los bits.

* **Descripción del testbench:** Se configuró un reloj de 100MHz (periodo de 10ns) y se aplicó un reinicio síncrono inicial (`rst=1`). Posteriormente, se realizaron dos pruebas de transmisión secuenciales enviando los valores hexadecimales `0xA5` (binario: `10100101`) y `0x3C` (binario: `00111100`). En ambas pruebas, la transmisión se activa mediante un pulso de un ciclo en la señal `start`, esperando a que la señal `done` se active antes de proceder con el siguiente dato.
* **Código del testbench:** [`src/serial_tx_tb.v`](../src/serial_tx_tb.v)
* **Señales observadas:** 
  * `tx`: Transmite los bits de manera serial iniciando desde el bit menos significativo (LSB).
  * `busy`: Pasa a nivel alto al recibir la señal `start` y se mantiene así durante toda la ráfaga de transmisión.
  * `done`: Emite un pulso de un ciclo exacto al terminar de enviar el octavo bit.
  * `Estado y Contadores`: Se aprecian las transiciones del registro de estado y cómo el contador de temporización asegura el ancho de cada bit, mientras el contador de bits va de 0 a 7.
* **Resultados obtenidos:** El resultado en el visor de ondas es el esperado. Se verificó exitosamente que el módulo mantiene cada bit durante los 8 ciclos de reloj definidos por el parámetro `CLKS_PER_BIT`, serializa los datos de forma impecable y levanta las banderas de control (`busy` y `done`) en los tiempos exactos estipulados por el diseño.

### Evidencias

### Ejercicio #3

<img width="1615" height="441" alt="image" src="https://github.com/user-attachments/assets/09b9afed-19c7-479f-855b-2276338fdcb9" />



---

## Conclusiones

### Ejercicio #3

El desarrollo de este transmisor nos ayudó a entender la ventaja de separar la lógica de control de la ruta de datos (datapath). También vimos que usar contadores internos es una forma muy práctica de controlar cuánto dura cada bit en la transmisión sin necesidad de modificar el reloj principal del sistema.

Finalmente, como punto a mejorar para futuros diseños, nos dimos cuenta de que debimos incluir el diagrama de la máquina de estados (FSM) para la unidad de control, en lugar de poner únicamente el diagrama de flujo y el datapath. Esto no se añadio porque, al momento de hacer el ejercicio, en la clase magistral aún no se había profundizado en el tema de las máquinas algorítmicas (ASM), por lo que creíamos que el diagrama de flujo por sí solo era suficiente para documentar todo el sistema.

## Referencias

