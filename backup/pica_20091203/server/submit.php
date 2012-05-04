<html>

<head>
</head>

<body>
<?php
$map = $_POST["map"];
$hfile = fopen("map.txt", 'w+') or die("can't open file");
fwrite($hfile, $map);
fclose($hfile);
?>
</body>

</html>