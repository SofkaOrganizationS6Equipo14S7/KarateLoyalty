package features.ecommerces;

import com.intuit.karate.junit5.Karate;

class EcommercesRunner {

    @Karate.Test
    Karate testEcommerces() {
        return Karate.run("ecommerces").relativeTo(getClass());
    }

}
