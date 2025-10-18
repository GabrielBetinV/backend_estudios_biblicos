<?php

namespace App\Services;

use App\Models\SubLeccionModel;
use App\DTO\SubLeccionDTO;

class SubLeccionService {
    private SubLeccionModel $subLeccionModel;

    public function __construct() {
        $this->subLeccionModel = new SubLeccionModel();
    }

    public function createSubLeccion(SubLeccionDTO $dto) {
        return $this->subLeccionModel->create($dto);
    }

    public function getSubLeccionById($id) {
        return $this->subLeccionModel->getById($id);
    }

    public function updateSubLeccion(SubLeccionDTO $dto) {
        return $this->subLeccionModel->update($dto);
    }

    public function deleteSubLeccion($id) {
        return $this->subLeccionModel->delete($id);
    }

    public function getAll() {
        return $this->subLeccionModel->getAll();
    }
}
