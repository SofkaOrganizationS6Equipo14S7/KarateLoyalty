# Documentación — Buenas Prácticas en Karate

Guía de referencia para crear y mantener proyectos de automatización con Karate desde cero.

---

## Índice

1. [Estructura de proyecto recomendada](#1-estructura-de-proyecto-recomendada)
2. [Nomenclatura de archivos](#2-nomenclatura-de-archivos)
3. [karate-config.js — Configuración global](#3-karate-configjs--configuración-global)
4. [Utilidades comunes](#4-utilidades-comunes)
5. [Organización de datos de prueba](#5-organización-de-datos-de-prueba)
6. [Buenas prácticas en feature files](#6-buenas-prácticas-en-feature-files)
7. [Errores comunes (pitfalls)](#7-errores-comunes-pitfalls)
8. [Anti-patrones a evitar](#8-anti-patrones-a-evitar)
9. [Performance y ejecución paralela](#9-performance-y-ejecución-paralela)
10. [Runners — Ejecución de tests](#10-runners--ejecución-de-tests)

---

## 1. Estructura de proyecto recomendada

![alt text](image.png)

Organizar por **responsabilidad**, no por tipo de archivo:

```
src/test/java/
├── karate-config.js              # Configuración global (mínima)
├── logback-test.xml              # Configuración de logging
├── ExamplesTest.java             # Runner paralelo principal
├── common/
│   └── common-utils.feature     # Utilidades reutilizables (@ignore)
├── data/
│   └── users/                   # Datos organizados por dominio
│       ├── create-user.json
│       └── update-user.json
└── features/
    └── users/                   # Feature + Runner juntos por dominio
        ├── create-user.feature
        ├── CreateUserRunner.java
        ├── get-user.feature
        ├── GetUserRunner.java
        ├── update-user.feature
        ├── UpdateUserRunner.java
        ├── delete-user.feature
        └── DeleteUserRunner.java
```

**Reglas clave:**
- `data/` y `common/` son recursos compartidos → separados de `features/`
- Cada Runner vive al lado del feature que ejecuta
- El runner paralelo (`ExamplesTest.java`) vive en la raíz y escanea `classpath:features`

---

## 2. Nomenclatura de archivos

| Tipo de archivo | Convención | Ejemplo |
|---|---|---|
| Feature files | `kebab-case` | `create-user.feature` |
| JSON de datos | `kebab-case` | `create-user.json` |
| Archivos JS | `kebab-case` | `common-utils.feature` |
| Clases Java (Runners) | `PascalCase` | `CreateUserRunner.java` |
| Clases Java (Tests) | `PascalCase` | `ExamplesTest.java` |

> **Regla:** kebab-case para todo recurso de Karate, PascalCase exclusivamente para clases Java.

---

## 3. karate-config.js — Configuración global

Mantener **mínimo**. Esta función corre antes de **cada escenario**, por lo que código costoso aquí penaliza toda la suite.

```javascript
// ✅ CORRECTO — Solo configuración liviana
function fn() {
  var env = karate.env || 'dev';
  var config = {
    baseUrl: 'https://mi-api.com'
  };
  if (env == 'e2e') {
    config.baseUrl = 'https://staging.mi-api.com';
  }
  return config;
}

// ❌ INCORRECTO — Operaciones costosas en config global
function fn() {
  var config = { baseUrl: 'https://mi-api.com' };
  config.token = karate.call('classpath:auth/get-token.feature').token; // lento x cada escenario
  config.data  = karate.read('classpath:data/large-dataset.json');       // lento x cada escenario
  return config;
}
```

> Mover setup costoso (auth, seed de datos) a `callonce` dentro del `Background` del feature.

---

## 4. Utilidades comunes

Crear un archivo `common/common-utils.feature` marcado con `@ignore` para que no se ejecute como test independiente:

```gherkin
@ignore
Feature: Common utility functions

  Scenario: Utility library
    * def uuid      = function(){ return java.util.UUID.randomUUID() + '' }
    * def timestamp = function(){ return java.lang.System.currentTimeMillis() + '' }
    * def randomInt = function(max){ return Math.floor(Math.random() * max) }
    * def sleep     = function(ms){ java.lang.Thread.sleep(ms) }

    * def formatDate =
      """
      function(pattern) {
        var SimpleDateFormat = Java.type('java.text.SimpleDateFormat');
        var sdf = new SimpleDateFormat(pattern || 'yyyy-MM-dd');
        return sdf.format(new java.util.Date());
      }
      """
```

Importar en Features usando un **namespace aislado**:

```gherkin
Background:
  * def utils = call read('classpath:common/common-utils.feature')

Scenario: Ejemplo
  * def id   = utils.uuid()
  * def date = utils.formatDate('yyyy-MM-dd')
```

> `call read()` con asignación crea un namespace aislado, evitando contaminar el scope del feature.

---

## 5. Organización de datos de prueba

- Organizar por **dominio** (`data/users/`, `data/products/`) en lugar de por feature.
- Siempre referenciar con `classpath:` para rutas estables que no se rompan al mover archivos.
- Usar `karate.copy()` al leer datos desde archivo para no mutar el caché compartido.

```gherkin
# ✅ CORRECTO
* def user = karate.copy(read('classpath:data/users/create-user.json'))
* set user.email = 'nuevo@email.com'   # no afecta el archivo original

# ❌ INCORRECTO — modifica el objeto cacheado
* def user = read('classpath:data/users/create-user.json')
* set user.email = 'nuevo@email.com'   # contamina otros escenarios
```

---

## 6. Buenas prácticas en feature files

### configure url vs url

```gherkin
# ✅ CORRECTO — persiste al hacer 'call' a otros features
* configure url = baseUrl

# ❌ INCORRECTO — se resetea al llamar otros features
* url baseUrl
```

### callonce para setup costoso

```gherkin
Background:
  # Corre UNA sola vez por feature y cachea el resultado
  * def auth     = callonce read('classpath:auth/get-token.feature')
  * def testData = callonce read('classpath:setup/seed-data.feature')
```

### Rutas siempre con classpath:

```gherkin
# ✅ CORRECTO — funciona sin importar dónde esté el feature
* def utils = call read('classpath:common/common-utils.feature')

# ❌ INCORRECTO — se rompe si se mueve el archivo
* def utils = call read('../../common/common-utils.feature')
```

### Datos únicos para ejecución paralela

```gherkin
Scenario: Crear usuario
  * def uniqueEmail = 'test+' + utils.uuid() + '@example.com'
  # Cada ejecución paralela usa un email distinto → sin conflictos
```

---

## 7. Errores comunes (pitfalls)

### 7.1 Pass-by-reference

En JavaScript (y Karate), los objetos se asignan **por referencia**:

```gherkin
* def original = { role: 'admin' }
* def copia    = original          # NO es una copia, apunta al mismo objeto
* set copia.role = 'user'
* match original.role == 'user'    # ⚠️ original también cambió
```

**Solución:** usar `karate.copy()`:

```gherkin
* def copia = karate.copy(original)
* set copia.role = 'user'
* match original.role == 'admin'   # ✅ original intacto
```

### 7.2 Background se re-ejecuta antes de CADA escenario

```gherkin
Background:
  * def counter = 0   # se reinicia en cada escenario

Scenario: Primero
  * set counter = counter + 1
  * match counter == 1

Scenario: Segundo
  * match counter == 0   # counter vuelve a 0, no es 1
```

> Para estado compartido entre escenarios usar `callonce` o `karate.callSingle()`.

### 7.3 Números grandes pierden precisión

JavaScript maneja enteros hasta `2^53 - 1`. IDs más grandes deben ser strings:

```gherkin
# ❌ INCORRECTO — JavaScript redondea silenciosamente
* def id = 9007199254740993

# ✅ CORRECTO
* def id = '9007199254740993'
```

### 7.4 karate.stop() NUNCA en commits

`karate.stop(port)` pausa la ejecución indefinidamente esperando una conexión. Si se commitea, **bloquea el pipeline CI/CD para siempre**.

---

## 8. Anti-patrones a evitar

| Anti-patrón | Problema | Solución |
|---|---|---|
| URLs hardcodeadas en features | Se rompe al cambiar entorno | Usar `baseUrl` de `karate-config.js` |
| Mismos datos repetidos en cada escenario | Difícil de mantener | Centralizar en `data/` y usar `karate.copy()` |
| Lógica compleja en JavaScript inline | Difícil de debuggear y testear | Moverla a una clase Java estática |
| `karate-config.js` con auth o datos | Lento, corre antes de CADA escenario | Usar `callonce` en el feature |
| Rutas relativas (`../../file.json`) | Se rompen al mover archivos | Usar siempre `classpath:` |
| Exceso de abstracción en features reusables | Tests incomprensibles, requieren leer 5 archivos | Aceptar algo de duplicación si mejora la legibilidad |

---

## 9. Performance y ejecución paralela

### Runner paralelo principal

```java
// ExamplesTest.java
Results results = Runner.path("classpath:features")
    .parallel(5);  // 5 hilos en paralelo
```

### Garantizar independencia entre escenarios

- Cada escenario genera sus propios datos únicos (UUIDs, emails con timestamp)
- No compartir estado mutable entre escenarios
- No depender del orden de ejecución

### Minimizar I/O de archivos

```gherkin
Background:
  # ✅ Leer una vez en Background, reutilizar en todos los escenarios
  * def testData = read('classpath:data/users/create-user.json')

Scenario Outline: Test con datos
  * def item = karate.copy(testData)
  * set item.email = utils.uuid() + '@test.com'
```

---

## 10. Runners — Ejecución de tests

### Runner individual (por feature)

```java
public class CreateUserRunner {
    @Karate.Test
    Karate test() {
        return Karate.run("create-user").relativeTo(getClass());
    }
}
```

### Runner paralelo (toda la suite)

```java
class ExamplesTest {
    @Test
    void testParallel() {
        Results results = Runner.path("classpath:features")
                .parallel(5);
        assertEquals(0, results.getFailCount(), results.getErrorMessages());
    }
}
```

### Ejecutar desde línea de comandos

```bash
# Toda la suite
mvn clean test

# Un runner específico
mvn clean test -Dtest=CreateUserRunner

# Con entorno específico
mvn clean test -Dkarate.env=e2e
```

---

## Checklist — Nuevo proyecto desde cero

- [ ] Crear estructura de carpetas: `common/`, `data/<dominio>/`, `features/<dominio>/`
- [ ] Configurar `karate-config.js` con solo `baseUrl` y variables de entorno
- [ ] Crear `common/common-utils.feature` con `@ignore` (uuid, timestamp, etc.)
- [ ] Nombrar todos los recursos en `kebab-case`, clases Java en `PascalCase`
- [ ] Usar `configure url = baseUrl` (no `url baseUrl`) en todos los features
- [ ] Usar `classpath:` en todas las rutas (nunca rutas relativas)
- [ ] Usar `karate.copy()` al mutar datos leídos de archivo
- [ ] Usar `callonce` para setup costoso (auth, seed) en el `Background`
- [ ] Generar datos únicos (UUID/timestamp) para seguridad en ejecución paralela
- [ ] Verificar que no quede ningún `karate.stop()` antes de commitear
