<?php

namespace App\Models;

use App\Config\Database;
use App\DTO\ApiResponseDTO;

class InscritoModel {

    public function getCursosInscritos($id_usuario, $idCurso): ApiResponseDTO {
        return Database::getInstance()->executeProcedure(
            "CALL sp_get_cursos_inscritos(:v_data, @v_salida)",
            [
      
          'id_curso'   => $idCurso,
          'id_usuario' => $id_usuario
         ]
        );
    }
}
