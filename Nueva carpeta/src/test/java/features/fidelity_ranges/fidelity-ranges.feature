Feature: HU-08 - Configuración de rangos de fidelidad

  Background:
    * configure url = adminBaseUrl
    * def loyaltyLogin = callonce read('classpath:common/login.feature') loyaltyCredentials
    * def loyaltyToken = loyaltyLogin.authToken
    * def authHeader   = 'Bearer ' + loyaltyToken

  Scenario: TC-044 - Configurar rangos continuos válidos retorna HTTP 200 y queda activo
    Given path '/api/v1/fidelity-ranges'
    And header Authorization = authHeader
    And request read('classpath:data/fidelity-ranges/valid-ranges.json')
    When method PUT
    Then status 200
    Given path '/api/v1/fidelity-ranges'
    And header Authorization = authHeader
    When method GET
    Then status 200
    And match response[0] contains { nivel: 'Bronce', min: 0,  max: 10 }
    And match response[1] contains { nivel: 'Plata',  min: 11, max: 50 }
    And match response[2] contains { nivel: 'Oro',    min: 51           }

  Scenario Outline: TC-045 - <escenario> retorna HTTP <expectedStatus>
    Given path '/api/v1/fidelity-ranges'
    And header Authorization = authHeader
    And request read('classpath:data/fidelity-ranges/<requestFile>')
    When method PUT
    Then status <expectedStatus>

    Examples:
      | escenario                                    | requestFile          | expectedStatus |
      | Configuración continua y válida              | valid-ranges.json    | 200            |
      | Superposición entre Bronce y Plata           | overlap-ranges.json  | 400            |
      | Vacío entre Bronce (0-9) y Plata (15-50)     | gap-ranges.json      | 400            |
      | Orden invertido (Oro antes que Bronce/Plata) | reversed-ranges.json | 400            |
