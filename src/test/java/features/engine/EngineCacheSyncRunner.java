package features.engine;

import com.intuit.karate.junit5.Karate;

class EngineCacheSyncRunner {

    @Karate.Test
    Karate testEngineCacheSync() {
        return Karate.run("engine-cache-sync").relativeTo(getClass());
    }

}
