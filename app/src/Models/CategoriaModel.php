<?php

namespace App\Models;

use App\DTO\CategoriaDTO;
use App\DTO\ApiResponseDTO;
use App\Config\Database;

class CategoriaModel {

  public function getAll($id_usuario) {
    return Database::getInstance()->executeProcedure(
        "CALL sp_get_all_categorias(:v_data, @v_salida)",
        ['id_usuario' => $id_usuario]
    );
}

}
