Feature: HU-06 - Gestión de reglas de temporada

  Background:
    * configure url = adminBaseUrl
    * def utils        = callonce read('classpath:common/common-utils.feature')
    * def loyaltyUser  = callonce read('classpath:common/create-store-admin.feature') { prefix: 'loyalty' }
    * def authHeader   = 'Bearer ' + loyaltyUser.authToken
    * def basePath     = '/api/v1/rules'

  Scenario: TC-036 - Crear regla de temporada retorna HTTP 201 y regla activa en listado
    * def range = utils.futureDateRange(100)
    * def blackFridayPayload =
    """
    {
      "name": "Black Friday 2026",
      "description": "Descuento Black Friday",
      "discountPercentage": 20,
      "discountPriorityId": "#(seasonalPriorityId)",
      "attributes": {
        "start_date": "#(range.start)",
        "end_date": "#(range.end)"
      }
    }
    """
    Given path basePath
    And header Authorization = authHeader
    And request blackFridayPayload
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
    * def rangeCreate = utils.futureDateRange(200)
    * def rangeUpdate = utils.futureDateRange(210)
    * def createPayload =
    """
    {
      "name": "Regla a actualizar TC-038",
      "description": "Regla inicial para actualización",
      "discountPercentage": 10,
      "discountPriorityId": "#(seasonalPriorityId)",
      "attributes": {
        "start_date": "#(rangeCreate.start)",
        "end_date": "#(rangeCreate.end)"
      }
    }
    """
    * def updatePayload =
    """
    {
      "name": "Regla actualizada TC-038",
      "description": "Regla actualizada",
      "discountPercentage": 25,
      "discountPriorityId": "#(seasonalPriorityId)",
      "attributes": {
        "start_date": "#(rangeUpdate.start)",
        "end_date": "#(rangeUpdate.end)"
      }
    }
    """
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
    * def rangeDelete = utils.futureDateRange(300)
    * def createPayload =
    """
    {
      "name": "Regla a eliminar TC-039",
      "description": "Regla para eliminación",
      "discountPercentage": 15,
      "discountPriorityId": "#(seasonalPriorityId)",
      "attributes": {
        "start_date": "#(rangeDelete.start)",
        "end_date": "#(rangeDelete.end)"
      }
    }
    """
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

  Scenario: TC-040 - Regla estacional con datos válidos retorna HTTP 201
    * def rangeVerano = utils.futureDateRange(400)
    * def veranoPayload =
    """
    {
      "name": "Verano Test 2026",
      "description": "Descuento de verano",
      "discountPercentage": 15,
      "discountPriorityId": "#(seasonalPriorityId)",
      "attributes": {
        "start_date": "#(rangeVerano.start)",
        "end_date": "#(rangeVerano.end)"
      }
    }
    """
    Given path basePath
    And header Authorization = authHeader
    And request veranoPayload
    When method POST
    Then status 201

  Scenario: TC-040 - Descuento negativo inválido retorna HTTP 400
    Given path basePath
    And header Authorization = authHeader
    And request read('classpath:data/seasonal-rules/descuento-cero.json')
    When method POST
    Then status 400

  Scenario: TC-040 - Edición de regla inexistente retorna HTTP 404
    * def range404 = utils.futureDateRange(500)
    * def updateBody =
    """
    {
      "name": "Regla inexistente",
      "description": "No existe",
      "discountPercentage": 10,
      "discountPriorityId": "#(seasonalPriorityId)",
      "attributes": {
        "start_date": "#(range404.start)",
        "end_date": "#(range404.end)"
      }
    }
    """
    Given path basePath, nonExistentId
    And header Authorization = authHeader
    And request updateBody
    When method PUT
    Then status 404