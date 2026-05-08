<?php

namespace App\Models;

use App\DTO\ApiResponseDTO;
use App\Config\Database;

class AdminModel {
    public function getStats(): ApiResponseDTO {
        return Database::getInstance()->executeProcedure(
            "CALL sp_get_admin_stats(@v_salida)",
            []
        );
    }

    public function getAllUsuarios(): ApiResponseDTO {
        return Database::getInstance()->executeProcedure(
            "CALL sp_get_all_usuarios_admin(@v_salida)",
            []
        );
    }

    public function updateRol($data): ApiResponseDTO {
        return Database::getInstance()->executeProcedure(
            "CALL sp_update_usuario_rol(:v_data, @v_salida)",
            $data
        );
    }

    public function getCursosAdmin(): ApiResponseDTO {
        return Database::getInstance()->executeProcedure(
            "CALL sp_get_cursos_admin(@v_salida)",
            []
        );
    }

    public function getCursoDetalle($id_curso): ApiResponseDTO {
        return Database::getInstance()->executeProcedure(
            "CALL sp_get_curso_detalle_admin(:v_data, @v_salida)",
            ['id_curso' => $id_curso]
        );
    }
}
