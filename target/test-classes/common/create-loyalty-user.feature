@ignore
Feature: Helper - Crear usuario administrador de Loyalty reutilizable para tests

  Scenario: Crear usuario con rol STORE_ADMIN para gestión de reglas de Loyalty
    * def result    = call read('classpath:common/create-store-admin.feature') { prefix: 'loyalty' }
    * def username  = result.username
    * def authToken = result.authToken
