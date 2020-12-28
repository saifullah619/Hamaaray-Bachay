
<!DOCTYPE html>

<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta charset="utf-8" />
    <title></title>
</head>
<body>
<form action="" method="post">
    <div id="container" style=" width:778px; margin:0 auto;border:2px solid black;">
        <p style="text-align:center;font-size:20px;">
            <b>
                HAMAREY BACHCHEY<br />
                STUDENT ACCOMPANYING FORM
            </b>
        </p>
        <p style="margin-left:50px;">
            Student ID
            <span style="margin-left:53px;">
                :
                <input type="text" name="SID" style=" width:250px;border-style:none;">
            </span>
        </p>
        <p style="margin-left:50px;">
            Current Section
            <span style="margin-left:35px;">
                :
                <input type="text" name="" style=" width:250px;border-style:none;">
            </span>
        </p>
        <p style="margin-left:50px;">
            New Section
            <span style="margin-left:54px;">
                :
                <input type="text" name="NSEC" style=" width:250px;border-style:none;">
            </span>
        </p>
        <p style="margin-left:50px;">
            Reason for Change :
            <input type="text" name="" style=" width:300px; border:1px solid #000;height:80px;">
        </p>
        <p style="margin-left:50px;">
            Approved by
            <span style="margin-left:38px;">
                :
                <input type="text" name="" style=" width:250px;border-style:none;">
            </span>
        </p>

        <div style="clear:both; display: block; width:fit-content; position: relative; margin: 0 auto 10px; ">
            <input name = "submitForUpdate"type="submit" value = "Submit">
        </div>
        </form>
    

<?php

if (!empty($_POST["submitForUpdate"]))
{

    $username = "scott";                  // Use your username
    $password = "1234";             // and your password
    $database = "FARJAD";

    $query = "UPDATE STUDENT
    SET SECTION_ID = '{$_POST['NSEC']}'
    WHERE STUDENT_ID = {$_POST['SID']}";

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
    else
    {
        ?>

        <h2 style = "text-align: center;">Section updated successfully!</h2>

        <?php
    }
}

?>

</div>
</body>
</html>