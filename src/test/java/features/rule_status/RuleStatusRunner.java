package features.rule_status;

import com.intuit.karate.junit5.Karate;

class RuleStatusRunner {

    @Karate.Test
    Karate testRuleStatus() {
        return Karate.run("rule-status").relativeTo(getClass());
    }

}
