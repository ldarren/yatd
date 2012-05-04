<?php
// Copyright 2007 Facebook Corp.  All Rights Reserved. 
// 
// Application: Yatd 3D
// File: 'index.php' 
//   This is a sample skeleton for your application. 
// 

require_once '../facebook-platform/php/facebook.php';

$appapikey = 'ed31a65e55da33488cb4f758a415ac66';
$appsecret = '38db310b7e290030da0791851dec08de';
$facebook = new Facebook($appapikey, $appsecret);
$user_id = $facebook->require_login();

// Greet the currently logged-in user!
echo "<p>Hello, <fb:name uid=\"$user_id\" useyou=\"false\" />!</p>";

// Print out at most 25 of the logged-in user's friends,
// using the friends.get API method
echo "<p>Friends:";
$friends = $facebook->api_client->friends_get();
$friends = array_slice($friends, 0, 25);
foreach ($friends as $friend) {
  echo "<br>$friend";
}
echo "</p>";
?>