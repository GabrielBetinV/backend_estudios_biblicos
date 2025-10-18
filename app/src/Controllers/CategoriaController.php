<?php

namespace App\Controllers;

use App\Helpers\JwtHelper;
use Exception;

use App\Services\CategoriaService;

class CategoriaController {
    private CategoriaService $categoriaService;

    public function __construct() {
        $this->categoriaService = new CategoriaService();
    }
    
    
    
        /**
     * ✅ Validar el token JWT antes de permitir acceso
     */
private function validarToken(): array {
    $headers = getallheaders();

    // Permitir mayúsculas/minúsculas en la clave del header
    $authHeader = $headers['Authorization'] ?? $headers['authorization'] ?? null;

    if (!$authHeader) {
        http_response_code(401);
        echo json_encode([
            "status" => "ERROR",
            "message" => "Token no proporcionado en el encabezado Authorization.",
            "data" => null
        ]);
        exit;
    }

    // El formato esperado es: "Bearer <token>"
    if (!preg_match('/Bearer\s(\S+)/', $authHeader, $matches)) {
        http_response_code(400);
        echo json_encode([
            "status" => "ERROR",
            "message" => "Formato de token inválido. Debe ser 'Bearer <token>'.",
            "data" => null
        ]);
        exit;
    }

    $token = $matches[1]; // Captura el valor del token sin el prefijo "Bearer"

    try {
        // 🔐 Usa tu helper para verificar y decodificar el token
        $decoded = JwtHelper::verificarToken($token);

        // Validar si contiene los datos esperados
        if (!isset($decoded['data'])) {
            http_response_code(401);
            echo json_encode([
                "status" => "ERROR",
                "message" => "Token inválido: sin datos de usuario.",
                "data" => null
            ]);
            exit;
        }

        return $decoded['data']; // Retorna solo los datos del usuario autenticado

    } catch (\Exception $e) {
        http_response_code(401);
        echo json_encode([
            "status" => "ERROR",
            "message" => "Token inválido o corrupto: " . $e->getMessage(),
            "data" => null
        ]);
        exit;
    }
}

    // Obtener todas las categorías
    public function getAll(): void {
            $usuario = $this->validarToken();
        
        
        
        if (empty($usuario['id_usuario'])) {
            http_response_code(400);
            echo json_encode(["status" => "ERROR", "message" => "ID de usuario no encontrado en el token"]);
            return;
        }


        try {
            $response = $this->categoriaService->getAll($usuario);
            echo json_encode($response);
        } catch (\Exception $e) {
            http_response_code(500);
            echo json_encode([
                "status" => "ERROR",
                "message" => $e->getMessage(),
                "data" => null
            ]);
        }
    }
}
