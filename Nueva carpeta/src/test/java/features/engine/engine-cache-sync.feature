Feature: HU-10 - Sincronización de caché del motor vía RabbitMQ

  Background:
    * url engineBaseUrl
    * def enginePath = '/api/v1/engine/calculate'

  Scenario: TC-052 - Sincronización de caché vía RabbitMQ actualiza nivel Oro en el Engine
    * def sleep = function(ms){ java.lang.Thread.sleep(ms) }
    * def syncPayload = { idCliente: 'CLI-SYNC', totalCompras: 60, montoTotalGastado: 500.00, mesesComoCliente: 6 }

    Given path enginePath
    And header x-api-key = validApiKey
    And request syncPayload
    When method POST
    Then status 200
    * def nivelAntes = response.nivel
    * assert nivelAntes != 'Oro'

    * def adminLogin = call read('classpath:common/login.feature') loyaltyCredentials
    Given url adminBaseUrl
    And path '/api/v1/fidelity-ranges'
    And header Authorization = 'Bearer ' + adminLogin.authToken
    And request read('classpath:data/fidelity-ranges/valid-ranges.json')
    When method PUT
    Then status 200

    * sleep(5000)
    Given url engineBaseUrl
    And path enginePath
    And header x-api-key = validApiKey
    And request syncPayload
    When method POST
    Then status 200
    And match response.nivel == 'Oro'