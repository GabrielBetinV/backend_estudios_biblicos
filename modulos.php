<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

require __DIR__ . '/app/vendor/autoload.php';

use App\Controllers\ModuloController;
use Dotenv\Dotenv;

// Configurar CORS
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit();
}

// Cargar variables de entorno
$dotenv = Dotenv::createImmutable(__DIR__ . '/app/');
$dotenv->load();

$method = $_SERVER['REQUEST_METHOD'];
$scriptName = $_SERVER['SCRIPT_NAME'];
$requestUri = $_SERVER['REQUEST_URI'];
$basePath = dirname($scriptName);
$relativeUri = '/' . ltrim(str_replace($basePath, '', $requestUri), '/');

$action = $_GET['action'] ?? null;

$moduloController = new ModuloController();

// Rutas REST
if (preg_match('#^modulos.php/(\d+)$#', $relativeUri, $matches)) {
    $id = $matches[1];
    switch ($method) {
        case 'GET':
            $moduloController->getById($id);
            break;
        case 'PUT':
            $moduloController->update($id);
            break;
        case 'DELETE':
            $moduloController->delete($id);
            break;
        default:
            http_response_code(405);
            echo json_encode(["error" => "Método no permitido"]);
    }
} elseif ($relativeUri === '/modulos.php' && $method === 'GET') {
    $moduloController->getAll();
} elseif ($relativeUri === '/modulos.php' && $method === 'POST') {
    $moduloController->create();
} else {
    http_response_code(404);
    echo json_encode(["error" => "Ruta no encontrada: $relativeUri"]);
}
