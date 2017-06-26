<?php
$options = getopt("f:");
$field = isset($options["f"]) ? intval($options["f"]) : 0;

function remove($path, $obj) {
    if (count($path) == 1) {
        if (isset($obj[$path[0]])) {
            unset($obj[$path[0]]);
        }
    } else if (count($path) > 1) {
        $p = array_shift($path);
        if (isset($obj[$p])) {
            $obj[$p] = remove($path, $obj[$p]);
        }
    }
    return $obj;
}

while ($line = fgets(STDIN)) {
    $line = trim($line);
    if ($line) {
        $items = explode("\t", $line);

        $obj = json_decode($items[$field], true);
        if (is_array($obj)) {
            for ($i = count($options) + 1; $i < $argc; $i++) {
                $obj = remove(explode(".", $argv[$i]), $obj);
                /*
                if (array_key_exists($argv[$i], $obj)) {
                    unset($obj[$argv[$i]]);
                }
                 */
            }

            $items[$field] = json_encode($obj);
            fwrite(STDOUT, implode("\t", $items)."\n");
        } else {
            fwrite(STDERR, $line."\n");
        }
    }
}
?>
