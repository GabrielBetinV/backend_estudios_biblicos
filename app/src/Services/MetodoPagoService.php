<?php
namespace App\Services;

use App\Models\MetodoPagoModel;
use App\DTO\MetodoPagoDTO;

class MetodoPagoService {
    private MetodoPagoModel $model;

    public function __construct() { $this->model = new MetodoPagoModel(); }

    public function createMetodoPago(MetodoPagoDTO $dto) { return $this->model->create($dto); }
    public function getMetodoPagoById($id) { return $this->model->getById($id); }
    public function updateMetodoPago(MetodoPagoDTO $dto) { return $this->model->update($dto); }
    public function deleteMetodoPago($id) { return $this->model->delete($id); }
    public function getAll() { return $this->model->getAll(); }
}
