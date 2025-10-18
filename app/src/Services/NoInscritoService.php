<?php

namespace App\Services;

use App\Models\NoInscritoModel;

class NoInscritoService {
    private NoInscritoModel $model;

    public function __construct() {
        $this->model = new NoInscritoModel();
    }

    public function getCursosNoInscritos($id_usuario,$idCurso) {
        return $this->model->getCursosNoInscritos($id_usuario,$idCurso);
    }
}
