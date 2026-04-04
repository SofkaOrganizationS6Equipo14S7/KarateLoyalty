Feature: HU-06 - Gestión de reglas de temporada

  Background:
    * configure url = adminBaseUrl
    * def loyaltyLogin = callonce read('classpath:common/login.feature') loyaltyCredentials
    * def loyaltyToken = loyaltyLogin.authToken
    * def authHeader   = 'Bearer ' + loyaltyToken
    * def basePath     = '/api/v1/seasonal-rules'

  Scenario: TC-037 - Crear regla de temporada retorna HTTP 201 y regla activa en listado
    Given path basePath
    And header Authorization = authHeader
    And request read('classpath:data/seasonal-rules/black-friday.json')
    When method POST
    Then status 201
    And match response.id == '#notnull'
    And match response.nombre == 'Black Friday 2026'
    And match response.descuento == 20
    * def createdRuleId = response.id
    Given path basePath
    And header Authorization = authHeader
    When method GET
    Then status 200
    And match response[*].id contains createdRuleId

  Scenario: TC-038 - Actualizar regla de temporada retorna HTTP 200 con datos actualizados
    * def createPayload = read('classpath:data/seasonal-rules/regla-enero-2026.json')
    * def updatePayload = read('classpath:data/seasonal-rules/update-junio-2026.json')
    * def created = call read('classpath:features/seasonal_rules/create-seasonal-rule.feature@create_seasonal_rule') { authHeader: '#(authHeader)', payload: '#(createPayload)' }
    * def ruleId = created.ruleId
    Given path basePath, ruleId
    And header Authorization = authHeader
    And request updatePayload
    When method PUT
    Then status 200
    And match response.fechaInicio == updatePayload.fechaInicio
    And match response.fechaFin   == updatePayload.fechaFin
    And match response.descuento  == updatePayload.descuento
    Given path basePath, ruleId
    And header Authorization = authHeader
    When method GET
    Then status 200
    And match response contains updatePayload

  Scenario: TC-039 - Eliminar regla de temporada retorna HTTP 200 y HTTP 404 en consulta posterior
    * def createPayload = read('classpath:data/seasonal-rules/regla-marzo-2026.json')
    * def created = call read('classpath:features/seasonal_rules/create-seasonal-rule.feature@create_seasonal_rule') { authHeader: '#(authHeader)', payload: '#(createPayload)' }
    * def ruleId = created.ruleId
    Given path basePath, ruleId
    And header Authorization = authHeader
    When method DELETE
    Then status 200
    Given path basePath, ruleId
    And header Authorization = authHeader
    When method GET
    Then status 404

  Scenario Outline: TC-040 - <escenario> retorna HTTP <expectedStatus>
    Given path basePath
    And header Authorization = authHeader
    And request read('classpath:data/seasonal-rules/<requestFile>')
    When method POST
    Then status <expectedStatus>

    Examples:
      | escenario                        | requestFile         | expectedStatus |
      | Fechas libres + descuento válido | verano-2026.json    | 201            |
      | Fechas libres + descuento=0      | descuento-cero.json | 400            |

  Scenario: TC-040 - Conflicto de fechas duplicadas retorna HTTP 409
    Given path basePath
    And header Authorization = authHeader
    And request read('classpath:data/seasonal-rules/agosto-2026.json')
    When method POST
    Then status 201

    Given path basePath
    And header Authorization = authHeader
    And request read('classpath:data/seasonal-rules/agosto-dup-2026.json')
    When method POST
    Then status 409

  Scenario: TC-040 - Edición de regla inexistente retorna HTTP 404
    Given path basePath, 'ID-NO-EXISTE-TC040'
    And header Authorization = authHeader
    And request { descuento: 20 }
    When method PUT
    Then status 404