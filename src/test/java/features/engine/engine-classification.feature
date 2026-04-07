Feature: HU-10 - Validación del motor de cálculo

  Background:
    * def setup      = callonce read('classpath:common/engine-setup.feature')
    * configure url  = engineBaseUrl
    * def enginePath = setup.enginePath
    * def validApiKey = setup.validApiKey

  Scenario Outline: TC-049 - Payload inválido (<escenario>) retorna HTTP 400
    Given path enginePath
    And header x-api-key = validApiKey
    And request <payload>
    When method POST
    Then status 400

    Examples:
      | escenario                    | payload                                                                             |
      | Sin orderCount               | { ecommerceId: '#(validEcommerceId)' }                                               |
      | Sin ecommerceId              | { orderCount: 10 }                                                                  |
      | Payload vacío                | {}                                                                                  |
      | orderCount es null           | { ecommerceId: '#(validEcommerceId)', orderCount: null }                             |
      | orderCount negativo          | { ecommerceId: '#(validEcommerceId)', orderCount: -1 }                              |