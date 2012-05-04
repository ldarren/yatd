<?php
	$conn=new mysqli ("localhost", "rambus_ldarren", "xenoflake","rambus_ldarren") or die ("I cannot connect to the database because: " .mysql_error());
	
	if ($conn->query("DELETE FROM users;")){
		echo "Cleared";
	} else {
		echo "Error"+$conn->error;
	}
	$conn->close();
?>
