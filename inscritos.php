<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

require __DIR__ . '/app/vendor/autoload.php';

use App\Controllers\InscritoController;
use Dotenv\Dotenv;

// CORS
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, OPTIONS");
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

// Solo aceptamos GET
if ($_SERVER['REQUEST_METHOD'] === 'GET') {

    // Obtener el parámetro id_curso desde la URL
    if (isset($_GET['id_curso']) && !empty($_GET['id_curso'])) {
        $idCurso = intval($_GET['id_curso']); // Convertimos a entero para mayor seguridad
        $controller->getCursosInscritos($idCurso); // Llamamos al método del controlador
    } else {
        http_response_code(400);
        echo json_encode(["error" => "Se requiere el parámetro id_curso"]);
    }

} else {
    http_response_code(405); // Método no permitido
    echo json_encode(["error" => "Método no permitido"]);
}
