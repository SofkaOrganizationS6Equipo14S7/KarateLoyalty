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

    * def retryPayload = read('classpath:data/engine/calculate-request.json')
    * set retryPayload.externalOrderId = java.util.UUID.randomUUID() + ''
    * configure retry = { count: 20, interval: 1000 }
    Given url engineBaseUrl
    And path '/api/v1/engine/calculate'
    And header X-API-KEY = apiKey
    And request retryPayload
    And retry until responseStatus != 401
    When method POST
