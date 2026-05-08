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

    public function removeLeccionGrupo($data) {
        return $this->adminModel->removeLeccionGrupo($data);
    }
}
