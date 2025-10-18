<?php
// src/Models/GeneroModel.php

namespace App\Models;

use App\DTO\GeneroDTO;
use App\Config\Database;
use App\DTO\ApiResponseDTO;

class GeneroModel
{
    public function __construct() {}

    // Crear género
    public function create(GeneroDTO $generoDTO): ApiResponseDTO
    {
        return Database::getInstance()->executeProcedure(
            "CALL sp_insert_genero(:v_data, @v_salida)",
            [
                'nombre' => $generoDTO->getNombre(),
                'descripcion' => $generoDTO->getDescripcion()
            ]
        );
    }

    // Obtener género por ID
    public function getById($id_genero): ApiResponseDTO
    {
        return Database::getInstance()->executeProcedure(
            "CALL sp_get_genero_by_id(:v_data, @v_salida)",
            ['id_genero' => $id_genero]
        );
    }

    // Actualizar género
    public function update(GeneroDTO $generoDTO): ApiResponseDTO
    {
        return Database::getInstance()->executeProcedure(
            "CALL sp_update_genero(:v_data, @v_salida)",
            [
                'id_genero' => $generoDTO->getIdGenero(),
                'nombre' => $generoDTO->getNombre(),
                'descripcion' => $generoDTO->getDescripcion()
            ]
        );
    }

    // Eliminar género
    public function delete($id_genero): ApiResponseDTO
    {
        return Database::getInstance()->executeProcedure(
            "CALL sp_delete_genero(:v_data, @v_salida)",
            ['id_genero' => $id_genero]
        );
    }

    // Obtener todos los géneros
    public function getAll(): ApiResponseDTO
    {
        return Database::getInstance()->executeProcedure(
            "CALL sp_get_all_generos(:v_data, @v_salida)",
            []
        );
    }

  
}
