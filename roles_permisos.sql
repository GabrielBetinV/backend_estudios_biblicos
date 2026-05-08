-- ============================================
-- SISTEMA DE PERMISOS POR ROL
-- Tablas: permisos, rol_permisos
-- ============================================

CREATE TABLE IF NOT EXISTS `permisos` (
  `id_permiso` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `modulo` varchar(50) NOT NULL,
  `descripcion` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id_permiso`),
  UNIQUE KEY `uk_permiso_nombre` (`nombre`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `rol_permisos` (
  `id_rol` int(11) NOT NULL,
  `id_permiso` int(11) NOT NULL,
  PRIMARY KEY (`id_rol`, `id_permiso`),
  KEY `fk_rp_permiso` (`id_permiso`),
  CONSTRAINT `fk_rp_rol` FOREIGN KEY (`id_rol`) REFERENCES `roles` (`id_rol`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_rp_permiso` FOREIGN KEY (`id_permiso`) REFERENCES `permisos` (`id_permiso`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Permisos base del sistema
INSERT IGNORE INTO `permisos` (nombre, modulo, descripcion) VALUES
('admin.dashboard', 'admin', 'Ver dashboard de administración'),
('admin.courses', 'admin', 'Gestionar cursos'),
('admin.courses.editor', 'admin', 'Editor de contenido de cursos'),
('admin.users', 'admin', 'Gestionar usuarios'),
('admin.groups', 'admin', 'Gestionar grupos'),
('admin.enrollments', 'admin', 'Gestionar inscripciones'),
('admin.roles', 'admin', 'Gestionar roles y permisos');

-- Asignar todos los permisos al rol Administrador (id_rol = 1)
INSERT IGNORE INTO `rol_permisos` (id_rol, id_permiso)
SELECT 1, id_permiso FROM permisos;
