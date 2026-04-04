package features.engine;

import com.intuit.karate.junit5.Karate;

class EngineAuthRunner {

    @Karate.Test
    Karate testEngineAuth() {
        return Karate.run("engine-auth").relativeTo(getClass());
    }

}
