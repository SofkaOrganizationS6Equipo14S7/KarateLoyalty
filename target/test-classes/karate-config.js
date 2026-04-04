function fn() {
  var env = karate.env; // get system property 'karate.env'
  karate.log('karate.env system property was:', env);
  if (!env) {
    env = 'dev';
  }
  var config = {
    env: env,
    engineBaseUrl: 'http://localhost:8080',
    adminBaseUrl:  'http://localhost:8081',
    validApiKey:   'a1b2c3d4-e5f6-7890-abcd-ef1234567890'
  }
  if (env == 'dev') {
    config.engineBaseUrl = 'http://localhost:8080';
    config.adminBaseUrl  = 'http://localhost:8081';
    config.validApiKey   = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890';
  } else if (env == 'e2e') {
    config.engineBaseUrl = 'http://engine-service:8080';
    config.adminBaseUrl  = 'http://admin-service:8081';
    config.validApiKey   = karate.properties['api.key'];
  }
  return config;
}