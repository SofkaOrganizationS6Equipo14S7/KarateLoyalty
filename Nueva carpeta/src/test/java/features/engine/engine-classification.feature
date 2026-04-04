Feature: HU-10 - Clasificación de fidelidad en el motor de cálculo

  Background:
    * url engineBaseUrl
    * def enginePath = '/api/v1/engine/calculate'

  Scenario Outline: TC-046 - totalCompras=<totalCompras> clasifica en nivel '<expectedNivel>'
    Given path enginePath
    And header x-api-key = validApiKey
    And request { idCliente: 'CLI-BORDER', totalCompras: <totalCompras>, montoTotalGastado: 100.00, mesesComoCliente: 1 }
    When method POST
    Then status 200
    And match response.nivel == '<expectedNivel>'

    Examples:
      | totalCompras | expectedNivel |
      | 0            | Bronce        |
      | 5            | Bronce        |
      | 10           | Bronce        |
      | 11           | Plata         |
      | 30           | Plata         |
      | 50           | Plata         |
      | 51           | Oro           |
      | 75           | Oro           |

  Scenario Outline: TC-049 - Payload inválido (<escenario>) retorna HTTP 400 sin nivel
    Given path enginePath
    And header x-api-key = validApiKey
    And request <payload>
    When method POST
    Then status 400
    And match response !contains { nivel: '#notnull' }

    Examples:
      | escenario                    | payload                                       |
      | Sin totalCompras             | { idCliente: 'CLI-008' }                      |
      | Sin idCliente                | { totalCompras: 10 }                          |
      | Payload vacío                | {}                                            |
      | totalCompras es null         | { idCliente: 'CLI-NULL', totalCompras: null }  |
      | totalCompras negativo        | { idCliente: 'CLI-007', totalCompras: -1 }    |

  Scenario: TC-051 - Mismo payload produce nivel Plata en dos llamadas consecutivas (determinismo)
    * def payload = read('classpath:data/engine/calculate-request.json')

    Given path enginePath
    And header x-api-key = validApiKey
    And request payload
    When method POST
    Then status 200
    And match response.nivel == 'Plata'
    * def nivelPrimeraLlamada = response.nivel
    Given path enginePath
    And header x-api-key = validApiKey
    And request payload
    When method POST
    Then status 200
    And match response.nivel == nivelPrimeraLlamada