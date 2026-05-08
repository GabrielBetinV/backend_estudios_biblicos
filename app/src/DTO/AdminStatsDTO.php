<?php

namespace App\DTO;

class AdminStatsDTO {
    public function __construct(
        public int $total_usuarios = 0,
        public int $total_cursos = 0,
        public int $total_inscripciones = 0,
        public float $ingresos_totales = 0.0
    ) {}

    public function toArray(): array {
        return [
            'total_usuarios' => $this->total_usuarios,
            'total_cursos' => $this->total_cursos,
            'total_inscripciones' => $this->total_inscripciones,
            'ingresos_totales' => $this->ingresos_totales
        ];
    }
}
