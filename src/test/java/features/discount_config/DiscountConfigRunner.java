package features.discount_config;

import com.intuit.karate.junit5.Karate;

class DiscountConfigRunner {

    @Karate.Test
    Karate testDiscountConfig() {
        return Karate.run("discount-config").relativeTo(getClass());
    }

}
