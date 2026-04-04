@ignore
Feature: Helper - Crear STORE_ADMIN reutilizable para tests

  Scenario: Crear usuario con rol STORE_ADMIN
    * def adminLogin = call read('classpath:common/login.feature') adminCredentials
    * def adminAuth  = 'Bearer ' + adminLogin.authToken
    * def prefix     = typeof prefix != 'undefined' ? prefix : 'sa'
    * def ecommerce  = typeof ecommerce != 'undefined' ? ecommerce : validEcommerceId
    * def username   = prefix + '.' + java.util.UUID.randomUUID()
    * def email      = username + '@test.com'

    Given url adminBaseUrl
    And path '/api/v1/users'
    And header Authorization = adminAuth
    And request { username: '#(username)', email: '#(email)', password: '#(testUserPassword)', roleId: '#(storeAdminRoleId)', ecommerceId: '#(ecommerce)' }
    When method POST
    Then status 201
    * def username  = response.username
    * def saLogin   = call read('classpath:common/login.feature') { username: '#(username)', password: '#(testUserPassword)' }
    * def authToken = saLogin.authToken
