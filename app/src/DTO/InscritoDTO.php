<?php

namespace App\DTO;

class InscritoDTO {
    private $id_usuario;

    public function __construct($id_usuario) {
        $this->id_usuario = $id_usuario;
    }

    public function toArray() {
        return ['id_usuario' => $this->id_usuario];
    }
}
