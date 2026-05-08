<?php

namespace App\Controllers;

use App\Services\CursoService;
use App\DTO\CursoDTO;
use App\Helpers\JwtHelper;
use Exception;

class CursoController {
    private CursoService $cursoService;

    public function __construct() {
        $this->cursoService = new CursoService();
    }

    /**
     * ✅ Validar el token JWT antes de permitir acceso
     */
private function validarToken(): array {
    $headers = getallheaders();

    // Permitir mayúsculas/minúsculas en la clave del header
    $authHeader = $headers['Authorization'] ?? $headers['authorization'] ?? null;

    if (!$authHeader) {
        http_response_code(401);
        echo json_encode([
            "status" => "ERROR",
            "message" => "Token no proporcionado en el encabezado Authorization.",
            "data" => null
        ]);
        exit;
    }

    // El formato esperado es: "Bearer <token>"
    if (!preg_match('/Bearer\s(\S+)/', $authHeader, $matches)) {
        http_response_code(400);
        echo json_encode([
            "status" => "ERROR",
            "message" => "Formato de token inválido. Debe ser 'Bearer <token>'.",
            "data" => null
        ]);
        exit;
    }

    $token = $matches[1]; // Captura el valor del token sin el prefijo "Bearer"

    try {
        // 🔐 Usa tu helper para verificar y decodificar el token
        $decoded = JwtHelper::verificarToken($token);

        // Validar si contiene los datos esperados
        if (!isset($decoded['data'])) {
            http_response_code(401);
            echo json_encode([
                "status" => "ERROR",
                "message" => "Token inválido: sin datos de usuario.",
                "data" => null
            ]);
            exit;
        }

        return $decoded['data']; // Retorna solo los datos del usuario autenticado

    } catch (\Exception $e) {
        http_response_code(401);
        echo json_encode([
            "status" => "INFO",
            "message" => "" . $e->getMessage(),
            "data" => null
        ]);
        exit;
    }
}


    // Crear curso
    public function create(): void {
        $usuario = $this->validarToken(); // 🔒 Protegido por JWT

        $data = json_decode(file_get_contents('php://input'), true);

        if (empty($data['titulo']) || empty($data['descripcion'])) {
            http_response_code(400);
            echo json_encode(["status" => "ERROR", "message" => "Campos requeridos: titulo, descripcion."]);
            return;
        }

        $cursoDTO = new CursoDTO(
            titulo: $data['titulo'],
            descripcion: $data['descripcion'],
            id_estado: $data['id_estado'],
            precio: $data['precio'],
              portada: $data['portada']
        );

        try {
            $response = $this->cursoService->createCurso($cursoDTO);
            http_response_code($response->status === 'OK' ? 201 : 409);
            echo json_encode($response);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(["status" => "ERROR", "message" => $e->getMessage()]);
        }
    }

    // Obtener curso por ID
    public function getById($id): void {
        $this->validarToken(); // 🔒 Validar JWT

        try {
            $response = $this->cursoService->getCursoById($id);
            echo json_encode($response);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(["status" => "ERROR", "message" => $e->getMessage()]);
        }
    }

    // Actualizar curso
    public function update($id): void {
        $usuario = $this->validarToken(); // 🔒 Validar JWT

        $data = json_decode(file_get_contents('php://input'), true);

        if (empty($data['titulo']) || empty($data['descripcion'])) {
            http_response_code(400);
            echo json_encode(["status" => "ERROR", "message" => "Campos requeridos: titulo, descripcion."]);
            return;
        }

        $cursoDTO = new CursoDTO(
            titulo: $data['titulo'],
            descripcion: $data['descripcion'],
            id_estado: $data['id_estado'] ?? 1,
            id_curso: $id
        );

        try {
            $response = $this->cursoService->updateCurso($cursoDTO);
            echo json_encode($response);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(["status" => "ERROR", "message" => $e->getMessage()]);
        }
    }

    // Eliminar curso
    public function delete($id): void {
        $this->validarToken(); // 🔒 Validar JWT

        try {
            $response = $this->cursoService->deleteCurso($id);
            echo json_encode($response);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(["status" => "ERROR", "message" => $e->getMessage()]);
        }
    }

    // Obtener todos los cursos
    public function getAll(): void {
       $usuario = $this->validarToken();
        
        
        
        if (empty($usuario['id_usuario'])) {
            http_response_code(400);
            echo json_encode(["status" => "ERROR", "message" => "ID de usuario no encontrado en el token"]);
            return;
        }


        try {
            $response = $this->cursoService->getAll($usuario['id_usuario']);
            echo json_encode($response);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(["status" => "ERROR", "message" => $e->getMessage()]);
        }
    }
}
