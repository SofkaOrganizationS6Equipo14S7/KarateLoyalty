Feature: HU-05 - Autenticación del motor de cálculo

  Background:
    * configure url = engineBaseUrl
    * def enginePath = '/api/v1/discounts/calculate'
    * def keySetup = callonce read('classpath:common/create-api-key.feature')
    * def validApiKey = keySetup.apiKey

  Scenario: TC-035 Iter 1 - API Key válida retorna HTTP 200
    * configure retry = { count: 10, interval: 500 }
    Given path enginePath
    And header x-api-key = validApiKey
    And request read('classpath:data/engine/calculate-request.json')
    And retry until responseStatus == 200
    When method POST
    Then status 200
    And match response.classification.tierName == '#string'

  Scenario: TC-035 Iter 2 - API Key inválida retorna HTTP 401
    Given path enginePath
    And header x-api-key = 'INVALID-KEY-000'
    And request read('classpath:data/engine/calculate-request.json')
    When method POST
    Then status 401
    And match response contains { error: '#string' }
