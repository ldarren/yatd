<?php
$dbh=mysql_connect ("localhost", "rambus_ldarren", "xenoflake") or die ('I cannot connect to the database because: ' .mysql_error());
mysql_select_db ("rambus_ldarren", $dbh);

// Drop table
$sql = "DROP TABLE users";
if(! mysql_query( $sql, $dbh ) )
{
  die('Could not delete table: ' . mysql_error());
}
echo "Table deleted successfully\n";

// Create table
$sql = "CREATE TABLE users
(
  id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id CHAR(20) BINARY NOT NULL,
  map BLOB(4096),
  inventory BLOB(4096),
  level INT DEFAULT 1,
  cash INT DEFAULT 100,
  score INT DEFAULT 0,
  PRIMARY KEY (id)
)";

// Execute query
if (mysql_query($sql,$dbh)) {
  echo "tables created";
} else {
  echo "Error creating tables: " . mysql_error();
}

mysql_close($dbh);
?>
