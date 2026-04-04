Feature: HU-10 - Clasificación de fidelidad en el motor de cálculo

  Background:
    * configure url = engineBaseUrl
    * def enginePath = '/api/v1/discounts/calculate'
    * def keySetup = callonce read('classpath:common/create-api-key.feature')
    * def validApiKey = keySetup.apiKey

  Scenario Outline: TC-046 - totalSpent=<totalSpent>, orderCount=<orderCount> clasifica en tier '<expectedTier>'
    * def basePayload = read('classpath:data/engine/calculate-request.json')
    * copy payload = basePayload
    * set payload.totalSpent = <totalSpent>
    * set payload.orderCount = <orderCount>
    Given path enginePath
    And header x-api-key = validApiKey
    And request payload
    When method POST
    Then status 200
    And match response.classification.tierName == '<expectedTier>'

    Examples:
      | totalSpent | orderCount | expectedTier |
      | 50         | 2          | Bronze       |
      | 99         | 0          | Bronze       |
      | 300        | 10         | Silver       |
      | 400        | 5          | Silver       |
      | 1500       | 25         | Gold         |
      | 1000       | 50         | Gold         |
      | 3000       | 60         | Platinum     |
      | 5000       | 100        | Platinum     |

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

  Scenario: TC-051 - Mismo payload produce tier Gold en dos llamadas consecutivas (determinismo)
    * def payload = read('classpath:data/engine/calculate-request.json')

    Given path enginePath
    And header x-api-key = validApiKey
    And request payload
    When method POST
    Then status 200
    And match response.classification.tierName == 'Gold'
    * def tierPrimeraLlamada = response.classification.tierName
    Given path enginePath
    And header x-api-key = validApiKey
    And request payload
    When method POST
    Then status 200
    And match response.classification.tierName == tierPrimeraLlamada