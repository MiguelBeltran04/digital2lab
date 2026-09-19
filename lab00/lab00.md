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

<!-- INSTRUCCIONES: Descripción breve del diseño y del flujo de funcionamiento (1-2 párrafos cortos). -->
[Escribe aquí la descripción general del transmisor serial...]

* **Tipo de sistema:** Transmisor serial síncrono (ASM / Control y datos representado mediante diagrama de flujo)
* **Pasos/Etapas del flujo:** IDLE, LOAD, BIT_HOLD, SHIFT_NEXT, DONE_ST
* **Funcionamiento general:** [Escribe aquí el resumen breve de cómo se transmite el byte de datos de entrada]

<img width="2184" height="3859" alt="_Diagrama algoritmico ej3" src="https://github.com/user-attachments/assets/955f3a62-3de7-4c5d-ba02-fc44b2917ab7" />


---

## Código

### Ejercicio #3

<!-- INSTRUCCIONES: Breve introducción al código en Verilog del módulo principal (serial_tx.v). -->
[Escribe aquí una breve explicación del código fuente del hardware...]

* **Código fuente del módulo:** [`src/serial_tx.v`](../src/serial_tx.v)

---

## Simulaciones

### Ejercicio #3

<!-- INSTRUCCIONES: Descripción de las pruebas realizadas y análisis de las señales. -->
[Escribe aquí la explicación breve de las pruebas realizadas en la simulación...]

* **Descripción del testbench:** [Escribe qué datos probaste (ej. 0xA5 y 0x3C) y cómo aplicaste las señales de reset y start]
* **Código del testbench:** [`src/serial_tx_tb.v`](../src/serial_tx_tb.v)
* **Señales observadas:** [Menciona brevemente el comportamiento de tx, busy, done y los contadores internos]
* **Resultados obtenidos:** [Confirma que la transmisión fue correcta y respetó los tiempos de CLKS_PER_BIT]


### Evidencias

### Ejercicio #3

<img width="1622" height="301" alt="Simulación GTKWave Ejercicio 3" src="RUTA_O_ENLACE_DE_TU_CAPTURA_GTKWAVE" />

---

---

## Conclusiones

### Ejercicio #3

<!-- INSTRUCCIONES: Redacta tus conclusiones de forma directa y resumida. -->
[Escribe aquí tus conclusiones del ejercicio 3...]

* **Principales aprendizajes:** [Escribe el aprendizaje principal sobre el diseño e interpretación del diagrama de flujo]
* **Dificultades encontradas:** [Menciona la dificultad principal, ej. ajustar la temporización de los contadores]
* **Importancia de la simulación:** [Explica brevemente por qué fue útil validar las formas de onda en GTKWave]

## Referencias

