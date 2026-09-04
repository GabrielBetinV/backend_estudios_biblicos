<?php

namespace App\Models;

use App\Config\Database;
use App\DTO\ApiResponseDTO;

class ForoModel {

    // 🔹 Consultar preguntas por módulo
    public function getPreguntasByCurso($id_curso,$id_usuario,$id_leccion,$id_subleccion, $id_grupo = null ): ApiResponseDTO {
        
        $params = [
            'id_curso'   => $id_curso,
            'id_usuario' => $id_usuario,
            'id_leccion'  => $id_leccion ,
            'id_subleccion' => $id_subleccion
        ];
        if (!empty($id_grupo)) {
            $params['id_grupo'] = $id_grupo;
        }

        return Database::getInstance()->executeProcedure(
            "CALL sp_get_foro_pregunta_por_curso(:v_data, @v_salida)",
            $params
        );
    }







    // 🔹 Insertar nueva pregunta
    public function insertPregunta(array $data): ApiResponseDTO {
        $jsonInput = json_encode($data);
        return Database::getInstance()->executeProcedure(
            "CALL sp_insert_foro_pregunta(:v_data, @v_salida)",
            ['v_data' => $jsonInput]
        );
    }

    // 🔹 Insertar nueva respuesta
    public function insertRespuesta(array $data): ApiResponseDTO {
        $jsonInput = json_encode($data);
        
        return Database::getInstance()->executeProcedure(
            "CALL sp_insert_foro_respuesta(:v_data, @v_salida)",
            ['v_data' => $jsonInput]
        );
    }

    // 🔹 Insertar comentario en respuesta
    public function insertComentario(array $data): ApiResponseDTO {
        $jsonInput = json_encode($data);
        return Database::getInstance()->executeProcedure(
            "CALL sp_insert_foro_comentario(:v_data, @v_salida)",
            ['v_data' => $jsonInput]
        );
    }


}
