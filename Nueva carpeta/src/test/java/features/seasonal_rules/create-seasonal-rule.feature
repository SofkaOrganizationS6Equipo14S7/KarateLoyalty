@ignore
Feature: Helper - Crear una regla de temporada

  @create_seasonal_rule
  Scenario: POST /api/v1/seasonal-rules y retorna 201
    Given url adminBaseUrl + '/api/v1/seasonal-rules'
    And header Authorization = authHeader
    And request payload
    When method POST
    Then status 201
    * def ruleId = response.id
