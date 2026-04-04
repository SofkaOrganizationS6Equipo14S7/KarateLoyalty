Feature: HU-03 - Gestión restringida por STORE_ADMIN

  Background:
    * configure url = adminBaseUrl
    * def utils           = call read('classpath:common/common-utils.feature')
    * def saUser          = callonce read('classpath:common/create-store-admin.feature')
    * def storeAuthHeader = 'Bearer ' + saUser.authToken
    * def stdUser         = callonce read('classpath:common/create-store-user.feature')
    * def basePath        = '/api/v1/users'

  Scenario: TC-029 - STORE_ADMIN crea usuario en su propio ecommerce y obtiene HTTP 201
    * def newUser  = 'tc029.' + utils.uuid()
    * def newEmail = newUser + '@test.com'
    * def body     = read('classpath:data/store-admin/create-user-own-ecommerce.json')
    Given path basePath
    And header Authorization = storeAuthHeader
    And request body
    When method POST
    Then status 201
    And match response.ecommerceId == validEcommerceId

  Scenario: TC-030 - STORE_ADMIN crea usuario en ecommerce ajeno y obtiene HTTP 403
    * def newUser  = 'tc030.' + utils.uuid()
    * def newEmail = newUser + '@test.com'
    * def body     = read('classpath:data/store-admin/create-user-other-ecommerce.json')
    Given path basePath
    And header Authorization = storeAuthHeader
    And request body
    When method POST
    Then status 403

  Scenario: TC-031 - STORE_ADMIN consulta su propio ecommerce y obtiene HTTP 200
    Given path basePath
    And header Authorization = storeAuthHeader
    And param ecommerceId = validEcommerceId
    When method GET
    Then status 200

  Scenario: TC-031b - STORE_ADMIN consulta ecommerce ajeno y obtiene HTTP 403
    Given path basePath
    And header Authorization = storeAuthHeader
    And param ecommerceId = otherEcommerceId
    When method GET
    Then status 403

  Scenario: TC-031c - Sin sesión obtiene HTTP 401 al listar usuarios
    Given path basePath
    And param ecommerceId = validEcommerceId
    When method GET
    Then status 401
