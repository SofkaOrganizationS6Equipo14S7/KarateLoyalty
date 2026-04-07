Feature: HU-11 - Validación de precios en items del motor de cálculo

  Background:
    * def configSetup = callonce read('classpath:common/setup-engine-config.feature')
    * configure url   = engineBaseUrl
    * def enginePath  = '/api/v1/engine/calculate'
    * def keySetup    = callonce read('classpath:common/create-api-key.feature')
    * def validApiKey = keySetup.apiKey
    * def basePayload = read('classpath:data/engine/calculate-request.json')

  Scenario: TC-055 - Item con precio mínimo 0.01 es aceptado y calculado correctamente
    * copy payload = basePayload
    * set payload.externalOrderId = 'TC055-' + java.util.UUID.randomUUID()
    * set payload.customerId = 'CUST-LIM'
    * set payload.items = [{ productId: 'PROD-MIN', quantity: 1, unitPrice: 0.01, category: 'GENERAL' }]
    Given path enginePath
    And header x-api-key = validApiKey
    And request payload
    When method POST
    Then status 200
    And match response.subtotalAmount == 0.01
    And assert response.finalAmount >= 0
    And assert response.finalAmount <= 0.01

  Scenario: TC-056 - Item con precio negativo retorna HTTP 400
    * copy payload = basePayload
    * set payload.externalOrderId = 'TC056-' + java.util.UUID.randomUUID()
    * set payload.customerId = 'CUST-INV'
    * set payload.items = [{ productId: 'PROD-NEG', quantity: 1, unitPrice: -1.00, category: 'GENERAL' }]
    Given path enginePath
    And header x-api-key = validApiKey
    And request payload
    When method POST
    Then status 400
