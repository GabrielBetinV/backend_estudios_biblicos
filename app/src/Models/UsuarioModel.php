<?php
// src/Models/UsuarioModel.php

namespace App\Models;

use App\DTO\UsuarioDTO;
use App\DTO\ApiResponseDTO;
use App\Config\Database;

class UsuarioModel
{
    public function __construct() {}

    // Crear usuario
 public function create(UsuarioDTO $usuarioDTO): ApiResponseDTO
{
    return Database::getInstance()->executeProcedure(
        "CALL sp_insert_usuario(:v_data, @v_salida)",
      $usuarioDTO->toArray()
    );
}

    
    

    public function getById($id_usuario): ApiResponseDTO
    {
        return Database::getInstance()->executeProcedure(
            "CALL sp_get_usuario_by_id(:v_data, @v_salida)",
            ['id_usuario' => $id_usuario]
        );
    }

    public function update(UsuarioDTO $usuarioDTO): ApiResponseDTO
    {
        return Database::getInstance()->executeProcedure(
            "CALL sp_update_usuario(:v_data, @v_salida)",
            $usuarioDTO->toArray()
        );
    }

    public function delete($id_usuario): ApiResponseDTO
    {
        return Database::getInstance()->executeProcedure(
            "CALL sp_delete_usuario(:v_data, @v_salida)",
            ['id_usuario' => $id_usuario]
        );
    }

    public function getAll(): ApiResponseDTO
    {
        return Database::getInstance()->executeProcedure(
            "CALL sp_get_all_usuarios(:v_data, @v_salida)",
            []
        );
    }

    public function getByCorreo($correo): ApiResponseDTO
    {
        return Database::getInstance()->executeProcedure(
            "CALL sp_get_usuario_by_correo(:v_data, @v_salida)",
            ['correo' => $correo]
        );
    }

    public function guardarResetToken($id_usuario, $token, $expira): ApiResponseDTO
    {
        return Database::getInstance()->executeProcedure(
            "CALL sp_guardar_reset_token(:v_data, @v_salida)",
            [
                'id_usuario'   => $id_usuario,
                'reset_token'  => $token,
                'reset_expira' => $expira
            ]
        );
    }

    public function getByResetToken($token): ApiResponseDTO
    {
        return Database::getInstance()->executeProcedure(
            "CALL sp_get_usuario_by_token(:v_data, @v_salida)",
            ['reset_token' => $token]
        );
    }

    public function actualizarContrasena($id_usuario, $nuevoHash): ApiResponseDTO
    {
        return Database::getInstance()->executeProcedure(
            "CALL sp_actualizar_contrasena(:v_data, @v_salida)",
            [
                'id_usuario' => $id_usuario,
                'contrasena' => $nuevoHash
            ]
        );
    }
}
