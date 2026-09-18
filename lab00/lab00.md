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

El sistema funciona de la siguiente manera: cada flanco de subida del clock la maquina se mantendra en el mismo estado hasta que se llegue a un punto en donde la variable "contador" llegue a cierto valor (En el caso del Estado verde tiene que llegar a 4 para que en el siguiente flanco de subida del clock, el cual seria el quinto, este automáticamente cambie de estado, en el caso del amarillo será 1 y en el caso del rojo será el 3). Un ciclo e reloj después se va a pasar al siguiente estado tal y como se ve en la imagen.

En el momento en el que la maquina se encuentre en el estado S1, esta tiene que saber si cambiar al estado S0 o S2, es por eso que existe la variable "dirección", la cual será cero si se esta en el Estado S0 y 1 si se encuentra en el estado S2. Mas adelante en el código

<img width="1600" height="666" alt="WhatsApp Image 2026-09-15 at 8 43 53 PM" src="https://github.com/user-attachments/assets/f7d483d4-c7a3-4b5c-b087-eeaf162ca84d" />
 se vera de mejor manera la implementación de esta.

Describa brevemente los diseños realizados en el laboratorio.

Incluya:
- Tipo de sistema (FSM, FSM + datapath).
- Estados definidos.
- Funcionamiento general del sistema.

Cuando aplique, incluya el diagrama de la máquina de estados.

---

## Simulaciones

### Ejercicio #1

En primer lugar en el testbench se encuentran las señales de entrada las cuales son clk y rst, las cuales terminaran siendo manejadas activamente por el testbench, luego se colocan las tres salidas. Luego se genera el clk, en este caso va a tener un medio ciclo de 5 ns, ya que previamente se difinio una escala de 1ns/1ns (De ahi a que coloque el #5) y se define el nombre del nuevo archivo generado, el cual se usara para guardar todos los datos y asi, poder ser usados por GTKWave a la hora de realizar las graficas. Por ultimo se activa un reset con una duración de 20 ns, pasado ese tiempo este sera igual a ceroy se indica que luego de esos 20 ns, la simulación dure 300 ns mas.

A continuación  se explicara el comportamiento de las señales observadas en GTKWave, iniciando por las salidas. Se puede evidenciar que la maquina arroja las salidas correctamente, ya que hace la secuencia "verde, amarillo, rojo" y "rojo, amarillo, verde" de forma constante y nunca se queda en un bucle (Es decir, no se queda en el mismo estado). 

Se ve la presencia del rst, el cual deja practicamente a todas las señales en 0, no es hasta que sea igual a cero para que el resto de señales se empiecen a activar. 

En el caso de "contador", vemos que esta opera correctamente, reiniciandose en el momento en el que la maquina cambia de estados y asi volver a contar los flancos de subida para el estado enel que este presente. La variable "dirección" termina siendo igual a cero cuando pasa por ele stado S0 y 1 cuando pasa por S1.

Con respecto a "estado_actual" se evidencia como siempre cambia de estado correctamente, y a la vez cambia la salida. Mientras que "estado_siguietne" un ciclo de reloj antes deja definido ese estado al que necesita pasar una vez se termine ese ciclo de reloj (En la sección de implementació se eplicara con mayor profundida)

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

Explique cómo se implementó el diseño en Verilog.

Incluya:
- Organización del código.
- Manejo de reloj y reset.
- Comportamiento esperado del sistema.

> El código fuente debe encontrarse en la carpeta `src/`.

---

## Conclusiones

- Principales aprendizajes del laboratorio.
- Dificultades encontradas.
- Importancia de la simulación en el diseño digital.

---

## Referencias

