<?php

namespace App\DTO;

class ModuloDTO {
    private $id_modulo;
    private $id_curso;
    private $titulo;
    private $descripcion;
    private $id_estado;

    public function __construct($id_curso, $titulo, $descripcion = null, $id_estado = 1, $id_modulo = null) {
        $this->id_modulo = $id_modulo;
        $this->id_curso = $id_curso;
        $this->titulo = $titulo;
        $this->descripcion = $descripcion;
        $this->id_estado = $id_estado;
    }

    public function toArray() {
        return [
            'id_modulo' => $this->id_modulo,
            'id_curso' => $this->id_curso,
            'titulo' => $this->titulo,
            'descripcion' => $this->descripcion,
            'id_estado' => $this->id_estado
        ];
    }
}
