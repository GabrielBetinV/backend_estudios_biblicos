<?php

// src/Controllers/GeneroController.php

namespace App\Controllers;

use App\Services\GeneroService;
use App\DTO\GeneroDTO;
use Exception;

class GeneroController {
    private $generoService;

    public function __construct() {
        $this->generoService = new GeneroService;
    }

    // Crear nuevo género (POST)
    public function create(): void {
        $data = json_decode(file_get_contents('php://input'), true);

        if (empty($data['nombre'])) {
            http_response_code(400);
            echo json_encode(["error" => "El campo 'nombre' es obligatorio."]);
            return;
        }

        if (empty($data['descripcion'])) {
            http_response_code(400);
            echo json_encode(["error" => "El campo 'descripcion' es obligatorio."]);
            return;
        }

        $generoDTO = new GeneroDTO($data['nombre'], $data['descripcion']);

        try {
            $generos = $this->generoService->createGenero($generoDTO);
            echo json_encode($generos);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode([$e->getMessage()]);
        }
    }

    // Obtener género por ID (GET)
    public function getById($id_genero): void {
        try {
            $genero = $this->generoService->getGeneroById($id_genero);
            if ($genero) {
                echo json_encode($genero);
            } else {
                http_response_code(404);
                echo json_encode(["error" => "Género no encontrado."]);
            }
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(["error" => $e->getMessage()]);
        }
    }

    // Actualizar género (PUT)
    public function update($id_genero): void {
        $data = json_decode(file_get_contents('php://input'), true);

        if (empty($data['nombre'])) {
            http_response_code(400);
            echo json_encode(["error" => "El campo 'nombre' es obligatorio."]);
            return;
        }

        if (empty($data['descripcion'])) {
            http_response_code(400);
            echo json_encode(["error" => "El campo 'descripcion' es obligatorio."]);
            return;
        }

        $generoDTO = new GeneroDTO($data['nombre'], $data['descripcion'], id_genero: $id_genero);

        try {
            $generos = $this->generoService->updateGenero($generoDTO);
            echo json_encode($generos);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(["error" => $e->getMessage()]);
        }
    }

    // Eliminar género (DELETE)
    public function delete($id_genero): void {
        try {
            $generos =  $this->generoService->deleteGenero($id_genero);
            echo json_encode($generos);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(["error" => $e->getMessage()]);
        }
    }

    // Obtener todos los géneros (GET)
    public function getAll(): void {
        try {
            $generos = $this->generoService->getAll();
            echo json_encode($generos);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(["error" => $e->getMessage()]);
        }
    }
}
