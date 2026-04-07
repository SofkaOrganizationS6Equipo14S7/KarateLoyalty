package features.super_admin;

import com.intuit.karate.junit5.Karate;

class SuperAdminRunner {

    @Karate.Test
    Karate testSuperAdmin() {
        return Karate.run("super-admin").relativeTo(getClass());
    }

}
