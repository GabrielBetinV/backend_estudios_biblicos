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

    public function getCursosInscritos($id_usuario, $idCurso, $idGrupo = null)
    {
        return $this->model->getCursosInscritos($id_usuario, $idCurso, $idGrupo);
    }


    public function actualizarProgreso($id_usuario, $id_curso, $progreso, $id_grupo = null)
    {
        return $this->model->actualizarProgreso($id_usuario, $id_curso, $progreso, $id_grupo);
    }

    public function actualizarResultado($id_usuario, $id_quiz, $resultado, $id_grupo = null)
    {
        return $this->model->actualizarResultado($id_usuario, $id_quiz, $resultado, $id_grupo);
    }



    public function guardarReflexion($id_usuario, $id_evidencia, $respuesta, $id_grupo = null)
    {
        return $this->model->guardarReflexion($id_usuario, $id_evidencia, $respuesta, $id_grupo);
    }

    public function actualizarProgresoSubleccion($id_usuario, $id_curso, $id_leccion ,$id_subleccion, $completed, $id_grupo = null)
    {
        return $this->model->actualizarProgresoSubleccion($id_usuario, $id_curso, $id_leccion ,$id_subleccion, $completed, $id_grupo);
    }

}
