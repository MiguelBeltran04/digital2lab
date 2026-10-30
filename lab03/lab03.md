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
  
- **Módulo ALU:** [ALUMODULE.v](src/ALUMODULE.v)
  
---
## Testbench

### Explicación de las simulaciones
- **Módulo ALU:** [alu_tb.v](src/alu_tb.v)
  * En este testbench se verifican todas las posibles combinaciones que se pueden dar en las entradas (16 posibles numeros decimales en `A` y `B` y 8 posibles operaciones `op`), la comparación se hace por medio de referencia interno.
  * Por medio de tres bucles anidados `for`, se hace que `i`, `j` y `k` cubran todos los escenarios posibles que se pueden dar. Por cada iteración realizada, dentro del testbench se realiza la operación entre `A` y `B` de forma completamente independiente y lo guarda en `expected`
  * Se espera 1 ns para que la ALU realice la operación y así compararlo con `expected`
  * Por medio de un if y del uso del operador de desigualdad estricta se comparan ambos resultados y si estos coinciden se va sumando 1 a `tests` hasta llegar a 2048
  * <img width="1917" height="640" alt="image" src="https://github.com/user-attachments/assets/45e87f1a-7b1f-4128-a7e4-6384b99bf6ad" />

