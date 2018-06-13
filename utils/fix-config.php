<?php

$fileName = $_SERVER['argv'][1];
$config = include $fileName;

$config['front'] = [
    'showException' => true,
    'throwExceptions' => true,
    'noErrorHandler' => false,
];

$config['phpsettings'] = [
    'display_errors' => 1,
];

if (isset($_SERVER['argv'][2])) {
	switch ($_SERVER['argv'][2]) {
		case 'template':
			$config['template'] = [
			    'forceCompile' => true,
			];
			break;
		case 'elastic':
			$config['es'] = [
			    'enabled' => true,
		        'number_of_replicas' => null,
		        'number_of_shards' => 0,
		        'client' => [
		            'hosts' => [
		                'elastic:9200'
		            ]
		        ]
			];
			break;
	}
}

function var_export54($var, $indent="") {
    switch (gettype($var)) {
        case "string":
            return '"' . addcslashes($var, "\\\$\"\r\n\t\v\f") . '"';
        case "array":
            $indexed = array_keys($var) === range(0, count($var) - 1);
            $r = [];
            foreach ($var as $key => $value) {
                $r[] = "$indent    "
                     . ($indexed ? "" : var_export54($key) . " => ")
                     . var_export54($value, "$indent    ");
            }
            return "[\n" . implode(",\n", $r) . "\n" . $indent . "]";
        case "boolean":
            return $var ? "true" : "false";
        default:
            return var_export($var, TRUE);
    }
}

file_put_contents($fileName, '<?php' . PHP_EOL .'return ' .  var_export54($config) . ';');