# Laboratorio 04: Implementación de un SoC en Zynq-7000

---

## Integrantes

- Miguel Esteban Beltrán Silva – 1025524635
- Sebastián Camilo Ortegon Hernandez – 1014861874
- Andres Jacobo Rojas Gonzalez – 1025762831
 
**Semestre:** 2026-2   

---
c

## 1. Objetivos de Aprendizaje
Durante el desarrollo de esta práctica, se lograron los siguientes objetivos:
- Implementar un System on Chip (SoC) utilizando la herramienta Block Design de Vivado.
- Identificar y configurar los bloques principales del dispositivo Zynq-7000 (Processing System y Programmable Logic).
- Comprender la interconexión entre el procesador, la memoria, los periféricos (GPIO) y la lógica programable mediante el bus AXI.
- Preparar y exportar una plataforma de hardware personalizada para el desarrollo de software en Vitis.
- Integrar exitosamente código en C con el hardware programable de la FPGA Zybo Z7.

---

## 2. Fundamento Teórico

El desarrollo de este laboratorio se basó en la arquitectura del **Zynq-7000**, el cual es un *System on Chip* (SoC) que integra un sistema computacional completo en un solo circuito. Este dispositivo se divide en dos grandes bloques que interactúan entre sí:

1. **Processing System (PS):** Es el corazón del sistema, compuesto por un procesador ARM Cortex-A9, memorias caché y controladores de periféricos. Aquí se ejecuta el software (en este caso, la aplicación en C desarrollada en Vitis).
2. **Programmable Logic (PL):** Es la sección de FPGA tradicional (reconfigurable). Aquí se implementan los periféricos personalizados o aceleradores de hardware.
3. **Interconexión (AXI):** Para que el procesador (PS) pueda controlar los periféricos físicos conectados a la FPGA (PL), se utilizan los buses de comunicación AXI.

---

## 3. Desarrollo y Procedimiento

El flujo de trabajo se dividió en dos etapas principales: el diseño del hardware en Vivado y el desarrollo del software en Vitis. Aunque nos encontramos con algunos inconvenientes menores al cuadrar la configuración y las conexiones iniciales del diagrama de bloques, logramos resolverlos revisando el mapeo de memoria y las dependencias, logrando un funcionamiento exitoso.

### 3.1. Diseño de Hardware (Vivado)
1. **Creación del proyecto:** Se inició un nuevo proyecto en Vivado seleccionando explícitamente la tarjeta **Zybo Z7-10** desde la pestaña *Boards*.
2. **Block Design:** Utilizando *IP Integrator*, se creó el diagrama de bloques del SoC integrando los siguientes componentes:
   - `ZYNQ7 Processing System`
   - `Processor System Reset`
   - `AXI Interconnect`
   - `AXI BRAM Controller` & `Block Memory Generator`
3. **Modificación de Periféricos (GPIO):** 
   - *Nota de diseño:* A diferencia de lo propuesto en la guía original, **decidimos utilizar los 4 Switches de la placa en lugar de los botones** para controlar las entradas del sistema. Se agregó el bloque GPIO correspondiente a los LEDs y a los Switches.
4. **Mapeo de Memoria:** En la pestaña *Address Editor*, se ajustó el rango de memoria de 64K a 4K para el periférico `/axi_gpio_0/S_AXI`.
5. **Síntesis y Exportación:** Se generó el *HDL Wrapper* (dejando que Vivado lo administrara automáticamente), se ejecutó el *Run Block Automation* y se generó el *Bitstream*. Finalmente, el hardware se exportó generando el archivo `.xsa` (incluyendo el bitstream).

### 3.2. Desarrollo de Software (Vitis)
1. **Configuración del Workspace:** Se lanzó el entorno Vitis IDE desde Vivado y se definió el espacio de trabajo.
2. **Creación de la Plataforma:** Se creó un nuevo *Platform Component* importando el archivo `.xsa` generado en el paso anterior, configurando el sistema operativo como *standalone* y el procesador *ps7_cortexa9_0*.
3. **Aplicación:** Se creó un *Application Component* vacío vinculado a nuestra plataforma. 
4. **Integración del Código:** Se añadió el archivo `main.c` proporcionado en la carpeta `src`.
5. **Compilación (Build):** Se construyó el proyecto sin errores, quedando listo para ser cargado en la FPGA.

---

## 4. Resultados y Evidencias

Una vez cargado el programa en la placa Zybo Z7 (haciendo clic en *RUN* en Vitis), se verificó el correcto funcionamiento de la integración hardware/software. 

**Comportamiento observado:**
- El código `main.c` se ejecuta correctamente sobre el procesador ARM.
- Por defecto, los LEDs de la Zybo Z7 parpadean de forma continua.
- Al accionar cualquiera de los **Switches** (que reemplazaron a los botones), el sistema detecta la entrada a través del GPIO y el LED correspondiente a ese switch permanece encendido de manera fija mientras el switch esté activado, comprobando la comunicación bidireccional en tiempo real entre el PS y el PL.

### Demostración en Video
A continuación, se presenta la evidencia en video del funcionamiento del SoC implementado en la FPGA Zybo Z7:



https://github.com/user-attachments/assets/e42d3067-8968-4e72-b785-8b0b28b91cd3


---

## 5. Conclusiones
- La herramienta *Block Design* simplifica significativamente la creación de sistemas complejos, permitiendo conectar procesadores y periféricos de forma visual antes de generar el código HDL subyacente.
- Se comprendió el flujo de trabajo industrial moderno para sistemas embebidos en FPGAs: definir el hardware primero (Vivado), exportar la plataforma (`.xsa`) y, finalmente, desarrollar el software de control (Vitis).
