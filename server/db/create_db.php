<?php
$dbh=mysql_connect ("localhost", "root", "") or die ('I cannot connect to the database because: ' .mysql_error());
if (mysql_query("CREATE DATABASE rambus_ldarren",$dbh)) {
  echo "Database created";
} else {
  echo "Error creating database: " . mysql_error();
}
mysql_close($dbh);
?>