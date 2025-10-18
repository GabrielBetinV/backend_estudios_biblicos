<?php
// Configurar la visualización de errores
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// Carga automática con Composer
//require_once __DIR__ . '/../vendor/autoload.php';
require __DIR__ . '/app/vendor/autoload.php';

use App\Controllers\GeneroController;
use Dotenv\Dotenv;

// Manejo de CORS para permitir peticiones desde cualquier origen
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// Manejo de la solicitud OPTIONS (preflight CORS)
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit();
}

// Cargar variables de entorno desde .env
//$dotenv = Dotenv::createImmutable(__DIR__ . '/../');
$dotenv = Dotenv::createImmutable(__DIR__ . '/app/');
$dotenv->load();

// Obtener método y PATH_INFO
$method = $_SERVER['REQUEST_METHOD'];
$pathInfo = $_SERVER['PATH_INFO'] ?? '/';

error_log("Método: $method");
error_log("PATH_INFO: $pathInfo");

// Instanciar el controlador de géneros
$generoController = new GeneroController();

// Enrutamiento
if (preg_match('#^/(\d+)$#', $pathInfo, $matches)) {
    $id = (int) $matches[1];
    error_log("Ruta: /ID, ID: $id");

    switch ($method) {
        case 'GET':
            $generoController->getById($id);
            break;
        case 'PUT':
            $generoController->update($id);
            break;
        case 'DELETE':
            $generoController->delete($id);
            break;
        default:
            http_response_code(405);
            echo json_encode(["error" => "Método no permitido"]);
    }
} elseif ($pathInfo === '/' && $method === 'GET') {
    error_log("Ruta: / (GET todos)");
    $generoController->getAll();
} elseif ($pathInfo === '/' && $method === 'POST') {
    error_log("Ruta: / (POST crear)");
    $generoController->create();
} else {
    http_response_code(404);
    echo json_encode(["error" => "Ruta no encontrada: $pathInfo"]);
    error_log("Ruta no encontrada: $pathInfo");
}
