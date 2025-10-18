<?php
namespace App\Models;

use App\DTO\PagoDTO;
use App\DTO\ApiResponseDTO;
use App\Config\Database;

class PagoModel {
    public function create(PagoDTO $dto): ApiResponseDTO {
        return Database::getInstance()->executeProcedure(
            "CALL sp_insert_pago(:v_data, @v_salida)",
            $dto->toArray()
        );
    }

    public function getById($id_pago): ApiResponseDTO {
        return Database::getInstance()->executeProcedure(
            "CALL sp_get_pago_by_id(:v_data, @v_salida)",
            ['id_pago' => $id_pago]
        );
    }

    public function update(PagoDTO $dto): ApiResponseDTO {
        return Database::getInstance()->executeProcedure(
            "CALL sp_update_pago(:v_data, @v_salida)",
            $dto->toArray()
        );
    }

    public function delete($id_pago): ApiResponseDTO {
        return Database::getInstance()->executeProcedure(
            "CALL sp_delete_pago(:v_data, @v_salida)",
            ['id_pago' => $id_pago]
        );
    }

    public function getAll(): ApiResponseDTO {
        return Database::getInstance()->executeProcedure(
            "CALL sp_get_all_pagos(:v_data, @v_salida)",
            []
        );
    }
}
