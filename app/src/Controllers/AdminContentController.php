<?php

namespace App\Controllers;

use App\Helpers\JwtHelper;
use App\Config\Database;
use Exception;

class AdminContentController {
    
    private function validarAdmin(): array {
        $headers = getallheaders();
        $authHeader = $headers['Authorization'] ?? $headers['authorization'] ?? null;
        if (!$authHeader || !preg_match('/Bearer\s(\S+)/', $authHeader, $matches)) {
            http_response_code(401); echo json_encode(["status" => "ERROR", "message" => "No autorizado."]); exit;
        }
        try {
            $decoded = JwtHelper::verificarToken($matches[1]);
            $userData = $decoded['data'];
            if ($userData['id_rol'] != 1) {
                http_response_code(403); echo json_encode(["status" => "ERROR", "message" => "Acceso denegado."]); exit;
            }
            return $userData;
        } catch (Exception $e) {
            http_response_code(401); echo json_encode(["status" => "ERROR", "message" => "Sesión inválida."]); exit;
        }
    }

    public function createEvidencia(): void {
        $this->validarAdmin();
        $data = json_decode(file_get_contents('php://input'), true);
        $res = Database::getInstance()->executeProcedure("CALL sp_insert_evidencia(:v_data, @v_salida)", $data);
        echo json_encode($res);
    }

    public function createQuiz(): void {
        $this->validarAdmin();
        $data = json_decode(file_get_contents('php://input'), true);
        $res = Database::getInstance()->executeProcedure("CALL sp_insert_quiz(:v_data, @v_salida)", $data);
        echo json_encode($res);
    }

    public function addQuizPregunta(): void {
        $this->validarAdmin();
        $data = json_decode(file_get_contents('php://input'), true);
        $res = Database::getInstance()->executeProcedure("CALL sp_insert_quiz_pregunta(:v_data, @v_salida)", $data);
        echo json_encode($res);
    }

    public function createForoPregunta(): void {
        $this->validarAdmin();
        $data = json_decode(file_get_contents('php://input'), true);
        echo json_encode(Database::getInstance()->executeProcedure("CALL sp_insert_foro_pregunta_admin(:v_data, @v_salida)", $data));
    }

    public function createModulo(): void {
        $this->validarAdmin();
        $data = json_decode(file_get_contents('php://input'), true);
        echo json_encode(Database::getInstance()->executeProcedure("CALL sp_insert_modulo(:v_data, @v_salida)", $data));
    }

    public function createLeccion(): void {
        $this->validarAdmin();
        $data = json_decode(file_get_contents('php://input'), true);
        echo json_encode(Database::getInstance()->executeProcedure("CALL sp_insert_leccion(:v_data, @v_salida)", $data));
    }

    public function createSubleccion(): void {
        $this->validarAdmin();
        $data = json_decode(file_get_contents('php://input'), true);
        echo json_encode(Database::getInstance()->executeProcedure("CALL sp_insert_subleccion(:v_data, @v_salida)", $data));
    }

    public function updateModulo(): void {
        $this->validarAdmin();
        $data = json_decode(file_get_contents('php://input'), true);
        echo json_encode(Database::getInstance()->executeProcedure("CALL sp_update_modulo(:v_data, @v_salida)", $data));
    }

    public function updateLeccion(): void {
        $this->validarAdmin();
        $data = json_decode(file_get_contents('php://input'), true);
        echo json_encode(Database::getInstance()->executeProcedure("CALL sp_update_leccion(:v_data, @v_salida)", $data));
    }

    public function updateSubleccion(): void {
        $this->validarAdmin();
        $data = json_decode(file_get_contents('php://input'), true);
        echo json_encode(Database::getInstance()->executeProcedure("CALL sp_update_subleccion(:v_data, @v_salida)", $data));
    }

    public function manageCategoria(): void {
        $this->validarAdmin();
        $method = $_SERVER['REQUEST_METHOD'];
        $data = json_decode(file_get_contents('php://input'), true);
        if ($method === 'POST') {
            echo json_encode(Database::getInstance()->executeProcedure("CALL sp_insert_categoria(:v_data, @v_salida)", $data));
        } elseif ($method === 'PUT') {
            echo json_encode(Database::getInstance()->executeProcedure("CALL sp_update_categoria(:v_data, @v_salida)", $data));
        }
    }
}
