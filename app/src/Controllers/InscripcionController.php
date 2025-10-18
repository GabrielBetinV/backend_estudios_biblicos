<?php
namespace App\Controllers;

use App\Services\InscripcionService;
use App\DTO\InscripcionDTO;
use Exception;

class InscripcionController {
    private InscripcionService $service;

    public function __construct() {
        $this->service = new InscripcionService();
    }

    // Crear inscripción
    public function create(): void {
        $data = json_decode(file_get_contents('php://input'), true);
        if (empty($data['id_usuario']) || empty($data['id_curso'])) {
            http_response_code(400);
            echo json_encode(["status"=>"ERROR","message"=>"Campos requeridos: id_usuario, id_curso.","data"=>null]);
            return;
        }

        $dto = new InscripcionDTO(
            id_usuario: $data['id_usuario'],
            id_curso: $data['id_curso'],
            fecha_inscripcion: $data['fecha_inscripcion'] ?? date('Y-m-d H:i:s')
        );

        try {
            $res = $this->service->createInscripcion($dto);
            echo json_encode($res);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(["status"=>"ERROR","message"=>$e->getMessage(),"data"=>null]);
        }
    }

    // Obtener por ID
    public function getById($id): void {
        try {
            $res = $this->service->getInscripcionById($id);
            echo json_encode($res);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(["status"=>"ERROR","message"=>$e->getMessage(),"data"=>null]);
        }
    }

    // Actualizar
    public function update($id): void {
        $data = json_decode(file_get_contents('php://input'), true);
        if (empty($data['id_usuario']) || empty($data['id_curso'])) {
            http_response_code(400);
            echo json_encode(["status"=>"ERROR","message"=>"Campos requeridos: id_usuario, id_curso.","data"=>null]);
            return;
        }

        $dto = new InscripcionDTO(
            id_inscripcion: $id,
            id_usuario: $data['id_usuario'],
            id_curso: $data['id_curso'],
            fecha_inscripcion: $data['fecha_inscripcion'] ?? date('Y-m-d H:i:s')
        );

        try {
            $res = $this->service->updateInscripcion($dto);
            echo json_encode($res);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(["status"=>"ERROR","message"=>$e->getMessage(),"data"=>null]);
        }
    }

    // Eliminar
    public function delete($id): void {
        try {
            $res = $this->service->deleteInscripcion($id);
            echo json_encode($res);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(["status"=>"ERROR","message"=>$e->getMessage(),"data"=>null]);
        }
    }

    // Obtener todos
    public function getAll(): void {
        try {
            $res = $this->service->getAll();
            echo json_encode($res);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(["status"=>"ERROR","message"=>$e->getMessage(),"data"=>null]);
        }
    }
}
