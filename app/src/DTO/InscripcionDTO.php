<?php
namespace App\DTO;

class InscripcionDTO {
    private $id_inscripcion;
    private $id_usuario;
    private $id_curso;
    private $fecha_inscripcion;

    public function __construct($id_usuario, $id_curso, $fecha_inscripcion = null, $id_inscripcion = null) {
        $this->id_inscripcion = $id_inscripcion;
        $this->id_usuario = $id_usuario;
        $this->id_curso = $id_curso;
        $this->fecha_inscripcion = $fecha_inscripcion ?? date('Y-m-d H:i:s');
    }

    public function toArray() {
        return [
            'id_inscripcion' => $this->id_inscripcion,
            'id_usuario' => $this->id_usuario,
            'id_curso' => $this->id_curso,
            'fecha_inscripcion' => $this->fecha_inscripcion
        ];
    }
}
