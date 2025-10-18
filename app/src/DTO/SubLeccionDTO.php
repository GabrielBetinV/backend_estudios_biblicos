<?php

namespace App\DTO;

class SubLeccionDTO {
    private $id_subleccion;
    private $id_leccion;
    private $titulo;
    private $descripcion;
    private $video_url;
    private $id_estado;

    public function __construct($id_leccion, $titulo, $descripcion = null, $video_url = null, $id_estado = 1, $id_subleccion = null) {
        $this->id_subleccion = $id_subleccion;
        $this->id_leccion = $id_leccion;
        $this->titulo = $titulo;
        $this->descripcion = $descripcion;
        $this->video_url = $video_url;
        $this->id_estado = $id_estado;
    }

    public function toArray() {
        return [
            'id_subleccion' => $this->id_subleccion,
            'id_leccion' => $this->id_leccion,
            'titulo' => $this->titulo,
            'descripcion' => $this->descripcion,
            'video_url' => $this->video_url,
            'id_estado' => $this->id_estado
        ];
    }
}
