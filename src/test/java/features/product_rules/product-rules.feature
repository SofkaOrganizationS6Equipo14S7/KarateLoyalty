Feature: HU-07 - Gestión de reglas por tipo de producto

  Background:
    * configure url = adminBaseUrl
    * def utils        = callonce read('classpath:common/common-utils.feature')
    * def loyaltyUser  = callonce read('classpath:common/create-store-admin.feature') { prefix: 'loyalty' }
    * def authHeader   = 'Bearer ' + loyaltyUser.authToken
    * def basePath     = '/api/v1/rules'

  Scenario: TC-041 - Crear regla con tipo nuevo retorna HTTP 201 y se puede consultar
    * def tipoProducto = 'TIPO-' + utils.uuid()
    * def rawPayload = read('classpath:data/product-rules/product-rule-base.json')
    * copy payload = rawPayload
    * set payload.name = 'Product Rule - ' + tipoProducto
    * def created = call read('classpath:common/create-rule.feature@create_rule') { authHeader: '#(authHeader)', payload: '#(payload)' }
    Given path basePath, created.ruleId
    And header Authorization = authHeader
    When method GET
    Then status 200
    And match response.name contains tipoProducto

  Scenario: TC-042 - Actualizar regla con descuento=100.01 retorna HTTP 400
    * def tipoProducto = 'TIPO-' + utils.uuid()
    * def rawPayload = read('classpath:data/product-rules/product-rule-base.json')
    * copy payload = rawPayload
    * set payload.name = 'Product Rule - ' + tipoProducto
    * def created = call read('classpath:common/create-rule.feature@create_rule') { authHeader: '#(authHeader)', payload: '#(payload)' }
    * def ruleId = created.ruleId
    * def updateBody = read('classpath:data/product-rules/update-discount-exceeded.json')
    Given path basePath, ruleId
    And header Authorization = authHeader
    And request updateBody
    When method PUT
    Then status 400
    Given path basePath, ruleId
    And header Authorization = authHeader
    When method GET
    Then status 200
    And match response.discountPercentage == 10

  Scenario: TC-043 - Eliminar regla retorna HTTP 204 y queda inactiva
    * def tipoProducto = 'TIPO-' + utils.uuid()
    * def rawPayload = read('classpath:data/product-rules/product-rule-delete.json')
    * copy payload = rawPayload
    * set payload.name = 'Product Rule - ' + tipoProducto
    * def created = call read('classpath:common/create-rule.feature@create_rule') { authHeader: '#(authHeader)', payload: '#(payload)' }
    * def ruleId = created.ruleId
    Given path basePath, ruleId
    And header Authorization = authHeader
    When method DELETE
    Then status 204
    Given path basePath, ruleId
    And header Authorization = authHeader
    When method GET
    Then status 200
    And match response.isActive == false