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
    
    <form action="" method="post">
    
    <div class="parent">
        <div class = "formtitle">
            <h2>Class Information</h2>
        </div>
    
        <div class="left">
          <textarea name = "searchEntry" placeholder="e.g Number: 1A/3C/9A       e.g Name: AAA/ABC/ABA" id="styled" rows="1" cols="50"></textarea>

          <select name = "searchBy">
            <option value="CID">Class Number</option>
            <option value="NAME">Class Name</option>
          </select>
        </div>

        <div class = "submit_part" style="clear:both; display: block; width:fit-content; position: relative; margin: 0 auto; ">
            <input type="submit" name = "submitForSearch" value = "Submit">
        </div>
    </div>
  </form>

  <?php

    if (!empty($_POST["submitForSearch"]))
    {
        $username = "scott";                  // Use your username
        $password = "1234";             // and your password
        $database = "FARJAD";   // and the connect string to connect to your database
        $query_cond = "";

        if ($_POST["searchBy"] == "CID")
        {
            $query_cond = " WHERE S.CLASS_ID||S.SECTION_ID = '".$_POST["searchEntry"]."'";
        }
        else
        {
            $query_cond = " WHERE S.TITLE = '".$_POST["searchEntry"]."'";
        }

        $query = "SELECT S.CLASS_ID, S.SECTION_ID, S.TITLE, COUNT(STM.STUDENT_ID) AS NUM_MALE_STUDENTS, COUNT(STF.STUDENT_ID) AS NUM_FEMALE_STUDENTS, COUNT(STM.STUDENT_ID) + COUNT(STF.STUDENT_ID) TOTAL_NUM_STUDENTS
        FROM STUDENT ST
        LEFT JOIN STUDENT STM ON ST.STUDENT_ID = STM.STUDENT_ID AND STM.GENDER = 'M'
        LEFT JOIN STUDENT STF ON ST.STUDENT_ID = STF.STUDENT_ID AND STF.GENDER = 'F'
        RIGHT JOIN SECTION S ON ST.CLASS_ID = S.CLASS_ID AND ST.SECTION_ID = S.SECTION_ID
        $query_cond
        GROUP BY S.CLASS_ID, S.SECTION_ID, S.TITLE
        ORDER BY S.CLASS_ID, S.SECTION_ID";


        $s = runQuery($username, $password, $database, $query);

        ?>
        
        <div class = "parent">
            <div class = "formtitle">
                <h2>Search results</h2>
            </div>
            
            <?php

                if (($row = oci_fetch_array($s, OCI_ASSOC+OCI_RETURN_NULLS)) != false)
                {
                    echo "<table id = 'output_table'>\n";
                    $ncols = oci_num_fields($s);
                    echo "<tr>\n";
                    for ($i = 1; $i <= $ncols; ++$i) {
                        $colname = oci_field_name($s, $i);
                        echo "  <th id = 'output_table'>".htmlspecialchars($colname,ENT_QUOTES|ENT_SUBSTITUTE)."</th>\n";
                    }
                    echo "</tr>\n";
                    
                    do {
                        echo "<tr id = 'output_table'>\n";
                        foreach ($row as $item) {
                            echo "<td id = 'output_table'>";
                            echo $item!==null?htmlspecialchars($item, ENT_QUOTES|ENT_SUBSTITUTE):"&nbsp;";
                            echo "</td>\n";
                        }

                        echo "</tr>\n";
                    } while (($row = oci_fetch_array($s, OCI_ASSOC+OCI_RETURN_NULLS)) != false);
                    echo "</table>\n";
                }
                else
                {
                    ?>
                        <h2 style = "text-align: center;">No results found.</h2>
                    <?php
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
    </div>

</body>
</html>