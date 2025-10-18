<?php
namespace App\Models;

use App\DTO\InscripcionDTO;
use App\DTO\ApiResponseDTO;
use App\Config\Database;

class InscripcionModel {
    public function create(InscripcionDTO $dto): ApiResponseDTO {
        return Database::getInstance()->executeProcedure(
            "CALL sp_insert_inscripcion(:v_data, @v_salida)",
            $dto->toArray()
        );
    }

    public function getById($id_inscripcion): ApiResponseDTO {
        return Database::getInstance()->executeProcedure(
            "CALL sp_get_inscripcion_by_id(:v_data, @v_salida)",
            ['id_inscripcion' => $id_inscripcion]
        );
    }

    public function update(InscripcionDTO $dto): ApiResponseDTO {
        return Database::getInstance()->executeProcedure(
            "CALL sp_update_inscripcion(:v_data, @v_salida)",
            $dto->toArray()
        );
    }

    public function delete($id_inscripcion): ApiResponseDTO {
        return Database::getInstance()->executeProcedure(
            "CALL sp_delete_inscripcion(:v_data, @v_salida)",
            ['id_inscripcion' => $id_inscripcion]
        );
    }

    public function getAll(): ApiResponseDTO {
        return Database::getInstance()->executeProcedure(
            "CALL sp_get_all_inscripciones(:v_data, @v_salida)",
            []
        );
    }
}
