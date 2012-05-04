<?php
$returnVars = array();
$hfile = fopen("map.txt", 'r') or die("can't open file");
$returnVars['map']=fgets($hfile);
fclose($hfile);
$returnString = http_build_query($returnVars);

// send variables back to Flash
echo $returnString;
?>