<?php

namespace App\Models;

use App\DTO\LeccionDTO;
use App\DTO\ApiResponseDTO;
use App\Config\Database;

class LeccionModel {
    public function create(LeccionDTO $leccionDTO): ApiResponseDTO {
        return Database::getInstance()->executeProcedure(
            "CALL sp_insert_leccion(:v_data, @v_salida)",
            $leccionDTO->toArray()
        );
    }

    public function getById($id_leccion): ApiResponseDTO {
        return Database::getInstance()->executeProcedure(
            "CALL sp_get_leccion_by_id(:v_data, @v_salida)",
            ['id_leccion' => $id_leccion]
        );
    }

    public function update(LeccionDTO $leccionDTO): ApiResponseDTO {
        return Database::getInstance()->executeProcedure(
            "CALL sp_update_leccion(:v_data, @v_salida)",
            $leccionDTO->toArray()
        );
    }

    public function delete($id_leccion): ApiResponseDTO {
        return Database::getInstance()->executeProcedure(
            "CALL sp_delete_leccion(:v_data, @v_salida)",
            ['id_leccion' => $id_leccion]
        );
    }

    public function getAll(): ApiResponseDTO {
        return Database::getInstance()->executeProcedure(
            "CALL sp_get_all_lecciones(:v_data, @v_salida)",
            []
        );
    }
}
