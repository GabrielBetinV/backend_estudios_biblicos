<?php

namespace App\Controllers;

use App\Services\SubLeccionService;
use App\DTO\SubLeccionDTO;
use Exception;

class SubLeccionController {
    private SubLeccionService $subLeccionService;

    public function __construct() {
        $this->subLeccionService = new SubLeccionService();
    }

    public function create(): void {
        $data = json_decode(file_get_contents('php://input'), true);

        if (empty($data['id_leccion']) || empty($data['titulo'])) {
            http_response_code(400);
            echo json_encode(["status" => "ERROR", "message" => "Campos requeridos: id_leccion, titulo"]);
            return;
        }

        $subLeccionDTO = new SubLeccionDTO(
            id_leccion: $data['id_leccion'],
            titulo: $data['titulo'],
            descripcion: $data['descripcion'] ?? null,
            video_url: $data['video_url'] ?? null,
            id_estado: $data['id_estado'] ?? 1
        );

        try {
            $response = $this->subLeccionService->createSubLeccion($subLeccionDTO);
            http_response_code($response->status === 'OK' ? 201 : 409);
            echo json_encode($response);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(["status" => "ERROR", "message" => $e->getMessage()]);
        }
    }

    public function getById($id): void {
        try {
            $response = $this->subLeccionService->getSubLeccionById($id);
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

        $subLeccionDTO = new SubLeccionDTO(
            id_leccion: $data['id_leccion'],
            titulo: $data['titulo'],
            descripcion: $data['descripcion'] ?? null,
            video_url: $data['video_url'] ?? null,
            id_estado: $data['id_estado'] ?? 1,
            id_subleccion: $id
        );

        try {
            $response = $this->subLeccionService->updateSubLeccion($subLeccionDTO);
            echo json_encode($response);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(["status" => "ERROR", "message" => $e->getMessage()]);
        }
    }

    public function delete($id): void {
        try {
            $response = $this->subLeccionService->deleteSubLeccion($id);
            echo json_encode($response);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(["status" => "ERROR", "message" => $e->getMessage()]);
        }
    }

    public function getAll(): void {
        try {
            $response = $this->subLeccionService->getAll();
            echo json_encode($response);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(["status" => "ERROR", "message" => $e->getMessage()]);
        }
    }
}
