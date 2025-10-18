<?php

namespace App\Services;

use App\Models\CursoInscritosModel;
use App\DTO\CursoDTO;

class CursoInscritosService {
    private CursoInscritosModel $cursoModel;

    public function __construct() {
        $this->cursoModel = new CursoInscritosModel();
    }

    public function createCurso(CursoDTO $cursoDTO) {
        return $this->cursoModel->create($cursoDTO);
    }

    public function getCursoById($id) {
        return $this->cursoModel->getById($id);
    }

    public function updateCurso(CursoDTO $cursoDTO) {
        return $this->cursoModel->update($cursoDTO);
    }

    public function deleteCurso($id) {
        return $this->cursoModel->delete($id);
    }

    public function getAll($id_usuario) {
        return $this->cursoModel->getAll($id_usuario);
    }
}
