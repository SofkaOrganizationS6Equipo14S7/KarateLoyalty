@ignore
Feature: Helper - Crear STORE_USER reutilizable para tests

  Scenario: Crear usuario con rol STORE_USER
    * def utils      = call read('classpath:common/common-utils.feature')
    * def adminLogin = call read('classpath:common/login.feature') adminCredentials
    * def adminAuth  = 'Bearer ' + adminLogin.authToken
    * def username   = 'std.' + utils.uuid()
    * def email      = username + '@test.com'

    Given url adminBaseUrl
    And path '/api/v1/users'
    And header Authorization = adminAuth
    And request { username: '#(username)', email: '#(email)', password: '#(testUserPassword)', roleId: '#(storeUserRoleId)', ecommerceId: '#(validEcommerceId)' }
    When method POST
    Then status 201
    * def uid       = response.uid
    * def username  = response.username
    * def userLogin = call read('classpath:common/login.feature') { username: '#(username)', password: '#(testUserPassword)' }
    * def authToken = userLogin.authToken
