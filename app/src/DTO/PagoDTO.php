<?php
namespace App\DTO;

class PagoDTO {
    private $id_pago;
    private $id_inscripcion;
    private $monto;
    private $fecha;
    private $id_metodo;
    private $id_estado;

    public function __construct($id_inscripcion, $monto, $fecha = null, $id_metodo = null, $id_estado = 1, $id_pago = null) {
        $this->id_pago = $id_pago;
        $this->id_inscripcion = $id_inscripcion;
        $this->monto = $monto;
        $this->fecha = $fecha ?? date('Y-m-d H:i:s');
        $this->id_metodo = $id_metodo;
        $this->id_estado = $id_estado;
    }

    public function toArray() {
        return [
            'id_pago' => $this->id_pago,
            'id_inscripcion' => $this->id_inscripcion,
            'monto' => $this->monto,
            'fecha' => $this->fecha,
            'id_metodo' => $this->id_metodo,
            'id_estado' => $this->id_estado
        ];
    }
}
