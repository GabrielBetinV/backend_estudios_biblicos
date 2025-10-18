<?php
// src/DTO/UsuarioDTO.php

namespace App\DTO;

class UsuarioDTO {
    private $id_usuario;
    private $nombre;
    private $apellido;
    private $correo;
    private $contrasena;
    private $fecha_nacimiento;
    private $edad;
    private $id_genero;
    private $telefono;
    private $direccion;
    private $id_rol;
    private $fecha_registro;
    private $id_estado;

    public function __construct($nombre, $apellido, $correo, $contrasena, $fecha_nacimiento = null, $edad = null, 
        $id_genero = null, $telefono = null, $direccion = null, $id_rol = null, $fecha_registro = null, $id_estado = 3) {

        $this->nombre = $nombre;
        $this->apellido = $apellido;
        $this->correo = $correo;
        $this->contrasena = $contrasena;
        $this->fecha_nacimiento = $fecha_nacimiento;
        $this->edad = $edad;
        $this->id_genero = $id_genero;
        $this->telefono = $telefono;
        $this->direccion = $direccion;
        $this->id_rol = $id_rol;
        $this->fecha_registro = $fecha_registro ? $fecha_registro : date('Y-m-d H:i:s'); // Si no se proporciona, se usa la fecha actual
        $this->id_estado = $id_estado; // 3 por defecto (activo)
    }

    // Getters y setters
    public function getIdUsuario() {
        return $this->id_usuario;
    }

    public function setIdUsuario($id_usuario) {
        $this->id_usuario = $id_usuario;
    }

    public function getNombre() {
        return $this->nombre;
    }

    public function setNombre($nombre) {
        $this->nombre = $nombre;
    }

    public function getApellido() {
        return $this->apellido;
    }

    public function setApellido($apellido) {
        $this->apellido = $apellido;
    }

    public function getCorreo() {
        return $this->correo;
    }

    public function setCorreo($correo) {
        $this->correo = $correo;
    }

    public function getContrasena() {
        return $this->contrasena;
    }

    public function setContrasena($contrasena) {
        $this->contrasena = $contrasena;
    }

    public function getFechaNacimiento() {
        return $this->fecha_nacimiento;
    }

    public function setFechaNacimiento($fecha_nacimiento) {
        $this->fecha_nacimiento = $fecha_nacimiento;
    }

    public function getEdad() {
        return $this->edad;
    }

    public function setEdad($edad) {
        $this->edad = $edad;
    }

    public function getIdSexo() {
        return $this->id_genero;
    }

    public function setIdSexo($id_genero) {
        $this->id_genero = $id_genero;
    }

    public function getTelefono() {
        return $this->telefono;
    }

    public function setTelefono($telefono) {
        $this->telefono = $telefono;
    }

    public function getDireccion() {
        return $this->direccion;
    }

    public function setDireccion($direccion) {
        $this->direccion = $direccion;
    }

    public function getIdRol() {
        return $this->id_rol;
    }

    public function setIdRol($id_rol) {
        $this->id_rol = $id_rol;
    }

    public function getFechaRegistro() {
        return $this->fecha_registro;
    }

    public function setFechaRegistro($fecha_registro) {
        $this->fecha_registro = $fecha_registro;
    }

    public function getIdEstado() {
        return $this->id_estado;
    }

    public function setIdEstado($id_estado) {
        $this->id_estado = $id_estado;
    }

    // Método para convertir el DTO en un array para transferir a la base de datos
  public function toArray() {
    return [
        'nombre' => $this->nombre,
        'apellido' => $this->apellido,
        'correo' => $this->correo,
        'contrasena' => $this->contrasena,
        'fecha_nacimiento' => $this->fecha_nacimiento,
        'edad' => $this->edad,
        'id_genero' => $this->id_genero,
        'telefono' => $this->telefono,
        'direccion' => $this->direccion,
        'id_rol' => $this->id_rol,
        'fecha_registro' => $this->fecha_registro,
        'id_estado' => $this->id_estado
    ];
}

}
