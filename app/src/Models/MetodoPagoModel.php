<?php
namespace App\Models;

use App\DTO\MetodoPagoDTO;
use App\DTO\ApiResponseDTO;
use App\Config\Database;

class MetodoPagoModel {
    public function create(MetodoPagoDTO $dto): ApiResponseDTO {
        return Database::getInstance()->executeProcedure(
            "CALL sp_insert_metodo_pago(:v_data, @v_salida)",
            $dto->toArray()
        );
    }

    public function getById($id_metodo): ApiResponseDTO {
        return Database::getInstance()->executeProcedure(
            "CALL sp_get_metodo_pago_by_id(:v_data, @v_salida)",
            ['id_metodo' => $id_metodo]
        );
    }

    public function update(MetodoPagoDTO $dto): ApiResponseDTO {
        return Database::getInstance()->executeProcedure(
            "CALL sp_update_metodo_pago(:v_data, @v_salida)",
            $dto->toArray()
        );
    }

    public function delete($id_metodo): ApiResponseDTO {
        return Database::getInstance()->executeProcedure(
            "CALL sp_delete_metodo_pago(:v_data, @v_salida)",
            ['id_metodo' => $id_metodo]
        );
    }

    public function getAll(): ApiResponseDTO {
        return Database::getInstance()->executeProcedure(
            "CALL sp_get_metodos_pago(:v_data, @v_salida)",
            []
        );
    }
}
