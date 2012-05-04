<?php
$dbh=mysql_connect ("localhost", "rambus_ldarren", "xenoflake") or die ('I cannot connect to the database because: ' .mysql_error());
mysql_select_db ("rambus_ldarren", $dbh);

// Drop table
$sql = "DROP TABLE games";
if(! mysql_query( $sql, $dbh ) )
{
  die('Could not delete table: ' . mysql_error());
}
$sql = "DROP TABLE users";
if(! mysql_query( $sql, $dbh ) )
{
  die('Could not delete table: ' . mysql_error());
}
echo "Table deleted successfully\n";

// Create table
$sql = "CREATE TABLE games
(
  id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  title VARCHAR(32) BINARY NOT NULL,
  api VARCHAR(32) BINARY NOT NULL,
  secret VARCHAR(32) BINARY NOT NULL,
  PRIMARY KEY (id)
)";

// Execute query
if (mysql_query($sql,$dbh)) {
  echo "tables created";
} else {
  echo "Error creating tables: " . mysql_error();
}
$sql = "CREATE TABLE users
(
  id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id CHAR(9) BINARY NOT NULL,
  map BLOB(5120),
  inventory BLOB(5120),
  level INT,
  cash INT,
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
