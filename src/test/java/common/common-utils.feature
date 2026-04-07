@ignore
Feature: Common utility functions

  Scenario: Utility library
    * def uuid      = function(){ return java.util.UUID.randomUUID() + '' }
    * def timestamp = function(){ return java.lang.System.currentTimeMillis() + '' }
    * def randomUsername = function(prefix){ return (prefix || 'user') + '.' + java.util.UUID.randomUUID() }
    * def randomEmail   = function(prefix){ return (prefix || 'user') + '.' + java.util.UUID.randomUUID() + '@test.com' }