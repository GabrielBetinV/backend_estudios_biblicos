<?php

namespace App\Controllers;

use App\Services\ModuloService;
use App\DTO\ModuloDTO;
use Exception;

class ModuloController {
    private ModuloService $moduloService;

    public function __construct() {
        $this->moduloService = new ModuloService();
    }

    // Crear módulo
    public function create(): void {
        $data = json_decode(file_get_contents('php://input'), true);

        if (empty($data['id_curso']) || empty($data['titulo'])) {
            http_response_code(400);
            echo json_encode(["status" => "ERROR", "message" => "Campos requeridos: id_curso, titulo"]);
            return;
        }

        $moduloDTO = new ModuloDTO(
            id_curso: $data['id_curso'],
            titulo: $data['titulo'],
            descripcion: $data['descripcion'] ?? null,
            id_estado: $data['id_estado'] ?? 1
        );

        try {
            $response = $this->moduloService->createModulo($moduloDTO);
            http_response_code($response->status === 'OK' ? 201 : 409);
            echo json_encode($response);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(["status" => "ERROR", "message" => $e->getMessage()]);
        }
    }

    // Obtener por ID
    public function getById($id): void {
        try {
            $response = $this->moduloService->getModuloById($id);
            echo json_encode($response);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(["status" => "ERROR", "message" => $e->getMessage()]);
        }
    }

    // Actualizar módulo
    public function update($id): void {
        $data = json_decode(file_get_contents('php://input'), true);

        if (empty($data['titulo'])) {
            http_response_code(400);
            echo json_encode(["status" => "ERROR", "message" => "Campo requerido: titulo"]);
            return;
        }

        $moduloDTO = new ModuloDTO(
            id_modulo: $id,
            id_curso: $data['id_curso'] ?? null,
            titulo: $data['titulo'],
            descripcion: $data['descripcion'] ?? null,
            id_estado: $data['id_estado'] ?? 1
        );

        try {
            $response = $this->moduloService->updateModulo($moduloDTO);
            echo json_encode($response);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(["status" => "ERROR", "message" => $e->getMessage()]);
        }
    }

    // Eliminar módulo
    public function delete($id): void {
        try {
            $response = $this->moduloService->deleteModulo($id);
            echo json_encode($response);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(["status" => "ERROR", "message" => $e->getMessage()]);
        }
    }

    // Obtener todos
    public function getAll(): void {
        try {
            $response = $this->moduloService->getAll();
            echo json_encode($response);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(["status" => "ERROR", "message" => $e->getMessage()]);
        }
    }
}
