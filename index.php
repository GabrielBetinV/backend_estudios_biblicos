<?php
// index.php

// Importar las clases necesarias
use App\Controllers\UsuarioController;
use App\Services\UsuarioService;
use App\Models\UsuarioModel;
use config\Database;

// Manejo de CORS
header("Access-Control-Allow-Origin: *"); // Permite todas las solicitudes
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// Si la solicitud es OPTIONS (pre-flight), respondemos sin procesar la lógica de la aplicación
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(204); // Respuesta vacía para la solicitud OPTIONS
    exit();
}

// Enrutamiento
$method = $_SERVER['REQUEST_METHOD']; // Obtiene el método HTTP (POST, GET, PUT, DELETE)
$uri = $_SERVER['REQUEST_URI']; // Obtiene la URI de la solicitud

// Crear una instancia del controlador de Usuario
$usuarioController = new UsuarioController();

// Definir las rutas
if (preg_match('/^\/usuarios\/(\d+)$/', $uri, $matches)) {
    $id_usuario = $matches[1]; // Extrae el ID de usuario de la URL
    
    if ($method == 'GET') {
        $usuarioController->getById($id_usuario); // Si es GET, obtener un usuario por ID
    } elseif ($method == 'PUT') {
        $usuarioController->update($id_usuario); // Si es PUT, actualizar un usuario
    } elseif ($method == 'DELETE') {
        $usuarioController->delete($id_usuario); // Si es DELETE, eliminar un usuario
    } else {
        http_response_code(405); // Método no permitido
        echo json_encode(["error" => "Método no permitido"]);
    }
} elseif ($uri == '/usuarios' && $method == 'POST') {
    $usuarioController->create(); // Si es POST, crear un nuevo usuario
} elseif ($uri == '/usuarios' && $method == 'GET') {
    $usuarioController->getAll(); // Si es GET sin ID, obtener todos los usuarios
} else {
    http_response_code(404); // Ruta no encontrada
    echo json_encode(["error" => "Ruta no encontrada"]);
}
