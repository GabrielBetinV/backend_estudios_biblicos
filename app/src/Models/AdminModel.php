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

    public function createCurso($data): ApiResponseDTO {
        return Database::getInstance()->executeProcedure("CALL sp_insert_curso(:v_data, @v_salida)", $data);
    }

    public function updateEstadoCurso($data): ApiResponseDTO {
        return Database::getInstance()->executeProcedure("CALL sp_update_estado_curso(:v_data, @v_salida)", $data);
    }

    public function getGrupos(): ApiResponseDTO {
        return Database::getInstance()->executeProcedure("CALL sp_get_grupos_admin(@v_salida)", []);
    }

    public function createGrupo($data): ApiResponseDTO {
        return Database::getInstance()->executeProcedure("CALL sp_insert_grupo(:v_data, @v_salida)", $data);
    }

    public function getInscripciones(): ApiResponseDTO {
        return Database::getInstance()->executeProcedure("CALL sp_get_inscripciones_admin(@v_salida)", []);
    }

    public function createInscripcion($data): ApiResponseDTO {
        return Database::getInstance()->executeProcedure("CALL sp_insert_inscripcion(:v_data, @v_salida)", $data);
    }

    public function deleteInscripcion($data): ApiResponseDTO {
        return Database::getInstance()->executeProcedure("CALL sp_delete_inscripcion(:v_data, @v_salida)", $data);
    }

    public function getGrupoUsuarios($id_grupo): ApiResponseDTO {
        return Database::getInstance()->executeProcedure("CALL sp_get_grupo_usuarios(:v_data, @v_salida)", ['id_grupo' => $id_grupo]);
    }

    public function assignUsuarioGrupo($data): ApiResponseDTO {
        return Database::getInstance()->executeProcedure("CALL sp_assign_usuario_grupo(:v_data, @v_salida)", $data);
    }

    public function removeUsuarioGrupo($data): ApiResponseDTO {
        return Database::getInstance()->executeProcedure("CALL sp_remove_usuario_grupo(:v_data, @v_salida)", $data);
    }

    public function getGrupoLecciones($id_grupo): ApiResponseDTO {
        return Database::getInstance()->executeProcedure("CALL sp_get_grupo_lecciones(:v_data, @v_salida)", ['id_grupo' => $id_grupo]);
    }

    public function assignLeccionGrupo($data): ApiResponseDTO {
        return Database::getInstance()->executeProcedure("CALL sp_assign_leccion_grupo(:v_data, @v_salida)", $data);
    }

    public function getLeccionesFull(): ApiResponseDTO {
        return Database::getInstance()->executeProcedure("CALL sp_get_lecciones_full(@v_salida)", []);
    }

    public function removeLeccionGrupo($data): ApiResponseDTO {
        return Database::getInstance()->executeProcedure("CALL sp_remove_leccion_grupo(:v_data, @v_salida)", $data);
    }
}
