function fn() {
  var env = karate.env || 'dev';
  karate.log('karate.env:', env);

  var envUrls = {
    dev:     { admin: 'http://localhost:8081', engine: 'http://localhost:8082' },  };
  var urls = envUrls[env] || envUrls['dev'];

  var config = {
    env: env,
    adminBaseUrl:  karate.properties['admin.base.url']  || urls.admin,
    engineBaseUrl: karate.properties['engine.base.url'] || urls.engine,
    adminCredentials: { username: karate.properties['admin.user'] || 'admin',
                        password: karate.properties['admin.pass'] || 'admin123' },
    testUserPassword: karate.properties['test.user.password'] || 'Admin123456!@',
    storeAdminRoleId: karate.properties['role.store.admin'] || 'fa94e179-670c-484a-a8ae-5e55a400b724',
    storeUserRoleId:  karate.properties['role.store.user']  || '8c23eacb-dbbd-4f31-9613-af9cda1d4cce',
    validEcommerceId:   karate.properties['test.ecommerce.id']       || '550e8400-e29b-41d4-a716-446655440000',
    otherEcommerceId:   karate.properties['test.ecommerce.other.id'] || '550e8400-e29b-41d4-a716-446655440001',
    nonExistentId:      '00000000-0000-0000-0000-000000000099',
    seasonalPriorityId: karate.properties['test.priority.seasonal']  || '550e8400-e29b-41d4-a716-446655440111',
    productPriorityId:  karate.properties['test.priority.product']   || '550e8400-e29b-41d4-a716-446655440112'
  };
  return config;
}