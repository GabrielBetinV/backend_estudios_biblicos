<?php

namespace App\Controllers;

use App\Services\LeccionService;
use App\DTO\LeccionDTO;
use Exception;

class LeccionController {
    private LeccionService $leccionService;

    public function __construct() {
        $this->leccionService = new LeccionService();
    }

    public function create(): void {
        $data = json_decode(file_get_contents('php://input'), true);

        if (empty($data['id_modulo']) || empty($data['titulo'])) {
            http_response_code(400);
            echo json_encode(["status" => "ERROR", "message" => "Campos requeridos: id_modulo, titulo"]);
            return;
        }

        $leccionDTO = new LeccionDTO(
            id_modulo: $data['id_modulo'],
            titulo: $data['titulo'],
            descripcion: $data['descripcion'] ?? null,
            video_url: $data['video_url'] ?? null,
            id_estado: $data['id_estado'] ?? 1
        );

        try {
            $response = $this->leccionService->createLeccion($leccionDTO);
            http_response_code($response->status === 'OK' ? 201 : 409);
            echo json_encode($response);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(["status" => "ERROR", "message" => $e->getMessage()]);
        }
    }

    public function getById($id): void {
        try {
            $response = $this->leccionService->getLeccionById($id);
            echo json_encode($response);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(["status" => "ERROR", "message" => $e->getMessage()]);
        }
    }

    public function update($id): void {
        $data = json_decode(file_get_contents('php://input'), true);

        if (empty($data['titulo'])) {
            http_response_code(400);
            echo json_encode(["status" => "ERROR", "message" => "Campo requerido: titulo"]);
            return;
        }

        $leccionDTO = new LeccionDTO(
            id_modulo: $data['id_modulo'],
            titulo: $data['titulo'],
            descripcion: $data['descripcion'] ?? null,
            video_url: $data['video_url'] ?? null,
            id_estado: $data['id_estado'] ?? 1,
            id_leccion: $id
        );

        try {
            $response = $this->leccionService->updateLeccion($leccionDTO);
            echo json_encode($response);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(["status" => "ERROR", "message" => $e->getMessage()]);
        }
    }

    public function delete($id): void {
        try {
            $response = $this->leccionService->deleteLeccion($id);
            echo json_encode($response);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(["status" => "ERROR", "message" => $e->getMessage()]);
        }
    }

    public function getAll(): void {
        try {
            $response = $this->leccionService->getAll();
            echo json_encode($response);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(["status" => "ERROR", "message" => $e->getMessage()]);
        }
    }
}
