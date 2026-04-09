Feature: HU-14 - Cambio de estado de reglas de descuento

  Background:
    * configure url = adminBaseUrl
    * def loyaltyUser = callonce read('classpath:common/create-store-admin.feature') { prefix: 'tc059' }
    * def authHeader = 'Bearer ' + loyaltyUser.authToken
    * def basePath   = '/api/v1/rules'

  Scenario: TC-059 Iter 3 - Eliminar regla inexistente retorna HTTP 404
    Given path basePath, nonExistentId
    And header Authorization = authHeader
    When method DELETE
    Then status 404
