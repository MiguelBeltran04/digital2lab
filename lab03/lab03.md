# Laboratorio 03 
## ALU + Banco de Registros + Diseño Modular

---

## Integrantes

- Miguel Esteban Beltrán Silva – 1025524635
- Sebastián Camilo Ortegon Hernandez – 1014861874
- Andres Jacobo Rojas Gonzalez – 1025762831
 
**Semestre:** 2026-2   

---

## Funcionamiento del sistema

- El sistema integra una Unidad Aritmético Lógica (ALU) de 4 bits, un banco de 4 registros de memoria y un display externo (TM1637) para ejecutar y visualizar operaciones matemáticas y lógicas.
- El ingreso de datos se realiza a través de 4 interruptores físicos (`sw[3:0]`), cuyo valor se guarda temporalmente en los registros internos (R0 a R3).
- La selección del registro donde se va a escribir se controla con el botón `BTN0`, y el registro activo se identifica de manera visual mediante un color específico en el LED RGB.
- Al oprimir `BTN1`, el valor actual de los interruptores se almacena de forma persistente en el registro seleccionado.
- Con el botón `BTN2`, el sistema alterna cíclicamente entre 12 combinaciones posibles de operandos (A y B) tomados del banco de registros. Los 4 LEDs estándar de la tarjeta se encienden para indicar qué registros están siendo utilizados en ese momento.
- Los tres primeros interruptores (`sw[2:0]`) definen el código de la operación que ejecutará la ALU.
- La operación matemática o lógica se ejecuta únicamente al presionar `BTN3`. En ese instante, la ALU procesa los operandos y el resultado se captura para mostrarse en el display de 7 segmentos.
- El valor proyectado en el display se mantiene estático, reteniendo la última operación válida, hasta que se vuelva a oprimir `BTN3`, sin importar si los interruptores o los registros se modifican en el proceso.

---

### Resumiendo

- **Carga de datos:** Se ingresa el valor en los interruptores (`sw`), se elige el registro destino con `BTN0` (guiado por el LED RGB) y se guarda oprimiendo `BTN1`.
- **Selección de operandos:** Se oprime `BTN2` para rotar qué pareja de registros actuarán como operando A y operando B (indicado por los LEDs regulares).
- **Ejecución y visualización:** Se configura la operación deseada con los interruptores `sw[2:0]` y se ejecuta con `BTN3`, actualizando instantáneamente el resultado en el display externo.


---




## Implementación

### Explicación de los módulos desarrollados
- **Módulo ALU:** [ALU.v](src/ALU.v)
  * Modulo de procesamiento matemático y lógico que cuenta con entradas de 4 bits para los operandos (`A` y `B`) y de 2 bits para la operación (`op`), el cual siempre se ejecutara si hay algun cambio en las entradas gracias a `always @(*)` .
  * Genera una salida de 8 bits (`result`) para evitar un overflow.
  * Utiliza operadores condicionales (operador ternario) para ejecutar la operación de suma, resta, AND, OR, XOR, NOT A, DESPLAZAMIENTO A LA IZQUIERDA DE A Y EL COMPARADOR DE A, dependiendo exclusivamente del valor de `op`.
  * Por defecto siempre entregara como resultado 8'sd0.
  
- **Módulo Button Debounce (Antirrebote):** [button_debounce.v](src/button_debounce.v)
  * El objetivo de este modulo es el de filtrar ruido electrico (rebotes) porovcados por los botones mecanicos de la FPGA.
  * Se define el parámetro `DEBOUNCE_CYCLES`, el cual indica el numero de ciclos del clock consecutivos durante los cuales la señal del botón debe permanecer estable o constante para que se pueda considerar como valida (considerando que la FPGA cuenta con un clock de 125 MHz, ese tiempo seria de unos 20 ms para que se valida la señal) y con `COUNTER_WIDTH` se calcula automáticamente la cantidad de bits que necesita el contador.
  * Se presentan 3 entradas (`clk`,`btn_in`  y `rst`) y 2 salidas (`btn_level`  y `btn_pulse`), estas ultimas sirven para indicar si el botón se ha presionado de forma estable y constante y para señalar por medio de un unico pulso la confirmación de la pulsación del boton.
  * Se cuenta con `reg sync0`  y `reg sync1`, con este ultimo, se va comparando con `btn_level` y para verificar si el estado sigue estable (Entre estar y no estar presionado el boton) o si hay algun cambio. En el momento en el que la entrada se mantiene sin cambios y logra durar mas de 20 ms, `btn_level` toma el valor de `sync1`. Y si por ejemplo si la transición fue hacia un alto, `sync1==1` y posterior a eso `btn_pulse==1`, si este deja de estar en alto o no hace esa transición por default `btn_pulse==0` y el contador se reiniciara
   
- **Módulo SELECTOR:** [comb_selector.v](src/comb_selector.v)
  * Este tiene la función de que por medio del uso de un botón, se vayan rotando todas las posibles combinaciones de valores previamente colocados (Serian 4 números distintos, cada uno de 4 bits). Esto se hace cuando recibe la señal `next_comb`. Al final las dos salidas son `read_addrA` y `read_addrB`, las cuales indican la dirección/ubicación del operando A Y B.
  * Se cuenta con `comb_index`, la cual va incrementando de 1 en 1 hasta llegar a 11 y se reinicia a 0 creando un bucle o ciclo de 12 "estados" (Son 12, ya que es la cantidad total de pares ordenados que se pueden obtener si se quiere operar dos registros distintos entre si)

- **Módulo BANCO DE REGISTROS:** [reg_bank.v](src/reg_bank.v)
  * En este modulo se almacenan 4 registros de 4 bits cada uno.
  * Se cuenta con `registers`, el cual es un arreglo de 4 posiciones y en cada uno se encuentro un valor de 4 bits. Por otro lado se encuentran las entradas `write_enable`, `write_addr` y `write_data`, los cuales sirven para habilitar la escritura de un valor, el registro en el que este se escribira y el valor que se va a guardar. Tambien se tiene a `read_addrA` y a `read_addrB`, los cuales indican las direcciones de los registros que van a ser leidos, y por ultimo estan `A` y `B`, los cuales son los datos leidos de las direcciones previamente marcadas.
  * Si se activa el reset, se ejecuta un bucle el cual hara que se reinicien las 4 posiciones de memoria a 0.
  * si `write_enable`, se guarda el valor que se encuentra en `write_data` en el registro especificado por `write_addr`. En cuanto se cambien las direcciones, las salidas automáticamente cambian sus valores, ya que estas no dependen del clock principal.

- **Módulo Latch de Resultados:** [result_latch.v](src/result_latch.v)
  * Su propósito principal es aislar la salida dinámica de la ALU y retener su último resultado válido.
  * Se actualiza únicamente de manera síncrona en el flanco de subida del reloj, y solo cuando la señal `execute` (controlada por `btn3`) se pone en alto.
  * Garantiza que el display no cambie si se modifican los operandos en el banco de registros, hasta que explícitamente se ordene una nueva ejecución.


- **Módulo Write Selector:** [write_selector.v](src/write_selector.v)
  * Gestiona qué registro dentro del banco será modificado por el usuario al presionar el botón de escritura.
  * Utiliza un contador interno básico (`write_addr`) de 2 bits.
  * El contador avanza de forma cíclica (0, 1, 2, 3, 0...) con cada pulso detectado en la señal `select_next` (controlada por `btn0`).



- **Módulo System Core:** [system_core.v](src/system_core.v)
  * Actúa como el puente lógico del sistema, agrupando e interconectando el módulo de escritura, el banco de registros, el selector de combinaciones, la ALU y el latch de resultados.
  * Se alimenta del reloj (`clk`), de las señales limpias de los switches y de los pulsos de un ciclo (provenientes de `top.v`) y reparte estas señales entre los submódulos de la arquitectura.
  * Conecta las entradas de la `ALU` (`a` y `b`) de forma directa a las salidas asíncronas (`A` y `B`) del banco de registros.
  * La salida de la `ALU` (`alu_result`) no va directo al exterior, sino que pasa por un módulo de retención (`result_latch`).
  * Realiza un desplazamiento de bits (`<<`) para traducir las direcciones binarias de los operandos en uso (`read_addrA` y `read_addrB`) hacia las posiciones físicas de los 4 LEDs indicadores (`leds`).

- **Módulo Top-Level:** [top.v](src/top.v)
  * Funciona como el nivel más alto de la jerarquía del diseño, encargándose exclusivamente de la interfaz con los periféricos físicos de la placa FPGA.
  * Genera internamente una señal de reinicio (reset) automático (`rst`) basada en un contador de los primeros ciclos del reloj del sistema (`sysclk`).
  * Implementa un bloque de sincronización con memoria en cascada (`sw_meta` y `sw_sync`) para estabilizar las señales de entrada de los interruptores y prevenir problemas de metaestabilidad.
  * Instancia de manera dinámica un módulo de filtro antirrebote (`button_debounce`) para cada uno de los 4 botones utilizando un bloque `generate`, transformando las entradas mecánicas en pulsos limpios de un solo ciclo (`btn_pulse`).
  * Instancia el módulo principal lógico (`system_core`), pasándole las señales estabilizadas y los pulsos generados por los botones.
  * Gestiona directamente el LED RGB, asignándole un color fijo dependiendo del valor que devuelva la señal `selected_reg`: Rojo (`0`), Verde (`1`), Azul (`2`) o Blanco (`3`).
  * Instancia el controlador del display externo de 7 segmentos (`display_tm1637`) para la visualización del resultado retenido.




  
---
## Testbench

### Explicación de las simulaciones
- **Módulo ALU:** [alu_tb.v](src/alu_tb.v)
  * En este testbench se verifican todas las posibles combinaciones que se pueden dar en las entradas (16 posibles numeros decimales en `A` y `B` y 8 posibles operaciones `op`), la comparación se hace por medio de referencia interno.
  * Por medio de tres bucles anidados `for`, se hace que `i`, `j` y `k` cubran todos los escenarios posibles que se pueden dar. Por cada iteración realizada, dentro del testbench se realiza la operación entre `A` y `B` de forma completamente independiente y lo guarda en `expected`
  * Se espera 1 ns para que la ALU realice la operación y así compararlo con `expected`
  * Por medio de un if y del uso del operador de desigualdad estricta se comparan ambos resultados y si estos coinciden se va sumando 1 a `tests` hasta llegar a 2048
  * <img width="1917" height="640" alt="image" src="https://github.com/user-attachments/assets/45e87f1a-7b1f-4128-a7e4-6384b99bf6ad" />
  
- **Módulo ANTIREBOTE:** [button_debounce_tb.v](src/button_debounce_tb.v)
  * En primer lugar se aplica un reset inicial con una duración de 3 ciclos de reloj, para limpiar los registros y dejar el contador en 0. Posteriormente se prueba alternando los valores de `btn_in` en un corto periodo de tiempo, lo que provoca que no se llegue en tiempo al valor de `DEBOUNCE_CYCLES`, el cual en el caso de la simulación se dejo definido como la duración de cuatro ciclos de `counter`.
  * Una vez se hayan superado esos 4 ciclos de reloj (lo que indica como se logra ver en `btn_in` que el boton esta pulsado por un periodo prolongado de tiempo), `btn_level` cambia a 1 al igual que `btn_pulse` (este ultimo solo dura un ciclo de reloj) y asi se mantiene hasta que se deje de pulsar el boton (Se evidencia que como tal `counter` responde a `sync1` y no directamente a `btn_in`, esto básicamente se da porque `sync0` y `sync1` son una cadena de Flip Flops D las caules ayudan a tener una "estabilidad" si las pulsaciones del boton no coinciden con los flancos de subida del clock.
  * <img width="1917" height="581" alt="image" src="https://github.com/user-attachments/assets/aca75a59-ae91-48e5-9256-991325f89598" />

 - **Módulo SELECTOR:** [comb_selector_tb.v](src/comb_selector_tb.v)
  * En la simulación se hizo un barrido por los 12 posibles "estados", en donde tras la activación de `next_comb` durante un ciclo de reloj (Para esta simulación no se coloco en ns los clocks y la respuesta de las demas entradas y salidas), se le empieza a sumar a `i` 1 y se pasa a la siguiente combinación. Una vez se hallan recorrido las 12 direcciones, se comprueba que para el siguiente pulso se tiene que reiniciar el contador regresando al estado inicial.
  * Al final se mantiene `next_comb` igualado a cero para verificar que no se cambie de estado y que el contador no siga sumándose unos tras varias ciclos de reloj con `next_comb=0`
  * <img width="1917" height="536" alt="image" src="https://github.com/user-attachments/assets/5902bef7-a4c1-4cdc-a8bc-534e24bf3780" />

- **Módulo BANCO REGISTROS:** [reg_bank_tb.v](src/reg_bank_tb.v)
  *

- **Módulo LATCH DE RESULTADOS:** [result_latch_tb.v](src/result_latch_tb.v)
  * En esta simulación se verifica el correcto funcionamiento del reinicio (reset), asegurando que la salida inicialice en 0.
  * Se comprueba la captura de un dato válido (como el valor 12) activando la señal `execute` durante un flanco de subida del reloj.
  * Se valida el aislamiento del módulo: al cambiar la entrada `alu_result` a un valor distinto (como -5) mientras `execute` está en bajo, el resultado retenido (`last_result`) permanece intacto en 12.
  * Posteriormente, se envía un nuevo pulso de `execute` para comprobar que ahora sí captura el nuevo valor, y se repite el proceso de alteración en bajo para ratificar la retención.
  * <img width="1912" height="510" alt="image" src="https://github.com/user-attachments/assets/9ecdc56b-b8f9-466e-8e9a-f79c1d268ff1" />


- **Módulo SYSTEM CORE:** [system_core_tb.v](src/system_core_tb.v)
  * Esta prueba integra lógica y memoria; inicia validando que, tras el reset, los LEDs muestren la combinación inicial predeterminada (registros R0 y R1).
  * Simula una secuencia de usuario completa mediante la tarea `press`, la cual imita la pulsación limpia de botones.
  * Se escriben valores en distintos registros (5 en R0 y 9 en R1) y se verifica que las salidas asíncronas de lectura `A` y `B` correspondan correctamente a estos datos.
  * Ejecuta una suma (14), cambia la operación a resta sin pulsar ejecutar (verificando que la retención no cambie el 14) y luego ejecuta la resta (-4), corroborando el flujo completo de la ALU y el Latch.
  * Finalmente, simula el cambio de operandos (a R0 y R2), demostrando que la interfaz de los LEDs se actualiza sin alterar el último resultado retenido.
  * <img width="1917" height="400" alt="image" src="AQUÍ_VA_TU_IMAGEN_SYSTEM_CORE" />


  - **Módulo SELECTOR DE ESCRITURA:** [write_selector_tb.v](src/write_selector_tb.v)
  * Evalúa el comportamiento del contador de 2 bits asegurándose de que inicie en el registro 0 tras aplicar la señal de `rst`.
  * Ejecuta varios pulsos secuenciales en la señal `select_next` para corroborar que la dirección de escritura avance en un ciclo cerrado perfecto (0 -> 1 -> 2 -> 3 -> 0).
  * Introduce un periodo de inactividad (varios ciclos de reloj sin pulsar el botón) para confirmar que la última selección se conserva estable en el tiempo.
  * Verifica el reinicio asíncrono, activando el reset en medio de una selección avanzada para asegurar que el contador regrese inmediatamente a la posición 0.
  * <img width="1917" height="400" alt="image" src="AQUÍ_VA_TU_IMAGEN_WRITE_SELECTOR" />


- **Módulo TOP:** [top_tb.v](src/top_tb.v)
  * Representa la prueba del hardware real. Comienza esperando a que el sistema complete automáticamente sus ciclos de reset basados en el reloj del sistema `sysclk`.
  * Incluye retardos prolongados (`repeat(12)`) en la simulación de los botones para superar intencionalmente el filtro antirrebote y asegurar que los pulsos se registren correctamente.
  * Réplica una secuencia completa de operaciones (sumar 5+9, restar 5-9, cambiar operandos y sumar 5+7) para validar todo el flujo de datos.
  * Culmina con una comprobación indispensable para este nivel: verificar que, tras calcular el resultado final de 12, los registros correspondientes al controlador del display TM1637 (`frame_seg2` y `frame_seg3`) almacenen la decodificación correcta en segmentos para el número.
  * <img width="1917" height="400" alt="image" src="AQUÍ_VA_TU_IMAGEN_TOP" />


