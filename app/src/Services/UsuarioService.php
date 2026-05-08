<?php

namespace App\Services;

use App\Models\UsuarioModel;
use App\DTO\UsuarioDTO;
use App\DTO\ApiResponseDTO;
use App\Helpers\JwtHelper;

class UsuarioService {
    private $usuarioModel;

    public function __construct() {
        $this->usuarioModel = new UsuarioModel();
    }

    public function createUsuario(UsuarioDTO $usuarioDTO) {
        return $this->usuarioModel->create($usuarioDTO);
    }

    public function getUsuarioById($id_usuario) {
        return $this->usuarioModel->getById($id_usuario);
    }

    public function updateUsuario(UsuarioDTO $usuarioDTO) {
        $this->usuarioModel->update($usuarioDTO);
    }

    public function deleteUsuario($id_usuario) {
        $this->usuarioModel->delete($id_usuario);
    }

    public function getAll() {
        return $this->usuarioModel->getAll();
    }

    // 🔍 Buscar por correo
    public function getByCorreo($correo) {
        return $this->usuarioModel->getByCorreo($correo);
    }

    // 💾 Guardar token de recuperación
    public function guardarResetToken($id_usuario, $token, $expira) {
        $this->usuarioModel->guardarResetToken($id_usuario, $token, $expira);
    }

    // 🔍 Buscar por token válido
    public function getByResetToken($token) {
        return $this->usuarioModel->getByResetToken($token);
    }

    // 🔐 Cambiar contraseña
    public function actualizarContrasena($id_usuario, $nuevoHash) {
        $this->usuarioModel->actualizarContrasena($id_usuario, $nuevoHash);
    }
    
       // Enviar token de recuperación
    public function generarTokenRecuperacion(string $correo): ApiResponseDTO {
    $usuario = $this->usuarioModel->getByCorreo($correo);

    if (!$usuario) {
        return new ApiResponseDTO('ERROR', 'Correo no registrado', null);
    }

    // ✅ Generar un JWT en lugar de un bin2hex
    $token = JwtHelper::generarToken([
        'correo' => $correo
    ]);
    
    
    
    $expira = date('Y-m-d H:i:s', strtotime('+1 hour'));

    $this->usuarioModel->guardarResetToken($usuario['id_usuario'], $token, $expira);

    return new ApiResponseDTO('OK', 'Token JWT generado y guardado', ['token' => $token]);
}




    // Cambiar contraseña usando token
public function actualizarContrasenaConToken(string $token, string $nuevoHash): ApiResponseDTO {
     // Verificar token
       $tokenLimpio = trim($token, '"');
       $payload = JwtHelper::verificarToken($tokenLimpio);
    
        if (!$payload || empty($payload['data']['correo'])) {
            return new ApiResponseDTO('ERROR', 'Token inválido o expirado', $payload);
        }

    
        $correo = $payload['data']['correo'];
    
        $response = $this->usuarioModel->getByCorreo($correo);
    
        if ($response->status !== 'OK' || empty($response->data)) {
            return new ApiResponseDTO('ERROR', 'Usuario no encontrado para el correo del token', null);
        }
    
        $usuario = $response->data;
    
        $this->usuarioModel->actualizarContrasena($usuario['id_usuario'], $nuevoHash);
    
        return new ApiResponseDTO('OK', 'Contraseña actualizada correctamente', []);
}

    


public function generarNuevaContrasena(string $correo): ApiResponseDTO {
    $response = $this->usuarioModel->getByCorreo($correo);

    if ($response->status !== 'OK' || empty($response->data)) {
        return new ApiResponseDTO('ERROR', 'Correo no registrado', null);
    }

    $usuario = $response->data;
    $id_usuario = $usuario['id_usuario'];

    // Generar contraseña aleatoria segura
    $nuevaContrasena = bin2hex(random_bytes(4)); // 8 caracteres hex (4 bytes)
    $nuevaContrasenaHash = password_hash($nuevaContrasena, PASSWORD_BCRYPT);

    // Actualizar en la BD
    $this->usuarioModel->actualizarContrasena($id_usuario, $nuevaContrasenaHash);

    // Enviar por correo
    $this->enviarCorreoContrasena($correo, $usuario['nombre'], $nuevaContrasena);

    return new ApiResponseDTO('OK', 'Contraseña generada y enviada al correo.', null);
}

    public function getPermisosByRol($id_rol) {
        return $this->usuarioModel->getPermisosByRol($id_rol);
    }

private function enviarCorreoContrasena(string $correo, string $nombre, string $contrasena): void {
    $asunto = "Recuperación de contraseña";
    $mensaje = "
        <h2>Hola, {$nombre}</h2>
        <p>Has solicitado una nueva contraseña.</p>
        <p><strong>Tu nueva contraseña es:</strong> {$contrasena}</p>
        <p>Por favor, cámbiala una vez ingreses al sistema.</p>
        <br><p>Saludos,<br>Equipo de soporte</p>
    ";
    $cabeceras = "MIME-Version: 1.0" . "\r\n";
    $cabeceras .= "Content-type:text/html;charset=UTF-8" . "\r\n";
    $cabeceras .= "From: " . $_ENV['MAIL_FROM'] . "\r\n";

    mail($correo, $asunto, $mensaje, $cabeceras);
}


}
