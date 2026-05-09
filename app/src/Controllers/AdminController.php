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

    public function updateEstadoGrupo(): void {
        $this->validarAdmin();
        $data = json_decode(file_get_contents('php://input'), true);
        echo json_encode($this->adminService->updateEstadoGrupo($data));
    }

    public function getCursosByUsuario(): void {
        $this->validarAdmin();
        $id_usuario = $_GET['id_usuario'] ?? null;
        if (!$id_usuario) {
            echo json_encode(["status" => "ERROR", "message" => "ID de usuario requerido"]);
            return;
        }
        echo json_encode($this->adminService->getCursosByUsuario($id_usuario));
    }

    public function getResultadosByUsuarioCurso(): void {
        $this->validarAdmin();
        $id_usuario = $_GET['id_usuario'] ?? null;
        $id_curso = $_GET['id_curso'] ?? null;
        if (!$id_usuario || !$id_curso) {
            echo json_encode(["status" => "ERROR", "message" => "ID de usuario y curso requeridos"]);
            return;
        }
        echo json_encode($this->adminService->getResultadosByUsuarioCurso($id_usuario, $id_curso));
    }

    public function deleteCurso(): void {
        $this->validarAdmin();
        $data = json_decode(file_get_contents('php://input'), true);
        echo json_encode($this->adminService->deleteCurso($data));
    }

    public function deleteGrupo(): void {
        $this->validarAdmin();
        $data = json_decode(file_get_contents('php://input'), true);
        echo json_encode($this->adminService->deleteGrupo($data));
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

    public function insertPermiso(): void {
        $this->validarAdmin();
        $data = json_decode(file_get_contents('php://input'), true);
        echo json_encode($this->adminService->insertPermiso($data));
    }

    public function updatePermiso(): void {
        $this->validarAdmin();
        $data = json_decode(file_get_contents('php://input'), true);
        echo json_encode($this->adminService->updatePermiso($data));
    }

    public function deletePermiso(): void {
        $this->validarAdmin();
        $data = json_decode(file_get_contents('php://input'), true);
        echo json_encode($this->adminService->deletePermiso($data));
    }

    public function getTiposEvidencia(): void {
        $this->validarAdmin();
        echo json_encode($this->adminService->getTiposEvidencia());
    }

    public function insertTipoEvidencia(): void {
        $this->validarAdmin();
        $data = json_decode(file_get_contents('php://input'), true);
        echo json_encode($this->adminService->insertTipoEvidencia($data));
    }

    public function updateTipoEvidencia(): void {
        $this->validarAdmin();
        $data = json_decode(file_get_contents('php://input'), true);
        echo json_encode($this->adminService->updateTipoEvidencia($data));
    }

    public function deleteTipoEvidencia(): void {
        $this->validarAdmin();
        $data = json_decode(file_get_contents('php://input'), true);
        echo json_encode($this->adminService->deleteTipoEvidencia($data));
    }

    public function getEvidenciasAdmin(): void {
        $this->validarAdmin();
        echo json_encode($this->adminService->getEvidenciasAdmin());
    }

    public function getEvidencia(): void {
        $this->validarAdmin();
        $data = json_decode(file_get_contents('php://input'), true);
        echo json_encode($this->adminService->getEvidencia($data));
    }

    public function updateEvidencia(): void {
        $this->validarAdmin();
        $data = json_decode(file_get_contents('php://input'), true);
        echo json_encode($this->adminService->updateEvidencia($data));
    }

    public function deleteEvidencia(): void {
        $this->validarAdmin();
        $data = json_decode(file_get_contents('php://input'), true);
        echo json_encode($this->adminService->deleteEvidencia($data));
    }

    public function getAvanceEstudiantes(): void {
        $this->validarAdmin();
        echo json_encode($this->adminService->getAvanceEstudiantes());
    }

    public function getSubleccionesAll(): void {
        $this->validarAdmin();
        echo json_encode($this->adminService->getSubleccionesAll());
    }

    private function asegurarArray(mixed $data): array
    {
        if (is_string($data)) {
            $decoded = json_decode($data, true);
            return is_array($decoded) ? $decoded : [];
        }
        return is_array($data) ? $data : [];
    }

    public function descargarReporte(): void {
        $this->validarAdmin();
        $response = $this->adminService->getReporteCompleto();

        if ($response->status !== 'OK' || !$response->data) {
            echo json_encode(["status" => "ERROR", "message" => "No se pudo generar el reporte"]);
            return;
        }

        $raw = $this->asegurarArray($response->data);

        $xlsx = new \App\Helpers\XlsxWriter();

        // Usuarios
        $usuarios = $this->asegurarArray($raw['usuarios'] ?? []);
        $rows = [];
        foreach ($usuarios as $u) {
            $rows[] = [$u['id_usuario'] ?? '', $u['nombre'] ?? '', $u['correo'] ?? '', $u['rol'] ?? '', $u['estado'] ?? '', $u['fecha_registro'] ?? ''];
        }
        $xlsx->addSection('USUARIOS', ['ID', 'Nombre', 'Correo', 'Rol', 'Estado', 'Fecha Registro'], $rows);

        // Cursos
        $cursos = $this->asegurarArray($raw['cursos'] ?? []);
        $rows = [];
        foreach ($cursos as $c) {
            $rows[] = [$c['id_curso'] ?? '', $c['titulo'] ?? '', $c['descripcion'] ?? '', $c['precio'] ?? '', $c['categoria'] ?? '', $c['estado'] ?? '', $c['fecha_creacion'] ?? '', $c['total_inscripciones'] ?? ''];
        }
        $xlsx->addSection('CURSOS', ['ID', 'Título', 'Descripción', 'Precio', 'Categoría', 'Estado', 'Fecha Creación', 'Total Inscripciones'], $rows);

        // Inscripciones
        $inscripciones = $this->asegurarArray($raw['inscripciones'] ?? []);
        $rows = [];
        foreach ($inscripciones as $i) {
            $rows[] = [$i['id_inscripcion'] ?? '', $i['usuario'] ?? '', $i['curso'] ?? '', $i['fecha_inscripcion'] ?? ''];
        }
        $xlsx->addSection('INSCRIPCIONES', ['ID', 'Usuario', 'Curso', 'Fecha Inscripción'], $rows);

        // Grupos
        $grupos = $this->asegurarArray($raw['grupos'] ?? []);
        $rows = [];
        foreach ($grupos as $g) {
            $rows[] = [$g['id_grupo'] ?? '', $g['nombre'] ?? '', $g['descripcion'] ?? '', $g['estado'] ?? '', $g['total_usuarios'] ?? '', $g['total_lecciones'] ?? ''];
        }
        $xlsx->addSection('GRUPOS', ['ID', 'Nombre', 'Descripción', 'Estado', 'Total Usuarios', 'Total Lecciones'], $rows);

        // Resultados
        $resultados = $this->asegurarArray($raw['resultados'] ?? []);
        $rows = [];
        foreach ($resultados as $r) {
            $rows[] = [
                $r['id_resultado'] ?? '', $r['usuario'] ?? '', $r['curso'] ?? '',
                $r['modulo'] ?? '', $r['leccion'] ?? '', $r['subleccion'] ?? '',
                $r['grupo'] ?? '', $r['evidencia'] ?? '', $r['tipo'] ?? '',
                $r['nota'] ?? '', $r['fecha'] ?? ''
            ];
        }
        $xlsx->addSection('RESULTADOS (NOTAS)', ['ID', 'Usuario', 'Curso', 'Módulo', 'Lección', 'Sublección', 'Grupo', 'Evidencia', 'Tipo', 'Nota', 'Fecha'], $rows);

        // Progreso
        $progreso = $this->asegurarArray($raw['progreso'] ?? []);
        $rows = [];
        foreach ($progreso as $p) {
            $rows[] = [$p['id_progreso'] ?? '', $p['usuario'] ?? '', $p['curso'] ?? '', $p['progreso'] ?? '', $p['fecha_actualizacion'] ?? ''];
        }
        $xlsx->addSection('PROGRESO POR ESTUDIANTE', ['ID', 'Usuario', 'Curso', 'Progreso (%)', 'Fecha Actualización'], $rows);

        // Generar XLSX y enviar
        $tmpFile = tempnam(sys_get_temp_dir(), 'reporte_') . '.xlsx';
        $xlsx->generate($tmpFile);

        header('Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        header('Content-Disposition: attachment; filename="reporte_escuela_' . date('Y-m-d') . '.xlsx"');
        header('Content-Length: ' . filesize($tmpFile));
        header('Pragma: no-cache');
        header('Expires: 0');

        readfile($tmpFile);
        unlink($tmpFile);
        exit;
    }
}
