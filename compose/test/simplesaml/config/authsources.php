<?php

$config = array(

    // This is a authentication source which handles admin authentication.
    'admin' => array(
        // The default is to use core:AdminPassword, but it can be replaced with
        // any authentication source.

        'core:AdminPassword',
    ),


    'default-sp' => array(
    'cas:CAS',
    'cas' => array(
        'login' => 'https://webauth.arizona.edu/webauth/login',
        'validate' => 'https://webauth.arizona.edu/webauth/validate',
        'logout' => 'https://webauth.arizona.edu/webauth/logout'
    ),
    'ldap' => array(
        'servers' => 'ldaps://ldap.arizona.edu:636/',
        'enable_tls' => true,
        'searchbase' => 'ou=people,dc=org,dc=com',
        'searchattributes' => 'uid',
        'attributes' => array('uid','cn'),
        'priv_user_dn' => 'cn=simplesamlphp,ou=applications,dc=org,dc=com',
        'priv_user_pw' => 'password',

    ),
);

