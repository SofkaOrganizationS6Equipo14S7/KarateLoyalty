@ignore
Feature: Helper de autenticación compartida

  Scenario: Obtener token de autenticación
    Given url adminBaseUrl
    And path '/api/v1/auth/login'
    And request { username: '#(username)', password: '#(password)' }
    When method POST
    Then status 200
    And match response contains { token: '#string' }
    * def authToken = response.token