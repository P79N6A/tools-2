<?php
$options = getopt("kf:");
foreach(array("k"=>1, "f"=>2) as $k=>$c) {
    if (isset($options[$k])) {
        $argc -= $c;
        while ($c-- > 0) {
            array_shift($argv);
        }
    }
}

if (!isset($options["f"])) {
    $options["f"] = 0;
}

function select($path, $obj) {
    $ret = $obj;

    foreach($path as $p) {
        if (!(is_array($ret) && isset($ret[$p]))) {
            $ret = "";
            break;
        }
        $ret = $ret[$p];
    }
    if (is_array($ret)) {
        $ret = json_encode($ret);
    }

    return str_replace("\t", "", $ret);
}

while ($line = fgets(STDIN)) {
    $line = trim($line);
    if ($line) {
        $data = explode("\t", $line);
        $obj = json_decode($data[$options["f"]], true);
        if (is_array($obj)) {
            $item = array();
            for ($i = 1; $i < $argc; $i++) {
                #var_dump(explode(".", $argv[$i]));
                $item []= select(explode(".", $argv[$i]), $obj);
            }

            if (isset($options["k"])) {
                $item []= $line;
            }
            #if($item[0] == '') {
            #fwrite(STDOUT, $line);
            #}
            fwrite(STDOUT, implode("\t", $item)."\n");
        } else {
            fwrite(STDERR, $line."\n");
        }
    }
}
?>
