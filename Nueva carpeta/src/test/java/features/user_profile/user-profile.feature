Feature: HU-04 - Perfil y permisos de usuario con rol USER

  Background:
    * configure url = adminBaseUrl
    * def loginResult    = callonce read('classpath:common/login.feature') userCredentials
    * def userAuthHeader = 'Bearer ' + loginResult.authToken
    * def profilePath    = '/api/v1/users/me'

  Scenario: TC-033 - USER consulta su propio perfil y obtiene HTTP 200 con sus datos
    Given path profilePath
    And header Authorization = userAuthHeader
    When method GET
    Then status 200
    And match response.username == userCredentials.username
    And match response contains { username: '#string', email: '#string' }

  Scenario Outline: TC-034 - USER recibe HTTP 403 al intentar <accion>
    * def body        = '<requestFile>' != '' ? read('classpath:data/user-profile/<requestFile>') : null
    * def queryParams = '<withEcommerceId>' == 'true' ? { ecommerceId: '#(validEcommerceId)' } : {}

    Given path '<endpointPath>'
    And header Authorization = userAuthHeader
    And params queryParams
    And request body
    When method <method>
    Then status 403

    Examples:
      | accion                     | endpointPath            | method | requestFile                           | withEcommerceId |
      | crear usuario              | /api/v1/users           | POST   | create-user-forbidden.json            | false           |
      | actualizar discount-config | /api/v1/discount-config | PUT    | update-discount-config-forbidden.json | false           |
      | listar usuarios            | /api/v1/users           | GET    |                                       | true            |

  Scenario: TC-035 - USER actualiza su email con formato mínimo válido y obtiene HTTP 200
    Given path profilePath
    And header Authorization = userAuthHeader
    And request read('classpath:data/user-profile/update-email.json')
    When method PUT
    Then status 200
    Given path profilePath
    And header Authorization = userAuthHeader
    When method GET
    Then status 200
    And match response.email == 'a@b.c'
