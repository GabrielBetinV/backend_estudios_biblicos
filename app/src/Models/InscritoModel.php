<?php

namespace App\Models;

use App\Config\Database;
use App\DTO\ApiResponseDTO;

class InscritoModel {

    public function getCursosInscritos($id_usuario, $idCurso, $idGrupo = null): ApiResponseDTO {
        $data = [
          'id_curso'   => $idCurso,
          'id_usuario' => $id_usuario
        ];
        if (!empty($idGrupo)) {
            $data['id_grupo'] = $idGrupo;
        }
        return Database::getInstance()->executeProcedure(
            "CALL sp_get_cursos_inscritos(:v_data, @v_salida)",
            $data
        );
    }



public function actualizarProgreso($id_usuario, $id_curso, $progreso, $id_grupo = null): ApiResponseDTO {
    $data = [
        'id_usuario' => $id_usuario,
        'id_curso'   => $id_curso,
        'progreso'   => $progreso
    ];
    if (!empty($id_grupo)) {
        $data['id_grupo'] = $id_grupo;
    }
    return Database::getInstance()->executeProcedure(
        "CALL sp_actualizar_progreso_curso(:v_data, @v_salida)",
        $data
    );
}

public function actualizarResultado($id_usuario, $id_quiz, $resultado, $id_grupo = null): ApiResponseDTO {
    $data = [
        'id_usuario' => $id_usuario,
        'id_quiz'   => $id_quiz,
        'nota'  => $resultado
    ];
    if (!empty($id_grupo)) {
        $data['id_grupo'] = $id_grupo;
    }
    return Database::getInstance()->executeProcedure(
        "CALL sp_actualizar_resultado(:v_data, @v_salida)",
        $data
    );
}

public function guardarReflexion($id_usuario, $id_evidencia, $respuesta, $id_grupo = null): ApiResponseDTO {
    $data = [
        'id_usuario'   => $id_usuario,
        'id_evidencia' => $id_evidencia,
        'respuesta'    => $respuesta
    ];
    if (!empty($id_grupo)) {
        $data['id_grupo'] = $id_grupo;
    }
    return Database::getInstance()->executeProcedure(
        "CALL sp_insert_reflexion_respuesta(:v_data, @v_salida)",
        $data
    );
}

public function actualizarProgresoSubleccion($id_usuario, $id_curso, $id_leccion ,$id_subleccion, $completed, $id_grupo = null): ApiResponseDTO {
    $data = [
        'id_usuario' => $id_usuario,
        'id_curso'   => $id_curso,
        'id_leccion'   => $id_leccion,
        'id_subleccion'   => $id_subleccion,
        'completed'   => $completed
    ];
    if (!empty($id_grupo)) {
        $data['id_grupo'] = $id_grupo;
    }
    return Database::getInstance()->executeProcedure(
        "CALL sp_actualizar_progreso_subleccion(:v_data, @v_salida)",
        $data
    );
}

}
