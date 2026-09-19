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


Describa brevemente los diseños realizados en el laboratorio.

Incluya:
- Tipo de sistema (FSM, FSM + datapath).
- Estados definidos.
- Funcionamiento general del sistema.

Cuando aplique, incluya el diagrama de la máquina de estados.

---

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

## Diseño implementado

### Ejercicio #3

El diseño consiste en un transmisor serial síncrono de 8 bits controlado por una máquina de estados algorítmica (ASM). Su función principal es recibir un byte en paralelo, serializarlo (enviando el bit menos significativo primero) y controlar con precisión la duración de cada bit en la línea de transmisión utilizando contadores internos.

* **Tipo de sistema:** Transmisor serial síncrono (ASM / Control y datos representado mediante diagrama de flujo)
* **Pasos/Etapas del flujo:** IDLE, LOAD, BIT_HOLD, SHIFT_NEXT, DONE_ST
* **Funcionamiento general:** El sistema reposa en `IDLE` hasta recibir la señal `start`. En `LOAD`, captura el dato de entrada y inicializa los contadores. Durante `BIT_HOLD`, expone el bit actual en la salida `tx` y espera el tiempo parametrizado (`CLKS_PER_BIT - 2`). En `SHIFT_NEXT`, desplaza el registro para preparar el siguiente bit y aumenta el contador de bits enviados. Tras procesar los 8 bits, pasa a `DONE_ST`, activa la bandera `done` por un ciclo y retorna al inicio.

<img width="2184" height="3859" alt="_Diagrama algoritmico ej3" src="https://github.com/user-attachments/assets/955f3a62-3de7-4c5d-ba02-fc44b2917ab7" />


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

