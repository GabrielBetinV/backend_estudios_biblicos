<?php
namespace App\Controllers;

use App\Services\MetodoPagoService;
use App\DTO\MetodoPagoDTO;
use Exception;

class MetodoPagoController {
    private MetodoPagoService $service;

    public function __construct() { $this->service = new MetodoPagoService(); }

    public function create(): void {
        $data = json_decode(file_get_contents('php://input'), true);
        if (empty($data['metodo_nombre'])) {
            http_response_code(400);
            echo json_encode(["status"=>"ERROR","message"=>"Campo requerido: metodo_nombre","data"=>null]);
            return;
        }

        $dto = new MetodoPagoDTO(metodo_nombre: $data['metodo_nombre'], id_metodo: $data['id_metodo'] ?? null);

        try { echo json_encode($this->service->createMetodoPago($dto)); }
        catch (Exception $e) { http_response_code(500); echo json_encode(["status"=>"ERROR","message"=>$e->getMessage(),"data"=>null]); }
    }

    public function getById($id): void {
        try { echo json_encode($this->service->getMetodoPagoById($id)); }
        catch (Exception $e) { http_response_code(500); echo json_encode(["status"=>"ERROR","message"=>$e->getMessage(),"data"=>null]); }
    }

    public function update($id): void {
        $data = json_decode(file_get_contents('php://input'), true);
        if (empty($data['metodo_nombre'])) {
            http_response_code(400);
            echo json_encode(["status"=>"ERROR","message"=>"Campo requerido: metodo_nombre","data"=>null]);
            return;
        }
        $dto = new MetodoPagoDTO($data['metodo_nombre'], $id);
        try { echo json_encode($this->service->updateMetodoPago($dto)); }
        catch (Exception $e) { http_response_code(500); echo json_encode(["status"=>"ERROR","message"=>$e->getMessage(),"data"=>null]); }
    }

    public function delete($id): void {
        try { echo json_encode($this->service->deleteMetodoPago($id)); }
        catch (Exception $e) { http_response_code(500); echo json_encode(["status"=>"ERROR","message"=>$e->getMessage(),"data"=>null]); }
    }

    public function getAll(): void {
        try { echo json_encode($this->service->getAll()); }
        catch (Exception $e) { http_response_code(500); echo json_encode(["status"=>"ERROR","message"=>$e->getMessage(),"data"=>null]); }
    }
}
