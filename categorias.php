<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

require __DIR__ . '/app/vendor/autoload.php';

use App\Controllers\CategoriaController;
use Dotenv\Dotenv;

// CORS
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Authorization, Content-Type, X-Requested-With, Accept, Origin");
header("Access-Control-Allow-Credentials: true");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit();
}

// Cargar .env
$dotenv = Dotenv::createImmutable(__DIR__ . '/app/');
$dotenv->load();

// Obtener método y URI
$method = $_SERVER['REQUEST_METHOD'];
$scriptName = $_SERVER['SCRIPT_NAME'];
$requestUri = $_SERVER['REQUEST_URI'];
$basePath = dirname($scriptName);
$relativeUri = '/' . ltrim(str_replace($basePath, '', $requestUri), '/');

$action = $_GET['action'] ?? null;

error_log("Método: $method");
error_log("Request URI: $requestUri");
error_log("Relative URI: $relativeUri");
error_log("Action: $action");

// Controlador
$categoriaController = new CategoriaController();

// Rutas REST
// Si quieres agregar GET por id en el futuro
if (preg_match('#^categorias.php/(\d+)$#', $relativeUri, $matches)) {
    $id = $matches[1];
    switch ($method) {
        case 'GET':
            // Podrías crear un método getById en CategoriaController si se necesita
            echo json_encode(["status" => "ERROR", "message" => "Método no implementado", "data" => null]);
            break;
        case 'PUT':
        case 'DELETE':
        case 'POST':
            http_response_code(405);
            echo json_encode(["error" => "Método no permitido"]);
            break;
        default:
            http_response_code(405);
            echo json_encode(["error" => "Método no permitido"]);
    }
} elseif ($relativeUri === '/categorias.php' && $method === 'GET') {
    // Obtener todas las categorías
    $categoriaController->getAll();
} else {
    http_response_code(404);
    echo json_encode(["error" => "Ruta no encontrada: $relativeUri"]);
}
