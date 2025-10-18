<?php

namespace App\Services;

use App\Models\CategoriaModel;

class CategoriaService {
    private CategoriaModel $categoriaModel;

    public function __construct() {
        $this->categoriaModel = new CategoriaModel();
    }

    public function getAll($id_usuario) {
        return $this->categoriaModel->getAll($id_usuario);
    }
}
