<html>

<header>
    <link href="home.css" type="text/css" rel="stylesheet">
  <script src="https://kit.fontawesome.com/af5a6f7cd6.js" crossorigin="anonymous"></script>
</header>

<body>
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
?>

<div class="header" id="myHeader">
        <span style="font-size:30px;cursor:pointer; float: left; font-family: 'Montserrat'; font-size: 24px;" onclick="openNav()">&#9776; Reports</span>
        <i class="fas fa-sun" style="color: yellow; font-size: 30px;"></i>
        <h1 align = "center">Humaarey Bachey</h1>
    </div>

    <div id="main">
    <div id="mySidenav" class="sidenav">
    <a href="javascript:void(0)" class="closebtn" onclick="closeNav()">&times;</a>
    <a href="home.php" class = "active">Report 1: Add | Edit | Delete</a>
    <a href="form12.php">Report 2: Student count per Class</a>
    <a href="form13.php">Report 3: Dormant Students</a>
    <a href="more_info14.php">Report 4: Student - Detailed Information</a>
    <a href="form15.php">Report 5: Parent - Detailed Information</a>
    </div>

<script>
function openNav() {
  document.getElementById("mySidenav").style.width = "250px";
  document.getElementById("main").style.marginLeft = "250px";
  document.body.style.backgroundColor = "rgba(0,0,0,0.4)";
}

function closeNav() {
  document.getElementById("mySidenav").style.width = "0";
  document.getElementById("main").style.marginLeft= "0";
  document.body.style.backgroundColor = "white";
}
</script>
    
    <form action="more_info14.php#searchThis" method="post">
    
    <div class="parent">
        <div class = "formtitle">
            <h2>Detailed Student Information</h2>
        </div>
    
        <div class="left">
          <textarea name = "searchEntry" placeholder="FULL NAME or ID" id="styled" rows="1" cols="50"></textarea>

          <select name = "searchBy">
            <option value="Name">Name</option>
            <option value="SID">Student ID</option>
          </select>

          <a href = "add_student.php"><button class="add_button" type="button">Add Student</button></a>
        </div>

        <div class = "submit_part" style="clear:both; display: block; width:fit-content; position: relative; margin: 0 auto; ">
            <a href = "#searchThis"><input type="submit" name = "submitForSearch" value = "Submit"></a>
        </div>
    </div>

  </form>

    <!-- searchEntry: 10043, searchBy: SID, submitForSearch = set-->
    <!--  -->

    <?php

    if (!empty($_POST["submitForSearch"]))
    {
        $username = "scott";                  // Use your username
        $password = "1234";             // and your password
        $database = "FARJAD";   // and the connect string to connect to your database
        $query_cond = "";

        if ($_POST["searchBy"] == "SID")
        {
            $query_cond = " WHERE STUDENT_ID = ".$_POST["searchEntry"];
        }
        else
        {
            $query_cond = " WHERE F_NAME||' '||L_NAME LIKE '".$_POST["searchEntry"]."%'";
        }
        
        $query = "SELECT STUDENT_ID, CNIC, TO_CHAR(DOB, 'DD/MM/YYYY') DOB, F_NAME||' '||L_NAME AS NAME, ROUND(MONTHS_BETWEEN(SYSDATE, DOB)/12,1) AS AGE, GENDER, CLASS_ID CLASS, SECTION_ID SECTION, CHALLAN_ID
        FROM STUDENT".$query_cond. 
        "ORDER BY CLASS_ID, SECTION_ID";

        $s = runQuery($username, $password, $database, $query);
        ?>
            
            <?php
                
                $result_id = 1;

                while (($row = oci_fetch_array($s, OCI_ASSOC+OCI_RETURN_NULLS)) != false) 
                {
                    ?>

                    <div class = "parent">

                    <div class = "minleft">
                    <a name = "searchThis"><h2><?php echo "RESULT #$result_id"; ?></h2></a>
                    </div>

                    <?php

                    $result_id = $result_id + 1;

                    $cur_id = $row['STUDENT_ID'];
                    
                    echo "<table id = 'output_table'><caption><h2>Student Info</h2?</caption>\n";
                    $ncols = oci_num_fields($s);
                    echo "<tr>\n";
                    for ($i = 1; $i <= $ncols; ++$i) {
                        $colname = oci_field_name($s, $i);
                        echo "  <th id = 'output_table'>".htmlspecialchars($colname,ENT_QUOTES|ENT_SUBSTITUTE)."</th>\n";
                    }

                    echo "<th id = 'output_table'>Edit</th>";
                    echo "<th id = 'output_table'>Delete</th>";
                    echo "</tr>\n";
                    echo "<tr id = 'output_table'>\n";
                    foreach ($row as $item) {
                        echo "<td id = 'output_table'>";
                        echo $item!==null?htmlspecialchars($item, ENT_QUOTES|ENT_SUBSTITUTE):"&nbsp;";
                        echo "</td>\n";
                    }
                    ?>
                    <td id = 'output_table'><a href="update_student.php?id=<?=$row['STUDENT_ID'];?>"><i class='far fa-edit' id = 'tcell'></i></a></td>
                    <td id = 'output_table'><a href="delete_student.php?id=<?=$row['STUDENT_ID'];?>"><i class='fa fa-trash' aria-hidden='true' id = 'tcell'></i></a></td>
                    <?php
                    echo "</tr>\n";
                
                    echo "</table>\n";




                    $query = "SELECT P2.CNIC FCNIC, PS2.F_NAME||' '||PS2.L_NAME AS FNAME, PS2.CONTACT_NO FCONTACT, P1.CNIC MCNIC, PS1.F_NAME||' '||PS1.L_NAME AS MNAME, PS1.CONTACT_NO MCONTACT
                    FROM FAMILY F
                    INNER JOIN PARENT P1 ON F.MOTHER_ID = P1.PARENT_ID
                    INNER JOIN PERSON PS1 ON PS1.CNIC = P1.CNIC
                    INNER JOIN PARENT P2 ON F.FATHER_ID = P2.PARENT_ID
                    INNER JOIN PERSON PS2 ON PS2.CNIC = P2.CNIC
                    WHERE F.FAMILY_ID = (SELECT FAMILY_ID FROM STUDENT WHERE STUDENT_ID = $cur_id)";

                    $ps = runQuery($username, $password, $database, $query);

                    if (($prow = oci_fetch_array($ps, OCI_ASSOC+OCI_RETURN_NULLS)) != false) 
                    {
                        echo "<table id = 'output_table'><caption><h2>Parents' Info</h2?</caption>\n";
                        $ncols = oci_num_fields($ps);
                        ?>
                        <tr>
                        <th id = 'output_table' colspan = 3>Father</th>
                        <th id = 'output_table' colspan = 3>Mother</th>
                        </tr>
                        
                        <th id = 'output_table' style = "background-color: #66D3FA; color: white;">CNIC</td>
                        <th id = 'output_table' style = "background-color: #66D3FA; color: white;">NAME</td>
                        <th id = 'output_table' style = "background-color: #66D3FA; color: white;">CONTACT_NO</td>
                        <th id = 'output_table' style = "background-color: #66D3FA; color: white;">CNIC</td>
                        <th id = 'output_table' style = "background-color: #66D3FA; color: white;">NAME</td>
                        <th id = 'output_table' style = "background-color: #66D3FA; color: white;">CONTACT_NO</td>
                        </tr>
                        <?php
                        echo "<tr id = 'output_table'>\n";
                        foreach ($prow as $item) {
                            echo "<td id = 'output_table'>";
                            echo $item!==null?htmlspecialchars($item, ENT_QUOTES|ENT_SUBSTITUTE):"&nbsp;";
                            echo "</td>\n";
                        }
                        echo "</tr>\n";
                    }
                    echo "</table>\n";




                    $query = "SELECT G.GUARDIAN_ID, G.CNIC, G.F_NAME||' '||G.L_NAME AS NAME, G.GENDER, G.CONTACT_NO FROM STUDENT S
                    INNER JOIN GUARDIAN G ON S.GUARDIAN_ID = G.GUARDIAN_ID
                    WHERE S.STUDENT_ID = $cur_id";

                    $ps = 0;
                    $ps = runQuery($username, $password, $database, $query);

                    if (($prow = oci_fetch_array($ps, OCI_ASSOC+OCI_RETURN_NULLS)) != false) 
                    {
                        echo "<table id = 'output_table'><caption><h2>Guardian Info</h2?</caption>\n";
                        $ncols = oci_num_fields($ps);
                        echo "<tr>\n";
                        for ($i = 1; $i <= $ncols; ++$i) {
                            $colname = oci_field_name($ps, $i);
                            echo "  <th id = 'output_table'>".htmlspecialchars($colname,ENT_QUOTES|ENT_SUBSTITUTE)."</th>\n";
                        }
                        echo "</tr>\n";

                        echo "<tr id = 'output_table'>\n";
                        foreach ($prow as $item) {
                            echo "<td id = 'output_table'>";
                            echo $item!==null?htmlspecialchars($item, ENT_QUOTES|ENT_SUBSTITUTE):"&nbsp;";
                            echo "</td>\n";
                        }
                        echo "</tr>\n";                    
                    }
                    echo "</table>\n";



                    $query = "SELECT ST2.STUDENT_ID, ST2.CNIC, ST2.F_NAME||' '||ST2.L_NAME NAME, TO_CHAR(ST2.DOB,'DD/MM/YYYY') DOB, ST2.GENDER, ST2.CLASS_ID CLASS, ST2.SECTION_ID SECTION, ST2.CHALLAN_ID, TO_CHAR(ST2.ADMIT_DATE, 'DD/MM/YYYY') ADMIT_DATE
                    FROM STUDENT ST1
                    INNER JOIN STUDENT ST2 
                    ON ST1.FAMILY_ID = ST2.FAMILY_ID
                    WHERE ST1.STUDENT_ID <> ST2.STUDENT_ID AND ST1.STUDENT_ID = $cur_id";

                    $ps = 0;
                    $ps = runQuery($username, $password, $database, $query);

                    echo "<table id = 'output_table'><caption><h2>Siblings Info</h2?</caption>\n";
                    $ncols = oci_num_fields($ps);
                    echo "<tr>\n";
                    for ($i = 1; $i <= $ncols; ++$i) {
                        $colname = oci_field_name($ps, $i);
                        echo "  <th id = 'output_table'>".htmlspecialchars($colname,ENT_QUOTES|ENT_SUBSTITUTE)."</th>\n";
                    }
                    echo "</tr>\n";

                    while (($prow = oci_fetch_array($ps, OCI_ASSOC+OCI_RETURN_NULLS)) != false) 
                    {
                        echo "<tr id = 'output_table'>\n";
                        foreach ($prow as $item) {
                            echo "<td id = 'output_table'>";
                            echo $item!==null?htmlspecialchars($item, ENT_QUOTES|ENT_SUBSTITUTE):"&nbsp;";
                            echo "</td>\n";
                        }
                        echo "</tr>\n";                    
                    }
                    echo "</table>\n";
                    echo "</div>\n";
                }
            ?>
        </div>

        <?php
    }

    ?>

</div>

    <div class = "footer">
        <h4 style="align-content: center;">Where Kids are #1</h4>
        <div class = "footermessage">
            <h3 style="color: white; font-size: 22px; font-weight: lighter;">Muhammad Farjad Ilyas</h3>
    </div>

    
</body>
</html>