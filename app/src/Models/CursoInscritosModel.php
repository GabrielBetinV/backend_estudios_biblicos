<?php

namespace App\Models;

use App\DTO\CursoDTO;
use App\DTO\ApiResponseDTO;
use App\Config\Database;

class CursoInscritosModel {
    public function create(CursoDTO $cursoDTO): ApiResponseDTO {
        return Database::getInstance()->executeProcedure(
            "CALL sp_insert_curso(:v_data, @v_salida)",
            $cursoDTO->toArray()
        );
    }

    public function getById($id_curso): ApiResponseDTO {
        return Database::getInstance()->executeProcedure(
            "CALL sp_get_curso_by_id(:v_data, @v_salida)",
            ['id_curso' => $id_curso]
        );
    }

    public function update(CursoDTO $cursoDTO): ApiResponseDTO {
        return Database::getInstance()->executeProcedure(
            "CALL sp_update_curso(:v_data, @v_salida)",
            $cursoDTO->toArray()
        );
    }

    public function delete($id_curso): ApiResponseDTO {
        return Database::getInstance()->executeProcedure(
            "CALL sp_delete_curso(:v_data, @v_salida)",
            ['id_curso' => $id_curso]
        );
    }

    public function getAll($id_usuario): ApiResponseDTO {
        return Database::getInstance()->executeProcedure(
            "CALL sp_get_all_cursos_inscritos(:v_data, @v_salida)",
             [
              'id_usuario' => $id_usuario
             ]
        );
    }
}
