Feature: Engine Calculate Service - Clasificación de Nivel de Lealtad (TC-053 a TC-061)

  Background:
    * url engineBaseUrl
    * def calcPath = '/api/v1/engine/calculate'

  @TC-053 @HU-05 @critico
  Scenario: TC-053 - POST calculate con API Key válida retorna HTTP 200 y cuerpo con campos de descuento
    * def payload = read('classpath:data/engine/calculate-request.json')

    Given path calcPath
    And header x-api-key = validApiKey
    And request payload
    When method POST
    Then status 200
    And match response contains { nivel: '#string', descuento: '#number', idCliente: '#string' }

  # ---------------------------------------------------------------------------
  # HU-05 | TC-054 | API Key inválida → HTTP 401 sin datos de descuento
  # ---------------------------------------------------------------------------
  @TC-054 @HU-05 @critico
  Scenario: TC-054 - POST calculate con API Key inválida retorna HTTP 401 Unauthorized
    * def payload = read('classpath:data/engine/calculate-request.json')

    Given path calcPath
    And header x-api-key = 'INVALID-KEY-000'
    And request payload
    When method POST
    Then status 401
    And match response !contains { nivel: '#present' }

  # ---------------------------------------------------------------------------
  # HU-10 | TC-055 | Valores de frontera Bronce/Plata/Oro → nivel correcto
  # ---------------------------------------------------------------------------
  @TC-055 @HU-10 @critico
  Scenario Outline: TC-055 - Clasificación en valores exactos de frontera entre niveles
    * def payload =
      """
      {
        "idCliente"          : "CLI-005",
        "totalCompras"       : <totalCompras>,
        "montoTotalGastado"  : 500.00,
        "mesesComoCliente"   : 12
      }
      """

    Given path calcPath
    And header x-api-key = validApiKey
    And request payload
    When method POST
    Then status 200
    And match response.nivel == '<nivelEsperado>'

    Examples:
      | totalCompras | nivelEsperado |
      | 10           | Bronce        |
      | 11           | Plata         |
      | 50           | Plata         |
      | 51           | Oro           |

  # ---------------------------------------------------------------------------
  # HU-10 | TC-056 | totalCompras=0 → HTTP 200 nivel Bronce (valor mínimo)
  # ---------------------------------------------------------------------------
  @TC-056 @HU-10 @alto
  Scenario: TC-056 - POST con totalCompras=0 retorna HTTP 200 con nivel Bronce
    * def payload =
      """
      {
        "idCliente"         : "CLI-006",
        "totalCompras"      : 0,
        "montoTotalGastado" : 0.00,
        "mesesComoCliente"  : 0
      }
      """

    Given path calcPath
    And header x-api-key = validApiKey
    And request payload
    When method POST
    Then status 200
    And match response.nivel == 'Bronce'

  # ---------------------------------------------------------------------------
  # HU-10 | TC-057 | totalCompras=-1 → HTTP 400 sin campo nivel
  # ---------------------------------------------------------------------------
  @TC-057 @HU-10 @critico
  Scenario: TC-057 - POST con totalCompras negativo retorna HTTP 400 sin campo nivel
    * def payload =
      """
      {
        "idCliente"    : "CLI-007",
        "totalCompras" : -1
      }
      """

    Given path calcPath
    And header x-api-key = validApiKey
    And request payload
    When method POST
    Then status 400
    And match response !contains { nivel: '#present' }

  # ---------------------------------------------------------------------------
  # HU-10 | TC-058 | Campos obligatorios omitidos → HTTP 400 por cada caso
  # ---------------------------------------------------------------------------
  @TC-058 @HU-10 @critico
  Scenario Outline: TC-058 - POST sin campo obligatorio <campoFaltante> retorna HTTP 400
    Given path calcPath
    And header x-api-key = validApiKey
    And request <payload>
    When method POST
    Then status 400
    And match response !contains { nivel: '#present' }

    Examples:
      | campoFaltante | payload                                                                           |
      | totalCompras  | { idCliente: 'CLI-008', montoTotalGastado: 100.00, mesesComoCliente: 6 }         |
      | idCliente     | { totalCompras: 20, montoTotalGastado: 100.00, mesesComoCliente: 6 }             |
      | todos (vacío) | {}                                                                                |

  # ---------------------------------------------------------------------------
  # HU-10 | TC-059 | Múltiples valores válidos → nivel correcto por cada uno
  # ---------------------------------------------------------------------------
  @TC-059 @HU-10 @critico
  Scenario Outline: TC-059 - Clasificación correcta en Bronce, Plata y Oro para valores representativos
    * def payload =
      """
      {
        "idCliente"         : "CLI-009",
        "totalCompras"      : <totalCompras>,
        "montoTotalGastado" : 500.00,
        "mesesComoCliente"  : 12
      }
      """

    Given path calcPath
    And header x-api-key = validApiKey
    And request payload
    When method POST
    Then status 200
    And match response.nivel == '<nivelEsperado>'

    Examples:
      | totalCompras | nivelEsperado |
      | 5            | Bronce        |
      | 30           | Plata         |
      | 75           | Oro           |

  @TC-059 @HU-10 @critico
  Scenario: TC-059 - POST con totalCompras=null retorna HTTP 400 sin campo nivel
    * def payload =
      """
      {
        "idCliente"         : "CLI-009",
        "totalCompras"      : null,
        "montoTotalGastado" : 500.00,
        "mesesComoCliente"  : 12
      }
      """

    Given path calcPath
    And header x-api-key = validApiKey
    And request payload
    When method POST
    Then status 400
    And match response !contains { nivel: '#present' }

  # ---------------------------------------------------------------------------
  # HU-08 / HU-10 | TC-060 | Determinismo: mismo payload → misma respuesta
  # ---------------------------------------------------------------------------
  @TC-060 @HU-08 @HU-10 @critico
  Scenario: TC-060 - Determinismo: dos POST idénticos retornan HTTP 200 con nivel Plata
    * def payload =
      """
      {
        "idCliente"         : "CLI-001",
        "totalCompras"      : 25,
        "montoTotalGastado" : 1500.00,
        "mesesComoCliente"  : 18
      }
      """

    # Primera llamada
    Given path calcPath
    And header x-api-key = validApiKey
    And request payload
    When method POST
    Then status 200
    And match response.nivel == 'Plata'
    * def primeraRespuesta = response

    # Segunda llamada con el mismo payload
    Given path calcPath
    And header x-api-key = validApiKey
    And request payload
    When method POST
    Then status 200
    And match response.nivel == 'Plata'
    And match response.nivel == primeraRespuesta.nivel

  # ---------------------------------------------------------------------------
  # HU-10 | TC-061 | Sincronización de caché via RabbitMQ → nivel Oro disponible
  # ---------------------------------------------------------------------------
  @TC-061 @HU-10 @critico
  Scenario: TC-061 - Actualización de matriz via Admin Service sincroniza caché del Engine mediante RabbitMQ
    * def payloadClasificacion =
      """
      {
        "idCliente"         : "CLI-010",
        "totalCompras"      : 60,
        "montoTotalGastado" : 3000.00,
        "mesesComoCliente"  : 24
      }
      """
    * def matrizActualizada =
      """
      [
        { "nivel": "Bronce", "min": 0,  "max": 10     },
        { "nivel": "Plata",  "min": 11, "max": 50     },
        { "nivel": "Oro",    "min": 51, "max": 999999 }
      ]
      """

    # Paso 1: Verificar que con la caché inicial (sin Oro) totalCompras=60 aún no clasifica como Oro
    Given path calcPath
    And header x-api-key = validApiKey
    And request payloadClasificacion
    When method POST
    Then status 200
    And match response.nivel != 'Oro'

    # Paso 2: Actualizar la matriz en el Admin Service añadiendo nivel Oro [51+]
    Given url adminBaseUrl
    And path '/api/v1/fidelity/ranges'
    And header x-api-key = validApiKey
    And request matrizActualizada
    When method PUT
    Then status 200

    # Paso 3: Esperar propagación del evento RabbitMQ al Engine (reintentos automáticos)
    * configure retry = { count: 6, interval: 2000 }

    # Paso 4: Verificar que la caché del Engine fue actualizada y clasifica totalCompras=60 como Oro
    Given url engineBaseUrl
    And path calcPath
    And header x-api-key = validApiKey
    And request payloadClasificacion
    And retry until response.nivel == 'Oro'
    When method POST
    Then status 200
    And match response.nivel == 'Oro'
