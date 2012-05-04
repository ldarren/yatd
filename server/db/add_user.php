<?php
$dbh=mysql_connect ("localhost", "root", "") or die ('I cannot connect to the database because: ' .mysql_error());
if (mysql_query("GRANT ALL ON rambus_ldarren.* TO rambus_ldarren@localhost IDENTIFIED BY 'xenoflake'",$dbh)) {
  echo "user created";
} else {
  echo "Error creating user: " . mysql_error();
}
mysql_close($dbh);
?>