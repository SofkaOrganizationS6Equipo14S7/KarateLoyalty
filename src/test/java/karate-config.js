function fn() {
  var env = karate.env; // get system property 'karate.env'
  karate.log('karate.env system property was:', env);
  if (!env) {
    env = 'dev';
  }
  var config = {
    env: env,
    engineBaseUrl:    'http://localhost:8082',
    adminBaseUrl:     'http://localhost:8081',
    validApiKey:      'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
    superAdminApiKey: 'super-admin-api-key-12345',

    // Credenciales por rol
    adminCredentials:      { username: 'admin',       password: 'Pass123!' },
    storeAdminCredentials: { username: 'store_admin', password: 'Pass123!' },
    userCredentials:       { username: 'user.std',    password: 'Pass123!' },
    loyaltyCredentials:    { username: 'loyalty',     password: 'Pass123!' },

    // IDs de ecommerce para pruebas
    validEcommerceId:      'ECOM-001',
    ecommerceIdB:          'ECOM-002',
    invalidEcommerceId:    'ID-INEXISTENTE',
    storeAdminEcommerceId: 'ECOM-001',
    otherEcommerceId:      'ECOM-002'
  }
  if (env == 'dev') {
    // dev defaults already set above
  } else if (env == 'e2e') {
    config.engineBaseUrl    = 'http://engine-service:8082';
    config.adminBaseUrl     = 'http://admin-service:8081';
    config.validApiKey      = karate.properties['api.key'];
    config.superAdminApiKey = karate.properties['super.admin.api.key'];
  }
  return config;
}