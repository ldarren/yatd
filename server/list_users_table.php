<html>
<head>
<title>Table Listing</title>
</head>
<body>
<table border="1">
<tr><th>id</th><th>user_id</th><th>map</th><th>inventory</th><th>level</th><th>cash</th><th>score</th></tr>
<?php
	$conn=new mysqli ("localhost", "rambus_ldarren", "xenoflake","rambus_ldarren") or die ("I cannot connect to the database because: " .mysql_error());
	
	if ($result = $conn->query("SELECT id, user_id, map, inventory, level, cash, score FROM users;")){
		while ($row = $result->fetch_row()) {
			echo "<tr><td>$row[0]</td><td>$row[1]</td><td>$row[2]</td><td>$row[3]</td><td>$row[4]</td><td>$row[5]</td><td>$row[6]</td></tr>";
		}
		$result->free();
	}
		if ($result = $conn->query("SELECT COUNT(*) FROM users WHERE user_id='100000481579781';")){
			$row = $result->fetch_row();
			echo "return rows: $conn->affected_rows count: $row[0]";
			$result->free();
		} else {
			echo "Error: $conn->error";
		}

	$conn->close();
?>
</table>
</body>
</html>