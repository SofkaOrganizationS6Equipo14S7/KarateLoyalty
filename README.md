# KarateLoyalty

Suite de tests automatizados con **Karate 1.5.0** para las APIs REST del sistema de fidelización (loyalty-admin + engine de descuentos).

## Requisitos previos

- **Java 11** o superior
- **Maven 3.8+**
- Servicios corriendo en local:
  - `loyalty-admin` en `http://localhost:8081`
  - `loyalty-engine` en `http://localhost:8082`

## Estructura del proyecto

```
src/test/java/
├── karate-config.js              # Configuración global (baseUrls, credenciales)
├── logback-test.xml              # Configuración de logging
├── ExamplesTest.java             # Runner paralelo principal (5 hilos)
├── common/                       # Helpers reutilizables (@ignore)
│   ├── common-utils.feature      # Funciones utilitarias (uuid, timestamp)
│   ├── auth-helper.feature       # Autenticación condicional
│   ├── login.feature             # Login y obtención de token
│   ├── create-api-key.feature    # Creación de API Key para el engine
│   ├── create-loyalty-user.feature
│   ├── create-store-admin.feature
│   ├── create-store-user.feature
│   └── create-rule.feature       # Creación genérica de reglas
├── data/                         # Datos de prueba organizados por dominio
│   ├── discount-config/
│   ├── engine/
│   ├── product-rules/
│   ├── seasonal-rules/
│   ├── store-admin/
│   ├── user-profile/
│   └── users/
└── features/                     # Features + Runners por dominio
    ├── auth/                     # HU-01: Autenticación
    ├── users/                    # HU-02: Gestión de usuarios
    ├── store_admin/              # HU-03: Restricciones STORE_ADMIN
    ├── user_profile/             # HU-04: Perfil de usuario
    ├── engine/                   # HU-05, HU-10: Engine auth + clasificación
    ├── seasonal_rules/           # HU-06: Reglas de temporada
    ├── product_rules/            # HU-07: Reglas por producto
    └── discount_config/          # HU-09: Configuración de descuentos
```

## Ejecución

### Toda la suite (paralelo, 5 hilos)

```bash
mvn clean test
```

### Un feature específico por runner

```bash
mvn clean test -Dtest=AuthRunner
mvn clean test -Dtest=UsersRunner
mvn clean test -Dtest=EngineClassificationRunner
```

### Con entorno específico

```bash
mvn clean test -Dkarate.env=e2e
```

### Con credenciales personalizadas

```bash
mvn clean test -Dadmin.user=admin -Dadmin.pass=admin123
```

## Reportes

Después de la ejecución, los reportes se generan en:

```
target/karate-reports/karate-summary.html
```

Abrir `karate-summary.html` en el navegador para ver el resumen visual con detalle por feature y escenario.

## Cobertura de HUs

| Feature | HU | Escenarios |
|---|---|---|
| auth | HU-01 | TC-022, TC-023, TC-024 |
| users | HU-02 | TC-025, TC-026, TC-027, TC-028 |
| store_admin | HU-03 | TC-029, TC-030, TC-031 |
| user_profile | HU-04 | TC-032, TC-033, TC-034 |
| engine (auth) | HU-05 | TC-035 |
| seasonal_rules | HU-06 | TC-036, TC-038, TC-039, TC-040 |
| product_rules | HU-07 | TC-041, TC-042, TC-043 |
| discount_config | HU-09 | TC-058 |
| engine (classification) | HU-10 | TC-046, TC-049, TC-051 |