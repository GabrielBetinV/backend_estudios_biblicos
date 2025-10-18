<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

require __DIR__ . '/app/vendor/autoload.php';

use App\Controllers\SubLeccionController;
use Dotenv\Dotenv;

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit();
}

$dotenv = Dotenv::createImmutable(__DIR__ . '/app/');
$dotenv->load();

$method = $_SERVER['REQUEST_METHOD'];
$scriptName = $_SERVER['SCRIPT_NAME'];
$requestUri = $_SERVER['REQUEST_URI'];
$basePath = dirname($scriptName);
$relativeUri = '/' . ltrim(str_replace($basePath, '', $requestUri), '/');

$subLeccionController = new SubLeccionController();

if (preg_match('#^sublecciones.php/(\d+)$#', $relativeUri, $matches)) {
    $id = $matches[1];
    switch ($method) {
        case 'GET':
            $subLeccionController->getById($id);
            break;
        case 'PUT':
            $subLeccionController->update($id);
            break;
        case 'DELETE':
            $subLeccionController->delete($id);
            break;
        default:
            http_response_code(405);
            echo json_encode(["error" => "Método no permitido"]);
    }
} elseif ($relativeUri === '/sublecciones.php' && $method === 'GET') {
    $subLeccionController->getAll();
} elseif ($relativeUri === '/sublecciones.php' && $method === 'POST') {
    $subLeccionController->create();
} else {
    http_response_code(404);
    echo json_encode(["error" => "Ruta no encontrada: $relativeUri"]);
}
