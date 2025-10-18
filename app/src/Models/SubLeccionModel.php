<?php

namespace App\Models;

use App\DTO\SubLeccionDTO;
use App\DTO\ApiResponseDTO;
use App\Config\Database;

class SubLeccionModel {
    public function create(SubLeccionDTO $dto): ApiResponseDTO {
        return Database::getInstance()->executeProcedure(
            "CALL sp_insert_subleccion(:v_data, @v_salida)",
            $dto->toArray()
        );
    }

    public function getById($id): ApiResponseDTO {
        return Database::getInstance()->executeProcedure(
            "CALL sp_get_subleccion_by_id(:v_data, @v_salida)",
            ['id_subleccion' => $id]
        );
    }

    public function update(SubLeccionDTO $dto): ApiResponseDTO {
        return Database::getInstance()->executeProcedure(
            "CALL sp_update_subleccion(:v_data, @v_salida)",
            $dto->toArray()
        );
    }

    public function delete($id): ApiResponseDTO {
        return Database::getInstance()->executeProcedure(
            "CALL sp_delete_subleccion(:v_data, @v_salida)",
            ['id_subleccion' => $id]
        );
    }

    public function getAll(): ApiResponseDTO {
        return Database::getInstance()->executeProcedure(
            "CALL sp_get_all_sublecciones(:v_data, @v_salida)",
            []
        );
    }
}
