<?php

namespace App\DTO;

class CursoDTO {

    private $titulo;
    private $descripcion;
    private $id_estado;
    private $precio;
    private $portada;

    public function __construct($titulo, $descripcion, $id_estado = 1, $precio, $portada) {
        $this->titulo = $titulo;
        $this->descripcion = $descripcion;
        $this->id_estado = $id_estado;
        $this->precio = $precio;
        $this->portada = $portada;
    }

    public function toArray() {
        return [
            'titulo' => $this->titulo,
            'descripcion' => $this->descripcion,
            'id_estado' => $this->id_estado,
            'precio' => $this->precio,
             'portada' => $this->portada
        ];
    }
}
