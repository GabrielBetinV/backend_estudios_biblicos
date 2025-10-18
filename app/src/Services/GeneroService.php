<?php
// src/Services/GeneroService.php

namespace App\Services;

use App\Models\GeneroModel;
use App\DTO\GeneroDTO;
use App\DTO\ApiResponseDTO;


class GeneroService {
    private $generoModel;

    public function __construct() {
        $this->generoModel = new GeneroModel();
    }

    public function createGenero(GeneroDTO $generoDTO): ApiResponseDTO {
        return $this->generoModel->create($generoDTO);
    }

    public function getGeneroById($id_genero): ApiResponseDTO {
        return $this->generoModel->getById($id_genero);
    }

    public function updateGenero(GeneroDTO $generoDTO): ApiResponseDTO {
       return $this->generoModel->update($generoDTO);
    }

    public function deleteGenero($id_genero): ApiResponseDTO {
       return $this->generoModel->delete($id_genero);
    }

    public function getAll(): ApiResponseDTO {
        return $this->generoModel->getAll();
    }
}
