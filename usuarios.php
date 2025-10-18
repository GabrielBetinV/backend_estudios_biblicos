<?php
// Configurar la visualización de errores
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// Carga automática con Composer
require __DIR__ . '/app/vendor/autoload.php';

use App\Controllers\UsuarioController;
use Dotenv\Dotenv;

// CORS
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

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

$action = $_GET['action'] ?? null; // ← AQUÍ ESTÁ LA CLAVE

// Logs para depuración
error_log("Método: $method");
error_log("Request URI: $requestUri");
error_log("Relative URI: $relativeUri");
error_log("Action: $action");

// Instanciar el controlador
$usuarioController = new UsuarioController();

// Enrutamiento
if ($action === 'login' && $method === 'POST') {
    $usuarioController->login();
}  elseif ($action === 'recuperar' && $method === 'POST') {
    $usuarioController->enviarNuevaContrasenaPorCorreo();
}  elseif ($action === 'changePassword' && $method === 'POST') {
    $usuarioController->cambiarContrasenaConToken();
} elseif (preg_match('#^usuarios.php/(\d+)$#', $relativeUri, $matches)) {
    $id = $matches[1];
    switch ($method) {
        case 'GET':
            $usuarioController->getById($id);
            break;
        case 'PUT':
            $usuarioController->update($id);
            break;
        case 'DELETE':
            $usuarioController->delete($id);
            break;
        default:
            http_response_code(405);
            echo json_encode(["error" => "Método no permitido"]);
    }
} elseif ($relativeUri === '/usuarios.php' && $method === 'GET') {
    $usuarioController->getAll();
} elseif ($relativeUri === '/usuarios.php' && $method === 'POST') {
    $usuarioController->create();
}else {
    http_response_code(404);
    echo json_encode(["error" => "Ruta no encontrada: $relativeUri"]);
    error_log("Ruta no encontrada: $relativeUri");
}
