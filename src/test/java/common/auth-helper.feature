@ignore
Feature: Helper de autenticación condicional

  Scenario: Obtener authHeaders con login opcional
    * def loginResult = requiresLogin ? karate.call('classpath:common/login.feature', { username: username, password: password }) : { authToken: null }
    * def authHeaders = loginResult.authToken ? { Authorization: 'Bearer ' + loginResult.authToken } : {}
