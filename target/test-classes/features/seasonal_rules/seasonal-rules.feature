Feature: HU-06 - Gestión de reglas de temporada

  Background:
    * configure url = adminBaseUrl
    * def loyaltyUser  = callonce read('classpath:common/create-store-admin.feature') { prefix: 'loyalty' }
    * def authHeader   = 'Bearer ' + loyaltyUser.authToken
    * def basePath     = '/api/v1/rules'

  Scenario: TC-036 - Crear regla de temporada retorna HTTP 201 y regla activa en listado
    Given path basePath
    And header Authorization = authHeader
    And request read('classpath:data/seasonal-rules/black-friday.json')
    When method POST
    Then status 201
    And match response.id == '#uuid'
    And match response.name == 'Black Friday 2026'
    And match response.discountPercentage == 20
    * def createdRuleId = response.id
    Given path basePath
    And header Authorization = authHeader
    When method GET
    Then status 200
    And match response.content[*].id contains createdRuleId

  Scenario: TC-038 - Actualizar regla de temporada retorna HTTP 200 con datos actualizados
    * def createPayload = read('classpath:data/seasonal-rules/regla-enero-2026.json')
    * def updatePayload = read('classpath:data/seasonal-rules/update-junio-2026.json')
    * def created = call read('classpath:common/create-rule.feature@create_rule') { authHeader: '#(authHeader)', payload: '#(createPayload)' }
    * def ruleId = created.ruleId
    Given path basePath, ruleId
    And header Authorization = authHeader
    And request updatePayload
    When method PUT
    Then status 200
    And match response.discountPercentage == 25
    And match response.name == 'Regla actualizada TC-038'
    Given path basePath, ruleId
    And header Authorization = authHeader
    When method GET
    Then status 200
    And match response.discountPercentage == 25

  Scenario: TC-039 - Eliminar regla de temporada retorna HTTP 204 y queda inactiva
    * def createPayload = read('classpath:data/seasonal-rules/regla-marzo-2026.json')
    * def created = call read('classpath:common/create-rule.feature@create_rule') { authHeader: '#(authHeader)', payload: '#(createPayload)' }
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

  Scenario Outline: TC-040 - <escenario> retorna HTTP <expectedStatus>
    Given path basePath
    And header Authorization = authHeader
    And request read('classpath:data/seasonal-rules/<requestFile>')
    When method POST
    Then status <expectedStatus>

    Examples:
      | escenario                            | requestFile         | expectedStatus |
      | Regla estacional con datos válidos   | verano-2026.json    | 201            |
      | Descuento negativo inválido          | descuento-cero.json | 400            |

  Scenario: TC-040 - Edición de regla inexistente retorna HTTP 404
    * def updateBody = read('classpath:data/seasonal-rules/regla-enero-2026.json')
    Given path basePath, nonExistentId
    And header Authorization = authHeader
    And request updateBody
    When method PUT
    Then status 404