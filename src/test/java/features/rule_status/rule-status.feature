Feature: HU-14 - Cambio de estado de reglas de descuento

  Background:
    * configure url = adminBaseUrl
    * def utils      = callonce read('classpath:common/common-utils.feature')
    * def loyaltyUser = callonce read('classpath:common/create-store-admin.feature') { prefix: 'tc059' }
    * def authHeader = 'Bearer ' + loyaltyUser.authToken
    * def basePath   = '/api/v1/rules'

  Scenario: TC-059 Iter 1 - Desactivar regla activa retorna HTTP 204 y queda inactiva
    * def tipoProducto = 'TIPO-' + utils.uuid()
    * def rawPayload = read('classpath:data/product-rules/product-rule-base.json')
    * copy payload = rawPayload
    * set payload.name = 'Rule TC059-1 - ' + tipoProducto
    * def created = call read('classpath:common/create-rule.feature@create_rule') { authHeader: '#(authHeader)', payload: '#(payload)' }

    Given path basePath, created.ruleId
    And header Authorization = authHeader
    When method DELETE
    Then status 204
    Given path basePath, created.ruleId
    And header Authorization = authHeader
    When method GET
    Then status 200
    And match response.isActive == false

  Scenario: TC-059 Iter 2 - Actualizar regla inactiva con PUT retorna HTTP 200
    * def tipoProducto = 'TIPO-' + utils.uuid()
    * def rawPayload = read('classpath:data/product-rules/product-rule-base.json')
    * copy payload = rawPayload
    * set payload.name = 'Rule TC059-2 - ' + tipoProducto
    * def created = call read('classpath:common/create-rule.feature@create_rule') { authHeader: '#(authHeader)', payload: '#(payload)' }

    Given path basePath, created.ruleId
    And header Authorization = authHeader
    When method DELETE
    Then status 204
    * def rawPayload2 = read('classpath:data/product-rules/product-rule-base.json')
    * copy updatePayload = rawPayload2
    * set updatePayload.name = 'Rule TC059-2 Updated - ' + tipoProducto
    Given path basePath, created.ruleId
    And header Authorization = authHeader
    And request updatePayload
    When method PUT
    Then status 200
    Given path basePath, created.ruleId
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
    * def tipoProducto = 'TIPO-' + utils.uuid()
    * def rawPayload = read('classpath:data/product-rules/product-rule-base.json')
    * copy payload = rawPayload
    * set payload.name = 'Rule TC059-4 - ' + tipoProducto
    * def created = call read('classpath:common/create-rule.feature@create_rule') { authHeader: '#(authHeader)', payload: '#(payload)' }
    Given path basePath, created.ruleId
    When method DELETE
    Then status 401
