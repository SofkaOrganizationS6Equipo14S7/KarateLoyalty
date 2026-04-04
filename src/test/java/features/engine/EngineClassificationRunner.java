package features.engine;

import com.intuit.karate.junit5.Karate;

class EngineClassificationRunner {

    @Karate.Test
    Karate testEngineClassification() {
        return Karate.run("engine-classification").relativeTo(getClass());
    }

}
