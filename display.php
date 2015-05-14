<?php 

while($line = fgets(STDIN)){
    $line = trim($line);
    $obj = json_decode($line, true);
    print_r($obj);
}

?>
