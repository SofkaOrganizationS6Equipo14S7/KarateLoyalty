Feature: HU-09 - Configuración de tope y prioridades de descuento

  Background:
    * configure url = adminBaseUrl
    * def adminLogin = callonce read('classpath:common/login.feature') adminCredentials
    * def authHeader = 'Bearer ' + adminLogin.authToken

  Scenario: TC-058 - Config válida completa se crea o ya existe
    Given path '/api/v1/discount-config'
    And header Authorization = authHeader
    And request read('classpath:data/discount-config/valid-config.json')
    When method POST
    * assert responseStatus == 201 || responseStatus == 500
    Given path '/api/v1/discount-config'
    And header Authorization = authHeader
    And param ecommerceId = '550e8400-e29b-41d4-a716-446655440001'
    When method GET
    Then status 200
    And match response.maxDiscountLimit == '#notnull'

  Scenario Outline: TC-058 - <escenario> retorna HTTP <expectedStatus>
    Given path '/api/v1/discount-config'
    And header Authorization = authHeader
    And request read('classpath:data/discount-config/<requestFile>')
    When method POST
    Then status <expectedStatus>

    Examples:
      | escenario                                 | requestFile               | expectedStatus |
      | maxDiscountLimit=0 inválido               | zero-discount.json              | 400            |
      | ecommerceId con formato inválido          | invalid-ecommerce-format.json   | 500            |
      | maxDiscountLimit negativo                 | negative-discount-limit.json    | 400            |