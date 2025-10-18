<?php

namespace App\Models;

use App\Config\Database;
use App\DTO\ApiResponseDTO;

class InscritoModel {

    public function getCursosInscritos($id_usuario, $idCurso): ApiResponseDTO {
        return Database::getInstance()->executeProcedure(
            "CALL sp_get_cursos_inscritos(:v_data, @v_salida)",
            [
      
          'id_curso'   => $idCurso,
          'id_usuario' => $id_usuario
         ]
        );
    }



public function actualizarProgreso($id_usuario, $id_curso, $progreso): ApiResponseDTO {
    return Database::getInstance()->executeProcedure(
        "CALL sp_actualizar_progreso_curso(:v_data, @v_salida)",
        [
            'id_usuario' => $id_usuario,
            'id_curso'   => $id_curso,
            'progreso'   => $progreso
        ]
    );
}

public function actualizarResultado($id_usuario, $id_quiz, $resultado): ApiResponseDTO {
    return Database::getInstance()->executeProcedure(
        "CALL sp_actualizar_resultado(:v_data, @v_salida)",
        [
            'id_usuario' => $id_usuario,
            'id_quiz'   => $id_quiz,
            'nota'  => $resultado
        ]
    );
}

public function actualizarProgresoSubleccion($id_usuario, $id_curso, $id_leccion ,$id_subleccion, $completed): ApiResponseDTO {
    return Database::getInstance()->executeProcedure(
        "CALL sp_actualizar_progreso_subleccion(:v_data, @v_salida)",
        [
            'id_usuario' => $id_usuario,
            'id_curso'   => $id_curso,
            'id_leccion'   => $id_leccion,
            'id_subleccion'   => $id_subleccion,
            'completed'   => $completed
        ]
    );
}

}
