Feature: HU-02 - Gestión de usuarios por administrador

  Background:
    * configure url = adminBaseUrl
    * def utils        = call read('classpath:common/common-utils.feature')
    * def loginResult  = callonce read('classpath:common/login.feature') adminCredentials
    * def authHeader   = 'Bearer ' + loginResult.authToken
    * def basePath     = '/api/v1/users'
    * def stdUser      = callonce read('classpath:common/create-store-user.feature')
    * def stdUsername  = stdUser.username

  Scenario Outline: TC-025 - Crear usuario: <escenario> retorna HTTP <expectedStatus>
    * def body = { username: '<username>', email: '<email>', password: '#(testUserPassword)', roleId: '#(storeUserRoleId)', ecommerceId: '<ecommerceId>' }

    Given path basePath
    And header Authorization = authHeader
    And request body
    When method POST
    Then status <expectedStatus>
    And match response !contains { uid: '#notnull' }

    Examples:
      | escenario                        | username    | email            | ecommerceId         | expectedStatus |
      | Iter 1 - ecommerceId inexistente | user.nuevo2 | user2@tienda.com | #(nonExistentId) | 404            |
      | Iter 2 - Username vacío          |             | user3@tienda.com | #(validEcommerceId) | 400            |

  Scenario: TC-026 - Listar usuarios del ecommerce retorna HTTP 200 con campos requeridos
    Given path basePath
    And header Authorization = authHeader
    And param ecommerceId = validEcommerceId
    When method GET
    Then status 200
    And match each response.content contains { username: '#string', roleId: '#string', roleName: '#string', email: '#string', createdAt: '#string' }

  Scenario: TC-027 - Eliminar usuario impide su autenticación posterior
    * def tempUser = call read('classpath:common/create-store-user.feature')
    Given path basePath, tempUser.uid
    And header Authorization = authHeader
    When method DELETE
    Then status 204
    Given path '/api/v1/auth/login'
    And request { username: '#(tempUser.username)', password: '#(testUserPassword)' }
    When method POST
    Then status 401

  Scenario Outline: TC-028 - <actor> intenta POST /api/v1/users y obtiene HTTP <expectedStatus>
    * def authResult  = karate.call('classpath:common/auth-helper.feature', { requiresLogin: '<requiresLogin>' == 'true', username: '<actorUsername>', password: '<actorPassword>' })
    * def authHeaders = authResult.authHeaders
    * def uniqueUser  = 'tc028.' + utils.uuid()
    * def uniqueEmail = uniqueUser + '@test.com'
    * def body        = { username: '#(uniqueUser)', email: '#(uniqueEmail)', password: '#(testUserPassword)', roleId: '#(storeUserRoleId)', ecommerceId: '<ecommerceId>' }

    Given path basePath
    And headers authHeaders
    And request body
    When method POST
    Then status <expectedStatus>

    Examples:
      | actor                           | actorUsername | actorPassword | ecommerceId           | requiresLogin | expectedStatus |
      | ADMIN con ecommerce válido      | admin         | admin123      | #(validEcommerceId)   | true          | 201            |
      | ADMIN con ecommerce inexistente | admin         | admin123      | #(nonExistentId) | true          | 404            |
      | Sin sesión                      |               |               | #(validEcommerceId)   | false         | 401            |

  Scenario: TC-028b - USER con rol STORE_USER no puede crear usuarios (HTTP 403)
    * def uniqueUser  = 'tc028b.' + utils.uuid()
    * def uniqueEmail = uniqueUser + '@test.com'
    * def body        = read('classpath:data/users/create-user.json')
    Given path basePath
    And header Authorization = 'Bearer ' + stdUser.authToken
    And request body
    When method POST
    Then status 403