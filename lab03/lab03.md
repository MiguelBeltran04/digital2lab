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
- El sistema emplea una arquitectura jerárquica que separa la lógica secuencial (memoria y control) de la lógica combinacional (cálculo).
- La lógica secuencial se ubica en el módulo superior, utilizando la señal de reloj (`clk`) para gestionar el almacenamiento de datos en los registros `reg_A` y `reg_B`.
- Para los botones de control de operación (`btn[2]` y `btn[3]`), el módulo superior implementa detectores de flanco de subida.
- Esta detección de flancos evita cambios múltiples causados por la alta frecuencia del reloj, asegurando que el bit cambie solo una vez por pulsación.
- La lógica combinacional está encapsulada por completo en la ALU.
- La ALU funciona de manera aislada, sin conocer el estado de los botones ni encargarse de las conexiones físicas de la tarjeta FPGA.
---
### Explicación de los módulos desarrollados
- **Módulo Top-Level:** [top.v](src/top.v)
  * Actúa como el controlador principal que recibe las entradas físicas y sincroniza el sistema con el reloj `clk`.
  * Administra la memoria interna mediante la instanciación de los registros `reg_A`, `reg_B` y `reg_op`.
  * Genera pulsos de un solo ciclo de reloj (`btn2_pulse` y `btn3_pulse`) usando registros de retardo (`btn2_d` y `btn3_d`) para alternar correctamente el código de operación.
  * Instancia la ALU, pasándole los registros internos y dirigiendo la salida directamente a los LEDs.
  * Controla el LED RGB (`led6_r`, `led6_g`, `led6_b`) mediante un bloque de casos (`case`) evaluando el registro de operación.
- **Módulo ALU:** [ALUMODULE.v](src/ALUMODULE.v)
  * Modulo de procesamiento matemático y lógico que cuenta con entradas de 4 bits para los operandos (`A` y `B`) y de 2 bits para la operación (`op`).
  * Genera una salida de 4 bits (`Result`) utilizando asignación continua (`assign`).
  * Utiliza operadores condicionales (operador ternario) para ejecutar la suma, resta, AND y OR dependiendo exclusivamente del valor de `op`.
---
### Tabla de operaciones implementadas

- El código de operación (`op`) es de 2 bits, donde BTN2 conmuta el bit menos significativo (`op[0]`) y BTN3 conmuta el bit más significativo (`op[1]`):
  
| Código (`op`) | Operación Ejecutada | Expresión Lógica/Aritmética | Color en LED RGB |
| :---: | :--- | :---: | :--- |
| `00` | Suma Aritmética | `A + B` | Verde (`led6_g = 1`) |
| `01` | Resta Aritmética | `A - B` | Rojo (`led6_r = 1`) |
| `10` | AND Lógico | `A & B` | Azul (`led6_b = 1`) |
| `11` | OR Lógico | `A \| B` | Amarillo (`led6_r = 1`, `led6_g = 1`) |

- **Operación por defecto:** Para estados no contemplados, el resultado es `0000` y el LED RGB permanece apagado.

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

