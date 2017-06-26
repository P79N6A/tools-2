<?php
ini_set("memory_limit", "2G");

$options = getopt("dzf:");

while ($line = fgets(STDIN)) {
    if ($line = trim($line)) {
        $index = 0;
        if(isset($options["f"])) {
            $index = (int)$options["f"];
        }
        $items = explode("\t", $line);
        $line = $items[$index];
        if (isset($options["d"])) {
            $line = base64_decode($line);
            if (isset($options["z"])) {
                $line = gzuncompress($line);
            }
        } else {
            if (isset($options["z"])) {
                $line = gzcompress($line);
            }
            $line = base64_encode($line);
        }
        $items[$index] = $line;
        $str = implode("\t", $items);
        fwrite(STDOUT, sprintf("%s\n", $str));
    }
}
?>

