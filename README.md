# Proyecto del I Bimestre · Analizador léxico de MiniLang

**Grupo N.º:** _N_
**Integrantes y responsabilidades:**

| Integrante | Responsabilidad principal |
|---|---|
| _Apellido Nombre_ | _por ejemplo: errores E5 y E6_ |
| _Apellido Nombre_ | _por ejemplo: tabla de símbolos_ |
| _Apellido Nombre_ | _por ejemplo: pruebas y Makefile_ |
| _Apellido Nombre_ | _por ejemplo: informe_ |

## Cómo compilar y probar

```
make            # genera ./minilang
./minilang pruebas/p1_correcto.ml
make pruebas    # compara cada salida con esperadas/
```

En Google Colab: `!apt-get -qq install -y flex` y luego `!make pruebas`.

## Programas de prueba

| Archivo | Qué prueba |
|---|---|
| `pruebas/p1_correcto.ml` | _programa sin errores_ |
| `pruebas/p2_…ml` | _…_ |
| `pruebas/p3_…ml` | _…_ |
| `pruebas/p4_…ml` | _…_ |

## Decisiones de diseño

_Explique brevemente el orden de las reglas, cómo detectan E5 y E6 y la estructura de la tabla de símbolos._
