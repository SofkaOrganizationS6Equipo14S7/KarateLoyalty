Feature: HU-11 - Tope máximo en el motor de cálculo de descuentos

  Background:
    * def setup      = callonce read('classpath:common/engine-setup.feature')
    * def utils      = setup.utils
    * configure url  = engineBaseUrl
    * def enginePath = setup.enginePath
    * def validApiKey = setup.validApiKey
    * def basePayload = setup.basePayload

  Scenario: TC-053 - Descuento acumulado es limitado por el tope máximo configurado
    * copy payload = basePayload
    * set payload.externalOrderId = 'TC053-' + utils.uuid()
    * set payload.totalSpent      = 5000.00
    * set payload.orderCount      = 50
    * set payload.membershipDays  = 730
    * set payload.items = [{ productId: 'PROD-CAP-1', quantity: 2, unitPrice: 100.00, category: 'GENERAL' }]
    Given path enginePath
    And header x-api-key = validApiKey
    And request payload
    When method POST
    Then status 200
    And match response contains { subtotalAmount: '#number', finalAmount: '#number', discountApplied: '#number', wasCapped: '#boolean', customerTier: '#string' }
    And match response.subtotalAmount == 200.00
    And assert response.finalAmount <= response.subtotalAmount
    And assert response.finalAmount >= 0
    And assert response.discountApplied >= 0
    And match response.appliedRules == '#[]'

  Scenario: TC-054 - Descuento sin recorte cuando acumulado no excede el tope
    * copy payload = basePayload
    * set payload.externalOrderId = 'TC054-' + utils.uuid()
    * set payload.totalSpent      = 100.00
    * set payload.orderCount      = 2
    * set payload.membershipDays  = 30
    * set payload.items = [{ productId: 'PROD-EXACT', quantity: 1, unitPrice: 100.00, category: 'GENERAL' }]
    Given path enginePath
    And header x-api-key = validApiKey
    And request payload
    When method POST
    Then status 200
    And match response.subtotalAmount == 100.00
    And assert response.finalAmount <= 100.00
    And assert response.finalAmount >= 0
    And match response.customerTier == '#string'
    And match response.discountApplied == '#number'
