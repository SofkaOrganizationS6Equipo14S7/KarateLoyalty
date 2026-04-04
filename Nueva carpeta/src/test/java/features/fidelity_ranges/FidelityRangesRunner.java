package features.fidelity_ranges;

import com.intuit.karate.junit5.Karate;

class FidelityRangesRunner {

    @Karate.Test
    Karate testFidelityRanges() {
        return Karate.run("fidelity-ranges").relativeTo(getClass());
    }

}
