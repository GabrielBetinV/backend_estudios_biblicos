<?php
// ============================================================
// 🔧 Configuración inicial
// ============================================================
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// Carga automática con Composer
require __DIR__ . '/app/vendor/autoload.php';

use App\Controllers\ForoController;
use Dotenv\Dotenv;

// ============================================================
// 🌐 CORS
// ============================================================
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit();
}

// ============================================================
// ⚙️ Cargar variables de entorno
// ============================================================
$dotenv = Dotenv::createImmutable(__DIR__ . '/app/');
$dotenv->load();

// ============================================================
// 📦 Obtener método y URI
// ============================================================
$method = $_SERVER['REQUEST_METHOD'];
$scriptName = $_SERVER['SCRIPT_NAME'];
$requestUri = $_SERVER['REQUEST_URI'];
$basePath = dirname($scriptName);
$relativeUri = '/' . ltrim(str_replace($basePath, '', $requestUri), '/');

// Clave: detección por parámetro "action"
$action = $_GET['action'] ?? null;

// ============================================================
// 🧩 Logs de depuración
// ============================================================
error_log("Método: $method");
error_log("Request URI: $requestUri");
error_log("Relative URI: $relativeUri");
error_log("Action: $action");

// ============================================================
// 🧠 Token (si usas autenticación Bearer)
// ============================================================
$headers = getallheaders();
$token = $headers['Authorization'] ?? null;
if ($token) {
    $token = str_replace('Bearer ', '', $token);
    // Aquí puedes validar el token si usas JWT
    // Ejemplo:
    // if (!JwtHelper::verify($token)) {
    //     http_response_code(401);
    //     echo json_encode(["status" => "ERROR", "message" => "Token inválido o expirado"]);
    //     exit();
    // }
}

// ============================================================
// 🚀 Instanciar el controlador
// ============================================================
$foroController = new ForoController();

// ============================================================
// 🧭 Enrutamiento REST del foro
// ============================================================

// 🔹 Obtener preguntas del curso
if ($action === 'getPreguntas' && $method === 'POST') {
    $foroController->getPreguntasByCurso();

// 🔹 Insertar nueva pregunta
} elseif ($action === 'insertPregunta' && $method === 'POST') {
    $foroController->insertPregunta();

// 🔹 Insertar respuesta
} elseif ($action === 'insertRespuesta' && $method === 'POST') {
    $foroController->insertRespuesta();

// 🔹 Insertar comentario
} elseif ($action === 'insertComentario' && $method === 'POST') {
    $foroController->insertComentario();

// 🔹 Rutas REST adicionales (si algún día se amplía)
} elseif (preg_match('#^foro.php/(\d+)$#', $relativeUri, $matches)) {
    $id = $matches[1];
    switch ($method) {
        case 'GET':
            // Ejemplo futuro: $foroController->getById($id);
            http_response_code(501);
            echo json_encode(["error" => "No implementado"]);
            break;
        default:
            http_response_code(405);
            echo json_encode(["error" => "Método no permitido"]);
    }

// 🔴 Ruta no encontrada
} else {
    http_response_code(404);
    echo json_encode(["error" => "Ruta no encontrada: $relativeUri"]);
    error_log("Ruta no encontrada: $relativeUri");
}
