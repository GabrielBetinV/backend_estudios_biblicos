<?php

namespace App\Services;

use App\Models\LeccionModel;
use App\DTO\LeccionDTO;

class LeccionService {
    private LeccionModel $leccionModel;

    public function __construct() {
        $this->leccionModel = new LeccionModel();
    }

    public function createLeccion(LeccionDTO $leccionDTO) {
        return $this->leccionModel->create($leccionDTO);
    }

    public function getLeccionById($id) {
        return $this->leccionModel->getById($id);
    }

    public function updateLeccion(LeccionDTO $leccionDTO) {
        return $this->leccionModel->update($leccionDTO);
    }

    public function deleteLeccion($id) {
        return $this->leccionModel->delete($id);
    }

    public function getAll() {
        return $this->leccionModel->getAll();
    }
}
