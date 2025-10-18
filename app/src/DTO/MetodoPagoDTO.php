<?php
namespace App\DTO;

class MetodoPagoDTO {
    private $id_metodo;
    private $metodo_nombre;

    public function __construct($metodo_nombre, $id_metodo = null) {
        $this->id_metodo = $id_metodo;
        $this->metodo_nombre = $metodo_nombre;
    }

    public function toArray() {
        return [
            'id_metodo' => $this->id_metodo,
            'metodo_nombre' => $this->metodo_nombre
        ];
    }
}
