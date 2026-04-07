@ignore
Feature: Helper - Setup común para tests del motor de cálculo

  Scenario: Inicializar configuración, API Key y payload base del engine
    * def utils       = call read('classpath:common/common-utils.feature')
    * def configSetup = call read('classpath:common/setup-engine-config.feature')
    * configure url   = engineBaseUrl
    * def enginePath  = '/api/v1/engine/calculate'
    * def keySetup    = call read('classpath:common/create-api-key.feature')
    * def validApiKey = keySetup.apiKey
    * def basePayload = read('classpath:data/engine/calculate-request.json')
