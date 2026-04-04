Feature: HU-03 - Gestión restringida por STORE_ADMIN

  Background:
    * configure url = adminBaseUrl
    * def loginResult     = callonce read('classpath:common/login.feature') storeAdminCredentials
    * def storeAuthHeader = 'Bearer ' + loginResult.authToken
    * def basePath        = '/api/v1/users'

  Scenario: TC-030 - STORE_ADMIN crea usuario en su propio ecommerce y obtiene HTTP 201
    Given path basePath
    And header Authorization = storeAuthHeader
    And request read('classpath:data/store-admin/create-user-own-ecommerce.json')
    When method POST
    Then status 201
    And match response.ecommerceId == storeAdminEcommerceId
    Given path basePath
    And header Authorization = storeAuthHeader
    And param ecommerceId = storeAdminEcommerceId
    When method GET
    Then status 200
    And match response[*].username contains 'usr.std'

  Scenario: TC-031 - STORE_ADMIN crea usuario en ecommerce ajeno y obtiene HTTP 403
    Given path basePath
    And header Authorization = storeAuthHeader
    And request read('classpath:data/store-admin/create-user-other-ecommerce.json')
    When method POST
    Then status 403

  Scenario Outline: TC-032 - <actor> consulta GET /api/v1/users y obtiene HTTP <expectedStatus>
    * def authResult  = karate.call('classpath:common/auth-helper.feature', { requiresLogin: '<requiresLogin>' == 'true', username: '<actorUsername>', password: '<actorPassword>' })
    * def authHeaders = authResult.authHeaders

    Given path basePath
    And headers authHeaders
    And param ecommerceId = '<queriedEcommerceId>'
    When method GET
    Then status <expectedStatus>

    Examples:
      | actor                            | actorUsername | actorPassword | queriedEcommerceId        | requiresLogin | expectedStatus |
      | STORE_ADMIN sobre su ecommerce   | store_admin   | Pass123!      | #(storeAdminEcommerceId)  | true          | 200            |
      | STORE_ADMIN sobre otro ecommerce | store_admin   | Pass123!      | #(otherEcommerceId)       | true          | 403            |
      | USER autenticado                 | user.std      | Pass123!      | #(storeAdminEcommerceId)  | true          | 403            |
      | Sin sesión                       |               |               | #(storeAdminEcommerceId)  | false         | 401            |
