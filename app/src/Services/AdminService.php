<?php

namespace App\Services;

use App\Models\AdminModel;

class AdminService {
    private AdminModel $adminModel;

    public function __construct() {
        $this->adminModel = new AdminModel();
    }

    public function getStats() {
        return $this->adminModel->getStats();
    }

    public function getAllUsuarios() {
        return $this->adminModel->getAllUsuarios();
    }

    public function updateRol($data) {
        return $this->adminModel->updateRol($data);
    }

    public function updateEstadoUsuario($data) {
        return $this->adminModel->updateEstadoUsuario($data);
    }

    public function getCursosAdmin() {
        return $this->adminModel->getCursosAdmin();
    }

    public function getCursoDetalle($id_curso) {
        return $this->adminModel->getCursoDetalle($id_curso);
    }

    public function createCurso($data) {
        return $this->adminModel->createCurso($data);
    }

    public function updateEstadoCurso($data) {
        return $this->adminModel->updateEstadoCurso($data);
    }

    public function getGrupos() {
        return $this->adminModel->getGrupos();
    }

    public function createGrupo($data) {
        return $this->adminModel->createGrupo($data);
    }

    public function getInscripciones() {
        return $this->adminModel->getInscripciones();
    }

    public function createInscripcion($data) {
        return $this->adminModel->createInscripcion($data);
    }

    public function deleteInscripcion($data) {
        return $this->adminModel->deleteInscripcion($data);
    }

    public function getGrupoUsuarios($id_grupo) {
        return $this->adminModel->getGrupoUsuarios($id_grupo);
    }

    public function assignUsuarioGrupo($data) {
        return $this->adminModel->assignUsuarioGrupo($data);
    }

    public function removeUsuarioGrupo($data) {
        return $this->adminModel->removeUsuarioGrupo($data);
    }

    public function getGrupoLecciones($id_grupo) {
        return $this->adminModel->getGrupoLecciones($id_grupo);
    }

    public function assignLeccionGrupo($data) {
        return $this->adminModel->assignLeccionGrupo($data);
    }

    public function getLeccionesFull() {
        return $this->adminModel->getLeccionesFull();
    }

    public function getRoles() {
        return $this->adminModel->getRoles();
    }

    public function createRol($data) {
        return $this->adminModel->createRol($data);
    }

    public function updateRoleDef($data) {
        return $this->adminModel->updateRoleDef($data);
    }

    public function deleteRol($data) {
        return $this->adminModel->deleteRol($data);
    }

    public function getPermisos() {
        return $this->adminModel->getPermisos();
    }

    public function updateRolEstado($data) {
        return $this->adminModel->updateRolEstado($data);
    }

    public function getPermisosByRol($id_rol) {
        return $this->adminModel->getPermisosByRol($id_rol);
    }

    public function getRolPermisos($id_rol) {
        return $this->adminModel->getRolPermisos($id_rol);
    }

    public function removeLeccionGrupo($data) {
        return $this->adminModel->removeLeccionGrupo($data);
    }

    public function insertPermiso($data) {
        return $this->adminModel->insertPermiso($data);
    }

    public function updatePermiso($data) {
        return $this->adminModel->updatePermiso($data);
    }

    public function deletePermiso($data) {
        return $this->adminModel->deletePermiso($data);
    }

    public function getTiposEvidencia() {
        return $this->adminModel->getTiposEvidencia();
    }

    public function insertTipoEvidencia($data) {
        return $this->adminModel->insertTipoEvidencia($data);
    }

    public function updateTipoEvidencia($data) {
        return $this->adminModel->updateTipoEvidencia($data);
    }

    public function deleteTipoEvidencia($data) {
        return $this->adminModel->deleteTipoEvidencia($data);
    }

    public function getEvidenciasAdmin() {
        return $this->adminModel->getEvidenciasAdmin();
    }

    public function getEvidencia($data) {
        return $this->adminModel->getEvidencia($data);
    }

    public function updateEvidencia($data) {
        return $this->adminModel->updateEvidencia($data);
    }

    public function deleteEvidencia($data) {
        return $this->adminModel->deleteEvidencia($data);
    }

    public function getAvanceEstudiantes() {
        return $this->adminModel->getAvanceEstudiantes();
    }

    public function updateEstadoGrupo($data) {
        return $this->adminModel->updateEstadoGrupo($data);
    }

    public function getCursosByUsuario($id_usuario) {
        return $this->adminModel->getCursosByUsuario($id_usuario);
    }

    public function getResultadosByUsuarioCurso($id_usuario, $id_curso) {
        return $this->adminModel->getResultadosByUsuarioCurso($id_usuario, $id_curso);
    }

    public function deleteCurso($data) {
        return $this->adminModel->deleteCurso($data);
    }

    public function deleteGrupo($data) {
        return $this->adminModel->deleteGrupo($data);
    }

    public function getSubleccionesAll() {
        return $this->adminModel->getSubleccionesAll();
    }

    public function getReporteCompleto() {
        return $this->adminModel->getReporteCompleto();
    }
}
