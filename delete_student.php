<?php
$username = "scott";                  // Use your username
$password = "1234";             // and your password
$database = "localhost/FARJAD";   // and the connect string to connect to your database

$query = "DELETE FROM STUDENT WHERE STUDENT_ID = {$_GET['id']}";

$c = oci_connect($username, $password, $database);
if (!$c) {
    $m = oci_error();
    trigger_error('Could not connect to database: '. $m['message'], E_USER_ERROR);
}

$s = oci_parse($c, $query);
if (!$s) {
    $m = oci_error($c);
    trigger_error('Could not parse statement: '. $m['message'], E_USER_ERROR);
}
$r = oci_execute($s);
if (!$r) {
    $m = oci_error($s);
    if ($showerror == TRUE)
    {
        trigger_error('Could not execute statement: '. $m['message'], E_USER_ERROR);
        echo $query;
    }
}

header("Location: home.php");
exit;
?>