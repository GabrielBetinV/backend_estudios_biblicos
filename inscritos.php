<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

require __DIR__ . '/app/vendor/autoload.php';

use App\Controllers\InscritoController;
use Dotenv\Dotenv;

// CORS
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Authorization, Content-Type, X-Requested-With, Accept, Origin");
header("Access-Control-Allow-Credentials: true");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit();
}

// Cargar .env
$dotenv = Dotenv::createImmutable(__DIR__ . '/app/');
$dotenv->load();

$controller = new InscritoController();

// Detectar método
$method = $_SERVER['REQUEST_METHOD'];

// ---- RUTAS ----

// ✅ GET → Obtener cursos inscritos
if ($method === 'GET') {
    if (isset($_GET['id_curso']) && !empty($_GET['id_curso'])) {
        $idCurso = intval($_GET['id_curso']);
        $controller->getCursosInscritos($idCurso);
    } else {
        http_response_code(400);
        echo json_encode(["status" => "ERROR", "message" => "Se requiere el parámetro id_curso"]);
    }
}

// ✅ POST → Actualizar progreso o resultado
elseif ($method === 'POST') {
    // Determinar acción por parámetro ?action=
    $action = $_GET['action'] ?? null;

    switch ($action) {
        case 'actualizar_progreso':
            $controller->actualizarProgreso();
            break;

        case 'actualizar_resultado':
            $controller->actualizarResultado();
            break;
        case 'actualizar_progreso_subleccion':
            $controller->actualizarProgresoSubleccion();
            break;

        default:
            http_response_code(400);
            echo json_encode(["status" => "ERROR", "message" => "Acción no reconocida. Usa ?action=actualizar_progreso o ?action=actualizar_resultado"]);
    }
}

// 🚫 Otro método no permitido
else {
    http_response_code(405);
    echo json_encode(["status" => "ERROR", "message" => "Método no permitido"]);
}
