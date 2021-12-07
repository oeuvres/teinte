<?php
spl_autoload_register(function ($class) {
    $slash = DIRECTORY_SEPARATOR;
    $file = __DIR__ . $slash . str_replace('\\', $slash, $class).'.php';
    if (file_exists($file)) {
        require_once $file;
        return true;
    }
    else throw new Exception("Impossible to load " . $file);
});
// ensure timezone, not a good place, but not found yet better
if(ini_get('date.timezone')) {
    date_default_timezone_set(ini_get('date.timezone'));
}
else {
    date_default_timezone_set("Europe/Paris");
}