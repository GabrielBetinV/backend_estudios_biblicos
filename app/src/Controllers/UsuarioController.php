<?php

namespace App\Controllers;

use App\Services\UsuarioService;
use App\DTO\UsuarioDTO;
use App\Helpers\JwtHelper;
use Exception;

class UsuarioController {
    private UsuarioService $usuarioService;

    public function __construct() {
        $this->usuarioService = new UsuarioService();
    }

    // Crear nuevo usuario (POST)
    public function create(): void {
        $data = json_decode(file_get_contents('php://input'), true);

        // Validaciones mínimas
        if (empty($data['nombre']) || empty($data['correo']) || empty($data['contrasena'])) {
            http_response_code(400);
            echo json_encode([
                "status" => "ERROR",
                "message" => "Campos obligatorios: nombre, correo y contrasena.",
                "data" => null
            ]);
            return;
        }

        $usuarioDTO = new UsuarioDTO(
            nombre: $data['nombre'],
            apellido: $data['apellido'] ?? null,
            correo: $data['correo'],
            contrasena: password_hash($data['contrasena'], PASSWORD_BCRYPT),
            fecha_nacimiento: $data['fecha_nacimiento'] ?? null,
            edad: $data['edad'] ?? null,
            id_genero: $data['id_genero'] ?? null,
            telefono: $data['telefono'] ?? null,
            direccion: $data['direccion'] ?? null,
            id_rol: $data['id_rol'] ?? 1,
            fecha_registro: $data['fecha_registro'] ?? date('Y-m-d H:i:s'),
            id_estado: $data['id_estado'] ?? 3
        );

        try {
            $response = $this->usuarioService->createUsuario($usuarioDTO);
            http_response_code($response->status === 'OK' ? 201 : 409);
            echo json_encode($response);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode([
                "status" => "ERROR",
                "message" => "Error al crear el usuario: " . $e->getMessage(),
                "data" => null
            ]);
        }
    }

    // Obtener usuario por ID (GET)
    public function getById($id_usuario): void {
        try {
            $response = $this->usuarioService->getUsuarioById($id_usuario);
            echo json_encode($response);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(["status" => "ERROR", "message" => $e->getMessage(), "data" => null]);
        }
    }

    // Actualizar usuario (PUT)
    public function update($id_usuario): void {
        $data = json_decode(file_get_contents('php://input'), true);

        if (empty($data['nombre']) || empty($data['correo'])) {
            http_response_code(400);
            echo json_encode(["status" => "ERROR", "message" => "Campos 'nombre' y 'correo' son obligatorios.", "data" => null]);
            return;
        }

        $usuarioDTO = new UsuarioDTO(
            nombre: $data['nombre'],
            apellido: $data['apellido'] ?? null,
            correo: $data['correo'],
            contrasena: isset($data['contrasena']) ? password_hash($data['contrasena'], PASSWORD_BCRYPT) : null,
            fecha_nacimiento: $data['fecha_nacimiento'] ?? null,
            edad: $data['edad'] ?? null,
            id_genero: $data['id_genero'] ?? null,
            telefono: $data['telefono'] ?? null,
            direccion: $data['direccion'] ?? null,
            id_rol: $data['id_rol'] ?? 1,
            fecha_registro: $data['fecha_registro'] ?? null,
            id_estado: $data['id_estado'] ?? 3,
            id_usuario: $id_usuario
        );

        try {
            $response = $this->usuarioService->updateUsuario($usuarioDTO);
            echo json_encode($response);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(["status" => "ERROR", "message" => "Error al actualizar: " . $e->getMessage(), "data" => null]);
        }
    }

    // Eliminar usuario (DELETE)
    public function delete($id_usuario): void {
        try {
            $response = $this->usuarioService->deleteUsuario($id_usuario);
            echo json_encode($response);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(["status" => "ERROR", "message" => $e->getMessage(), "data" => null]);
        }
    }

    // Obtener todos los usuarios (GET)
    public function getAll(): void {
        try {
            $response = $this->usuarioService->getAll();
            echo json_encode($response);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(["status" => "ERROR", "message" => $e->getMessage(), "data" => null]);
        }
    }
    
    // Enviar token de recuperación de contraseña (POST)
public function enviarTokenRecuperacion(): void {
    $data = json_decode(file_get_contents('php://input'), true);

    if (empty($data['correo'])) {
        http_response_code(400);
        echo json_encode([
            "status" => "ERROR",
            "message" => "El campo 'correo' es obligatorio.",
            "data" => null
        ]);
        return;
    }

    try {
        $response = $this->usuarioService->generarTokenRecuperacion($data['correo']);
        echo json_encode($response);
    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode([
            "status" => "ERROR",
            "message" => "Error al generar token: " . $e->getMessage(),
            "data" => null
        ]);
    }
}

// Cambiar contraseña usando el token (POST)
public function cambiarContrasenaConToken(): void {
    $data = json_decode(file_get_contents('php://input'), true);

    if (empty($data['token']) || empty($data['nueva_contrasena'])) {
        http_response_code(400);
        echo json_encode([
            "status" => "ERROR",
            "message" => "Token y nueva contraseña son obligatorios.",
            "data" => null
        ]);
        return;
    }

    try {
        $nuevaHash = password_hash($data['nueva_contrasena'], PASSWORD_BCRYPT);
        $response = $this->usuarioService->actualizarContrasenaConToken($data['token'], $nuevaHash);
        echo json_encode($response);
    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode([
            "status" => "ERROR",
            "message" => "Error al actualizar contraseña: " . $e->getMessage(),
            "data" => $data['token']
        ]);
    }
}

 public function login(): void {
        $data = json_decode(file_get_contents('php://input'), true);

        if (empty($data['correo']) || empty($data['contrasena'])) {
            http_response_code(400);
            echo json_encode([
                "status" => "ERROR",
                "message" => "Correo y contraseña son obligatorios.",
                "data" => null
            ]);
            return;
        }

        try {
            $usuarioResponse = $this->usuarioService->getByCorreo($data['correo']);

            if ($usuarioResponse->status === 'ERROR' || empty($usuarioResponse->data)) {
                http_response_code(401);
                echo json_encode([
                    "status" => "ERROR",
                    "message" => "Credenciales inválidas.",
                    "data" => null
                ]);
                return;
            }

            $usuario = $usuarioResponse->data;

            if (!password_verify($data['contrasena'], $usuario['contrasena'])) {
                http_response_code(401);
                echo json_encode([
                    "status" => "ERROR",
                    "message" => "Contraseña incorrecta.",
                    "data" => null
                ]);
                return;
            }

            unset($usuario['contrasena']); // Nunca enviar la contraseña al frontend
            
     
            // ✅ Generar JWT
            $token = JwtHelper::generarToken([
                "id_usuario" => $usuario['id_usuario'],
                "correo" => $usuario['correo'],
                "nombre" => $usuario['nombre']
            ]);

            echo json_encode([
                "status" => "OK",
                "message" => "Login exitoso.",
                "data" => $token
            ]);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode([
                "status" => "ERROR",
                "message" => "Error al iniciar sesión: " . $e->getMessage(),
                "data" => null
            ]);
        }
    }
    
    
    public function enviarNuevaContrasenaPorCorreo(): void {
    $data = json_decode(file_get_contents('php://input'), true);

    if (empty($data['correo'])) {
        http_response_code(400);
        echo json_encode([
            "status" => "ERROR",
            "message" => "El campo 'correo' es obligatorio.",
            "data" => null
        ]);
        return;
    }

    try {
        $response = $this->usuarioService->generarNuevaContrasena($data['correo']);
        echo json_encode($response);
    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode([
            "status" => "ERROR",
            "message" => "Error al generar nueva contraseña: " . $e->getMessage(),
            "data" => null
        ]);
    }
}


}
