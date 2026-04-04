package features.product_rules;

import com.intuit.karate.junit5.Karate;

class ProductRulesRunner {

    @Karate.Test
    Karate testProductRules() {
        return Karate.run("product-rules").relativeTo(getClass());
    }

}
