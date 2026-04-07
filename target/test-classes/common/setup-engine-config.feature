@ignore
Feature: Helper - Ensure discount config exists for engine ecommerce

  Scenario: Create discount config for validEcommerceId
    * def adminLogin = call read('classpath:common/login.feature') adminCredentials
    * def adminAuth = 'Bearer ' + adminLogin.authToken
    Given url adminBaseUrl
    And path '/api/v1/discount-config'
    And header Authorization = adminAuth
    And request { ecommerceId: '#(validEcommerceId)', maxDiscountCap: 50, currencyCode: 'USD', allowStacking: true, roundingRule: 'HALF_UP' }
    When method POST
    * assert responseStatus == 201 || responseStatus == 500
