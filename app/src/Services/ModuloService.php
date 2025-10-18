<?php

namespace App\Services;

use App\Models\ModuloModel;
use App\DTO\ModuloDTO;

class ModuloService {
    private ModuloModel $moduloModel;

    public function __construct() {
        $this->moduloModel = new ModuloModel();
    }

    public function createModulo(ModuloDTO $moduloDTO) {
        return $this->moduloModel->create($moduloDTO);
    }

    public function getModuloById($id) {
        return $this->moduloModel->getById($id);
    }

    public function updateModulo(ModuloDTO $moduloDTO) {
        return $this->moduloModel->update($moduloDTO);
    }

    public function deleteModulo($id) {
        return $this->moduloModel->delete($id);
    }

    public function getAll() {
        return $this->moduloModel->getAll();
    }
}
