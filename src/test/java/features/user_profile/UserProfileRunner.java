package features.user_profile;

import com.intuit.karate.junit5.Karate;

class UserProfileRunner {

    @Karate.Test
    Karate testUserProfile() {
        return Karate.run("user-profile").relativeTo(getClass());
    }

}
