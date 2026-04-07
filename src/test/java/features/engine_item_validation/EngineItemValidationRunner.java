package features.engine_item_validation;

import com.intuit.karate.junit5.Karate;

class EngineItemValidationRunner {

    @Karate.Test
    Karate testEngineItemValidation() {
        return Karate.run("engine-item-validation").relativeTo(getClass());
    }

}
