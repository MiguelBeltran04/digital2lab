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

- **ALU:**  Para este ejercicio se programo la ALU en un modulo completamente aparte al top_system o unidad de control (Básicamente para que esta cumpliera de forma exclusiva la función de realizar operaciones con base a las entradas, y devolver al top el resultado dependiendo de las entradas actuales). En esta parte dependiendo del estado de un par de botones de la FPGA, se realizara una operación entre dos números de 4 bits (Mas adelante se vera con mas detalle como se guardan estos números en el programa). Estas operaciones son; suma, resta y comparación utilizando AND y OR y al final, el resultado seguirá siendo de 4 bits (Si por ejemplo, el resultado de la suma de los dos números es mayor a 4 bits, se mostraran en los bits de salida los 4 bits menos significativos del resultado).
- **Funcionamiento de interfaz fisica:** Los números se guardaran gracias a la activación física de dos botones (por medio de los cuales el usuario decidirá si guardar el numero en el registro A, en el registro B, en ambos o si decide no guardar el numero previamente seleccionado por medio de los switches de la placa de desarrollo). Finalmente, dependiendo de la operación seleccionada (La cual se debe seleccionar al pulsar una vez el boton y no manteniendolo presionado), el led RGB se encendera y arrojara distintos colores (Verde si se selecciona la suma; Rojo si se selecciona la resta; Azul si se selección la compuerta AND y Amarillo si se selecciona la compuerta OR)

---

## Implementación
