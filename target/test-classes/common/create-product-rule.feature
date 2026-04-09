@ignore
Feature: Helper - Crear regla de producto con tipo único

  Scenario: Crear regla de producto con nombre único
    * def tipoProducto = 'TIPO-' + utils.uuid()
    * def payload =
    """
    {
      "name": "#(namePrefix + ' - ' + tipoProducto)",
      "description": "Regla de producto",
      "discountPercentage": 10,
      "discountPriorityId": "#(productPriorityId)",
      "attributes": {
        "productType": "#(tipoProducto)"
      }
    }
    """
    * def created = call read('classpath:common/create-rule.feature@create_rule') { authHeader: '#(authHeader)', payload: '#(payload)' }
    * def ruleId = created.ruleId
