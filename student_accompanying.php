
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
        <p style="font-size:20px;margin-left:10px;">
            <b>
                Student Information:
            </b>
        </p>
        <p style="margin-left:100px;">
            ID 
            <span style="margin-left:60px;">
                :
                <input type="text" name="SID" style=" width:250px;border-style:none;">
            </span>
        </p>
        <p style="margin-left:100px;">
            Name
            <span style="margin-left:38px;">
                :
                <input type="text" name="SNAME" style=" width:250px;border-style:none;">
            </span>
        </p>
        <p style="margin-left:100px;">
            Class
            <span style="margin-left:41px;">
                :
                <input type="text" name="SCLASS" style=" width:250px;border-style:none;">
            </span>
        </p>
        <p style="font-size:20px;margin-left:10px;">
            <b>
                Accompanying Guardian Information:
            </b>
        </p>
        <p style="margin-left:40px;">
            ID
            <span style="margin-left:60px;">
                :
                <input type="text" name="GID" style=" width:250px;border-style:none;">
            </span>
        </p>
        <p style="margin-left:40px;">
            Name
            <span style="margin-left:38px;">
                :
                <input type="text" name="GNAME" style=" width:250px;border-style:none;">
            </span>
        </p>
        <p style="margin-left:40px;">
            Pregnant  
            <span style="margin-left:20px;">
                :
                <input type="radio" id="GPYES" name="GPREG" value="YES">
                <label for="GPYES">Yes</label>
            
                <input type="radio" id="GPNO" name="GPREG" value="NO" checked>
                <label for="GPNO">No</label>
                </label>
            </span>
        </p>
        <p style="margin-left:40px;">
            Reason for
            Parents Absence :
            <input type="text" name="REASON" style=" width:300px; border:1px solid #000;height:80px;">
        </p>

        <div style="clear:both; display: block; width:fit-content; position: relative; margin: 0 auto 10px; ">
            <input name = "submitForInsert"type="submit" value = "Submit">
        </div>
    </form>

<?php

    if (!empty($_POST["submitForInsert"]))
    {

        $username = "scott";                  // Use your username
        $password = "1234";             // and your password
        $database = "FARJAD";
        $gpreg = 0; 

        if ($_POST["GPREG"] == "YES")
        {
            $gpreg = 1;
        }
    
        $query = "INSERT INTO ACCOMPANYING
        VALUES({$_POST['SID']}, 0, {$_POST['GID']}, $gpreg, '{$_POST['REASON']}')";

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

            <h2 style = "text-align: center;">Student insertion successful!</h2>

            <?php
        }
    }

?>

    </div>
</body>
</html>