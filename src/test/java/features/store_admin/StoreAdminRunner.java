package features.store_admin;

import com.intuit.karate.junit5.Karate;

class StoreAdminRunner {

    @Karate.Test
    Karate testStoreAdmin() {
        return Karate.run("store-admin").relativeTo(getClass());
    }

}
