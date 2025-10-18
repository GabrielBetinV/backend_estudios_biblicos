<?php

namespace App\Controllers;

use App\Services\InscritoService;
use App\Helpers\JwtHelper;
use Exception;

class InscritoController {
    private InscritoService $service;

    public function __construct() {
        $this->service = new InscritoService();
    }

    private function validarToken(): array {
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

    public function getCursosInscritos($idCurso): void {
        $usuario = $this->validarToken();

        if (empty($usuario['id_usuario'])) {
            http_response_code(400);
            echo json_encode(["status" => "ERROR", "message" => "ID de usuario no encontrado en el token"]);
            return;
        }

        try {
            $response = $this->service->getCursosInscritos($usuario['id_usuario'],$idCurso);
            echo json_encode($response);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(["status" => "ERROR", "message" => $e->getMessage()]);
        }
    }
}
