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

    public function updateEstadoUsuario($data): ApiResponseDTO {
        return Database::getInstance()->executeProcedure("CALL sp_update_usuario_estado(:v_data, @v_salida)", $data);
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

    public function getRoles(): ApiResponseDTO {
        return Database::getInstance()->executeProcedure("CALL sp_get_roles_admin(@v_salida)", []);
    }

    public function createRol($data): ApiResponseDTO {
        return Database::getInstance()->executeProcedure("CALL sp_insert_rol(:v_data, @v_salida)", $data);
    }

    public function updateRoleDef($data): ApiResponseDTO {
        return Database::getInstance()->executeProcedure("CALL sp_update_rol(:v_data, @v_salida)", $data);
    }

    public function deleteRol($data): ApiResponseDTO {
        return Database::getInstance()->executeProcedure("CALL sp_delete_rol(:v_data, @v_salida)", $data);
    }

    public function getPermisos(): ApiResponseDTO {
        return Database::getInstance()->executeProcedure("CALL sp_get_permisos(@v_salida)", []);
    }

    public function getPermisosByRol($id_rol): ApiResponseDTO {
        return Database::getInstance()->executeProcedure("CALL sp_get_permisos_by_rol(:v_data, @v_salida)", ['id_rol' => $id_rol]);
    }

    public function updateRolEstado($data): ApiResponseDTO {
        return Database::getInstance()->executeProcedure("CALL sp_update_rol_estado(:v_data, @v_salida)", $data);
    }

    public function getRolPermisos($id_rol): ApiResponseDTO {
        return Database::getInstance()->executeProcedure("CALL sp_get_rol_permisos(:v_data, @v_salida)", ['id_rol' => $id_rol]);
    }

    public function removeLeccionGrupo($data): ApiResponseDTO {
        return Database::getInstance()->executeProcedure("CALL sp_remove_leccion_grupo(:v_data, @v_salida)", $data);
    }

    public function insertPermiso($data): ApiResponseDTO {
        return Database::getInstance()->executeProcedure("CALL sp_insert_permiso(:v_data, @v_salida)", $data);
    }

    public function updatePermiso($data): ApiResponseDTO {
        return Database::getInstance()->executeProcedure("CALL sp_update_permiso(:v_data, @v_salida)", $data);
    }

    public function deletePermiso($data): ApiResponseDTO {
        return Database::getInstance()->executeProcedure("CALL sp_delete_permiso(:v_data, @v_salida)", $data);
    }

    public function getTiposEvidencia(): ApiResponseDTO {
        return Database::getInstance()->executeProcedure("CALL sp_get_tipos_evidencia(@v_salida)", []);
    }

    public function insertTipoEvidencia($data): ApiResponseDTO {
        return Database::getInstance()->executeProcedure("CALL sp_insert_tipo_evidencia(:v_data, @v_salida)", $data);
    }

    public function updateTipoEvidencia($data): ApiResponseDTO {
        return Database::getInstance()->executeProcedure("CALL sp_update_tipo_evidencia(:v_data, @v_salida)", $data);
    }

    public function deleteTipoEvidencia($data): ApiResponseDTO {
        return Database::getInstance()->executeProcedure("CALL sp_delete_tipo_evidencia(:v_data, @v_salida)", $data);
    }

    public function getEvidenciasAdmin(): ApiResponseDTO {
        return Database::getInstance()->executeProcedure("CALL sp_get_evidencias_admin(@v_salida)", []);
    }

    public function getEvidencia($data): ApiResponseDTO {
        return Database::getInstance()->executeProcedure("CALL sp_get_evidencia(:v_data, @v_salida)", $data);
    }

    public function updateEvidencia($data): ApiResponseDTO {
        return Database::getInstance()->executeProcedure("CALL sp_update_evidencia(:v_data, @v_salida)", $data);
    }

    public function deleteEvidencia($data): ApiResponseDTO {
        return Database::getInstance()->executeProcedure("CALL sp_delete_evidencia(:v_data, @v_salida)", $data);
    }

    public function getAvanceEstudiantes(): ApiResponseDTO {
        return Database::getInstance()->executeProcedure("CALL sp_get_avance_estudiantes(@v_salida)", []);
    }

    public function getCursosByUsuario($id_usuario): ApiResponseDTO {
        return Database::getInstance()->executeProcedure(
            "CALL sp_get_cursos_inscritos_by_usuario(:v_data, @v_salida)",
            ['id_usuario' => $id_usuario]
        );
    }

    public function getResultadosByUsuarioCurso($id_usuario, $id_curso): ApiResponseDTO {
        return Database::getInstance()->executeProcedure(
            "CALL sp_get_resultados_by_usuario_curso(:v_data, @v_salida)",
            ['id_usuario' => $id_usuario, 'id_curso' => $id_curso]
        );
    }

    public function updateEstadoGrupo($data): ApiResponseDTO {
        return Database::getInstance()->executeProcedure("CALL sp_update_estado_grupo(:v_data, @v_salida)", $data);
    }

    public function deleteCurso($data): ApiResponseDTO {
        return Database::getInstance()->executeProcedure("CALL sp_delete_curso(:v_data, @v_salida)", $data);
    }

    public function deleteGrupo($data): ApiResponseDTO {
        return Database::getInstance()->executeProcedure("CALL sp_delete_grupo(:v_data, @v_salida)", $data);
    }

    public function getSubleccionesAll(): ApiResponseDTO {
        return Database::getInstance()->executeProcedure("CALL sp_get_sublecciones_admin(@v_salida)", []);
    }

    public function getReporteCompleto(): ApiResponseDTO {
        return Database::getInstance()->executeProcedure("CALL sp_get_reporte_completo(@v_salida)", []);
    }
}
