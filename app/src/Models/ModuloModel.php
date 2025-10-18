<?php

namespace App\Models;

use App\DTO\ModuloDTO;
use App\DTO\ApiResponseDTO;
use App\Config\Database;

class ModuloModel {
    public function create(ModuloDTO $moduloDTO): ApiResponseDTO {
        return Database::getInstance()->executeProcedure(
            "CALL sp_insert_modulo(:v_data, @v_salida)",
            $moduloDTO->toArray()
        );
    }

    public function getById($id_modulo): ApiResponseDTO {
        return Database::getInstance()->executeProcedure(
            "CALL sp_get_modulo_by_id(:v_data, @v_salida)",
            ['id_modulo' => $id_modulo]
        );
    }

    public function update(ModuloDTO $moduloDTO): ApiResponseDTO {
        return Database::getInstance()->executeProcedure(
            "CALL sp_update_modulo(:v_data, @v_salida)",
            $moduloDTO->toArray()
        );
    }

    public function delete($id_modulo): ApiResponseDTO {
        return Database::getInstance()->executeProcedure(
            "CALL sp_delete_modulo(:v_data, @v_salida)",
            ['id_modulo' => $id_modulo]
        );
    }

    public function getAll(): ApiResponseDTO {
        return Database::getInstance()->executeProcedure(
            "CALL sp_get_all_modulos(:v_data, @v_salida)",
            []
        );
    }
}
