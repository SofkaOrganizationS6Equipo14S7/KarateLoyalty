Feature: HU-04 - Perfil y permisos de usuario con rol USER

  Background:
    * configure url = adminBaseUrl
    * def utils          = call read('classpath:common/common-utils.feature')
    * def stdUser        = callonce read('classpath:common/create-store-user.feature')
    * def userAuthHeader = 'Bearer ' + stdUser.authToken
    * def profilePath    = '/api/v1/users/me'
    * def getProfilePath = '/api/v1/auth/me'

  Scenario: TC-032 - USER consulta su propio perfil y obtiene HTTP 200 con sus datos
    Given path getProfilePath
    And header Authorization = userAuthHeader
    When method GET
    Then status 200
    And match response.username == stdUser.username
    And match response contains { username: '#string', email: '#string' }

  Scenario: TC-033 - STORE_USER no puede crear usuarios y obtiene HTTP 403
    Given path '/api/v1/users'
    And header Authorization = userAuthHeader
    And request read('classpath:data/user-profile/create-user-forbidden.json')
    When method POST
    Then status 403

  Scenario: TC-034 - USER actualiza su email con formato mínimo válido y obtiene HTTP 200
    * def newEmail = 'tc034.' + utils.uuid() + '@test.com'
    Given path profilePath
    And header Authorization = userAuthHeader
    And request { email: '#(newEmail)' }
    When method PUT
    Then status 200
    Given path getProfilePath
    And header Authorization = userAuthHeader
    When method GET
    Then status 200
    And match response.email == newEmail
