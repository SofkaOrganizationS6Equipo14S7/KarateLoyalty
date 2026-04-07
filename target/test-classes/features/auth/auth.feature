Feature: HU-01 - Autenticación de usuarios

  Background:
    * configure url = adminBaseUrl

  Scenario: TC-022 - Login con credenciales válidas retorna HTTP 200 con token JWT
    Given path '/api/v1/auth/login'
    And request adminCredentials
    When method POST
    Then status 200
    And match response.token == '#string'
    And match response.token == '#regex [A-Za-z0-9-_=]+\\.[A-Za-z0-9-_=]+\\.[A-Za-z0-9-_=]+'

  Scenario Outline: TC-023 - <escenario> retorna HTTP <expectedStatus>
    Given path '/api/v1/auth/login'
    And request { username: '<username>', password: '<password>' }
    When method POST
    Then status <expectedStatus>
    And match response !contains { token: '#notnull' }

    Examples:
      | escenario                           | username | password  | expectedStatus |
      | Iter 1 - Contraseña incorrecta      | admin    | wrongPass | 401            |
      | Iter 2 - Username vacío             |          | admin123  | 400            |
      | Iter 3 - Username y password vacíos |          |           | 400            |

  Scenario: TC-024 - Logout
    * def loginResult = call read('classpath:common/login.feature') adminCredentials
    * def token = loginResult.authToken
    Given path '/api/v1/auth/logout'
    And header Authorization = 'Bearer ' + token
    When method POST
    Then status 204