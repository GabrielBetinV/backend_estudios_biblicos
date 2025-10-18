<?php

namespace App\Services;

use App\Models\InscritoModel;

class InscritoService
{
    private InscritoModel $model;

    public function __construct()
    {
        $this->model = new InscritoModel();
    }

    public function getCursosInscritos($id_usuario, $idCurso)
    {
        return $this->model->getCursosInscritos($id_usuario, $idCurso);
    }


    public function actualizarProgreso($id_usuario, $id_curso, $progreso)
    {
        return $this->model->actualizarProgreso($id_usuario, $id_curso, $progreso);
    }

    public function actualizarResultado($id_usuario, $id_quiz, $resultado)
    {
        return $this->model->actualizarResultado($id_usuario, $id_quiz, $resultado);
    }



    public function actualizarProgresoSubleccion($id_usuario, $id_curso, $id_leccion ,$id_subleccion, $completed)
    {
        return $this->model->actualizarProgresoSubleccion($id_usuario, $id_curso, $id_leccion ,$id_subleccion, $completed);
    }

}
