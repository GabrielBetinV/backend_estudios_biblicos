<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

require __DIR__ . '/app/vendor/autoload.php';

use App\Controllers\CursoController;
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
$cursoController = new CursoController();

// Rutas REST
if (preg_match('#^cursos.php/(\d+)$#', $relativeUri, $matches)) {
    $id = $matches[1];
    switch ($method) {
        case 'GET':
            $cursoController->getById($id);
            break;
        case 'PUT':
            $cursoController->update($id);
            break;
        case 'DELETE':
            $cursoController->delete($id);
            break;
        default:
            http_response_code(405);
            echo json_encode(["error" => "Método no permitido"]);
    }
} elseif ($relativeUri === '/cursos.php' && $method === 'GET') {
    $cursoController->getAll();
} elseif ($relativeUri === '/cursos.php' && $method === 'POST') {
    $cursoController->create();
} else {
    http_response_code(404);
    echo json_encode(["error" => "Ruta no encontrada: $relativeUri"]);
}
