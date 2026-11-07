#!/usr/bin/env bash
set -u

fallos=0

probar() {
  archivo="$1"
  esperado="$2"
  if ./parser < "$archivo" >/dev/null 2>&1; then
    obtenido=0
  else
    obtenido=$?
  fi
  if [ "$obtenido" -eq "$esperado" ]; then
    echo "OK  $archivo -> $obtenido"
  else
    echo "FALLO  $archivo -> $obtenido; se esperaba $esperado"
    fallos=$((fallos + 1))
  fi
}

probar pruebas/01_precedencia.txt 0
probar pruebas/02_parentesis.txt 0
probar pruebas/03_else_cercano.txt 0
probar pruebas/04_else_doble.txt 0
probar pruebas/05_operador_invalido.txt 1
probar pruebas/06_else_sin_if.txt 1

test "$fallos" -eq 0