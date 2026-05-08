<?php
require __DIR__ . '/app/vendor/autoload.php';

use App\Controllers\AdminController;
use App\Controllers\AdminContentController;
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
$action = $_GET['action'] ?? null;

$adminController = new AdminController();
$contentController = new AdminContentController();

switch ($action) {
    case 'stats':
        if ($method === 'GET') $adminController->getDashboardStats();
        break;
    case 'usuarios':
        if ($method === 'GET') $adminController->getUsuarios();
        break;
    case 'usuarios_rol':
        if ($method === 'POST') $adminController->updateUsuarioRol();
        break;
    case 'cursos':
        if ($method === 'GET') $adminController->getCursos();
        break;
    case 'curso_detalle':
        if ($method === 'GET') $adminController->getCursoDetalle();
        break;
    case 'evidencias':
        if ($method === 'POST') $contentController->createEvidencia();
        break;
    case 'modulos':
        if ($method === 'POST') $contentController->createModulo();
        if ($method === 'PUT') $contentController->updateModulo();
        break;
    case 'lecciones':
        if ($method === 'POST') $contentController->createLeccion();
        if ($method === 'PUT') $contentController->updateLeccion();
        break;
    case 'sublecciones':
        if ($method === 'POST') $contentController->createSubleccion();
        if ($method === 'PUT') $contentController->updateSubleccion();
        break;
    case 'quiz':
        if ($method === 'POST') $contentController->createQuiz();
        break;
    case 'quiz_pregunta':
        if ($method === 'POST') $contentController->addQuizPregunta();
        break;
    case 'foro_pregunta':
        if ($method === 'POST') $contentController->createForoPregunta();
        break;
    case 'categorias':
        $contentController->manageCategoria();
        break;
    default:
        http_response_code(404);
        echo json_encode(["status" => "ERROR", "message" => "Acción no válida."]);
        break;
}
