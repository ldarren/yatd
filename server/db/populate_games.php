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


$sql = "INSERT INTO games ".
       "(title,api, secret) ".
       "VALUES ".
       "('harvester','ed31a65e55da33488cb4f758a415ac66','38db310b7e290030da0791851dec08de')";
if(! mysql_query( $sql, $conn ) ) {
  die('Could not enter data: ' . mysql_error());
}
echo "Entered data successfully\n";
mysql_close($conn);
?>
</body>
</html>