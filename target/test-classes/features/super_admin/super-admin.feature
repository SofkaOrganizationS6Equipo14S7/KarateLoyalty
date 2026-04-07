Feature: HU-16 - Operaciones globales del SUPER_ADMIN sin restricción de ecommerce

  Background:
    * configure url = adminBaseUrl
    * def utils      = callonce read('classpath:common/common-utils.feature')
    * def adminLogin = callonce read('classpath:common/login.feature') adminCredentials
    * def authHeader = 'Bearer ' + adminLogin.authToken

  Scenario: TC-062 - SUPER_ADMIN lista todos los ecommerces registrados sin filtro retorna HTTP 200
    Given path '/api/v1/ecommerces'
    And header Authorization = authHeader
    When method GET
    Then status 200
    And match response.content == '#[]'
    And match each response.content contains { uid: '#uuid', name: '#string', slug: '#string', status: '#string' }

  Scenario: TC-063 - SUPER_ADMIN ejecuta cuatro operaciones cross-ecommerce sin restricción
    * def newUsername = 'tc063.' + utils.uuid()
    * def newEmail    = newUsername + '@test.com'
    * def body = read('classpath:data/super-admin/create-store-admin.json')
    Given path '/api/v1/users'
    And header Authorization = authHeader
    And request body
    When method POST
    Then status 201
    * def createdUid = response.uid

    Given path '/api/v1/ecommerces'
    And header Authorization = authHeader
    When method GET
    Then status 200
    And match response.content == '#[_ > 0]'

    Given path '/api/v1/users', createdUid
    And header Authorization = authHeader
    When method DELETE
    Then status 204

    * def reassignUser  = 'tc063r.' + utils.uuid()
    * def reassignEmail = reassignUser + '@test.com'
    * def reassignBody = read('classpath:data/super-admin/create-store-admin.json')
    * set reassignBody.username = reassignUser
    * set reassignBody.email = reassignEmail
    Given path '/api/v1/users'
    And header Authorization = authHeader
    And request reassignBody
    When method POST
    Then status 201
    * def reassignUid = response.uid
    Given path '/api/v1/users', reassignUid
    And header Authorization = authHeader
    And request read('classpath:data/super-admin/reassign-ecommerce.json')
    When method PUT
    Then status 200
    And match response.ecommerceId == otherEcommerceId
