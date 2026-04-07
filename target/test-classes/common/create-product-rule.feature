@ignore
Feature: Helper - Crear regla de producto con tipo único

  Scenario: Crear regla de producto con nombre único
    * def tipoProducto = 'TIPO-' + utils.uuid()
    * def rawPayload = read('classpath:data/product-rules/product-rule-base.json')
    * copy payload = rawPayload
    * set payload.name = namePrefix + ' - ' + tipoProducto
    * def created = call read('classpath:common/create-rule.feature@create_rule') { authHeader: '#(authHeader)', payload: '#(payload)' }
    * def ruleId = created.ruleId
