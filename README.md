# Actividad 5 — Diagnóstico y resolución de conflictos sintácticos con GNU Bison

**Materia:** Programación de Sistemas  
**Unidad:** 4. Análisis sintáctico  
**Alumno:** Diego Deciderio Garcia
**Matricula:** 10240041  
**Fecha:** 6 de noviembre de 2026  
**Repositorio:** [(https://github.com/TecDeci2141/actividad05_conflictos.git]

---

## 1. Objetivo

Diagnosticar y corregir conflictos sintácticos en un analizador LALR generado con GNU Bison, partiendo de una gramática ambigua con 5 conflictos shift/reduce y llevándola a 0 conflictos mediante precedencia/asociatividad y reescritura de la regla del `if/else`.

---

## 2. Predicciones iniciales

Antes de ejecutar Bison, se predijo:

- **Conflictos por operadores:** 4 (combinaciones `+/+`, `+/*`, `*/+`, `*/*`).
- **Conflictos por el `else`:** 1 (dangling else en `if` anidados).
- **Total esperado:** 5 shift/reduce conflicts.

Esta predicción se confirmó al revisar `evidencias/01_inicial.txt`.

---

## 3. Progresión de conflictos

| Etapa | Archivo de evidencia | Conflictos shift/reduce | Acción realizada |
|-------|----------------------|-------------------------|------------------|
| Inicial | `01_inicial.txt` | **5** | Gramática ambigua sin precedencia ni reescritura |
| Precedencia | `02_precedencia.txt` | **1** | Se agregaron `%left MAS` y `%left POR` |
| Dangling else | `03_else_resuelto.txt` | **0** | Se reescribió `sentencia` en emparejada/no emparejada |
| Final | `04_final.txt` | **0** | Validación estricta con `-Werror=conflicts-sr` |

---

## 4. Diagnóstico del counterexample de operadores

### Entrada: `a + b * c`

Bison reporta un conflicto en el token `*` después de haber reducido `a + b` como candidato.

- **Shift derivation:** el parser desplaza `*` y continúa, esperando leer `c` para formar `b * c`. Esto produce la interpretación `a + (b * c)`, que es la correcta matemáticamente.
- **Reduce derivation:** el parser reduce `a + b` a `expr` inmediatamente y luego ve `*`, lo que produciría `(a + b) * c`, incorrecto en aritmética estándar.

La declaración `%left POR` con mayor precedencia que `%left MAS` resuelve el conflicto a favor del shift, dando la precedencia correcta al producto.

### Entrada: `a + b + c`

- **Shift derivation:** desplazaría el segundo `+`, produciendo `a + (b + c)`.
- **Reduce derivation:** reduce `a + b` a `expr`, produciendo `(a + b) + c`.

La declaración `%left MAS` fuerza la asociatividad por la izquierda, eligiendo reduce y obteniendo `(a + b) + c`, que es el comportamiento esperado.

---

## 5. Diagnóstico del dangling else

### Entrada: `if (a) if (b) x = 1; else x = 2;`

Al llegar al `else`, el parser tiene dos opciones:

1. **Asociar al `if` interno (más cercano):** `if (a) { if (b) x = 1; else x = 2; }` — el `else` cierra el `if (b)`.
2. **Asociar al `if` externo:** `if (a) { if (b) x = 1; } else x = 2;` — el `else` cierra el `if (a)`.

Ambas interpretaciones son sintácticamente válidas, lo que genera el conflicto shift/reduce.

### Por qué `%expect 1` no es una solución

`%expect 1` solo suprime la advertencia indicando a Bison que acepte 1 conflicto. La gramática **sigue siendo ambigua** y Bison resuelve el conflicto por defecto haciendo shift (asociando al `if` más cercano), pero esto es una convención, no una corrección formal. La práctica exige reescribir la gramática para eliminar la ambigüedad de raíz.

### Solución aplicada: gramática emparejada / no emparejada

Se dividió `sentencia` en:

- `sentencia_emparejada`: no deja ningún `if` esperando `else`.
- `sentencia_no_emparejada`: conserva exactamente un `if` pendiente.

Con esta separación, el `else` solo puede completar el `if` pendiente más cercano, eliminando la ambigüedad.

---

## 6. Preguntas de comprobación

### Pregunta 1: ¿Por qué aceptar una entrada no demuestra que la gramática carezca de ambigüedad?

**Respuesta:**  
Porque un parser LALR puede aceptar una cadena aplicando una de las dos decisiones posibles en un conflicto shift/reduce. La entrada `if (a) if (b) x = 1; else x = 2;` es aceptada tanto por la gramática ambigua como por la reescrita, pero en el primer caso Bison tuvo que elegir una interpretación por defecto (shift), lo que demuestra que había ambigüedad aunque la cadena se acepte. Como evidencia, en `evidencias/01_inicial.txt` se reporta 1 shift/reduce conflict a pesar de que el parser acepta la cadena.

### Pregunta 2: Compara `a + b * c` y `a + b + c`: ¿qué decisión toma el parser en cada caso y qué declaración de precedencia o asociatividad la justifica?

**Respuesta:**  
- En `a + b * c`, al ver `*` después de `a + b`, el parser hace **shift** porque `POR` tiene mayor precedencia que `MAS` (declarado después con `%left POR`). Esto produce `a + (b * c)`.
- En `a + b + c`, al ver el segundo `+`, el parser hace **reduce** porque `MAS` es asociativo a la izquierda (`%left MAS`), agrupando como `(a + b) + c`.

Ambas decisiones se justifican en `evidencias/02_precedencia.output`, donde Bison muestra "Conflict between ... resolved ...".

### Pregunta 3: En dos `if` anidados, explica las dos asociaciones posibles del `else` y por qué `%expect 1` oculta la advertencia sin corregir la causa.

**Respuesta:**  
El `else` puede asociarse al `if` interno (más cercano) o al externo. `%expect 1` solo indica a Bison que ignore una advertencia de conflicto; la gramática sigue siendo ambigua y Bison resuelve por convención (shift). La solución correcta es reescribir la gramática con sentencias emparejadas/no emparejadas para eliminar la ambigüedad de raíz. Esto se evidencia en el paso de `02_precedencia.txt` (1 conflicto) a `03_else_resuelto.txt` (0 conflictos) tras la reescritura.

---

## 7. Resultados de las pruebas

Salida completa de `evidencias/05_pruebas.txt`:

```
OK  pruebas/01_precedencia.txt -> 0
OK  pruebas/02_parentesis.txt -> 0
OK  pruebas/03_else_cercano.txt -> 0
OK  pruebas/04_else_doble.txt -> 0
OK  pruebas/05_operador_invalido.txt -> 1
OK  pruebas/06_else_sin_if.txt -> 1
```

Las 6 pruebas pasaron correctamente: las entradas válidas fueron aceptadas (código 0) y las inválidas fueron rechazadas (código 1).

---

## 8. Conclusión personal

[Redacta aquí 3–5 líneas con tus palabras sobre lo que aprendiste en la práctica: por qué es importante detectar ambigüedades, cómo los counterexamples ayudan a entender la causa real de un conflicto, y por qué reescribir la gramática es mejor que silenciar advertencias.]

---

## 9. Evidencias generadas

- `evidencias/00_versiones.txt`
- `evidencias/01_inicial.output` y `evidencias/01_inicial.txt`
- `evidencias/02_precedencia.output` y `evidencias/02_precedencia.txt`
- `evidencias/03_else_resuelto.output` y `evidencias/03_else_resuelto.txt`
- `evidencias/04_final.output` y `evidencias/04_final.txt`
- `evidencias/05_pruebas.txt`

---

## 10. Commits realizados

```
A05: estructura inicial y versiones
A05: reproducir cinco conflictos sintacticos
A05: resolver precedencia y asociatividad
A05: reescribir dangling else
A05: validar compilación y pruebas
A05: README y producto final
```