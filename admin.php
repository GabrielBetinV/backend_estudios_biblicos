<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);
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
    case 'usuarios_estado':
        if ($method === 'POST') $adminController->updateUsuarioEstado();
        break;
    case 'cursos':
        if ($method === 'GET') $adminController->getCursos();
        if ($method === 'POST') $adminController->createCurso();
        if ($method === 'DELETE') $adminController->deleteCurso();
        break;
    case 'cursos_estado':
        if ($method === 'POST') $adminController->updateEstadoCurso();
        break;
    case 'curso_detalle':
        if ($method === 'GET') $adminController->getCursoDetalle();
        break;
    case 'grupos':
        if ($method === 'GET') $adminController->getGrupos();
        if ($method === 'POST') $adminController->createGrupo();
        if ($method === 'DELETE') $adminController->deleteGrupo();
        break;
    case 'inscripciones':
        if ($method === 'GET') $adminController->getInscripciones();
        if ($method === 'POST') $adminController->createInscripcion();
        if ($method === 'DELETE') $adminController->deleteInscripcion();
        break;
    case 'grupo_usuarios':
        if ($method === 'GET') $adminController->getGrupoUsuarios();
        if ($method === 'POST') $adminController->assignUsuarioGrupo();
        if ($method === 'DELETE') $adminController->removeUsuarioGrupo();
        break;
    case 'grupo_lecciones':
        if ($method === 'GET') $adminController->getGrupoLecciones();
        if ($method === 'POST') $adminController->assignLeccionGrupo();
        if ($method === 'DELETE') $adminController->removeLeccionGrupo();
        break;
    case 'lecciones_full':
        if ($method === 'GET') $adminController->getLeccionesFull();
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
        if ($method === 'GET') $adminController->getSubleccionesAll();
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
    case 'roles':
        if ($method === 'GET') $adminController->getRoles();
        if ($method === 'POST') $adminController->createRol();
        if ($method === 'PUT') $adminController->updateRoleDef();
        if ($method === 'DELETE') $adminController->deleteRol();
        break;
    case 'rol_estado':
        if ($method === 'POST') $adminController->updateRolEstado();
        break;
    case 'permisos':
        if ($method === 'GET') $adminController->getPermisos();
        if ($method === 'POST') $adminController->insertPermiso();
        if ($method === 'PUT') $adminController->updatePermiso();
        if ($method === 'DELETE') $adminController->deletePermiso();
        break;
    case 'rol_permisos':
        if ($method === 'GET') $adminController->getRolPermisos();
        break;
    case 'tipos_evidencia':
        if ($method === 'GET') $adminController->getTiposEvidencia();
        if ($method === 'POST') $adminController->insertTipoEvidencia();
        if ($method === 'PUT') $adminController->updateTipoEvidencia();
        if ($method === 'DELETE') $adminController->deleteTipoEvidencia();
        break;
    case 'evidencias_admin':
        if ($method === 'GET') $adminController->getEvidenciasAdmin();
        if ($method === 'PUT') $adminController->updateEvidencia();
        if ($method === 'DELETE') $adminController->deleteEvidencia();
        break;
    case 'evidencia':
        if ($method === 'GET') $adminController->getEvidencia();
        break;
    case 'avance_estudiantes':
        if ($method === 'GET') $adminController->getAvanceEstudiantes();
        break;
    default:
        http_response_code(404);
        echo json_encode(["status" => "ERROR", "message" => "Acción no válida."]);
        break;
}
