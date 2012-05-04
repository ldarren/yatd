<?php

//////////////////////////////////////////////////////////////////////
//
// main.php 
//
///////////////////////////////////////////////////////////////////////

//include facebook api etc.
require_once("facebook.php");

//create new facebook instance
$facebook = new Facebook("ed31a65e55da33488cb4f758a415ac66", "38db310b7e290030da0791851dec08de");

//prompt the user to login
$fb_user = $facebook->require_login();

//check if the user has added the app
if (!$facebook->api_client->users_isAppUser()) {
	//if not, redirect him to add it
	$facebook->redirect($facebook->get_add_url());
}

?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
	<title>play</title>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<meta name="language" content="en" />
	<meta name="description" content="" />
	<meta name="keywords" content="" />
	
	<script src="js/swfobject.js" type="text/javascript"></script>
	<script type="text/javascript">
		var flashvars = {
		};
		var params = {
			menu: "false",
			scale: "noScale",
			allowFullscreen: "true",
			allowScriptAccess: "always",
			bgcolor: "#000000"
		};
		var attributes = {
			id:"pica_player"
		};
		var href = window.location.href;
		if (href.indexOf("?") > -1 ) {
		  var queries = href.substr(href.indexOf("?")+1);
		  var pairs = queries.split("&");
		  for (var i = 0; i < pairs.length; ++i) {
		    var param = pairs[i].split("=");
			flashvars[param[0]] = param[1];
		  }
		}
		swfobject.embedSWF("play.swf", "altContent", "760", "600", "10.0.0", "expressInstall.swf", flashvars, params, attributes);
	</script>
	<style>
		html, body { height:100%; }
		body { margin:0; }
	</style>
</head>
<body>
	<div id="altContent">
		<h1>play</h1>
		<p>Alternative content</p>
		<p><a href="http://www.adobe.com/go/getflashplayer"><img 
			src="http://www.adobe.com/images/shared/download_buttons/get_flash_player.gif" 
			alt="Get Adobe Flash player" /></a></p>
	</div>
</body>
</html>