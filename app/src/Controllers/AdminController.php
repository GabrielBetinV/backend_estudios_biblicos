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

            // Validar permisos de administración
            // Si las tablas/SP de permisos existen, verifica por permisos.
            // Si no (migración pendiente), fallback al id_rol == 1
            $tieneAccesoAdmin = false;
            try {
                $permisosResponse = $this->adminService->getPermisosByRol($userData['id_rol']);
                if ($permisosResponse !== null && $permisosResponse->status === 'OK' && !empty($permisosResponse->data)) {
                    foreach ($permisosResponse->data as $permiso) {
                        if (is_string($permiso) && strpos($permiso, 'admin.') === 0) {
                            $tieneAccesoAdmin = true;
                            break;
                        }
                    }
                }
            } catch (Exception $e) {
                // Tablas de permisos no existen aún
                $tieneAccesoAdmin = ($userData['id_rol'] == 1);
            }

            if (!$tieneAccesoAdmin && $userData['id_rol'] == 1) {
                $tieneAccesoAdmin = true;
            }

            if (!$tieneAccesoAdmin) {
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

    public function updateUsuarioEstado(): void {
        $this->validarAdmin();
        $data = json_decode(file_get_contents('php://input'), true);
        $response = $this->adminService->updateEstadoUsuario($data);
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

    public function getRoles(): void {
        $this->validarAdmin();
        echo json_encode($this->adminService->getRoles());
    }

    public function createRol(): void {
        $this->validarAdmin();
        $data = json_decode(file_get_contents('php://input'), true);
        echo json_encode($this->adminService->createRol($data));
    }

    public function updateRoleDef(): void {
        $this->validarAdmin();
        $data = json_decode(file_get_contents('php://input'), true);
        echo json_encode($this->adminService->updateRoleDef($data));
    }

    public function deleteRol(): void {
        $this->validarAdmin();
        $data = json_decode(file_get_contents('php://input'), true);
        echo json_encode($this->adminService->deleteRol($data));
    }

    public function updateRolEstado(): void {
        $this->validarAdmin();
        $data = json_decode(file_get_contents('php://input'), true);
        echo json_encode($this->adminService->updateRolEstado($data));
    }

    public function getPermisos(): void {
        $this->validarAdmin();
        echo json_encode($this->adminService->getPermisos());
    }

    public function getRolPermisos(): void {
        $this->validarAdmin();
        $id_rol = $_GET['id_rol'] ?? null;
        echo json_encode($this->adminService->getRolPermisos($id_rol));
    }

    public function removeLeccionGrupo(): void {
        $this->validarAdmin();
        $data = json_decode(file_get_contents('php://input'), true);
        echo json_encode($this->adminService->removeLeccionGrupo($data));
    }
}
