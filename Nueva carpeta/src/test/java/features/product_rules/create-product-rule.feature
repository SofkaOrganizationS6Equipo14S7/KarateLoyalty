@ignore
Feature: Helper - Crear una regla de producto

  @create_product_rule
  Scenario: POST /api/v1/product-rules y retorna 201
    Given url adminBaseUrl + '/api/v1/product-rules'
    And header Authorization = authHeader
    And request { tipoProducto: '#(tipoProducto)', descuento: '#(descuento)' }
    When method POST
    Then status 201
    * def ruleId   = response.id
    * def descuento = response.descuento
