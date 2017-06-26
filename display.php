<?php 
$options = getopt("f:");

while($line = fgets(STDIN)){
	$line = trim($line);
	if (isset($options["f"])){
		$idx = (int)$options["f"];
		#echo $idx."\n";
		$arr = explode("\t", $line);
		$line = $arr[$idx - 1];
	}
	$obj = json_decode($line, true);
	print_r($obj);
}

?>
