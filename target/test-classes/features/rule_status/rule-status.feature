Feature: HU-14 - Cambio de estado de reglas de descuento

  Background:
    * configure url = adminBaseUrl
    * def utils      = callonce read('classpath:common/common-utils.feature')
    * def loyaltyUser = callonce read('classpath:common/create-store-admin.feature') { prefix: 'tc059' }
    * def authHeader = 'Bearer ' + loyaltyUser.authToken
    * def basePath   = '/api/v1/rules'

  Scenario: TC-059 Iter 1 - Desactivar regla activa retorna HTTP 204 y queda inactiva
    * def rule = call read('classpath:common/create-product-rule.feature') { utils: '#(utils)', authHeader: '#(authHeader)', namePrefix: 'Rule TC059-1' }

    Given path basePath, rule.ruleId
    And header Authorization = authHeader
    When method DELETE
    Then status 204
    Given path basePath, rule.ruleId
    And header Authorization = authHeader
    When method GET
    Then status 200
    And match response.isActive == false

  Scenario: TC-059 Iter 2 - Actualizar regla inactiva con PUT retorna HTTP 200
    * def rule = call read('classpath:common/create-product-rule.feature') { utils: '#(utils)', authHeader: '#(authHeader)', namePrefix: 'Rule TC059-2' }

    Given path basePath, rule.ruleId
    And header Authorization = authHeader
    When method DELETE
    Then status 204
    * def tipoProducto = rule.tipoProducto
    * def rawPayload2 = read('classpath:data/product-rules/product-rule-base.json')
    * copy updatePayload = rawPayload2
    * set updatePayload.name = 'Rule TC059-2 Updated - ' + tipoProducto
    Given path basePath, rule.ruleId
    And header Authorization = authHeader
    And request updatePayload
    When method PUT
    Then status 200
    Given path basePath, rule.ruleId
    And header Authorization = authHeader
    When method GET
    Then status 200
    And match response.name contains 'Updated'

  Scenario: TC-059 Iter 3 - Eliminar regla inexistente retorna HTTP 404
    Given path basePath, nonExistentId
    And header Authorization = authHeader
    When method DELETE
    Then status 404

  Scenario: TC-059 Iter 4 - Eliminar regla sin sesión activa retorna HTTP 401
    * def rule = call read('classpath:common/create-product-rule.feature') { utils: '#(utils)', authHeader: '#(authHeader)', namePrefix: 'Rule TC059-4' }
    Given path basePath, rule.ruleId
    When method DELETE
    Then status 401
