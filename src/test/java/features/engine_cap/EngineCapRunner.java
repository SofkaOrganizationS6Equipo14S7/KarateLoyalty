package features.engine_cap;

import com.intuit.karate.junit5.Karate;

class EngineCapRunner {

    @Karate.Test
    Karate testEngineCap() {
        return Karate.run("engine-cap").relativeTo(getClass());
    }

}
