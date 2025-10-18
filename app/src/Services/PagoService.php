<?php
namespace App\Services;

use App\Models\PagoModel;
use App\DTO\PagoDTO;

class PagoService {
    private PagoModel $model;

    public function __construct() { $this->model = new PagoModel(); }

    public function createPago(PagoDTO $dto) { return $this->model->create($dto); }
    public function getPagoById($id) { return $this->model->getById($id); }
    public function updatePago(PagoDTO $dto) { return $this->model->update($dto); }
    public function deletePago($id) { return $this->model->delete($id); }
    public function getAll() { return $this->model->getAll(); }
}
