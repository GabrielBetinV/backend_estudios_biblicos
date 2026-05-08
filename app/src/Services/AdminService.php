<?php

namespace App\Services;

use App\Models\AdminModel;

class AdminService {
    private AdminModel $adminModel;

    public function __construct() {
        $this->adminModel = new AdminModel();
    }

    public function getStats() {
        return $this->adminModel->getStats();
    }

    public function getAllUsuarios() {
        return $this->adminModel->getAllUsuarios();
    }

    public function updateRol($data) {
        return $this->adminModel->updateRol($data);
    }

    public function getCursosAdmin() {
        return $this->adminModel->getCursosAdmin();
    }

    public function getCursoDetalle($id_curso) {
        return $this->adminModel->getCursoDetalle($id_curso);
    }
}
