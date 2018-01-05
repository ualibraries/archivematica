<?php

$metadata['https://test.sso.litnet.lt/auth/saml2/idp/metadata.php'] = array (
  'metadata-set' => 'saml20-idp-remote',
  'entityid' => 'https://test.sso.litnet.lt/auth/saml2/idp/metadata.php',
  'SingleSignOnService' => 
  array (
    0 => 
    array (
      'Binding' => 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect',
      'Location' => 'https://test.sso.litnet.lt/auth/saml2/idp/SSOService.php',
    ),
  ),
  'SingleLogoutService' => 
  array (
    0 => 
    array (
      'Binding' => 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect',
      'Location' => 'https://test.sso.litnet.lt/auth/saml2/idp/SingleLogoutService.php',
    ),
  ),
  'certData' => 'MIIDKjCCAhICCQCrlR3JPIbmmTANBgkqhkiG9w0BAQsFADBXMRswGQYDVQQDDBJ0ZXN0LnNzby5saXRuZXQubHQxDTALBgNVBAoMBHRlc3QxCzAJBgNVBAsMAklUMQswCQYDVQQGEwJMVDEPMA0GA1UEBwwGS2F1bmFzMB4XDTE2MDYwMjA1NDIzNloXDTI2MDYwMjA1NDIzNlowVzEbMBkGA1UEAwwSdGVzdC5zc28ubGl0bmV0Lmx0MQ0wCwYDVQQKDAR0ZXN0MQswCQYDVQQLDAJJVDELMAkGA1UEBhMCTFQxDzANBgNVBAcMBkthdW5hczCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBANWJzAP0sbTDqXouz3vKynQ7pxwUjm+Tadz6gzl2AO8G9vJfUar9Hq/FUolBZQbjEPeu9KCQzJSkHZ1OW5qjyA0DvcwUiUhMSOSIjlckjiuB84YUD5Kb5eN+0JLoW2UiFTqTHgfzRjDE87z8TpeTdL4gLA5jX1g2THa7NrgHDQSHQHe6KPLxK/meZvx1Si3IbbaHk9OIbVtpOucbm1qOFCvTFcJCgzS02hmbDyaDsqYshrOBhofPU0aOARZEzoS5v5LFlNRFiQ8+r7JrNYmcbrCe1yz9r45zeo62UiBi5C2+/DSJ3x9VfmyBlTMrKmyH/VIjkO6xs0y8FPq5dDlmAw0CAwEAATANBgkqhkiG9w0BAQsFAAOCAQEAWdvhewcKxIieLer6p8QZxFmFGWdLAKPuLxfGuQAopPYiJY7WDFTjV1tkedd2WUdGBTsso34cV7omCv19DyWZSn/UMPAXM3KibLD3X0X6ME2NDjndzOkiutw/tknC4j2F740NPek0CMdVnkIsOMk1JgPZu2ouIzlrlwRbwKzFbn9DWFVAjwhiBDyZUANguRxmmAb5tlw9qDycmdre8yOOrG/4IxgUXL/7lHoRJsZN26ABjL28jGsVPVQi3uuT3iHY/BfmyR8vqLIs7DkxbQtn4QK7XRgSY7pOQti0r/Xy9BaVg8wdFN4xqVqdFtM+U7HiEvSlRwjxb4/n8ngtrv3RVg==',
  'NameIDFormat' => 'urn:oasis:names:tc:SAML:2.0:nameid-format:transient',
  'OrganizationName' => 
  array (
    'en' => 'test',
    'lt' => 'test',
  ),
  'OrganizationDisplayName' => 
  array (
    'en' => 'test',
    'lt' => 'test',
  ),
  'OrganizationURL' => 
  array (
    'en' => 'http://www.test.lt/en',
    'lt' => 'http://www.test.lt',
  ),
  'scope' => 
  array (
    0 => 'test.lt',
  ),
  'UIInfo' => 
  array (
    'DisplayName' => 
    array (
      'en' => 'test',
      'lt' => 'test',
    ),
    'Description' => 
    array (
      'en' => 'test sso',
      'lt' => 'test vieningas prisijungimas',
    ),
    'InformationURL' => 
    array (
      'en' => 'http://www.test.lt/en',
      'lt' => 'http://www.test.lt',
    ),
    'Keywords' => 
    array (
      'en' => 
      array (
        0 => 'Kaunas',
        1 => 'test',
      ),
      'lt' => 
      array (
        0 => 'Kaunas',
        1 => 'test',
      ),
    ),
    'Logo' => 
    array (
      0 => 
      array (
        'url' => 'http://www.test.lt/images/logo/test_80x88.png',
        'height' => 88,
        'width' => 80,
        'lang' => 'en',
      ),
      1 => 
      array (
        'url' => 'http://www.test.lt/images/logo/test_80x88.png',
        'height' => 88,
        'width' => 80,
        'lang' => 'lt',
      ),
      2 => 
      array (
        'url' => 'http://www.test.lt/images/logo/test_16x16.png',
        'height' => 16,
        'width' => 16,
        'lang' => 'en',
      ),
      3 => 
      array (
        'url' => 'http://www.test.lt/images/logo/test_16x16.png',
        'height' => 16,
        'width' => 16,
        'lang' => 'lt',
      ),
    ),
  ),
  'RegistrationInfo' => 
  array (
    'authority' => 'https://fedi.litnet.lt',
    'instant' => '2014-05-01T11:00:03.577Z',
    'policies' => 
    array (
      'en' => 'https://fedi.litnet.lt/en',
      'lt' => 'https://fedi.litnet.lt/lt',
    ),
  ),
  'contacts' => 
  array (
    0 => 
    array (
      'emailAddress' => 'sso@test.lt',
      'contactType' => 'technical',
      'givenName' => 'test SSO Administrator',
    ),
  ),
);
