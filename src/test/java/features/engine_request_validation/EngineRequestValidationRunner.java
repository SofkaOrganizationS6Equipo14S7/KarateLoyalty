package features.engine_request_validation;

import com.intuit.karate.junit5.Karate;

class EngineRequestValidationRunner {

    @Karate.Test
    Karate testEngineRequestValidation() {
        return Karate.run("engine-request-validation").relativeTo(getClass());
    }

}
