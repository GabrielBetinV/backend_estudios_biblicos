<?php

namespace App\DTO;

class LeccionDTO {
    private $id_leccion;
    private $id_modulo;
    private $titulo;
    private $descripcion;
    private $video_url;
    private $id_estado;

    public function __construct($id_modulo, $titulo, $descripcion = null, $video_url = null, $id_estado = 1, $id_leccion = null) {
        $this->id_leccion = $id_leccion;
        $this->id_modulo = $id_modulo;
        $this->titulo = $titulo;
        $this->descripcion = $descripcion;
        $this->video_url = $video_url;
        $this->id_estado = $id_estado;
    }

    public function toArray() {
        return [
            'id_leccion' => $this->id_leccion,
            'id_modulo' => $this->id_modulo,
            'titulo' => $this->titulo,
            'descripcion' => $this->descripcion,
            'video_url' => $this->video_url,
            'id_estado' => $this->id_estado
        ];
    }
}
