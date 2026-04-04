@ignore
Feature: Helper - Crear API Key real para el engine

  Scenario: Crear una API Key via admin y devolver el plaintext key
    * def adminLogin = call read('classpath:common/login.feature') adminCredentials
    * def adminAuth  = 'Bearer ' + adminLogin.authToken

    Given url adminBaseUrl
    And path '/api/v1/ecommerces/' + validEcommerceId + '/api-keys'
    And header Authorization = adminAuth
    And request {}
    When method POST
    Then status 201
    * def apiKey = response.key
