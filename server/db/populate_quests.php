<html>
<head>
<title>Add New Record in MySQL Database</title>
</head>
<body>
<?php
$dbhost = 'localhost';
$dbuser = 'rambus_ldarren';
$dbpass = 'xenoflake';
$conn = mysql_connect($dbhost, $dbuser, $dbpass) or die ('I cannot connect to the database because: ' .mysql_error());
mysql_select_db('rambus_ldarren', $conn);


$sql = "INSERT INTO quests ".
       "(kills,cash, orbtype, orbcount,level) ".
       "VALUES ".
       "(5, 10, -1, 0, 0),".
       "(15, 50, -1, 0, 0),".
       "(30, 300, -1, 0, 0),".
       "(50, -1, 1, 1, 0),".
       "(100, -1, 1, 3, 0)";
if(! mysql_query( $sql, $conn ) ) {
  die('Could not enter data: ' . mysql_error());
}
echo "Entered data successfully\n";
mysql_close($conn);
?>
</body>
</html>