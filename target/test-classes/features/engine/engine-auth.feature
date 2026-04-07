Feature: HU-05 - Autenticación del motor de cálculo

  Background:
    * configure url = engineBaseUrl
    * def enginePath = '/api/v1/engine/calculate'
    * def keySetup = callonce read('classpath:common/create-api-key.feature')
    * def validApiKey = keySetup.apiKey
    * def basePayload = read('classpath:data/engine/calculate-request.json')

  Scenario: TC-035 Iter 1 - API Key válida retorna HTTP 200
    * copy payload = basePayload
    * set payload.externalOrderId = java.util.UUID.randomUUID() + ''
    Given path enginePath
    And header x-api-key = validApiKey
    And request payload
    When method POST
    Then status 200
    And match response.customerTier == '#string'

  Scenario: TC-035 Iter 2 - API Key inválida retorna HTTP 401
    * copy payload = basePayload
    * set payload.externalOrderId = java.util.UUID.randomUUID() + ''
    Given path enginePath
    And header x-api-key = 'INVALID-KEY-000'
    And request payload
    When method POST
    Then status 401
    And match response contains { error: '#string' }
