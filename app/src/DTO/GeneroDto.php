<?php
// src/DTO/GeneroDTO.php

namespace App\DTO;


class GeneroDTO {
    private $id_genero;
    private $nombre;
    private $descripcion;

    public function __construct($nombre, $descripcion = null, $id_genero = null) {
        $this->nombre = $nombre;
        $this->descripcion = $descripcion;
        $this->id_genero = $id_genero;
    }

    public function getIdGenero(): mixed {
        return $this->id_genero;
    }

    public function setIdGenero($id_genero) {
        $this->id_genero = $id_genero;
    }

    public function getNombre() {
        return $this->nombre;
    }

    public function setNombre($nombre) {
        $this->nombre = $nombre;
    }

    public function getDescripcion() {
        return $this->descripcion;
    }

    public function setDescripcion($descripcion) {
        $this->descripcion = $descripcion;
    }

    public function toArray() {
        return [
            'id_genero' => $this->id_genero,
            'nombre' => $this->nombre,
            'descripcion' => $this->descripcion
        ];
    }
}
