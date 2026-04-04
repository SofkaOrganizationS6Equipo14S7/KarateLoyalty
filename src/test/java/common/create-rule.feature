@ignore
Feature: Helper - Crear una regla genérica via /api/v1/rules

  @create_rule
  Scenario: POST /api/v1/rules y retorna 201
    Given url adminBaseUrl + '/api/v1/rules'
    And header Authorization = authHeader
    And request payload
    When method POST
    Then status 201
    * def ruleId = response.id
