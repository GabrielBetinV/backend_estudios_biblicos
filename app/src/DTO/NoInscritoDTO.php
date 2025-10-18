<?php

namespace App\DTO;

class NoInscritoDTO {
    private $id_usuario;
    private $id_curso;

    public function __construct($id_usuario, $id_curso) {
        $this->id_usuario = $id_usuario;
         $this->id_curso = $id_curso;
    }

    public function toArray() {
        return ['id_usuario' => $this->id_usuario];
    }
}
