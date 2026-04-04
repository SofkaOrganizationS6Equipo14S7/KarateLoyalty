@ignore
Feature: Helper de autenticación compartida

  Scenario: Obtener token de autenticación
    Given url adminBaseUrl + '/api/v1/auth/login'
    And request { username: '#(username)', password: '#(password)' }
    When method POST
    Then status 200
    * def authToken = response.token