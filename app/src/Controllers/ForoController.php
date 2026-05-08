<?php

namespace App\Controllers;

use App\Services\ForoService;
use App\Helpers\JwtHelper;
use Exception;

class ForoController {
    private ForoService $foroService;

    public function __construct() {
        $this->foroService = new ForoService();
    }

    private function validarToken(): array {
        $headers = getallheaders();
        $authHeader = $headers['Authorization'] ?? $headers['authorization'] ?? null;

        if (!$authHeader) {
            http_response_code(401);
            echo json_encode(["status" => "ERROR", "message" => "Token no proporcionado"]);
            exit;
        }

        if (!preg_match('/Bearer\s(\S+)/', $authHeader, $matches)) {
            http_response_code(400);
            echo json_encode(["status" => "ERROR", "message" => "Formato de token inválido"]);
            exit;
        }

        $token = $matches[1];

        try {
            $decoded = JwtHelper::verificarToken($token);
            return $decoded['data'] ?? [];
        } catch (Exception $e) {
            http_response_code(401);
            echo json_encode(["status" => "ERROR", "message" => "Token inválido: " . $e->getMessage()]);
            exit;
        }
    }

    // ✅ Obtener todas las preguntas de un módulo
    public function getPreguntasByCurso(): void {
        $usuario = $this->validarToken();
        $data = json_decode(file_get_contents('php://input'), true);

        if (empty($data['id_curso'])) {
            http_response_code(400);
            echo json_encode(["status" => "ERROR", "message" => "Debe enviar el id_modulo"]);
            return;
        }

        try {
            $response = $this->foroService->getPreguntasByCurso($data['id_curso'],$usuario['id_usuario'],$data['id_leccion'],$data['id_subleccion']);
            echo json_encode($response);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(["status" => "ERROR", "message" => $e->getMessage()]);
        }
    }

    // ✅ Insertar nueva pregunta
    public function insertPregunta(): void {
        $usuario = $this->validarToken();
        $data = json_decode(file_get_contents('php://input'), true);

        if (empty($data['id_curso']) || empty($data['titulo']) || empty($data['descripcion'])) {
            http_response_code(400);
            echo json_encode(["status" => "ERROR", "message" => "Campos requeridos: id_modulo, titulo, descripcion"]);
            return;
        }

        $data['id_usuario'] = $usuario['id_usuario'];

        try {
            $response = $this->foroService->insertPregunta($data);
            echo json_encode($response);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(["status" => "ERROR", "message" => $e->getMessage()]);
        }
    }

    // ✅ Insertar respuesta a una pregunta
    public function insertRespuesta(): void {
        $usuario = $this->validarToken();
        $data = json_decode(file_get_contents('php://input'), true);

        if (empty($data['id_pregunta']) || empty($data['respuesta'])) {
            http_response_code(400);
            echo json_encode(["status" => "ERROR", "message" => "Campos requeridos: id_pregunta, respuesta"]);
            return;
        }

        $data['id_usuario'] = $usuario['id_usuario'];

        try {
            $response = $this->foroService->insertRespuesta($data);
            echo json_encode($response);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(["status" => "ERROR", "message" => $e->getMessage()]);
        }
    }

    // ✅ Insertar comentario a una respuesta
    public function insertComentario(): void {
        $usuario = $this->validarToken();
        $data = json_decode(file_get_contents('php://input'), true);

        if (empty($data['id_respuesta']) || empty($data['contenido'])) {
            http_response_code(400);
            echo json_encode(["status" => "ERROR", "message" => "Campos requeridos: id_respuesta, comentario"]);
            return;
        }

        $data['id_usuario'] = $usuario['id_usuario'];

        try {
            $response = $this->foroService->insertComentario($data);
            echo json_encode($response);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(["status" => "ERROR", "message" => $e->getMessage()]);
        }
    }
}
