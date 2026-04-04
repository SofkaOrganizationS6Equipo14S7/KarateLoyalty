Feature: HU-09 - Configuración de tope y prioridades de descuento

  Background:
    * configure url = adminBaseUrl

  Scenario Outline: TC-058 - <escenario> retorna HTTP <expectedStatus>
    Given path '/api/v1/discount-config'
    And header x-api-key = superAdminApiKey
    And request read('classpath:data/discount-config/<requestFile>')
    When method PUT
    Then status <expectedStatus>

    Examples:
      | escenario                                 | requestFile               | expectedStatus |
      | tope=20% + prioridades únicas             | valid-config.json         | 200            |
      | tope=0% + prioridades únicas              | zero-discount.json        | 400            |
      | tope=20% + prioridades duplicadas         | duplicate-priorities.json | 400            |
      | tope=-5% + prioridades duplicadas         | negative-duplicate.json   | 400            |