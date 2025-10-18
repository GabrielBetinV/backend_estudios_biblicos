<?php

namespace App\DTO;

class CategoriaDTO {
    private int $id_categoria;
    private string $nombre;

    public function __construct(int $id_categoria = 0, string $nombre = '') {
        $this->id_categoria = $id_categoria;
        $this->nombre = $nombre;
    }

    public function toArray(): array {
        return [
            'id_categoria' => $this->id_categoria,
            'nombre' => $this->nombre
        ];
    }
}
