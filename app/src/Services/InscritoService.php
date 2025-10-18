<?php

namespace App\Services;

use App\Models\InscritoModel;

class InscritoService {
    private InscritoModel $model;

    public function __construct() {
        $this->model = new InscritoModel();
    }

    public function getCursosInscritos($id_usuario,$idCurso) {
        return $this->model->getCursosInscritos($id_usuario,$idCurso);
    }
}
