Feature: HU-07 - Gestión de reglas por tipo de producto

  Background:
    * configure url = adminBaseUrl
    * def loyaltyLogin = callonce read('classpath:common/login.feature') loyaltyCredentials
    * def loyaltyToken = loyaltyLogin.authToken
    * def authHeader   = 'Bearer ' + loyaltyToken
    * def utils        = callonce read('classpath:features/product_rules/utils.feature')

  Scenario: TC-041 - Crear regla con tipo nuevo retorna HTTP 201; duplicado retorna HTTP 409
    * def tipoProducto = 'TIPO-' + utils.uuid()
    * def created = call read('classpath:features/product_rules/create-product-rule.feature@create_product_rule') { authHeader: '#(authHeader)', tipoProducto: '#(tipoProducto)', descuento: 100 }
    * match created.tipoProducto == tipoProducto
    * match created.descuento == 100
    Given path '/api/v1/product-rules'
    And header Authorization = authHeader
    And request { tipoProducto: '#(tipoProducto)', descuento: 50 }
    When method POST
    Then status 409

  Scenario: TC-042 - Actualizar regla con descuento=100.01 retorna HTTP 400
    * def tipoProducto = 'TIPO-' + utils.uuid()
    * def created = call read('classpath:features/product_rules/create-product-rule.feature@create_product_rule') { authHeader: '#(authHeader)', tipoProducto: '#(tipoProducto)', descuento: 10 }
    * def ruleId = created.ruleId
    * def originalDiscount = created.descuento
    Given path '/api/v1/product-rules/' + ruleId
    And header Authorization = authHeader
    And request { descuento: 100.01 }
    When method PUT
    Then status 400
    Given path '/api/v1/product-rules/' + ruleId
    And header Authorization = authHeader
    When method GET
    Then status 200
    And match response.descuento == originalDiscount

  Scenario: TC-043 - Eliminar regla libera el tipo para una nueva regla
    * def tipoProducto = 'TIPO-' + utils.uuid()
    * def created = call read('classpath:features/product_rules/create-product-rule.feature@create_product_rule') { authHeader: '#(authHeader)', tipoProducto: '#(tipoProducto)', descuento: 30 }
    * def ruleId = created.ruleId
    Given path '/api/v1/product-rules/' + ruleId
    And header Authorization = authHeader
    When method DELETE
    Then status 200
    Given path '/api/v1/product-rules'
    And header Authorization = authHeader
    And request { tipoProducto: '#(tipoProducto)', descuento: 25 }
    When method POST
    Then status 201