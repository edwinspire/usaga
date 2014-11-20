<?php
include "pg.php";

if (isset($_uHTTP_POST['idevent'])) {
	$result = pg_query_params($pGdbconn, 'SELECT usaga.fun_event_comment_insert_xml($1::integer, $2::integer, $3::integer, $4::integer, $5::text, $6::integer[], $7::boolean);', array($_uHTTP_POST['idevent'], $_uHTTP_POST['idadmin'], $_uHTTP_POST['seconds'], $_uHTTP_POST['status'], $_uHTTP_POST['comment'], "{}", true));
$val = pg_fetch_result($result, 0, 0);
echo $val;
}else{
echo "<table></table>";
}
?>
