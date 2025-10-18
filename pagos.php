<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

require __DIR__ . '/app/vendor/autoload.php';

use App\Controllers\PagoController;
use Dotenv\Dotenv;

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') { http_response_code(204); exit(); }

$dotenv = Dotenv::createImmutable(__DIR__ . '/app/'); $dotenv->load();

$method = $_SERVER['REQUEST_METHOD'];
$scriptName = $_SERVER['SCRIPT_NAME'];
$requestUri = $_SERVER['REQUEST_URI'];
$basePath = dirname($scriptName);
$relativeUri = '/' . ltrim(str_replace($basePath, '', $requestUri), '/');

$controller = new PagoController();

if (preg_match('#^pagos.php/(\d+)$#', $relativeUri, $matches)) {
    $id = $matches[1];
    switch ($method) {
        case 'GET': $controller->getById($id); break;
        case 'PUT': $controller->update($id); break;
        case 'DELETE': $controller->delete($id); break;
        default: http_response_code(405); echo json_encode(["error"=>"Método no permitido"]);
    }
} elseif ($relativeUri === '/pagos.php' && $method === 'GET') {
    $controller->getAll();
} elseif ($relativeUri === '/pagos.php' && $method === 'POST') {
    $controller->create();
} else {
    http_response_code(404);
    echo json_encode(["error"=>"Ruta no encontrada: $relativeUri"]);
}
