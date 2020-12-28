<html>

<link href="home.css" type="text/css" rel="stylesheet">

<header>
    <script src="https://kit.fontawesome.com/af5a6f7cd6.js" crossorigin="anonymous"></script>
</header>

<body>
<form action="" method="post">
<?php

    function runQuery($username, $password, $database, $query, $showerror = TRUE) 
    {
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

        return $s;
    }

    $query = "SELECT STUDENT_ID, CNIC, F_NAME, L_NAME, TO_CHAR(DOB,'DD/MM/YYYY') DOB, GENDER, CLASS_ID, SECTION_ID, CHALLAN_ID, TO_CHAR(ADMIT_DATE, 'DD/MM/YYYY') ADMIT_DATE
    FROM STUDENT
    WHERE STUDENT_ID = {$_GET['id']}";

    $username = "scott";                  // Use your username
    $password = "1234";             // and your password
    $database = "FARJAD";   // and the connect string to connect to your database

    $s = runQuery($username, $password, $database, $query);

?>

    <div class="header" id="myHeader">
        <i class="fas fa-sun" style="color: yellow; font-size: 30px;"></i>
        <a href = "home.php"><h1 align = "center">Humaarey Bachey</h1></a>
    </div>

    <div class = "parent" style = "width: 90%; margin-bottom: 5%">
        <div class = "formtitle">
            <h2>Update a record</h2>
        </div>

        <?php

            echo "<table id = 'output_table' style = 'width: 90%;'>\n";
            $ncols = oci_num_fields($s);
            echo "<tr>\n";
            for ($i = 1; $i <= $ncols; ++$i) {
                $colname = oci_field_name($s, $i);
                echo "  <th id = 'output_table'>".htmlspecialchars($colname,ENT_QUOTES|ENT_SUBSTITUTE)."</th>\n";
            }

            $row = oci_fetch_array($s, OCI_ASSOC+OCI_RETURN_NULLS);

        ?>

            <tr id = 'output_table'>

            <td id = "output_table"><?php echo $row['STUDENT_ID']!==null?htmlspecialchars($row['STUDENT_ID'], ENT_QUOTES|ENT_SUBSTITUTE):"&nbsp;";?></td>
            <td id = "output_table"><?php echo $row['CNIC']!==null?htmlspecialchars($row['CNIC'], ENT_QUOTES|ENT_SUBSTITUTE):"&nbsp;";?></td>
            <td id = "output_table"><?php echo $row['F_NAME']!==null?htmlspecialchars($row['F_NAME'], ENT_QUOTES|ENT_SUBSTITUTE):"&nbsp;";?></td>
            <td id = "output_table"><?php echo $row['L_NAME']!==null?htmlspecialchars($row['L_NAME'], ENT_QUOTES|ENT_SUBSTITUTE):"&nbsp;";?></td>
            <td id = "output_table"><?php echo $row['DOB']!==null?htmlspecialchars($row['DOB'], ENT_QUOTES|ENT_SUBSTITUTE):"&nbsp;";?></td>
            <td id = "output_table"><?php echo $row['GENDER']!==null?htmlspecialchars($row['GENDER'], ENT_QUOTES|ENT_SUBSTITUTE):"&nbsp;";?></td>
            <td id = "output_table"><input type = "text" name = "sCLASS" size = 10 value = "<?php echo $row['CLASS_ID']!==null?htmlspecialchars($row['CLASS_ID'], ENT_QUOTES|ENT_SUBSTITUTE):"&nbsp;";?>"></td>
            <td id = "output_table"><input type = "text" name = "sSECTION" size = 10 value = "<?php echo $row['SECTION_ID']!==null?htmlspecialchars($row['SECTION_ID'], ENT_QUOTES|ENT_SUBSTITUTE):"&nbsp;";?>"></td>
            <td id = "output_table"><input type = "text" size = 10 name = "sCHALLAN" value = "<?php echo $row['CHALLAN_ID']!==null?htmlspecialchars($row['CHALLAN_ID'], ENT_QUOTES|ENT_SUBSTITUTE):"&nbsp;";?>"></td>
            <td id = "output_table"><input type = "text" size = 10 name = "sADMIT" value = "<?php echo $row['ADMIT_DATE']!==null?htmlspecialchars($row['ADMIT_DATE'], ENT_QUOTES|ENT_SUBSTITUTE):"&nbsp;";?>"></td>

            </tr>
        </table>

        
        <div class = "submit_part" style="clear:both; display: block; width:fit-content; position: relative; margin: 0 auto; ">
            <input type="submit" name = "submitForUpdate" value = "Submit">
        </div>
        </form>
    </div>

    <?php

    if (!empty($_POST["submitForUpdate"]))
    {
        $query = "UPDATE STUDENT
        SET CLASS_ID = {$_POST['sCLASS']},
        SECTION_ID = '{$_POST['sSECTION']}',
        CHALLAN_ID = '{$_POST['sCHALLAN']}',
        ADMIT_DATE = TO_DATE('{$_POST['sADMIT']}', 'DD/MM/YYYY'),
        LAST_UPDATE_DATE = SYSDATE
        WHERE STUDENT_ID = {$_GET['id']}";

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

            <div class = "bubblemem">
                <i class="fa fa-check" style="color: white; font-size: 24px; white-space: nowrap; margin-right: 20px"></i>    
                <h2 style="color: white; display: inline-block;">Record updated successfully</h2>   
            </div>

            <?php
        }
    }

    ?>

    <div class = "footer">
        <h4 style="align-content: center;">Where Kids are #1</h4>
        <div class = "footermessage">
            <h3 style="color: white; font-size: 22px; font-weight: lighter;">Muhammad Farjad Ilyas</h3>
        </div>
    </div>

</body>
</html>