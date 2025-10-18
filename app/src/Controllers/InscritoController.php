<?php

namespace App\Controllers;

use App\Services\InscritoService;
use App\Helpers\JwtHelper;
use Exception;

class InscritoController
{
    private InscritoService $service;

    public function __construct()
    {
        $this->service = new InscritoService();
    }

    private function validarToken(): array
    {
        $headers = getallheaders();
        $authHeader = $headers['Authorization'] ?? $headers['authorization'] ?? null;

        if (!$authHeader || !preg_match('/Bearer\s(\S+)/', $authHeader, $matches)) {
            http_response_code(401);
            echo json_encode(["status" => "ERROR", "message" => "Token no válido."]);
            exit;
        }

        try {
            $decoded = JwtHelper::verificarToken($matches[1]);
            return $decoded['data'] ?? [];
        } catch (Exception $e) {
            http_response_code(401);
            echo json_encode(["status" => "ERROR", "message" => $e->getMessage()]);
            exit;
        }
    }

    public function getCursosInscritos($idCurso): void
    {
        $usuario = $this->validarToken();

        if (empty($usuario['id_usuario'])) {
            http_response_code(400);
            echo json_encode(["status" => "ERROR", "message" => "ID de usuario no encontrado en el token"]);
            return;
        }

        try {
            $response = $this->service->getCursosInscritos($usuario['id_usuario'], $idCurso);
            echo json_encode($response);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(["status" => "ERROR", "message" => $e->getMessage()]);
        }
    }


    public function actualizarProgreso(): void
    {
        $usuario = $this->validarToken();
        $data = json_decode(file_get_contents("php://input"), true);

        if (empty($usuario['id_usuario']) || empty($data['id_curso']) || !isset($data['progreso'])) {
            http_response_code(400);
            echo json_encode(["status" => "ERROR", "message" => "Datos incompletos. Se requiere id_curso y progreso."]);
            return;
        }

        try {
            $response = $this->service->actualizarProgreso($usuario['id_usuario'], $data['id_curso'], $data['progreso']);
            echo json_encode($response);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(["status" => "ERROR", "message" => $e->getMessage()]);
        }
    }

    public function actualizarResultado(): void
    {
        $usuario = $this->validarToken();
        $data = json_decode(file_get_contents("php://input"), true);

        if (empty($usuario['id_usuario']) || empty($data['id_quiz']) || !isset($data['resultado'])) {
            http_response_code(400);
            echo json_encode(["status" => "ERROR", "message" => "Datos incompletos. Se requiere id_quiz y resultado."]);
            return;
        }

        try {
            $response = $this->service->actualizarResultado($usuario['id_usuario'], $data['id_quiz'], $data['resultado']);
            echo json_encode($response);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(["status" => "ERROR", "message" => $e->getMessage()]);
        }
    }



        public function actualizarProgresoSubleccion(): void
    {
        $usuario = $this->validarToken();
        $data = json_decode(file_get_contents("php://input"), true);

        if (empty($usuario['id_usuario']) || empty($data['id_curso']) || !isset($data['id_leccion']) || !isset($data['id_subleccion']) || !isset($data['completed'])) {
            http_response_code(400);
            echo json_encode(["status" => "ERROR", "message" => "Datos incompletos. Se requiere id_curso y progreso."]);
            return;
        }

        try {
            $response = $this->service->actualizarProgresoSubleccion($usuario['id_usuario'], $data['id_curso'], id_leccion: $data['id_leccion'], id_subleccion: $data['id_subleccion'], completed: $data['completed']);
            echo json_encode($response);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(["status" => "ERROR", "message" => $e->getMessage()]);
        }
    }


}
