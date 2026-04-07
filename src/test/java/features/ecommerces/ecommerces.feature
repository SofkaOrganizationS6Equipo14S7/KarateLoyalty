Feature: HU-15 - Gestión de ecommerces por SUPER_ADMIN

  Background:
    * configure url = adminBaseUrl
    * def utils      = callonce read('classpath:common/common-utils.feature')
    * def adminLogin = callonce read('classpath:common/login.feature') adminCredentials
    * def authHeader = 'Bearer ' + adminLogin.authToken
    * def ecommercesPath = '/api/v1/ecommerces'

  Scenario: TC-060 Iter 1 - Crear ecommerce con nombre y slug únicos retorna HTTP 201 y estado activo
    * def ecommerceName = 'Tienda A'
    * def uniqueSlug = 'tienda-a-' + utils.timestamp()
    Given path ecommercesPath
    And header Authorization = authHeader
    And request read('classpath:data/ecommerces/create-ecommerce.json')
    When method POST
    Then status 201
    And match response.uid == '#uuid'
    And match response.name == ecommerceName
    And match response.slug == uniqueSlug
    And match response.status == 'ACTIVE'
    * def createdId = response.uid
    Given path ecommercesPath, createdId
    And header Authorization = authHeader
    When method GET
    Then status 200
    And match response.status == 'ACTIVE'

  Scenario: TC-060 Iter 2 - Crear ecommerce con slug duplicado retorna HTTP 409
    * def ecommerceName = 'Tienda Original'
    * def uniqueSlug = 'dup-' + utils.timestamp()
    Given path ecommercesPath
    And header Authorization = authHeader
    And request read('classpath:data/ecommerces/create-ecommerce.json')
    When method POST
    Then status 201
    * def ecommerceName = 'Tienda Duplicada'
    Given path ecommercesPath
    And header Authorization = authHeader
    And request read('classpath:data/ecommerces/create-ecommerce.json')
    When method POST
    Then status 409

  Scenario: TC-060 Iter 3 - Crear ecommerce con slug vacío retorna HTTP 400
    Given path ecommercesPath
    And header Authorization = authHeader
    And request { name: 'Tienda Sin Slug', slug: '' }
    When method POST
    Then status 400

  Scenario: TC-061 - Desactivar ecommerce invalida tokens JWT de usuarios y API Keys del Motor
    * def ecommerceName = 'Ecommerce Desactivar'
    * def uniqueSlug = 'deactivate-' + utils.timestamp()
    Given path ecommercesPath
    And header Authorization = authHeader
    And request read('classpath:data/ecommerces/create-ecommerce.json')
    When method POST
    Then status 201
    * def ecommerceId = response.uid

    * def saUsername = 'tc061.' + java.util.UUID.randomUUID()
    * def saEmail    = saUsername + '@test.com'
    Given path '/api/v1/users'
    And header Authorization = authHeader
    And request read('classpath:data/ecommerces/create-user-for-ecommerce.json')
    When method POST
    Then status 201

    Given path '/api/v1/auth/login'
    And request { username: '#(saUsername)', password: '#(testUserPassword)' }
    When method POST
    Then status 200

    Given path '/api/v1/ecommerces', ecommerceId, 'api-keys'
    And header Authorization = authHeader
    And request {}
    When method POST
    Then status 201
    * def apiKey = response.key

    Given path ecommercesPath, ecommerceId, 'status'
    And header Authorization = authHeader
    And request { status: 'INACTIVE' }
    When method PUT
    Then status 200

    Given path '/api/v1/auth/login'
    And request { username: '#(saUsername)', password: '#(testUserPassword)' }
    When method POST
    Then status 401

    Given url engineBaseUrl
    And path '/api/v1/engine/calculate'
    And header x-api-key = apiKey
    * copy payload = read('classpath:data/engine/calculate-request.json')
    * set payload.externalOrderId = 'TC061-' + java.util.UUID.randomUUID()
    * set payload.ecommerceId = ecommerceId
    And request payload
    When method POST
    Then status 401