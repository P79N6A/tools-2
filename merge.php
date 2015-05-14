<?php
$options = getopt("mvk");

function _array_islist($a) {
	return is_array($a) && count($a) === count(array_filter(array_keys($a), "is_int"));
}

function _array_merge($a1, $a2, $append) {
    if (is_array($a1) &&is_array($a2)) {
        if (!$append && _array_islist($a2)) {
            $a1 = $a2;
        } else {
            foreach($a2 as $key=>$val) {
                if (is_int($key)) {
                    $a1 []= $val;
                } else {
                    if (isset($a1[$key])) {
                        $a1[$key] = _array_merge($a1[$key], $val, $append);
                    } else {
                        $a1[$key] = $val;
                    }
                }
            }
        }
        return $a1;
    }
    return $a2;
}

while ($line = fgets(STDIN)) {
    $line = rtrim($line, "\r\n");
    if ($line) {
        $x = explode("\t", $line);
        $data = array();
        foreach(array_slice($x, 1) as $o) {
            $data = _array_merge($data, json_decode($o, true), !isset($options["v"]));
        }
        if (isset($options["m"])) {
            $id = $x[0];
            $data = _array_merge($data, array("id"=>$id), !isset($options["v"]));
        }

		if (isset($options["k"])) {
        	echo $x[0]."\t".json_encode($data)."\n";
		} else {
        	echo json_encode($data)."\n";
		}
    }
}
?>
