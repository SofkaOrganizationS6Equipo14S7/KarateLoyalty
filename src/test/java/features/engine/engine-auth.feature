Feature: HU-05 - Autenticación del motor de cálculo

  Background:
    * configure url = engineBaseUrl
    * def enginePath = '/api/v1/engine/calculate'

  Scenario Outline: TC-036 - <escenario>: API Key '<apiKeyLabel>' retorna HTTP <expectedStatus>
    Given path enginePath
    And header x-api-key = '<apiKey>'
    And request read('classpath:data/engine/calculate-request.json')
    When method POST
    Then status <expectedStatus>
    * if (responseStatus == 200) match response.nivel == '#string'
    * if (responseStatus != 200) match response !contains { nivel: '#notnull' }

    Examples:
      | escenario                | apiKeyLabel | apiKey          | expectedStatus |
      | Iter 1 - API Key válida  | VALID       | #(validApiKey)  | 200            |
      | Iter 2 - API Key inválida| INVALID     | INVALID-KEY-000 | 401            |
