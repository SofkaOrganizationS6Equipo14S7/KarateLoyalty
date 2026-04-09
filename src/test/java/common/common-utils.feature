@ignore
Feature: Common utility functions

  Scenario: Utility library
    * def uuid      = function(){ return java.util.UUID.randomUUID() + '' }
    * def timestamp = function(){ return java.lang.System.currentTimeMillis() + '' }
    * def randomUsername = function(prefix){ return (prefix || 'user') + '.' + java.util.UUID.randomUUID() }
    * def randomEmail   = function(prefix){ return (prefix || 'user') + '.' + java.util.UUID.randomUUID() + '@test.com' }
    * def futureDateRange =
    """
    function(offsetDays) {
      var random = Math.floor(Math.random() * 3000);
      var cal = java.util.Calendar.getInstance();
      cal.add(java.util.Calendar.YEAR, 10);
      cal.add(java.util.Calendar.DAY_OF_YEAR, (offsetDays || 0) + random);
      var fmt = new java.text.SimpleDateFormat('yyyy-MM-dd');
      var start = fmt.format(cal.getTime());
      cal.add(java.util.Calendar.DAY_OF_YEAR, 3);
      var end = fmt.format(cal.getTime());
      return { start: start, end: end };
    }
    """