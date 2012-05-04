<?php
$dbh=mysql_connect ("localhost", "rambus_ldarren", "xenoflake") or die ('I cannot connect to the database because: ' .mysql_error());
mysql_select_db ("rambus_ldarren", $dbh);

// Drop table
$sql = "DROP TABLE IF EXISTS games";
if(! mysql_query( $sql, $dbh ) )
{
  die('Could not delete games table: ' . mysql_error());
}
$sql = "DROP TABLE IF EXISTS users";
if(! mysql_query( $sql, $dbh ) )
{
  die('Could not delete users table: ' . mysql_error());
}
$sql = "DROP TABLE IF EXISTS quests";
if(! mysql_query( $sql, $dbh ) )
{
  die('Could not delete quests table: ' . mysql_error());
}
echo "Tables deleted successfully<br>";

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
  cash INT DEFAULT 100,
  PRIMARY KEY (id)
)";

// Execute query
if (mysql_query($sql,$dbh)) {
  echo "tables created";
} else {
  echo "Error creating tables: " . mysql_error();
}

$sql = "CREATE TABLE quests
(
  id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  kills INT NOT NULL,
  cash SMALLINT DEFAULT -1,
  orbtype TINYINT DEFAULT -1,
  orbcount TINYINT DEFAULT 0,
  level INT DEFAULT 0,
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
