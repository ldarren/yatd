<?php
$ret="ret=OK";
if (isset($_GET['action'])){
	$conn=new mysqli ("localhost", "rambus_ldarren", "xenoflake","rambus_ldarren") or die ("I cannot connect to the database because: " .mysql_error());
	
	$action = $_GET['action'];
	$ret.="&action=$action";
	switch ($action){
	case 'api':
		$title=$_GET['title'];
		if (isset($title)){
			if ($result = $conn->query("SELECT api, secret FROM games WHERE title='$title';")){
				while ($row = $result->fetch_row()) {
					$ret.="&api=$row[0]&secret=$row[1]";
				}
				$result->free();
			} else {
				$ret="ret=KO&msg=$conn->error";
			}
		} else {
			$ret="ret=KO&msg=no title";
		}
		break;
	case 'pview': // preview, for friends list therefore level should be zero for non-player
		$userid=$_GET['id'];
		if (isset($userid)){
			if ($result = $conn->query("SELECT cash, level, score FROM users WHERE user_id='$userid';")){
				if ($conn->affected_rows == 0){
					$data="&uid=$userid&cash=0&lvl=0&score=0";
				} else {
					while ($row = $result->fetch_row()) {
						$data="&uid=$userid&cash=$row[0]&lvl=$row[1]&score=$row[2]";
					}
				}
				$ret.=$data;
				$result->free();
			} else {
				$ret="ret=KO&msg=$conn->error";
			}
		} else {
			$ret="ret=KO&msg=no user id";
		}
		break;
	case 'load': // load all for player, therefore if no record should return level=1
		$userid=$_GET['id'];
		if (isset($userid)){
			if ($result = $conn->query("SELECT map, inventory, cash, level, score FROM users WHERE user_id='$userid';")){
				if ($conn->affected_rows == 0){
					$data="&uid=$userid&map=''&inv=''&cash=100&lvl=1&score=0";
				} else {
					while ($row = $result->fetch_row()) {
						$data="&uid=$userid&map=$row[0]&inv=$row[1]&cash=$row[2]&lvl=$row[3]&score=$row[4]";
					}
				}
				$ret.=$data;
				$result->free();
			} else {
				$ret="ret=KO&msg=$conn->error";
			}
		} else {
			$ret="ret=KO&msg=no user id";
		}
		break;
	case 'quiz':
		$level=$_GET['lvl'];
		if (isset($level)){
			if ($result = $conn->query("SELECT kills, cash, orbtype, orbcount FROM quests WHERE level<$level+5 AND level > $level-5;")){
				if ($conn->affected_rows == 0){
					$data="&kills=$userid&map=''&inv=''&cash=100&lvl=1&score=0";
				} else {
					$data="&num=$conn->affected_rows";
					$i=0;
					while ($row = $result->fetch_row()) {
						$data.="&q$i=$row[0],$row[1],$row[2],$row[3]";
						$i++;
					}
				}
				$ret.=$data;
				$result->free();
			} else {
				$ret="ret=KO&msg=$conn->error";
			}
		} else {
			$ret="ret=KO&msg=no level";
		}
		break;
	default:
		$ret="ret=KO&msg=undefined request action: $action";
	}
	
	$conn->close();
} else {
	$ret="ret=KO&msg=no action";
}
echo $ret;
?>
