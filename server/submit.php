<?php
$ret="ret=OK";
if (isset($_POST['action'])){
	$conn=new mysqli ("localhost", "rambus_ldarren", "xenoflake","rambus_ldarren") or die ("I cannot connect to the database because: " .mysql_error());
	
	$action = $_POST['action'];
	$userid=$_POST['id'];
	if (empty($action) || empty($userid)) $ret="ret=KO&msg=missing action or userid";
	$ret.="&action=$action";
	switch ($action){
	case 'save':
		$map=$_POST['map'];
		$inventory=$_POST['inv'];
		$score=$_POST['score'];
		$level=$_POST['lvl'];
		$cash=$_POST['cash'];
		if (empty($map) && empty($inventory) && !isset($score) && !isset($level) && !isset($cash)){
			$ret="ret=KO&msg=nothing to be saved";
			break;
		}
		if ($result = $conn->query("SELECT COUNT(*) FROM users WHERE user_id='$userid';")){
			$row = $result->fetch_row();
			if ($row[0] == 0){
				$val="";
				$cols="";
				if (isset($cash)) {$cols.="cash, "; $vals.="$cash, ";}
				if (isset($level)) {$cols.="level, "; $vals.="$level, ";}
				if (isset($score)) {$cols.="score, "; $vals.="$score, ";}
				if (isset($inventory)) {$cols.="inventory, "; $vals.="'$inventory', ";}
				if (isset($map)) {$cols.="map, "; $vals.="'$map', ";}
				$cols.="user_id"; $vals.="'$userid'";
				if (!$conn->query("INSERT INTO users ($cols) VALUES ($vals)")){
					$ret="ret=KO&msg=$conn->error";
				}
			} else {
				$statement="";
				if (isset($cash)) $statement.="cash=$cash, ";
				if (isset($level)) $statement.="level=$level, ";
				if (isset($score)) $statement.="score=$score, ";
				if (isset($inventory)) $statement.="inventory='$inventory', ";
				if (isset($map)) $statement.="map='$map', ";
				$statement.= "user_id='$userid'";
				$conn->query("UPDATE users SET $statement WHERE user_id=$userid;");
				if ($conn->affected_rows == -1) { // zero update is common if data r the same, therefore only check for error
					$ret="ret=KO&msg=$conn->error";
				}
			}
			$result->free();
		} else {
			$ret="ret=KO&msg=$conn->error";
		}
		break;
	default:
		$ret="ret=KO&msg=undefined submit action: $action";
		break;
	}
	
	$conn->close();
} else {
	$ret="ret=KO&msg=no action";
}
echo $ret;
?>
