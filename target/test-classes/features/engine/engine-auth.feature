Feature: HU-05 - Autenticación del motor de cálculo

  Background:
    * def setup      = callonce read('classpath:common/engine-setup.feature')
    * def utils      = setup.utils
    * configure url  = engineBaseUrl
    * def enginePath = setup.enginePath
    * def validApiKey = setup.validApiKey
    * def basePayload = setup.basePayload

  Scenario: TC-035 Iter 1 - API Key válida retorna HTTP 200
    * copy payload = basePayload
    * set payload.externalOrderId = utils.uuid()
    Given path enginePath
    And header x-api-key = validApiKey
    And request payload
    When method POST
    Then status 200
    And match response.customerTier == '#string'

  Scenario: TC-035 Iter 2 - API Key inválida retorna HTTP 401
    * copy payload = basePayload
    * set payload.externalOrderId = utils.uuid()
    Given path enginePath
    And header x-api-key = 'INVALID-KEY-000'
    And request payload
    When method POST
    Then status 401
    And match response contains { error: '#string' }
