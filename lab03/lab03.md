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

-

### Resumiendo


---

### Descripción de la arquitectura propuesta


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

- **Módulo display TM1637:** [display_tm1637.v](src/display_tm1637.v)
  * EL display TM1637 se controla mediante una interfaz serial de dos señales: tm_clk. la cual corresponde al reloj del circuito integrado, y tm_dio, el cual recibe los datos enviados desde la FPGA.
  * EL sistema recibe un número de 8 bits con signo que corresponde a un intervalo entre -128 y 127. El modulo está dividido en diferentes secciones, la primera de ellas identifica el signo del número que entra al modulo y lo separa en unidades, decenas y centenas. Posteriormente, la función ´seg7´ convierte cada digito en un patrón de 8 bits que determina los segmentos que deben encenderse, incluyendo el signo negativo en caso de que corresponda en la representación del número.
  * Para sincronizar la comunicación, se utiliza un contador que genera una señal llamada ´step_tick´ cada 5 microsegundos, a partir del reloj principal de 125 Mhz de la FPGA. Esta señal controlará el avance de la FSM que se encarga de ejecutar el protocolo de comunicación.
  * Los datos a transmitir se preparan utilizando registros que permiten almacenar los comandos y los datos antes de enviarlos al controlador. El registro ´tx_byte´ se encarga de almacenar el byte de 8 bits que será transmitido. la variable ´bit_index´ indica la posición del bit que se está enviando. ´byte_index´ identifica el byte correspondiente a la secuencia dentro de la escritura
  * La comunicación con el display se realiza en 3 pasos, los cuales se definieron como´transacciones´. La primera parte es la configuración, la cual se activa con una señal cuyo valor hexadecimal es 0x40, la cual se encarga de habilitar el proceso de escritura e incrementa automáticamente las direcciones de memoria después de escribir cada byte.
  * La escritura se activa con una señal 0xC0, que establece la dirección inicial y transmite los 4 bytes que le corresponden a cada dígito del display.
  * Una señal 0x8A enciende el display y configura su nivel de brillo a aproximadamente el 20% de su ciclo útil para que se logre visualizar de manera correcta.
  * La transmisión de los bytes se realiza en série, empezando desde el bit menos significativo. La señal ´tm_dio´ establece el valor de cada bit, mientras que ´tm_clk´ está en estado bajo. Cuando el reloj está en estado alto, el tm1637 recibirá el dato.
  * Cuando los 8 bits se transmiten, se genera un noveno pulso de reloj para que el TM1637 envíe una confirmación ACK. Esto hace que DIO pase a nivel bajo y se pueda transmitir información nuevamente. Cada ciclo completo de actualización transmite 7 bytes y cada transacción empieza con una condición START y una STOP.
  * Los registros denominados frame_seg(0-3) almacenan temporalmente los patrones de los 4 digitos y únicamente se actualizan al iniciar un nuevo ciclo de comunicación. De esta forma se garantiza que las variaciones en la entrada alteren los resultados mientras se está realizando una transmisión.
  * **Máquina de estados finitos (FSM)**: Está compuesta por 14 estados que se encargan de controlar las señales de reloj, el flujo de datos y la confirmación con el TM1637:
  
    | ESTADO | FUNCIÓN |
    |--------|---------|
    | IDLE | Inicia la comunicación y almacena los datos de los 4 dígitos |
    | START | Inicia la transmisión llevando al pin DIO a bajo con CLK en alto |
    | START_HOLD | CLK pasa a estado bajo para preparar el envío de datos |
    | BIT_SETUP | Coloca el bit correspondiente en DIO |
    | BIT_ HIGH | Coloca CLK en estado alto para transmitir el bit |
    | BIT_LOW | Baja el estado de CLK y avanza al siguiente bit a transmitir |
    | ACK_RELEASE | Libera el pin DIO para recibir la confirmación |
    | ACK_RISE | Sube CLK para el pulso ACK |
    | ACK_SAMPLE | Lee y almacena la respuesta ACK del TM1637 |
    | ACK_FALL | Baja el estado de CLK y determina si faltan bytes por transmitir |
    | LOAD_NEXT | Carga el siguiente byte y reinicia el índice de bits |
    | STOP_PREP | Lleva DIO a estado bajo para preparar el cierre de la transacción |
    | STOP_RISE | Sube CLK manteniendo DIO en bajo |
    | STOP_RELEASE | Libera DIO para finalizar la transacción o iniciar con la siguiente |
    * La señal tm_dio se controla mediante el registro ´dio_drive_low´ que, cuando el registro está activo, la línea se lleva a un nivel lógico bajo. Cuando está inactivo, la FPGA libera la línea, permitiendo que una resistencia pull_up establezca el nivel lógico alto. De esta manera, el TM1637 utiliza la misma línea para enviar la señal de confirmación ACK.
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

- **Modulo TM1637** Con fines demostrativos y debido a la gran cantidad de señales que este módulo genera en gtkWave, se preparó un video en el que se muestran las señales más importantes del testbench y se muestra el funcionamiento del protocolo de comunicación con el display:
 [![Explicación del testbench TM1637](https://img.youtube.com/vi/bMWKr_Kpmek/maxresdefault.jpg)](https://www.youtube.com/watch?v=bMWKr_Kpmek)

**Evidencia de la implementacion en FPGA**
[![Implementación en FPGA laboratorio 3](https://img.youtube.com/vi/DcFJ4dNK-OM/maxresdefault.jpg)](https://www.youtube.com/watch?v=DcFJ4dNK-OM)
