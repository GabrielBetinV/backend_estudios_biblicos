<?php
namespace App\Services;

use App\Models\InscripcionModel;
use App\DTO\InscripcionDTO;

class InscripcionService {
    private InscripcionModel $model;

    public function __construct() {
        $this->model = new InscripcionModel();
    }

    public function createInscripcion(InscripcionDTO $dto) {
        return $this->model->create($dto);
    }

    public function getInscripcionById($id) {
        return $this->model->getById($id);
    }

    public function updateInscripcion(InscripcionDTO $dto) {
        return $this->model->update($dto);
    }

    public function deleteInscripcion($id) {
        return $this->model->delete($id);
    }

    public function getAll() {
        return $this->model->getAll();
    }
}
