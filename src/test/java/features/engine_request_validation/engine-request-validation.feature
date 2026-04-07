Feature: HU-11 - Validación de request en el motor de cálculo

  Background:
    * def setup      = callonce read('classpath:common/engine-setup.feature')
    * def utils      = setup.utils
    * configure url  = engineBaseUrl
    * def enginePath = setup.enginePath
    * def validApiKey = setup.validApiKey
    * def basePayload = setup.basePayload

  Scenario: TC-057 R1 - API Key válida + carrito válido + descuentos aplicables retorna HTTP 200
    * copy payload = basePayload
    * set payload.externalOrderId = 'TC057R1-' + utils.uuid()
    * set payload.items = [{ productId: 'PROD-R1', quantity: 2, unitPrice: 100.00, category: 'GENERAL' }]
    Given path enginePath
    And header x-api-key = validApiKey
    And request payload
    When method POST
    Then status 200
    And match response.subtotalAmount == 200.00
    And match response.finalAmount == '#number'
    And match response.discountApplied == '#number'
    And assert response.finalAmount <= response.subtotalAmount
    And match response.customerTier == '#string'

  Scenario: TC-057 R2 - Sin API Key retorna HTTP 401
    Given path enginePath
    And request basePayload
    When method POST
    Then status 401

  Scenario: TC-057 R3 - Sin campo items retorna HTTP 400
    Given path enginePath
    And header x-api-key = validApiKey
    And request read('classpath:data/engine/calculate-no-items.json')
    When method POST
    Then status 400

  Scenario: TC-057 R4 - Carrito válido con cliente nuevo retorna HTTP 200 con descuento calculado
    * copy payload = basePayload
    * set payload.externalOrderId = 'TC057R4-' + utils.uuid()
    * set payload.customerId = 'NEW-CUST-NO-DISCOUNT'
    * set payload.totalSpent = 0
    * set payload.orderCount = 0
    * set payload.membershipDays = 0
    * set payload.items = [{ productId: 'PROD-NODSC', quantity: 1, unitPrice: 200.00, category: 'UNCATEGORIZED' }]
    Given path enginePath
    And header x-api-key = validApiKey
    And request payload
    When method POST
    Then status 200
    And match response.subtotalAmount == 200.00
    And match response.finalAmount == '#number'
    And assert response.finalAmount <= response.subtotalAmount
    And assert response.finalAmount >= 0
    And match response.customerTier == '#string'
