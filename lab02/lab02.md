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

## 1. Explicación general del funcionamiento del sistema

El sistema consiste en el diseño e implementación de una Unidad Aritmético-Lógica (ALU) de 4 bits en la FPGA Zybo Z7. Su funcionamiento se basa en capturar valores numéricos desde un bus de entrada (4 switches) y almacenarlos temporalmente en memoria mediante el uso de botones físicos. 

Una vez ingresados los operandos, el usuario puede conmutar entre cuatro operaciones aritméticas y lógicas utilizando dos botones de control que modifican el código de operación internamente. El sistema procesa de manera continua los datos almacenados y muestra el resultado en tiempo real a través de los 4 LEDs estándar de la tarjeta. Simultáneamente, un LED RGB actúa como indicador visual de estado, mostrando un color único que le permite al usuario identificar rápidamente qué operación matemática o lógica se está ejecutando en ese momento.

## 2. Descripción de la arquitectura propuesta

La arquitectura del sistema sigue un modelo de *datapath* simplificado que separa estrictamente la lógica secuencial (memoria e interfaz física) de la lógica combinacional (procesamiento de datos). 

Para lograr el funcionamiento requerido, la arquitectura implementa:
* **Almacenamiento persistente:** Se definieron tres registros internos (`reg_A`, `reg_B` y `reg_op`) que conservan los valores de los operandos y la operación seleccionada. Esto permite que la ALU siga operando aunque los switches cambien de posición o los botones se dejen de presionar.
* **Control de rebotes/Flancos (Edge Detection):** Dado que la FPGA opera con un reloj principal de 125 MHz (`clk`), mantener presionado un botón cambiaría la operación millones de veces por segundo. Para solucionarlo, la arquitectura incorpora un detector de flanco de subida en los botones de selección (BTN2 y BTN3), garantizando que el cambio de código de operación ocurra una única vez por cada pulsación física.
* **Instanciación jerárquica:** El datapath fluye desde las entradas físicas hacia los registros secuenciales en el nivel superior, de ahí pasan como cables directos hacia el módulo combinacional de la ALU, y finalmente retornan al nivel superior para proyectarse en los LEDs físicos.

## 3. Explicación de los módulos desarrollados

El diseño se modularizó en dos archivos independientes para cumplir con los requisitos estructurales:

* **Módulo Superior (`top_system`):** Es el módulo principal y de carácter secuencial. Se encarga de toda la interacción con los periféricos de la tarjeta Zybo Z7 (reloj, switches, botones, LEDs estándar y LED RGB). Dentro de este módulo se evalúan las pulsaciones: BTN0 y BTN1 actúan como señales de carga (Enable) para guardar los datos de los switches en `reg_A` y `reg_B` respectivamente, mientras que BTN2 y BTN3 conmutan los bits del registro de operación (`reg_op`). Adicionalmente, este módulo contiene la estructura condicional (`case`) que asigna los canales de color al LED RGB.
* **Módulo ALU (`alu`):** Es un submódulo netamente combinacional dedicado exclusivamente al procesamiento de datos. No posee conexión al reloj (`clk`), no almacena variables internas y desconoce el origen físico de sus señales. Recibe los dos operandos de 4 bits y el código de 2 bits, devolviendo un resultado de 4 bits. Internamente utiliza un operador condicional anidado (`assign`) para enrutar instantáneamente el resultado de la suma, resta, AND u OR lógico dependiendo del código de operación.

## 4. Tabla de operaciones implementadas

El código de operación (`op`) es de 2 bits, donde BTN2 conmuta el bit menos significativo (`op[0]`) y BTN3 conmuta el bit más significativo (`op[1]`). Los colores definidos para las compuertas lógicas cumplen con el requisito de diferenciación visual:

| Código (`op`) | Operación Ejecutada | Expresión Lógica/Aritmética | Color en LED RGB |
| :---: | :--- | :---: | :--- |
| `00` | Suma Aritmética | `A + B` | Verde (`led6_g = 1`) |
| `01` | Resta Aritmética | `A - B` | Rojo (`led6_r = 1`) |
| `10` | AND Lógico | `A & B` | Azul (`led6_b = 1`) |
| `11` | OR Lógico | `A \| B` | Amarillo (`led6_r = 1`, `led6_g = 1`) |










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

### 1. Explicación general del funcionamiento del sistema
- El sistema captura datos a través de cuatro interruptores (`sw[0]` a `sw[3]`) físicos en la FPGA.
- Al presionar `btn[0]`, el sistema guarda el valor actual de los interruptores en el registro del Operando A.
- Al presionar `btn[1]`, el sistema guarda el valor de los interruptores en el registro del Operando B.
- Los valores de los operandos se mantienen almacenados de forma persistente hasta que se oprima nuevamente su respectivo botón de carga.
- Los botones `btn[2]` y `btn[3]` cambian el estado del bit 0 y del bit 1 del código de operación, respectivamente.
- La operación se mantiene seleccionada sin necesidad de mantener los botones oprimidos físicamente.
- La ALU recibe los operandos y el código de operación, calculando el resultado de forma inmediata ante cualquier cambio en la entrada.
- El resultado de 4 bits se muestra en los indicadores `led[0]` a `led[3]`.
- Un indicador visual (LED RGB) refleja mediante un color la operación que se encuentra seleccionada en ese momento.

### 2. Descripción de la arquitectura propuesta
- El sistema emplea una arquitectura jerárquica que separa la lógica secuencial (memoria y control) de la lógica combinacional (cálculo).
- La lógica secuencial se ubica en el módulo superior, utilizando la señal de reloj (`clk`) para gestionar el almacenamiento de datos en los registros `reg_A` y `reg_B`.
- Para los botones de control de operación (`btn[2]` y `btn[3]`), el módulo superior implementa detectores de flanco de subida.
- Esta detección de flancos evita cambios múltiples causados por la alta frecuencia del reloj, asegurando que el bit cambie solo una vez por pulsación.
- La lógica combinacional está encapsulada por completo en la ALU.
- La ALU funciona de manera aislada, sin conocer el estado de los botones ni encargarse de las conexiones físicas de la tarjeta FPGA.

### 3. Explicación de los módulos desarrollados
- **Módulo Top-Level:** [top.v](./top.v)
  * Actúa como el controlador principal que recibe las entradas físicas y sincroniza el sistema con el reloj `clk`.
  * Administra la memoria interna mediante la instanciación de los registros `reg_A`, `reg_B` y `reg_op`.
  * Genera pulsos de un solo ciclo de reloj (`btn2_pulse` y `btn3_pulse`) usando registros de retardo (`btn2_d` y `btn3_d`) para alternar correctamente el código de operación.
  * Instancia la ALU, pasándole los registros internos y dirigiendo la salida directamente a los LEDs.
  * Controla el LED RGB (`led6_r`, `led6_g`, `led6_b`) mediante un bloque de casos (`case`) evaluando el registro de operación.
- **Módulo ALU:** [ALUMODULE.v](./ALUMODULE.v)
  * Modulo de procesamiento matemático y lógico que cuenta con entradas de 4 bits para los operandos (`A` y `B`) y de 2 bits para la operación (`op`).
  * Genera una salida de 4 bits (`Result`) utilizando asignación continua (`assign`).
  * Utiliza operadores condicionales (operador ternario) para ejecutar la suma, resta, AND y OR dependiendo exclusivamente del valor de `op`.

### 4. Tabla de operaciones implementadas
- **Operación `00` (Suma):** Suma los operandos (`A + B`). El LED RGB se enciende en color Verde (`led6_g = 1`).
- **Operación `01` (Resta):** Resta el operando B al operando A (`A - B`). El LED RGB se enciende en color Rojo (`led6_r = 1`).
- **Operación `10` (AND lógico):** Aplica la compuerta AND bit a bit (`A & B`). El LED RGB se enciende en color Azul (`led6_b = 1`).
- **Operación `11` (OR lógico):** Aplica la compuerta OR bit a bit (`A | B`). El LED RGB se enciende en color Amarillo al encender simultáneamente el canal rojo y verde (`led6_r = 1`, `led6_g = 1`).
- **Operación por defecto:** Para estados no contemplados, el resultado es `0000` y el LED RGB permanece apagado.
