Feature: HU-02 - Gestión de usuarios por administrador

  Background:
    * configure url = adminBaseUrl
    * def loginResult = callonce read('classpath:common/login.feature') adminCredentials
    * def authHeader  = 'Bearer ' + loginResult.authToken
    * def basePath    = '/api/v1/users'

  Scenario Outline: TC-025 - Crear usuario: <escenario> retorna HTTP <expectedStatus>
    * def body = { username: '<username>', email: '<email>', password: 'Pass123!', ecommerceId: '<ecommerceId>' }

    Given path basePath
    And header Authorization = authHeader
    And request body
    When method POST
    Then status <expectedStatus>
    * assert response.id == null

    Examples:
      | escenario                        | username    | email            | ecommerceId         | expectedStatus |
      | Iter 1 - ecommerceId inexistente | user.nuevo2 | user2@tienda.com | ID-INEXISTENTE      | 404            |
      | Iter 2 - Username vacío          |             | user3@tienda.com | #(validEcommerceId) | 400            |

  Scenario: TC-026 - Listar usuarios del ecommerce retorna HTTP 200 con campos requeridos
    Given path basePath
    And header Authorization = authHeader
    And param ecommerceId = validEcommerceId
    When method GET
    Then status 200
    And match each response contains { username: '#string', role: '#string', email: '#string', createdAt: '#string' }

  Scenario: TC-027 - Eliminar usuario impide su autenticación posterior
    Given path basePath
    And header Authorization = authHeader
    And request read('classpath:data/users/create-user-temp.json')
    When method POST
    Then status 201
    * def deletedUserId = response.id
    Given path basePath, deletedUserId
    And header Authorization = authHeader
    When method DELETE
    Then status 200
    Given path '/api/v1/auth/login'
    And request read('classpath:data/users/deleted-user-login.json')
    When method POST
    Then status 401

  Scenario Outline: TC-028 - <actor> intenta POST /api/v1/users y obtiene HTTP <expectedStatus>
    * def authResult  = karate.call('classpath:common/auth-helper.feature', { requiresLogin: '<requiresLogin>' == 'true', username: '<actorUsername>', password: '<actorPassword>' })
    * def authHeaders = authResult.authHeaders
    * def body          = { username: 'tc028.user', email: 'tc028@test.com', password: 'Pass123!', ecommerceId: '<ecommerceId>' }

    Given path basePath
    And headers authHeaders
    And request body
    When method POST
    Then status <expectedStatus>

    Examples:
      | actor                           | actorUsername | actorPassword | ecommerceId         | requiresLogin | expectedStatus |
      | ADMIN con ecommerce válido      | admin         | Pass123!      | #(validEcommerceId) | true          | 201            |
      | ADMIN con ecommerce inexistente | admin         | Pass123!      | ID-INEXISTENTE      | true          | 404            |
      | USER autenticado                | user.std      | Pass123!      | #(validEcommerceId) | true          | 403            |
      | Sin sesión                      |               |               | #(validEcommerceId) | false         | 401            |

    Scenario: TC-029 - Reasignar usuario al ecommerce B retorna HTTP 200
    Given path basePath
    And header Authorization = authHeader
    And param ecommerceId = validEcommerceId
    When method GET
    Then status 200
    * def targetUserId = response[0].id
    Given path basePath, targetUserId, 'ecommerce'
    And header Authorization = authHeader
    And request read('classpath:data/users/reassign-ecommerce.json')
    When method PATCH
    Then status 200
  Given path basePath
    And header Authorization = authHeader
    And param ecommerceId = ecommerceIdB
    When method GET
    Then status 200
    And match response[*].id contains targetUserId