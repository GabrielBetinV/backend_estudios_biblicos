<?php

namespace App\Controllers;

use App\Services\AdminService;
use App\Helpers\JwtHelper;
use Exception;

class AdminController {
    private AdminService $adminService;

    public function __construct() {
        $this->adminService = new AdminService();
    }

    private function validarAdmin(): array {
        $headers = getallheaders();
        $authHeader = $headers['Authorization'] ?? $headers['authorization'] ?? null;

        if (!$authHeader || !preg_match('/Bearer\s(\S+)/', $authHeader, $matches)) {
            http_response_code(401);
            echo json_encode(["status" => "ERROR", "message" => "No autorizado."]);
            exit;
        }

        try {
            $decoded = JwtHelper::verificarToken($matches[1]);
            $userData = $decoded['data'];

            // VALIDAR ROL ADMIN (asumiendo id_rol = 1 es Admin)
            if ($userData['id_rol'] != 1) {
                http_response_code(403);
                echo json_encode(["status" => "ERROR", "message" => "Acceso denegado. Se requieren permisos de administrador."]);
                exit;
            }

            return $userData;
        } catch (Exception $e) {
            http_response_code(401);
            echo json_encode(["status" => "ERROR", "message" => "Sesión inválida."]);
            exit;
        }
    }

    public function getDashboardStats(): void {
        $this->validarAdmin();
        $response = $this->adminService->getStats();
        echo json_encode($response);
    }

    public function getUsuarios(): void {
        $this->validarAdmin();
        $response = $this->adminService->getAllUsuarios();
        echo json_encode($response);
    }

    public function updateUsuarioRol(): void {
        $this->validarAdmin();
        $data = json_decode(file_get_contents('php://input'), true);
        $response = $this->adminService->updateRol($data);
        echo json_encode($response);
    }

    public function getCursos(): void {
        $this->validarAdmin();
        $response = $this->adminService->getCursosAdmin();
        echo json_encode($response);
    }

    public function createCurso(): void {
        $this->validarAdmin();
        $data = json_decode(file_get_contents('php://input'), true);
        echo json_encode($this->adminService->createCurso($data));
    }

    public function updateEstadoCurso(): void {
        $this->validarAdmin();
        $data = json_decode(file_get_contents('php://input'), true);
        echo json_encode($this->adminService->updateEstadoCurso($data));
    }

    public function getCursoDetalle(): void {
        $this->validarAdmin();
        $id_curso = $_GET['id_curso'] ?? null;
        if (!$id_curso) {
            echo json_encode(["status" => "ERROR", "message" => "ID de curso requerido"]);
            return;
        }
        $response = $this->adminService->getCursoDetalle($id_curso);
        echo json_encode($response);
    }

    public function getGrupos(): void {
        $this->validarAdmin();
        echo json_encode($this->adminService->getGrupos());
    }

    public function createGrupo(): void {
        $this->validarAdmin();
        $data = json_decode(file_get_contents('php://input'), true);
        echo json_encode($this->adminService->createGrupo($data));
    }

    public function getInscripciones(): void {
        $this->validarAdmin();
        echo json_encode($this->adminService->getInscripciones());
    }

    public function createInscripcion(): void {
        $this->validarAdmin();
        $data = json_decode(file_get_contents('php://input'), true);
        echo json_encode($this->adminService->createInscripcion($data));
    }

    public function deleteInscripcion(): void {
        $this->validarAdmin();
        $data = json_decode(file_get_contents('php://input'), true);
        echo json_encode($this->adminService->deleteInscripcion($data));
    }

    public function getGrupoUsuarios(): void {
        $this->validarAdmin();
        $id_grupo = $_GET['id_grupo'] ?? null;
        echo json_encode($this->adminService->getGrupoUsuarios($id_grupo));
    }

    public function assignUsuarioGrupo(): void {
        $this->validarAdmin();
        $data = json_decode(file_get_contents('php://input'), true);
        echo json_encode($this->adminService->assignUsuarioGrupo($data));
    }

    public function removeUsuarioGrupo(): void {
        $this->validarAdmin();
        $data = json_decode(file_get_contents('php://input'), true);
        echo json_encode($this->adminService->removeUsuarioGrupo($data));
    }

    public function getGrupoLecciones(): void {
        $this->validarAdmin();
        $id_grupo = $_GET['id_grupo'] ?? null;
        echo json_encode($this->adminService->getGrupoLecciones($id_grupo));
    }

    public function assignLeccionGrupo(): void {
        $this->validarAdmin();
        $data = json_decode(file_get_contents('php://input'), true);
        echo json_encode($this->adminService->assignLeccionGrupo($data));
    }

    public function getLeccionesFull(): void {
        $this->validarAdmin();
        echo json_encode($this->adminService->getLeccionesFull());
    }

    public function removeLeccionGrupo(): void {
        $this->validarAdmin();
        $data = json_decode(file_get_contents('php://input'), true);
        echo json_encode($this->adminService->removeLeccionGrupo($data));
    }
}
