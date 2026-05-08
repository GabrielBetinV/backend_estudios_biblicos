<?php

namespace App\Services;

use App\Models\ForoModel;

class ForoService {
    private ForoModel $foroModel;

    public function __construct() {
        $this->foroModel = new ForoModel();
    }

    public function getPreguntasByCurso($id_curso,$id_usuario,$id_leccion,$id_subleccion) {
        return $this->foroModel->getPreguntasByCurso($id_curso,$id_usuario,$id_leccion,$id_subleccion);
    }

    public function insertPregunta(array $data) {
        return $this->foroModel->insertPregunta($data);
    }

    public function insertRespuesta(array $data) {
        return $this->foroModel->insertRespuesta($data);
    }

    public function insertComentario(array $data) {
        return $this->foroModel->insertComentario($data);
    }
}
