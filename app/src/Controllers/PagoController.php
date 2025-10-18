<?php
namespace App\Controllers;

use App\Services\PagoService;
use App\DTO\PagoDTO;
use Exception;

class PagoController {
    private PagoService $service;

    public function __construct() { $this->service = new PagoService(); }

    public function create(): void {
        $data = json_decode(file_get_contents('php://input'), true);
        if (empty($data['id_inscripcion']) || !isset($data['monto']) || empty($data['id_metodo'])) {
            http_response_code(400);
            echo json_encode(["status"=>"ERROR","message"=>"Campos requeridos: id_inscripcion, monto, id_metodo.","data"=>null]);
            return;
        }

        $dto = new PagoDTO(
            id_inscripcion: $data['id_inscripcion'],
            monto: $data['monto'],
            fecha: $data['fecha'] ?? date('Y-m-d H:i:s'),
            id_metodo: $data['id_metodo'],
            id_estado: $data['id_estado'] ?? 1
        );

        try {
            $res = $this->service->createPago($dto);
            echo json_encode($res);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(["status"=>"ERROR","message"=>$e->getMessage(),"data"=>null]);
        }
    }

    public function getById($id): void {
        try { echo json_encode($this->service->getPagoById($id)); }
        catch (Exception $e) { http_response_code(500); echo json_encode(["status"=>"ERROR","message"=>$e->getMessage(),"data"=>null]); }
    }

    public function update($id): void {
        $data = json_decode(file_get_contents('php://input'), true);
        $dto = new PagoDTO(
            id_pago: $id,
            id_inscripcion: $data['id_inscripcion'] ?? null,
            monto: $data['monto'] ?? null,
            fecha: $data['fecha'] ?? null,
            id_metodo: $data['id_metodo'] ?? null,
            id_estado: $data['id_estado'] ?? null
        );
        try { echo json_encode($this->service->updatePago($dto)); }
        catch (Exception $e) { http_response_code(500); echo json_encode(["status"=>"ERROR","message"=>$e->getMessage(),"data"=>null]); }
    }

    public function delete($id): void {
        try { echo json_encode($this->service->deletePago($id)); }
        catch (Exception $e) { http_response_code(500); echo json_encode(["status"=>"ERROR","message"=>$e->getMessage(),"data"=>null]); }
    }

    public function getAll(): void {
        try { echo json_encode($this->service->getAll()); }
        catch (Exception $e) { http_response_code(500); echo json_encode(["status"=>"ERROR","message"=>$e->getMessage(),"data"=>null]); }
    }
}
