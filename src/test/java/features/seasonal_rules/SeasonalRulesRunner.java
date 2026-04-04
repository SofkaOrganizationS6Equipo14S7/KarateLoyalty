package features.seasonal_rules;

import com.intuit.karate.junit5.Karate;

class SeasonalRulesRunner {

    @Karate.Test
    Karate testSeasonalRules() {
        return Karate.run("seasonal-rules").relativeTo(getClass());
    }

}
