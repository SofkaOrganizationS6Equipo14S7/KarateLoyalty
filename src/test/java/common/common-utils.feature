@ignore
Feature: Common utility functions

  Scenario: Utility library
    * def uuid      = function(){ return java.util.UUID.randomUUID() + '' }
    * def timestamp = function(){ return java.lang.System.currentTimeMillis() + '' }
    * def randomInt = function(max){ return Math.floor(Math.random() * max) }
