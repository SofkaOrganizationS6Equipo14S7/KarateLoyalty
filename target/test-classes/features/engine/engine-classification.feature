Feature: HU-10 - Validación del motor de cálculo

  Background:
    * def configSetup = callonce read('classpath:common/setup-engine-config.feature')
    * configure url = engineBaseUrl
    * def enginePath = '/api/v1/engine/calculate'
    * def keySetup = callonce read('classpath:common/create-api-key.feature')
    * def validApiKey = keySetup.apiKey

  Scenario Outline: TC-049 - Payload inválido (<escenario>) retorna HTTP 400
    Given path enginePath
    And header x-api-key = validApiKey
    And request <payload>
    When method POST
    Then status 400

    Examples:
      | escenario                    | payload                                                                             |
      | Sin orderCount               | { ecommerceId: '550e8400-e29b-41d4-a716-446655440000' }                             |
      | Sin ecommerceId              | { orderCount: 10 }                                                                  |
      | Payload vacío                | {}                                                                                  |
      | orderCount es null           | { ecommerceId: '550e8400-e29b-41d4-a716-446655440000', orderCount: null }           |
      | orderCount negativo          | { ecommerceId: '550e8400-e29b-41d4-a716-446655440000', orderCount: -1 }             |