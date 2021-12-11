<?php 
// isset has almost the same speed as array_key_exist
// 
$arr = array();
for ($i=0; $i < 5000; $i++) {
    $arr['pref'.$i] = true;
}

for ($loop = 0; $loop < 10; $loop++) {
    $s = microtime(1);
    $found = 0;
    for ($i = 0; $i < 100000; $i++) {
        if(isset($arr['pref1234'])) $found++;
    }
    $e = microtime(1);
    echo $found . " found with isset: ". 1000*($e - $s)." ms.\n";
    
    $s = microtime(1);
    $found = 0;
    for ($i = 0; $i < 100000; $i++) {
        if(array_key_exists('pref1234', $arr)) $found++;
    }
    $e = microtime(1);
    echo $found . " found with array_key_exists: ". 1000*($e - $s)." ms.\n";
}

