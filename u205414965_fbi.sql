-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1:3306
-- Tiempo de generación: 08-05-2026 a las 12:16:59
-- Versión del servidor: 11.8.6-MariaDB-log
-- Versión de PHP: 7.2.34

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `u205414965_fbi`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`u205414965_admin`@`127.0.0.1` PROCEDURE `sp_actualizar_contrasena` (IN `v_data` JSON, OUT `v_salida` JSON)   BEGIN
    DECLARE v_id_usuario INT;
    DECLARE v_contrasena VARCHAR(255);
    DECLARE v_count INT DEFAULT 0;
    DECLARE v_resultado JSON DEFAULT JSON_ARRAY();

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            @p_sqlstate = RETURNED_SQLSTATE,
            @p_errno = MYSQL_ERRNO,
            @p_message = MESSAGE_TEXT;

        SET v_salida = JSON_OBJECT(
            'status', 'ERROR',
            'message', CONCAT('Error al actualizar contraseña: ', @p_message),
            'data', NULL
        );
        ROLLBACK;
    END;

    -- Extraer datos del JSON
    SET v_id_usuario = JSON_UNQUOTE(JSON_EXTRACT(v_data, '$.id_usuario'));
    SET v_contrasena = JSON_UNQUOTE(JSON_EXTRACT(v_data, '$.contrasena'));

    -- Validar que el usuario exista
    SELECT COUNT(*) INTO v_count FROM usuarios WHERE id_usuario = v_id_usuario;

    IF v_count = 0 THEN
        SET v_salida = JSON_OBJECT(
            'status', 'ERROR',
            'message', 'El usuario no existe.',
            'data', NULL
        );
    ELSE
        START TRANSACTION;

        UPDATE usuarios
        SET contrasena = v_contrasena
        WHERE id_usuario = v_id_usuario;

        COMMIT;
        
                    SET v_resultado = JSON_ARRAY_APPEND(
                        v_resultado, '$',
                        JSON_OBJECT(
                            'id_usuario', v_id_usuario
                        )
                    );

        SET v_salida = JSON_OBJECT(
            'status', 'OK',
            'message', 'Contraseña actualizada correctamente.',
            'data', JSON_EXTRACT(v_resultado, '$')
        );
    END IF;
END$$

CREATE DEFINER=`u205414965_admin`@`127.0.0.1` PROCEDURE `sp_actualizar_progreso_curso` (IN `v_data` JSON, OUT `v_salida` JSON)   proc: BEGIN
    DECLARE v_id_usuario INT;
    DECLARE v_id_curso INT;
    DECLARE v_progreso DECIMAL(5,2);

    -- Extraer datos del JSON
    SET v_id_usuario = JSON_UNQUOTE(JSON_EXTRACT(v_data, '$.id_usuario'));
    SET v_id_curso   = JSON_UNQUOTE(JSON_EXTRACT(v_data, '$.id_curso'));
    SET v_progreso   = JSON_UNQUOTE(JSON_EXTRACT(v_data, '$.progreso'));

    -- Validar usuario
    IF NOT EXISTS (SELECT 1 FROM usuarios WHERE id_usuario = v_id_usuario) THEN
        SET v_salida = JSON_OBJECT(
            'status', 'ERROR',
            'message', 'El usuario no existe',
            'data', JSON_OBJECT()
        );
        LEAVE proc;
    END IF;

    -- Validar curso
    IF NOT EXISTS (SELECT 1 FROM cursos WHERE id_curso = v_id_curso) THEN
        SET v_salida = JSON_OBJECT(
            'status', 'ERROR',
            'message', 'El curso no existe',
            'data', JSON_OBJECT()
        );
        LEAVE proc;
    END IF;

    -- Insertar o actualizar progreso
    IF EXISTS (SELECT 1 FROM progreso_curso WHERE id_usuario = v_id_usuario AND id_curso = v_id_curso) THEN
        UPDATE progreso_curso
        SET progreso = v_progreso,
            fecha_actualizacion = NOW()
        WHERE id_usuario = v_id_usuario AND id_curso = v_id_curso;
    ELSE
        INSERT INTO progreso_curso (id_usuario, id_curso, progreso, fecha_actualizacion)
        VALUES (v_id_usuario, v_id_curso, v_progreso, NOW());
    END IF;

    -- Salida exitosa con formato estándar
    SET v_salida = JSON_OBJECT(
        'status', 'OK',
        'message', 'Progreso actualizado correctamente',
        'data', JSON_OBJECT(
            'id_usuario', v_id_usuario,
            'id_curso', v_id_curso,
            'progreso', v_progreso
        )
    );
END$$

CREATE DEFINER=`u205414965_admin`@`127.0.0.1` PROCEDURE `sp_actualizar_progreso_subleccion` (IN `v_data` JSON, OUT `v_salida` JSON)   proc: BEGIN
    DECLARE v_id_usuario INT;
    DECLARE v_id_curso INT;
    DECLARE v_id_leccion INT;
    DECLARE v_id_subleccion INT;
    DECLARE v_completado TINYINT;

    -- Extraer datos del JSON
    SET v_id_usuario    = JSON_UNQUOTE(JSON_EXTRACT(v_data, '$.id_usuario'));
    SET v_id_curso      = JSON_UNQUOTE(JSON_EXTRACT(v_data, '$.id_curso'));
    SET v_id_leccion    = JSON_UNQUOTE(JSON_EXTRACT(v_data, '$.id_leccion'));
    SET v_id_subleccion = JSON_UNQUOTE(JSON_EXTRACT(v_data, '$.id_subleccion'));
    SET v_completado    = JSON_UNQUOTE(JSON_EXTRACT(v_data, '$.completed'));

    -- Validar usuario
    IF NOT EXISTS (SELECT 1 FROM usuarios WHERE id_usuario = v_id_usuario) THEN
        SET v_salida = JSON_OBJECT(
            'status', 'ERROR',
            'message', 'El usuario no existe',
            'data', JSON_OBJECT()
        );
        LEAVE proc;
    END IF;

    -- Validar curso
    IF NOT EXISTS (SELECT 1 FROM cursos WHERE id_curso = v_id_curso) THEN
        SET v_salida = JSON_OBJECT(
            'status', 'ERROR',
            'message', 'El curso no existe',
            'data', JSON_OBJECT()
        );
        LEAVE proc;
    END IF;

    -- Validar lección
    IF NOT EXISTS (SELECT 1 FROM lecciones WHERE id_leccion = v_id_leccion ) THEN
        SET v_salida = JSON_OBJECT(
            'status', 'ERROR',
            'message', 'La lección no existe',
            'data', JSON_OBJECT()
        );
        LEAVE proc;
    END IF;

    -- Validar sublección
    IF NOT EXISTS (SELECT 1 FROM sublecciones WHERE id_subleccion = v_id_subleccion AND id_leccion = v_id_leccion) THEN
        SET v_salida = JSON_OBJECT(
            'status', 'ERROR',
            'message', 'La sublección no existe',
            'data', JSON_OBJECT()
        );
        LEAVE proc;
    END IF;

    -- Insertar o actualizar progreso de sublección
    IF EXISTS (SELECT 1 FROM progreso_subleccion 
               WHERE id_usuario = v_id_usuario 
                 AND id_curso = v_id_curso
                 AND id_leccion = v_id_leccion
                 AND id_subleccion = v_id_subleccion) THEN
        UPDATE progreso_subleccion
        SET completado = v_completado,
            fecha_completado = NOW()
        WHERE id_usuario = v_id_usuario
          AND id_curso = v_id_curso
          AND id_leccion = v_id_leccion
          AND id_subleccion = v_id_subleccion;
    ELSE
        INSERT INTO progreso_subleccion (id_usuario, id_curso, id_leccion, id_subleccion, completado, fecha_completado)
        VALUES (v_id_usuario, v_id_curso, v_id_leccion, v_id_subleccion, v_completado, NOW());
    END IF;

    -- Salida exitosa
    SET v_salida = JSON_OBJECT(
        'status', 'OK',
        'message', 'Progreso de sublección actualizado correctamente',
        'data', JSON_OBJECT(
            'id_usuario', v_id_usuario,
            'id_curso', v_id_curso,
            'id_leccion', v_id_leccion,
            'id_subleccion', v_id_subleccion,
            'completed', v_completado
        )
    );
END$$

CREATE DEFINER=`u205414965_admin`@`127.0.0.1` PROCEDURE `sp_actualizar_resultado` (IN `v_data` JSON, OUT `v_salida` JSON)   proc: BEGIN
    DECLARE v_id_usuario INT;
    DECLARE v_id_quiz INT;
    DECLARE v_id_evidencia INT;
    DECLARE v_nota DECIMAL(5,2);
    DECLARE v_comentario TEXT DEFAULT NULL;

    -- Extraer datos del JSON
    SET v_id_usuario = JSON_UNQUOTE(JSON_EXTRACT(v_data, '$.id_usuario'));
    SET v_id_quiz    = JSON_UNQUOTE(JSON_EXTRACT(v_data, '$.id_quiz'));
    SET v_nota       = JSON_UNQUOTE(JSON_EXTRACT(v_data, '$.nota'));

    -- Validar usuario
    IF NOT EXISTS (SELECT 1 FROM usuarios WHERE id_usuario = v_id_usuario) THEN
        SET v_salida = JSON_OBJECT(
            'status', 'ERROR',
            'message', 'El usuario no existe',
            'data', JSON_OBJECT()
        );
        LEAVE proc;
    END IF;

    -- Obtener id_evidencia desde el quiz
    SELECT id_evidencia INTO v_id_evidencia
    FROM quiz
    WHERE id_quiz = v_id_quiz;

    -- Validar existencia de evidencia
    IF v_id_evidencia IS NULL THEN
        SET v_salida = JSON_OBJECT(
            'status', 'ERROR',
            'message', 'No se encontró evidencia asociada al quiz',
            'data', JSON_OBJECT()
        );
        LEAVE proc;
    END IF;

    -- Insertar o actualizar resultado
    IF EXISTS (
        SELECT 1 FROM resultados 
        WHERE id_usuario = v_id_usuario AND id_evidencia = v_id_evidencia
    ) THEN
        UPDATE resultados
        SET nota = v_nota,
            fecha = NOW()
        WHERE id_usuario = v_id_usuario AND id_evidencia = v_id_evidencia;
    ELSE
        INSERT INTO resultados (id_evidencia, id_usuario, nota, fecha)
        VALUES (v_id_evidencia, v_id_usuario, v_nota, NOW());
    END IF;

    -- Salida exitosa
    SET v_salida = JSON_OBJECT(
        'status', 'OK',
        'message', 'Resultado actualizado correctamente',
        'data', JSON_OBJECT(
            'id_usuario', v_id_usuario,
            'id_evidencia', v_id_evidencia,
            'nota', v_nota
        )
    );
END$$

CREATE DEFINER=`u205414965_admin`@`127.0.0.1` PROCEDURE `sp_delete_curso` (IN `v_data` JSON, OUT `v_salida` JSON)   BEGIN
    DECLARE v_id_curso INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @msg = MESSAGE_TEXT;
        SET v_salida = JSON_OBJECT('status','ERROR','message',CONCAT('Error al eliminar curso: ',@msg),'data',NULL);
        ROLLBACK;
    END;

    SET v_id_curso = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_curso'));

    START TRANSACTION;
    DELETE FROM cursos WHERE id_curso=v_id_curso;
    COMMIT;

    SET v_salida = JSON_OBJECT('status','OK','message','Curso eliminado correctamente','data',JSON_OBJECT('id_curso',v_id_curso));
END$$

CREATE DEFINER=`u205414965_admin`@`127.0.0.1` PROCEDURE `sp_delete_inscripcion` (IN `p_id_inscripcion` INT)   BEGIN
    DELETE FROM inscripciones WHERE id_inscripcion = p_id_inscripcion;
END$$

CREATE DEFINER=`u205414965_admin`@`127.0.0.1` PROCEDURE `sp_delete_leccion` (IN `v_data` JSON, OUT `v_salida` JSON)   BEGIN
    DECLARE v_id_leccion INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @msg = MESSAGE_TEXT;
        SET v_salida = JSON_OBJECT('status','ERROR','message',CONCAT('Error al eliminar lección: ',@msg),'data',NULL);
        ROLLBACK;
    END;

    SET v_id_leccion = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_leccion'));

    START TRANSACTION;
        DELETE FROM lecciones WHERE id_leccion = v_id_leccion;
    COMMIT;

    SET v_salida = JSON_OBJECT('status','OK','message','Lección eliminada correctamente');
END$$

CREATE DEFINER=`u205414965_admin`@`127.0.0.1` PROCEDURE `sp_delete_metodo_pago` (IN `p_id_metodo` INT)   BEGIN
    DELETE FROM metodos_pago WHERE id_metodo = p_id_metodo;
END$$

CREATE DEFINER=`u205414965_admin`@`127.0.0.1` PROCEDURE `sp_delete_modulo` (IN `v_data` JSON, OUT `v_salida` JSON)   BEGIN
    DECLARE v_id_modulo INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @msg = MESSAGE_TEXT;
        SET v_salida = JSON_OBJECT('status','ERROR','message',CONCAT('Error al eliminar módulo: ',@msg),'data',NULL);
        ROLLBACK;
    END;

    SET v_id_modulo = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_modulo'));

    START TRANSACTION;
        DELETE FROM modulos WHERE id_modulo = v_id_modulo;
    COMMIT;

    SET v_salida = JSON_OBJECT('status','OK','message','Módulo eliminado correctamente');
END$$

CREATE DEFINER=`u205414965_admin`@`127.0.0.1` PROCEDURE `sp_delete_pago` (IN `p_id_pago` INT)   BEGIN
    DELETE FROM pagos WHERE id_pago = p_id_pago;
END$$

CREATE DEFINER=`u205414965_admin`@`127.0.0.1` PROCEDURE `sp_delete_subleccion` (IN `v_data` JSON, OUT `v_salida` JSON)   BEGIN
    DECLARE v_id_subleccion INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @msg = MESSAGE_TEXT;
        SET v_salida = JSON_OBJECT('status','ERROR','message',CONCAT('Error al eliminar sublección: ',@msg),'data',NULL);
        ROLLBACK;
    END;

    SET v_id_subleccion = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_subleccion'));

    START TRANSACTION;
        DELETE FROM sublecciones WHERE id_subleccion = v_id_subleccion;
    COMMIT;

    SET v_salida = JSON_OBJECT('status','OK','message','Sublección eliminada correctamente');
END$$

CREATE DEFINER=`u205414965_admin`@`127.0.0.1` PROCEDURE `sp_get_admin_stats` (OUT `v_salida` JSON)   BEGIN
    DECLARE v_total_usuarios INT;
    DECLARE v_total_cursos INT;
    DECLARE v_total_inscripciones INT;
    DECLARE v_ingresos_totales DECIMAL(15,2);

    SELECT COUNT(*) INTO v_total_usuarios FROM usuarios WHERE id_rol = 2;
    SELECT COUNT(*) INTO v_total_cursos FROM cursos;
    SELECT COUNT(*) INTO v_total_inscripciones FROM inscripciones;
    SELECT IFNULL(SUM(monto), 0) INTO v_ingresos_totales FROM pagos WHERE id_estado = 2;

    SET v_salida = JSON_OBJECT(
        'status', 'OK',
        'message', 'Estadísticas obtenidas correctamente',
        'data', JSON_EXTRACT(JSON_OBJECT(
            'total_usuarios', v_total_usuarios,
            'total_cursos', v_total_cursos,
            'total_inscripciones', v_total_inscripciones,
            'ingresos_totales', v_ingresos_totales
        ), '$')
    );
END$$

CREATE DEFINER=`u205414965_admin`@`127.0.0.1` PROCEDURE `sp_get_all_categorias` (IN `v_data` JSON, OUT `v_salida` JSON)   BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE v_id_categoria INT;
    DECLARE v_nombre VARCHAR(255);

    DECLARE v_resultado JSON DEFAULT JSON_ARRAY();

    DECLARE cur CURSOR FOR
        SELECT id_categoria, nombre
        FROM categorias;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            @sqlstate = RETURNED_SQLSTATE,
            @errno = MYSQL_ERRNO,
            @msg = MESSAGE_TEXT;

        SET v_salida = JSON_OBJECT('status','ERROR','message',CONCAT('Error al obtener categorías: ',@msg),'data',NULL);
        ROLLBACK;
    END;

    START TRANSACTION;

    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO v_id_categoria, v_nombre;
        IF done THEN LEAVE read_loop; END IF;

        SET v_resultado = JSON_ARRAY_APPEND(v_resultado, '$',
            JSON_OBJECT(
                'id_categoria', v_id_categoria,
                'nombre', v_nombre
            )
        );
    END LOOP;
    CLOSE cur;

    COMMIT;

    SET v_salida = JSON_OBJECT('status','OK','message','Categorías obtenidas correctamente','data',JSON_EXTRACT(v_resultado,'$'));
END$$

CREATE DEFINER=`u205414965_admin`@`127.0.0.1` PROCEDURE `sp_get_all_cursos` (IN `v_data` JSON, OUT `v_salida` JSON)   BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE v_id_curso INT;
    DECLARE v_titulo VARCHAR(255);
    DECLARE v_descripcion TEXT;
    DECLARE v_precio DECIMAL(10,2);
    DECLARE v_fecha_creacion DATETIME;
    DECLARE v_id_estado INT;
    DECLARE v_portada VARCHAR(400);
    DECLARE v_id_usuario INT;
    DECLARE v_id_categoria INT;
    DECLARE v_categoria_descripcion VARCHAR(255);
    
    DECLARE v_resultado JSON DEFAULT JSON_ARRAY();

    DECLARE cur CURSOR FOR
        SELECT c.id_curso, c.titulo, c.descripcion, c.precio, c.fecha_creacion, c.id_estado, c.portada,
               c.id_categoria, cat.nombre
        FROM cursos c
        LEFT JOIN categorias cat ON c.id_categoria = cat.id_categoria
        WHERE c.id_curso NOT IN (
            SELECT i.id_curso FROM inscripciones i WHERE i.id_usuario = v_id_usuario
        ) and c.id_estado = 1;


    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            @sqlstate = RETURNED_SQLSTATE,
            @errno = MYSQL_ERRNO,
            @msg = MESSAGE_TEXT;

        SET v_salida = JSON_OBJECT('status','ERROR','message',CONCAT('Error al obtener cursos: ',@msg),'data',NULL);
        ROLLBACK;
    END;
    
                 -- Extraer valores del JSON de entrada
    SET v_id_usuario = JSON_UNQUOTE(JSON_EXTRACT(v_data, '$.id_usuario'));

    START TRANSACTION;

    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO v_id_curso, v_titulo, v_descripcion, v_precio, v_fecha_creacion, v_id_estado, v_portada,v_id_categoria,v_categoria_descripcion;
        IF done THEN LEAVE read_loop; END IF;

        SET v_resultado = JSON_ARRAY_APPEND(v_resultado,'$',
            JSON_OBJECT(
                'id_curso',v_id_curso,
                'titulo',v_titulo,
                'descripcion',v_descripcion,
                'precio',v_precio,
                'fecha_creacion',v_fecha_creacion,
                'id_estado',v_id_estado,
                'portada',v_portada,
                 'id_categoria', v_id_categoria,
                'categoria', v_categoria_descripcion
            )
        );
    END LOOP;
    CLOSE cur;

    COMMIT;
    SET v_salida = JSON_OBJECT('status','OK','message','Cursos obtenidos correctamente','data',JSON_EXTRACT(v_resultado, '$'));
END$$

CREATE DEFINER=`u205414965_admin`@`127.0.0.1` PROCEDURE `sp_get_all_cursos_inscritos` (IN `v_data` JSON, OUT `v_salida` JSON)   BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE v_id_curso INT;
    DECLARE v_titulo VARCHAR(255);
    DECLARE v_descripcion TEXT;
    DECLARE v_precio DECIMAL(10,2);
    DECLARE v_fecha_creacion DATETIME;
    DECLARE v_id_estado INT;
    DECLARE v_portada VARCHAR(400);
    DECLARE v_id_usuario INT;

    DECLARE v_resultado JSON DEFAULT JSON_ARRAY();

    -- Cursor para cursos en los que el usuario sí está inscrito
    DECLARE cur CURSOR FOR
        SELECT c.id_curso, c.titulo, c.descripcion, c.precio, c.fecha_creacion, c.id_estado, c.portada
        FROM cursos c
        INNER JOIN inscripciones i ON c.id_curso = i.id_curso
        WHERE i.id_usuario = v_id_usuario AND c.id_estado = 1;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            @sqlstate = RETURNED_SQLSTATE,
            @errno = MYSQL_ERRNO,
            @msg = MESSAGE_TEXT;

        SET v_salida = JSON_OBJECT(
            'status','ERROR',
            'message',CONCAT('Error al obtener cursos inscritos: ', @msg),
            'data',NULL
        );
        ROLLBACK;
    END;

    -- Extraer valores del JSON de entrada
    SET v_id_usuario = JSON_UNQUOTE(JSON_EXTRACT(v_data, '$.id_usuario'));

    START TRANSACTION;

    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO v_id_curso, v_titulo, v_descripcion, v_precio, v_fecha_creacion, v_id_estado, v_portada;
        IF done THEN LEAVE read_loop; END IF;

        SET v_resultado = JSON_ARRAY_APPEND(
            v_resultado,
            '$',
            JSON_OBJECT(
                'id_curso', v_id_curso,
                'titulo', v_titulo,
                'descripcion', v_descripcion,
                'precio', v_precio,
                'fecha_creacion', v_fecha_creacion,
                'id_estado', v_id_estado,
                'portada', v_portada
            )
        );
    END LOOP;
    CLOSE cur;

    COMMIT;
    SET v_salida = JSON_OBJECT(
        'status','OK',
        'message','Cursos inscritos obtenidos correctamente',
        'data', JSON_EXTRACT(v_resultado, '$')
    );
END$$

CREATE DEFINER=`u205414965_admin`@`127.0.0.1` PROCEDURE `sp_get_all_generos` (IN `v_data` JSON, OUT `v_salida` JSON)   BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE v_id_genero INT;
    DECLARE v_nombre VARCHAR(50);
    DECLARE v_descripcion TEXT;

    DECLARE v_resultado JSON DEFAULT JSON_ARRAY();

    DECLARE cur CURSOR FOR SELECT id_genero, nombre, descripcion FROM generos;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Capturar el código de error (no el mensaje)
        GET DIAGNOSTICS CONDITION 1
            @p_sqlstate = RETURNED_SQLSTATE,
            @p_errno = MYSQL_ERRNO,
            @p_message = MESSAGE_TEXT;

        SET v_salida = JSON_OBJECT(
            'status', 'ERROR',
            'message', CONCAT('Error al obtener géneros: ', @p_message),
            'data', NULL
        );
    END;

    START TRANSACTION;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_id_genero, v_nombre, v_descripcion;
        IF done THEN
            LEAVE read_loop;
        END IF;

        SET v_resultado = JSON_ARRAY_APPEND(
            v_resultado, '$',
            JSON_OBJECT(
                'id_genero', v_id_genero,
                'nombre', v_nombre,
                'descripcion', v_descripcion
            )
        );
    END LOOP;

    CLOSE cur;

    COMMIT;

    SET v_salida = JSON_OBJECT(
        'status', 'OK',
        'message', 'Géneros obtenidos correctamente',
        'data', JSON_EXTRACT(v_resultado, '$')
    );

END$$

CREATE DEFINER=`u205414965_admin`@`127.0.0.1` PROCEDURE `sp_get_all_lecciones` (IN `v_data` JSON, OUT `v_salida` JSON)   BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE v_resultado JSON DEFAULT JSON_ARRAY();

    DECLARE v_id_leccion INT;
    DECLARE v_titulo VARCHAR(255);
    DECLARE v_descripcion TEXT;
    DECLARE v_duracion INT;
    DECLARE v_orden INT;
    DECLARE v_modulo VARCHAR(255);
    DECLARE v_curso VARCHAR(255);
    DECLARE v_estado VARCHAR(255);

    DECLARE cur CURSOR FOR
        SELECT 
            l.id_leccion,
            l.titulo,
            l.descripcion,
            l.duracion,
            l.orden,
            m.titulo AS modulo,
            c.titulo AS curso,
            e.nombre AS estado
        FROM lecciones l
        JOIN modulos m ON m.id_modulo = l.id_modulo
        JOIN cursos c ON c.id_curso = m.id_curso
        JOIN estados e ON e.id_estado = l.id_estado;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    START TRANSACTION;
        OPEN cur;
        read_loop: LOOP
            FETCH cur INTO v_id_leccion,v_titulo,v_descripcion,v_duracion,v_orden,v_modulo,v_curso,v_estado;
            IF done THEN LEAVE read_loop; END IF;

            SET v_resultado = JSON_ARRAY_APPEND(v_resultado,'$',
                JSON_OBJECT(
                    'id_leccion',v_id_leccion,
                    'titulo',v_titulo,
                    'descripcion',v_descripcion,
                    'duracion',v_duracion,
                    'orden',v_orden,
                    'modulo',v_modulo,
                    'curso',v_curso,
                    'estado',v_estado
                )
            );
        END LOOP;
        CLOSE cur;
    COMMIT;

    SET v_salida = JSON_OBJECT('status','OK','message','Lecciones obtenidas correctamente','data',v_resultado);
END$$

CREATE DEFINER=`u205414965_admin`@`127.0.0.1` PROCEDURE `sp_get_all_modulos` (IN `v_data` JSON, OUT `v_salida` JSON)   BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE v_resultado JSON DEFAULT JSON_ARRAY();

    DECLARE v_id_modulo INT;
    DECLARE v_titulo VARCHAR(255);
    DECLARE v_descripcion TEXT;
    DECLARE v_orden INT;
    DECLARE v_curso VARCHAR(255);
    DECLARE v_estado VARCHAR(255);
    DECLARE v_docente INT;

    DECLARE cur CURSOR FOR
        SELECT 
            m.id_modulo,
            m.titulo,
            m.descripcion,
            m.orden,
            c.titulo AS curso,
            e.nombre AS estado,
            m.id_docente
        FROM modulos m
        JOIN cursos c ON c.id_curso = m.id_curso
        JOIN estados e ON e.id_estado = m.id_estado;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    START TRANSACTION;
        OPEN cur;
        read_loop: LOOP
            FETCH cur INTO v_id_modulo,v_titulo,v_descripcion,v_orden,v_curso,v_estado,v_docente;
            IF done THEN LEAVE read_loop; END IF;

            SET v_resultado = JSON_ARRAY_APPEND(v_resultado,'$',
                JSON_OBJECT(
                    'id_modulo',v_id_modulo,
                    'titulo',v_titulo,
                    'descripcion',v_descripcion,
                    'orden',v_orden,
                    'curso',v_curso,
                    'estado',v_estado,
                    'id_docente',v_docente
                )
            );
        END LOOP;
        CLOSE cur;
    COMMIT;

    SET v_salida = JSON_OBJECT('status','OK','message','Módulos obtenidos correctamente','data',v_resultado);
END$$

CREATE DEFINER=`u205414965_admin`@`127.0.0.1` PROCEDURE `sp_get_all_sublecciones` (IN `v_data` JSON, OUT `v_salida` JSON)   BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE v_resultado JSON DEFAULT JSON_ARRAY();

    DECLARE v_id_subleccion INT;
    DECLARE v_titulo VARCHAR(255);
    DECLARE v_contenido TEXT;
    DECLARE v_video_url VARCHAR(500);
    DECLARE v_orden INT;
    DECLARE v_leccion VARCHAR(255);
    DECLARE v_modulo VARCHAR(255);
    DECLARE v_curso VARCHAR(255);
    DECLARE v_estado VARCHAR(255);

    DECLARE cur CURSOR FOR
        SELECT 
            s.id_subleccion,
            s.titulo,
            s.contenido,
            s.video_url,
            s.orden,
            l.titulo AS leccion,
            m.titulo AS modulo,
            c.titulo AS curso,
            e.nombre AS estado
        FROM sublecciones s
        JOIN lecciones l ON l.id_leccion = s.id_leccion
        JOIN modulos m ON m.id_modulo = l.id_modulo
        JOIN cursos c ON c.id_curso = m.id_curso
        JOIN estados e ON e.id_estado = s.id_estado;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    START TRANSACTION;
        OPEN cur;
        read_loop: LOOP
            FETCH cur INTO v_id_subleccion,v_titulo,v_contenido,v_video_url,v_orden,v_leccion,v_modulo,v_curso,v_estado;
            IF done THEN LEAVE read_loop; END IF;

            SET v_resultado = JSON_ARRAY_APPEND(v_resultado,'$',
                JSON_OBJECT(
                    'id_subleccion',v_id_subleccion,
                    'titulo',v_titulo,
                    'contenido',v_contenido,
                    'video_url',v_video_url,
                    'orden',v_orden,
                    'leccion',v_leccion,
                    'modulo',v_modulo,
                    'curso',v_curso,
                    'estado',v_estado
                )
            );
        END LOOP;
        CLOSE cur;
    COMMIT;

    SET v_salida = JSON_OBJECT('status','OK','message','Sublecciones obtenidas correctamente','data',v_resultado);
END$$

CREATE DEFINER=`u205414965_admin`@`127.0.0.1` PROCEDURE `sp_get_all_usuarios` (IN `v_data` JSON, OUT `v_salida` JSON)   BEGIN
        DECLARE done INT DEFAULT 0;
   
       DECLARE   v_id_usuario INT;
       DECLARE   v_nombre VARCHAR(255);
       DECLARE   v_apellido VARCHAR(255);
       DECLARE  v_correo VARCHAR(255);
       DECLARE   v_contrasena VARCHAR(255);
       DECLARE   v_fecha_nacimiento DATE;
       DECLARE   v_edad INT;
       DECLARE   v_id_genero INT;
       DECLARE   v_telefono VARCHAR(20);
       DECLARE   v_direccion TEXT;
       DECLARE   v_id_rol INT;
       DECLARE    v_fecha_registro DATETIME;
       DECLARE   v_id_estado INT;

    DECLARE v_resultado JSON DEFAULT JSON_ARRAY(); 

    DECLARE cur CURSOR FOR
        SELECT 
            id_usuario, nombre, apellido, correo, contrasena,
            fecha_nacimiento, edad, id_genero, telefono, direccion,
            id_rol, fecha_registro, id_estado
        FROM usuarios;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            @p_sqlstate = RETURNED_SQLSTATE,
            @p_errno = MYSQL_ERRNO,
            @p_message = MESSAGE_TEXT;

        SET v_salida = JSON_OBJECT(
            'status', 'ERROR',
            'message', CONCAT('Error al obtener usuarios: ', @p_message),
            'data', NULL
        );
        ROLLBACK;
    END;

    START TRANSACTION;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO 
            v_id_usuario, v_nombre, v_apellido, v_correo, v_contrasena,
            v_fecha_nacimiento, v_edad, v_id_genero, v_telefono,
            v_direccion, v_id_rol, v_fecha_registro, v_id_estado;

        IF done THEN
            LEAVE read_loop;
        END IF;

        SET v_resultado = JSON_ARRAY_APPEND(
            v_resultado, '$',
            JSON_OBJECT(
                'id_usuario', v_id_usuario,
                'nombre', v_nombre,
                'apellido', v_apellido,
                'correo', v_correo,
                'contrasena', v_contrasena,
                'fecha_nacimiento', v_fecha_nacimiento,
                'edad', v_edad,
                'id_genero', v_id_genero,
                'telefono', v_telefono,
                'direccion', v_direccion,
                'id_rol', v_id_rol,
                'fecha_registro', v_fecha_registro,
                'id_estado', v_id_estado
            )
        );
    END LOOP;

    CLOSE cur;

    COMMIT;

    SET v_salida = JSON_OBJECT(
        'status', 'OK',
        'message', 'Usuarios obtenidos correctamente',
        'data', JSON_EXTRACT(v_resultado, '$')
    );
END$$

CREATE DEFINER=`u205414965_admin`@`127.0.0.1` PROCEDURE `sp_get_all_usuarios_admin` (OUT `v_salida` JSON)   BEGIN
    DECLARE v_resultado JSON DEFAULT JSON_ARRAY();
    
    SELECT JSON_ARRAYAGG(
        JSON_OBJECT(
            'id_usuario', id_usuario,
            'nombre', nombre,
            'apellido', apellido,
            'correo', correo,
            'id_rol', id_rol,
            'id_estado', id_estado,
            'fecha_registro', fecha_registro
        )
    ) INTO v_resultado
    FROM usuarios;

    SET v_salida = JSON_OBJECT(
        'status', 'OK',
        'message', 'Usuarios obtenidos correctamente',
        'data', JSON_EXTRACT(IFNULL(v_resultado, JSON_ARRAY()), '$')
    );
END$$

CREATE DEFINER=`u205414965_admin`@`127.0.0.1` PROCEDURE `sp_get_cursos_admin` (OUT `v_salida` JSON)   BEGIN
    DECLARE v_resultado JSON DEFAULT JSON_ARRAY();
    
    SELECT JSON_ARRAYAGG(
        JSON_OBJECT(
            'id_curso', id_curso,
            'titulo', titulo,
            'descripcion', descripcion,
            'precio', precio,
            'id_estado', id_estado,
            'portada', portada,
            'id_categoria', id_categoria
        )
    ) INTO v_resultado
    FROM cursos;

    SET v_salida = JSON_OBJECT(
        'status', 'OK',
        'message', 'Cursos obtenidos correctamente',
        'data', JSON_EXTRACT(IFNULL(v_resultado, JSON_ARRAY()), '$')
    );
END$$

CREATE DEFINER=`u205414965_admin`@`127.0.0.1` PROCEDURE `sp_get_cursos_inscritos` (IN `v_data` JSON, OUT `v_salida` JSON)   BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE v_id_curso INT;
    DECLARE v_titulo VARCHAR(255);
    DECLARE v_descripcion TEXT;
    DECLARE v_precio DECIMAL(10,2);
    DECLARE v_fecha_creacion DATETIME;
    DECLARE v_id_estado INT;
    DECLARE v_portada VARCHAR(500);
    DECLARE v_id_usuario INT;
    DECLARE v_resultado JSON DEFAULT JSON_ARRAY();
    DECLARE v_progreso DECIMAL(5,2) DEFAULT 0;
     DECLARE v_id_grupo INT;

    -- Cursor: cursos en los que el usuario está inscrito
    DECLARE cur CURSOR FOR
        SELECT c.id_curso, c.titulo, c.descripcion, c.precio, c.fecha_creacion, c.id_estado, c.portada
        FROM cursos c
        INNER JOIN inscripciones i ON i.id_curso = c.id_curso
        WHERE  i.id_curso = v_id_curso and     i.id_usuario = v_id_usuario;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    START TRANSACTION;
    
              -- Extraer valores del JSON de entrada
    SET v_id_usuario = JSON_UNQUOTE(JSON_EXTRACT(v_data, '$.id_usuario'));
    SET v_id_curso   = JSON_UNQUOTE(JSON_EXTRACT(v_data, '$.id_curso'));
    
    
       -- === Obtener grupo del usuario ===
    SELECT id_grupo INTO v_id_grupo
    FROM grupo_usuarios
    WHERE id_usuario = v_id_usuario
    LIMIT 1;

    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO v_id_curso, v_titulo, v_descripcion, v_precio, v_fecha_creacion, v_id_estado, v_portada;
        IF done THEN LEAVE read_loop; END IF;
        
     -- === Obtener progreso del curso ===
        SET v_progreso = (
            SELECT COALESCE(
                (SELECT p.progreso 
                 FROM progreso_curso p
                 WHERE p.id_curso = v_id_curso
                   AND p.id_usuario = v_id_usuario
                 LIMIT 1), 
                0
            )
        );


        -- === MÓDULOS ===
        SET @modulos_json = (
            SELECT JSON_ARRAYAGG(
                JSON_OBJECT(
                    'id_modulo', m.id_modulo,
                    'titulo', m.titulo,
                    'descripcion', m.descripcion,
                    'orden', m.orden,
                    'id_estado', m.id_estado,

                     -- ✅ Información del docente
                    'id_docente', m.id_docente,
                    'docente_nombre', udoc.nombre,
                    'docente_apellido', udoc.apellido,


                    -- === LECCIONES ===
                    'lecciones', (
                        SELECT JSON_ARRAYAGG(
                            JSON_OBJECT(
                                'id_leccion', l.id_leccion,
                                'titulo', l.titulo,
                                'descripcion', l.descripcion,
                                'orden', l.orden,
                                'id_estado', l.id_estado,
                                
                                
    -- === FORO ===
                                'foro', (
                                    SELECT JSON_ARRAYAGG(
                                        JSON_OBJECT(
                                            'id_pregunta', fp.id_pregunta,
                                            'titulo', fp.titulo,
                                            'contenido', fp.contenido,
                                            'autor', CONCAT(u.nombre, ' ', u.apellido),
                                            'fecha', fp.fecha_creacion,

                                            -- === RESPUESTAS DEL GRUPO ===
                                            'respuestas', IFNULL((
                                                SELECT JSON_ARRAYAGG(
                                                    JSON_OBJECT(
                                                        'id_respuesta', fr.id_respuesta,
                                                        'autor', CONCAT(ur.nombre, ' ', ur.apellido),
                                                        'contenido', fr.contenido,
                                                        'fecha', fr.fecha_creacion,

                                                        -- === COMENTARIOS ===
                                                        'comentarios', IFNULL((
                                                            SELECT JSON_ARRAYAGG(
                                                                JSON_OBJECT(
                                                                    'id_comentario', fc.id_comentario,
                                                                    'autor', CONCAT(uc.nombre, ' ', uc.apellido),
                                                                    'contenido', fc.contenido,
                                                                    'fecha', fc.fecha_creacion
                                                                )
                                                            )
                                                            FROM foro_comentarios fc
                                                            INNER JOIN usuarios uc ON uc.id_usuario = fc.id_usuario
                                                            WHERE fc.id_respuesta = fr.id_respuesta
                                                        ), JSON_ARRAY())
                                                    )
                                                )
                                                FROM foro_respuestas fr
                                                INNER JOIN usuarios ur ON ur.id_usuario = fr.id_usuario
                                                WHERE fr.id_pregunta = fp.id_pregunta
                                                  AND fr.id_grupo = v_id_grupo
                                            ), JSON_ARRAY())
                                        )
                                    )
                                    FROM foro_preguntas fp
                                    INNER JOIN usuarios u ON u.id_usuario = fp.id_usuario
                                    WHERE fp.id_curso = v_id_curso
                                      AND fp.id_leccion = l.id_leccion
                                    ORDER BY fp.fecha_creacion ASC
                                ),
                                            
                                
                                

                                -- === SUBLECCIONES ===
                                'sublecciones', (
                                    SELECT JSON_ARRAYAGG(
                                        JSON_OBJECT(
                                            'id_subleccion', s.id_subleccion,
                                            'titulo', s.titulo,
                                            'url_recurso', s.url_recurso,
                                            'orden', s.orden,
                                            'tipo', s.tipo,
                                            'id_estado', s.id_estado,
                                            
                                             -- ✅ Estado de completado por usuario
                                            'completed', COALESCE(
                                                (SELECT p.completado
                                                 FROM progreso_subleccion p
                                                 WHERE p.id_usuario = v_id_usuario
                                                   AND p.id_curso = v_id_curso
                                                   AND p.id_leccion = l.id_leccion
                                                   AND p.id_subleccion = s.id_subleccion
                                                 LIMIT 1),
                                                0
                                            ),

                                            -- === QUIZ Y PREGUNTAS ===
                                            'quiz', (
                                                SELECT JSON_ARRAYAGG(
                                                    JSON_OBJECT(
                                                        'id_quiz', q.id_quiz,
                                                        'titulo', q.titulo,
                                                        'descripcion', q.descripcion,
                                                        'preguntas', (
                                                            SELECT JSON_ARRAYAGG(
                                                                JSON_OBJECT(
                                                                    'id_pregunta', p.id_pregunta,
                                                                    'pregunta', p.pregunta,
                                                                    'opcion_a', p.opcion_a,
                                                                    'opcion_b', p.opcion_b,
                                                                    'opcion_c', p.opcion_c,
                                                                    'opcion_d', p.opcion_d,
                                                                    'correcta', p.correcta
                                                                )
                                                            )
                                                            FROM quiz_preguntas p
                                                            WHERE p.id_quiz = q.id_quiz
                                                        )
                                                    )
                                                )
                                                FROM quiz q
                                                WHERE q.id_subleccion = s.id_subleccion
                                            )
                                        )
                                    )
                                    FROM sublecciones s
                                    WHERE s.id_leccion = l.id_leccion
                                ),
                                -- === EVIDENCIAS Y CALIFICACIONES ===
                                'evidencias', (
                                    SELECT JSON_ARRAYAGG(
                                        JSON_OBJECT(
                                            'id_evidencia', e.id_evidencia,
                                            'titulo', e.titulo,
                                            'descripcion', e.descripcion,
                                            'fecha', e.fecha,
                                            'tipo', te.tipo_nombre,

                                            -- Resultados por usuario
                                            'resultado', (
                                                SELECT JSON_OBJECT(
                                                    'nota', r.nota,
                                                    'comentario', r.comentario,
                                                    'fecha', r.fecha
                                                )
                                                FROM resultados r
                                                WHERE r.id_evidencia = e.id_evidencia
                                                  AND r.id_usuario = v_id_usuario
                                                LIMIT 1
                                            )
                                        )
                                    )
                                    FROM evidencias e
                                    INNER JOIN tipos_evidencia te ON te.id_tipo = e.id_tipo
                                    WHERE e.id_leccion = l.id_leccion

                               )
                            )
                        )
                        FROM lecciones l
                        INNER JOIN grupo_lecciones gl 
                            ON gl.id_leccion = l.id_leccion 
                            AND gl.id_grupo = v_id_grupo
                           AND gl.activo = 1
                        WHERE l.id_modulo = m.id_modulo

                    )
                )
            )
            FROM modulos m
            INNER JOIN docentes d ON d.id_docente = m.id_docente
            INNER JOIN usuarios udoc ON udoc.id_usuario = d.id_usuario
            WHERE m.id_curso = v_id_curso
        );

        -- === AGREGAR CURSO COMPLETO ===
        SET v_resultado = JSON_ARRAY_APPEND(v_resultado, '$',
            JSON_OBJECT(
                'id_curso', v_id_curso,
                'titulo', v_titulo,
                'descripcion', v_descripcion,
                'precio', v_precio,
                'fecha_creacion', v_fecha_creacion,
                'id_estado', v_id_estado,
                'portada', v_portada,
                'progreso', v_progreso,
                'modulos', JSON_EXTRACT(IFNULL(@modulos_json, JSON_ARRAY()), '$')
                -- 👆 convierte el texto a JSON real
            )
        );
    END LOOP;

    CLOSE cur;
    COMMIT;
    
    SET v_salida = JSON_OBJECT(
        'status', 'OK',
        'message', 'Cursos inscritos obtenidos correctamente',
        'data', JSON_EXTRACT(v_resultado, '$')
    );
END$$

CREATE DEFINER=`u205414965_admin`@`127.0.0.1` PROCEDURE `sp_get_cursos_no_inscritos` (IN `v_data` JSON, OUT `v_salida` JSON)   BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE v_id_curso INT;
    DECLARE v_titulo VARCHAR(255);
    DECLARE v_descripcion TEXT;
    DECLARE v_precio DECIMAL(10,2);
    DECLARE v_fecha_creacion DATETIME;
    DECLARE v_id_estado INT;
    DECLARE v_portada VARCHAR(500);
    DECLARE v_id_usuario INT;
    DECLARE v_resultado JSON DEFAULT JSON_ARRAY();
    
  

    -- Cursor para recorrer los cursos NO inscritos
    DECLARE cur CURSOR FOR
        SELECT c.id_curso, c.titulo, c.descripcion, c.precio, c.fecha_creacion, c.id_estado, c.portada
        FROM cursos c
        WHERE  c.id_curso = v_id_curso and  c.id_curso NOT IN (
            SELECT i.id_curso FROM inscripciones i WHERE i.id_usuario = v_id_usuario
        );

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    



    START TRANSACTION;
    
             -- Extraer valores del JSON de entrada
    SET v_id_usuario = JSON_UNQUOTE(JSON_EXTRACT(v_data, '$.id_usuario'));
    SET v_id_curso   = JSON_UNQUOTE(JSON_EXTRACT(v_data, '$.id_curso'));

    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO v_id_curso, v_titulo, v_descripcion, v_precio, v_fecha_creacion, v_id_estado, v_portada;
        IF done THEN LEAVE read_loop; END IF;

        -- === MÓDULOS ===
        SET @modulos_json = (
            SELECT JSON_ARRAYAGG(
                JSON_OBJECT(
                    'id_modulo', m.id_modulo,
                    'titulo', m.titulo,
                    'descripcion', m.descripcion,
                    'orden', m.orden,
                    'id_estado', m.id_estado,

                    -- === LECCIONES ===
                    'lecciones', (
                        SELECT JSON_ARRAYAGG(
                            JSON_OBJECT(
                                'id_leccion', l.id_leccion,
                                'titulo', l.titulo,
                                'descripcion', l.descripcion,
                                'orden', l.orden,
                                'id_estado', l.id_estado,

                                -- === SUBLECCIONES ===
                                'sublecciones', (
                                    SELECT JSON_ARRAYAGG(
                                        JSON_OBJECT(
                                            'id_subleccion', s.id_subleccion,
                                            'titulo', s.titulo,
                                            'url_recurso', s.url_recurso,
                                            'orden', s.orden,
                                            'tipo', s.tipo,
                                            'id_estado', s.id_estado,

                                            -- === QUIZ Y PREGUNTAS ===
                                            'quiz', (
                                                SELECT JSON_ARRAYAGG(
                                                    JSON_OBJECT(
                                                        'id_quiz', q.id_quiz,
                                                        'titulo', q.titulo,
                                                        'descripcion', q.descripcion,
                                                        'preguntas', (
                                                            SELECT JSON_ARRAYAGG(
                                                                JSON_OBJECT(
                                                                    'id_pregunta', p.id_pregunta,
                                                                    'pregunta', p.pregunta,
                                                                    'opcion_a', p.opcion_a,
                                                                    'opcion_b', p.opcion_b,
                                                                    'opcion_c', p.opcion_c,
                                                                    'opcion_d', p.opcion_d,
                                                                    'correcta', p.correcta
                                                                )
                                                            )
                                                            FROM quiz_preguntas p
                                                            WHERE p.id_quiz = q.id_quiz
                                                        )
                                                    )
                                                )
                                                FROM quiz q
                                                WHERE q.id_subleccion = s.id_subleccion
                                            )
                                        )
                                    )
                                    FROM sublecciones s
                                    WHERE s.id_leccion = l.id_leccion
                                )
                            )
                        )
                        FROM lecciones l
                        WHERE l.id_modulo = m.id_modulo
                    )
                )
            )
            FROM modulos m
            WHERE m.id_curso = v_id_curso
        );

        -- === AGREGAR CURSO COMPLETO ===
        SET v_resultado = JSON_ARRAY_APPEND(v_resultado, '$',
            JSON_OBJECT(
                'id_curso', v_id_curso,
                'titulo', v_titulo,
                'descripcion', v_descripcion,
                'precio', v_precio,
                'fecha_creacion', v_fecha_creacion,
                'id_estado', v_id_estado,
                'portada', v_portada,
                'modulos',  JSON_EXTRACT(IFNULL(@modulos_json, JSON_ARRAY()), '$')
            )
        );
    END LOOP;

    CLOSE cur;
    COMMIT;

    SET v_salida = JSON_OBJECT(
        'status', 'OK',
        'message', 'Cursos no inscritos obtenidos correctamente',
        'data', JSON_EXTRACT(v_resultado, '$')
    );
END$$

CREATE DEFINER=`u205414965_admin`@`127.0.0.1` PROCEDURE `sp_get_foro_pregunta_por_curso` (IN `v_data` JSON, OUT `v_salida` JSON)   BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE v_id_curso INT;
    DECLARE v_id_usuario INT;
    DECLARE v_id_grupo INT;

    DECLARE v_id_pregunta INT;
    DECLARE v_titulo VARCHAR(255);
    DECLARE v_contenido TEXT;
    DECLARE v_id_usuario_preg INT;
    DECLARE v_fecha_creacion DATETIME;
    DECLARE v_autor_preg VARCHAR(255);
    
      DECLARE v_id_leccion INT;
        DECLARE v_id_subleccion INT;
      

    DECLARE v_respuestas JSON;
    DECLARE v_resultado JSON DEFAULT JSON_ARRAY();

    -- === Cursor: Preguntas del foro por curso ===
    DECLARE cur CURSOR FOR
        SELECT 
            p.id_pregunta,
            p.titulo,
            p.contenido,
            p.id_usuario,
            p.fecha_creacion,
            CONCAT(u.nombre, ' ', u.apellido) AS autor_preg
        FROM foro_preguntas p
        INNER JOIN usuarios u ON u.id_usuario = p.id_usuario
        WHERE p.id_curso = v_id_curso and p.id_leccion = v_id_leccion
        ORDER BY p.fecha_creacion ASC;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    -- === Iniciar Transacción ===
    START TRANSACTION;

    -- === Extraer parámetros del JSON de entrada ===
    SET v_id_curso   = CAST(JSON_UNQUOTE(JSON_EXTRACT(v_data, '$.id_curso')) AS UNSIGNED);
    SET v_id_usuario = CAST(JSON_UNQUOTE(JSON_EXTRACT(v_data, '$.id_usuario')) AS UNSIGNED);
    SET v_id_leccion = CAST(JSON_UNQUOTE(JSON_EXTRACT(v_data, '$.id_leccion')) AS UNSIGNED);
    SET v_id_subleccion = CAST(JSON_UNQUOTE(JSON_EXTRACT(v_data, '$.id_subleccion')) AS UNSIGNED);

    -- === Obtener grupo del usuario ===
    SELECT id_grupo INTO v_id_grupo
    FROM grupo_usuarios
    WHERE id_usuario = v_id_usuario
    LIMIT 1;

    -- === Recorrer preguntas del curso ===
    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO v_id_pregunta, v_titulo, v_contenido, v_id_usuario_preg, v_fecha_creacion, v_autor_preg;
        IF done THEN LEAVE read_loop; END IF;

        -- === Obtener respuestas (solo del grupo del usuario) ===
        SET v_respuestas = (
            SELECT JSON_ARRAYAGG(
                JSON_OBJECT(
                    'id_respuesta', r.id_respuesta,
                    'autor', CONCAT(ur.nombre,' ',ur.apellido),
                    'contenido', r.contenido,
                    'fecha', r.fecha_creacion,
                    'comentarios', IFNULL((
                        SELECT JSON_ARRAYAGG(
                            JSON_OBJECT(
                                'id_comentario', c.id_comentario,
                                'autor', CONCAT(uc.nombre,' ',uc.apellido),
                                'contenido', c.contenido,
                                'fecha', c.fecha_creacion
                            )
                        )
                        FROM foro_comentarios c
                        INNER JOIN usuarios uc ON uc.id_usuario = c.id_usuario
                        WHERE c.id_respuesta = r.id_respuesta
                    ), JSON_ARRAY())
                )
            )
            FROM foro_respuestas r
            INNER JOIN usuarios ur ON ur.id_usuario = r.id_usuario
            WHERE r.id_pregunta = v_id_pregunta
              AND r.id_grupo = v_id_grupo
            ORDER BY r.fecha_creacion ASC
        );

        -- === Agregar pregunta al resultado ===
        SET v_resultado = JSON_ARRAY_APPEND(v_resultado, '$',
            JSON_OBJECT(
                'id_pregunta', v_id_pregunta,
                'titulo', v_titulo,
                'contenido', v_contenido,
                'autor', v_autor_preg,
                'fecha', v_fecha_creacion,
                'respuestas', JSON_EXTRACT(v_respuestas, '$')
            )
        );

    END LOOP;
    CLOSE cur;

    COMMIT;

    -- === Salida final ===
    SET v_salida = JSON_OBJECT(
        'status', 'OK',
        'message', 'Preguntas obtenidas correctamente',
        'data', JSON_EXTRACT(v_resultado, '$')
    );
END$$

CREATE DEFINER=`u205414965_admin`@`127.0.0.1` PROCEDURE `sp_get_inscripciones` ()   BEGIN
    SELECT 
        i.id_inscripcion,
        i.fecha_inscripcion,
        u.id_usuario,
        u.nombre AS nombre_usuario,
        c.id_curso,
        c.titulo AS nombre_curso,
        e.id_estado,
        e.estado_nombre AS estado
    FROM inscripciones i
    INNER JOIN usuarios u ON i.id_usuario = u.id_usuario
    INNER JOIN cursos c ON i.id_curso = c.id_curso
    LEFT JOIN estados_pago e ON e.id_estado = c.id_estado;
END$$

CREATE DEFINER=`u205414965_admin`@`127.0.0.1` PROCEDURE `sp_get_metodos_pago` ()   BEGIN
    SELECT * FROM metodos_pago;
END$$

CREATE DEFINER=`u205414965_admin`@`127.0.0.1` PROCEDURE `sp_get_pagos` ()   BEGIN
    SELECT 
        p.id_pago,
        p.monto,
        p.fecha,
        m.metodo_nombre AS metodo_pago,
        e.estado_nombre AS estado_pago,
        i.id_inscripcion,
        u.nombre AS usuario,
        c.titulo AS curso
    FROM pagos p
    INNER JOIN metodos_pago m ON p.id_metodo = m.id_metodo
    INNER JOIN estados_pago e ON p.id_estado = e.id_estado
    INNER JOIN inscripciones i ON p.id_inscripcion = i.id_inscripcion
    INNER JOIN usuarios u ON i.id_usuario = u.id_usuario
    INNER JOIN cursos c ON i.id_curso = c.id_curso;
END$$

CREATE DEFINER=`u205414965_admin`@`127.0.0.1` PROCEDURE `sp_get_usuario_by_correo` (IN `v_data` JSON, OUT `v_salida` JSON)   BEGIN
    DECLARE v_correo VARCHAR(150);
    DECLARE v_resultado JSON DEFAULT NULL;

    -- Manejo de errores
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            @p_message = MESSAGE_TEXT;
        SET v_salida = JSON_OBJECT(
            'status', 'ERROR',
            'message', CONCAT('Error al buscar usuario por correo: ', @p_message),
            'data', NULL
        );
        ROLLBACK;
    END;

    -- Extraer correo del JSON
    SET v_correo = JSON_UNQUOTE(JSON_EXTRACT(v_data, '$.correo'));

    -- Buscar usuario
    SELECT JSON_OBJECT(
        'id_usuario', u.id_usuario,
        'nombre', u.nombre,
        'apellido', u.apellido,
        'correo', u.correo,
        'contrasena', u.contrasena,
        'fecha_nacimiento', u.fecha_nacimiento,
        'edad', u.edad,
        'id_genero', u.id_genero,
        'telefono', u.telefono,
        'direccion', u.direccion,
        'id_rol', u.id_rol,
        'fecha_registro', u.fecha_registro,
        'id_estado', u.id_estado
    )
    INTO v_resultado
    FROM usuarios u
    WHERE u.correo = v_correo COLLATE utf8mb4_unicode_ci
    LIMIT 1;

    IF v_resultado IS NULL THEN
        SET v_salida = JSON_OBJECT(
            'status', 'ERROR',
            'message', 'Usuario no encontrado.',
            'data', NULL
        );
    ELSE
        SET v_salida = JSON_OBJECT(
            'status', 'OK',
            'message', 'Usuario encontrado.',
            'data', JSON_EXTRACT(v_resultado, '$')
        );
    END IF;
END$$

CREATE DEFINER=`u205414965_admin`@`127.0.0.1` PROCEDURE `sp_insert_categoria` (IN `v_data` JSON, OUT `v_salida` JSON)   BEGIN
    DECLARE v_nombre VARCHAR(255);
    SET v_nombre = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.nombre'));
    INSERT INTO categorias (nombre) VALUES (v_nombre);
    SET v_salida = JSON_OBJECT('status','OK','message','Categoría creada','data',JSON_OBJECT('id_categoria',LAST_INSERT_ID()));
END$$

CREATE DEFINER=`u205414965_admin`@`127.0.0.1` PROCEDURE `sp_insert_curso` (IN `v_data` JSON, OUT `v_salida` JSON)   BEGIN
    DECLARE v_titulo VARCHAR(255);
    DECLARE v_descripcion TEXT;
    DECLARE v_precio DECIMAL(10,2);
    DECLARE v_id_estado INT;
    DECLARE v_portada TEXT;

    DECLARE v_resultado JSON DEFAULT JSON_ARRAY();

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @msg = MESSAGE_TEXT;
        SET v_salida = JSON_OBJECT('status','ERROR','message',CONCAT('Error al insertar curso: ',@msg),'data',NULL);
        ROLLBACK;
    END;

    SET v_titulo       = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.titulo'));
    SET v_descripcion  = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.descripcion'));
    SET v_precio       = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.precio'));
    SET v_id_estado    = IFNULL(JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_estado')),1);
    SET v_portada      = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.portada'));

    START TRANSACTION;
    INSERT INTO cursos(titulo,descripcion,precio,fecha_creacion,id_estado, portada)
    VALUES(v_titulo,v_descripcion,v_precio,NOW(),v_id_estado,v_portada);
    COMMIT;

    SET v_salida = JSON_OBJECT('status','OK','message','Curso creado correctamente','data',JSON_OBJECT('id_curso',LAST_INSERT_ID()));
END$$

CREATE DEFINER=`u205414965_admin`@`127.0.0.1` PROCEDURE `sp_insert_evidencia` (IN `v_data` JSON, OUT `v_salida` JSON)   BEGIN
    DECLARE v_id_leccion INT;
    DECLARE v_id_subleccion INT;
    DECLARE v_titulo VARCHAR(255);
    DECLARE v_descripcion TEXT;
    DECLARE v_id_tipo INT;

    SET v_id_leccion    = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_leccion'));
    SET v_id_subleccion = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_subleccion'));
    SET v_titulo        = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.titulo'));
    SET v_descripcion   = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.descripcion'));
    SET v_id_tipo       = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_tipo'));

    INSERT INTO evidencias (id_leccion, id_subleccion, titulo, descripcion, id_tipo)
    VALUES (v_id_leccion, v_id_subleccion, v_titulo, v_descripcion, v_id_tipo);

    SET v_salida = JSON_OBJECT('status','OK','message','Evidencia creada','data',JSON_OBJECT('id_evidencia',LAST_INSERT_ID()));
END$$

CREATE DEFINER=`u205414965_admin`@`127.0.0.1` PROCEDURE `sp_insert_foro_comentario` (IN `v_data` JSON, OUT `v_salida` JSON)   BEGIN
    DECLARE v_id_respuesta INT;
    DECLARE v_id_pregunta INT;
    DECLARE v_id_usuario INT;
    DECLARE v_contenido TEXT;
    DECLARE v_payload JSON;
    DECLARE v_last_id INT;
    DECLARE v_id_evidencia INT;
    DECLARE v_tiene_respuesta INT DEFAULT 0;
    DECLARE v_tiene_comentario INT DEFAULT 0;
    DECLARE v_id_grupo INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            @sqlstate = RETURNED_SQLSTATE,
            @errno = MYSQL_ERRNO,
            @msg = MESSAGE_TEXT;

        SET v_salida = JSON_OBJECT('status','ERROR','message',CONCAT('Error al insertar comentario: ',@msg),'data',NULL);
        ROLLBACK;
    END;

    -- extraer campos
    -- 🔹 Extraer el JSON interno (v_data contiene v_data anidado)
    SET v_payload = JSON_UNQUOTE(JSON_EXTRACT(v_data, '$.v_data'));

    -- 🔹 Extraer campos y convertir a número
    SET v_id_respuesta = CAST(JSON_UNQUOTE(JSON_EXTRACT(v_payload, '$.id_respuesta')) AS UNSIGNED);
    SET v_id_usuario   = CAST(JSON_UNQUOTE(JSON_EXTRACT(v_payload, '$.id_usuario')) AS UNSIGNED);
    SET v_contenido    = JSON_UNQUOTE(JSON_EXTRACT(v_payload, '$.contenido'));


    START TRANSACTION;
    
    INSERT INTO foro_comentarios (id_respuesta, id_usuario, contenido, fecha_creacion, id_estado)
    VALUES (v_id_respuesta, v_id_usuario, v_contenido, CONVERT_TZ(NOW(), '+00:00', '-05:00'), 1);
  
  
    -- 🔹 Obtener el grupo al que pertenece el usuario (puede haber más de uno, tomamos el primero)
    SELECT id_grupo INTO v_id_grupo
    FROM grupo_usuarios
    WHERE id_usuario = v_id_usuario
    LIMIT 1;
    
     -- Obtener id_evidencia del foro
    SELECT fp.id_evidencia , fp.id_pregunta INTO v_id_evidencia, v_id_pregunta
    FROM foro_respuestas fr
    INNER JOIN foro_preguntas fp ON fr.id_pregunta = fp.id_pregunta
    WHERE fr.id_respuesta = v_id_respuesta;
    
    -- Verificar si el usuario respondió la pregunta
    SELECT COUNT(*) INTO v_tiene_respuesta
    FROM foro_respuestas
    WHERE id_pregunta = v_id_pregunta
      AND id_usuario = v_id_usuario AND id_grupo = v_id_grupo
      AND id_estado = 1;
  
    -- Verificar si el usuario comentó en una respuesta de otro usuario
     SELECT COUNT(*) INTO v_tiene_comentario
        FROM foro_comentarios c
        INNER JOIN foro_respuestas r ON c.id_respuesta = r.id_respuesta
        INNER JOIN foro_preguntas p ON r.id_pregunta = p.id_pregunta
        WHERE c.id_usuario = v_id_usuario
          AND r.id_usuario <> v_id_usuario 
          AND c.id_estado = 1
          AND p.id_evidencia = v_id_evidencia AND r.id_grupo = v_id_grupo;

 -- Si cumple ambas condiciones, actualizar resultados
    IF v_tiene_respuesta > 0 AND v_tiene_comentario > 0 THEN
    
    	IF EXISTS (
            SELECT 1 FROM resultados
            WHERE id_usuario = v_id_usuario AND id_evidencia = v_id_evidencia
        ) THEN
            UPDATE resultados
            SET nota = 5,  -- o el valor que quieras asignar
                fecha = NOW()
            WHERE id_usuario = v_id_usuario AND id_evidencia = v_id_evidencia;
        ELSE
            INSERT INTO resultados (id_evidencia, id_usuario, nota, fecha)
            VALUES (v_id_evidencia, v_id_usuario, 5, NOW());
        END IF;
    
    END IF;



    SET v_last_id = LAST_INSERT_ID();

    COMMIT;

    SET v_salida = JSON_OBJECT('status','OK','message','Comentario agregado correctamente','data', JSON_OBJECT('id_comentario', v_last_id));


END$$

CREATE DEFINER=`u205414965_admin`@`127.0.0.1` PROCEDURE `sp_insert_foro_pregunta_admin` (IN `v_data` JSON, OUT `v_salida` JSON)   BEGIN
    DECLARE v_id_curso INT;
    DECLARE v_id_leccion INT;
    DECLARE v_id_evidencia INT;
    DECLARE v_id_usuario INT;
    DECLARE v_titulo VARCHAR(255);
    DECLARE v_contenido TEXT;

    SET v_id_curso     = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_curso'));
    SET v_id_leccion   = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_leccion'));
    SET v_id_evidencia = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_evidencia'));
    SET v_id_usuario   = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_usuario'));
    SET v_titulo      = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.titulo'));
    SET v_contenido   = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.contenido'));

    INSERT INTO foro_preguntas (id_curso, id_leccion, id_evidencia, id_usuario, titulo, contenido)
    VALUES (v_id_curso, v_id_leccion, v_id_evidencia, v_id_usuario, v_titulo, v_contenido);

    SET v_salida = JSON_OBJECT('status','OK','message','Pregunta de foro creada');
END$$

CREATE DEFINER=`u205414965_admin`@`127.0.0.1` PROCEDURE `sp_insert_foro_respuesta` (IN `v_data` JSON, OUT `v_salida` JSON)   BEGIN
    DECLARE v_id_pregunta INT;
    DECLARE v_id_usuario INT;
    DECLARE v_contenido TEXT;
    DECLARE v_last_id INT;
    DECLARE v_payload JSON;
    DECLARE v_id_evidencia INT;
    DECLARE v_tiene_respuesta INT DEFAULT 0;
    DECLARE v_tiene_comentario INT DEFAULT 0;
    DECLARE v_id_grupo INT DEFAULT NULL;  

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            @sqlstate = RETURNED_SQLSTATE,
            @errno = MYSQL_ERRNO,
            @msg = MESSAGE_TEXT;

        SET v_salida = JSON_OBJECT('status','ERROR','message',CONCAT('Error al insertar respuesta: ',@msg),'data',NULL);
        ROLLBACK;
    END;

    -- extraer campos
  
    SET v_payload =     JSON_UNQUOTE(JSON_EXTRACT(v_data, '$.v_data'));
    SET v_id_pregunta = CAST(JSON_UNQUOTE(JSON_EXTRACT(v_payload, '$.id_pregunta')) AS UNSIGNED);
    SET v_id_usuario  = CAST(JSON_UNQUOTE(JSON_EXTRACT(v_payload, '$.id_usuario')) AS UNSIGNED);
    
    SET v_contenido   = JSON_UNQUOTE(JSON_EXTRACT(v_payload, '$.respuesta'));


    START TRANSACTION;
    
    -- Obtener id_evidencia del foro
    SELECT id_evidencia INTO v_id_evidencia
    FROM foro_preguntas
    WHERE id_pregunta = v_id_pregunta;
    
    
    -- 🔹 Obtener el grupo al que pertenece el usuario (puede haber más de uno, tomamos el primero)
    SELECT id_grupo INTO v_id_grupo
    FROM grupo_usuarios
    WHERE id_usuario = v_id_usuario
    LIMIT 1;

   INSERT INTO foro_respuestas (id_pregunta, id_usuario, id_grupo, contenido, fecha_creacion, id_estado)
   VALUES (v_id_pregunta, v_id_usuario, v_id_grupo, v_contenido, CONVERT_TZ(NOW(), '+00:00', '-05:00'), 1);
    
    
    -- Verificar si el usuario respondió la pregunta
    SELECT COUNT(*) INTO v_tiene_respuesta
    FROM foro_respuestas
    WHERE id_pregunta = v_id_pregunta
      AND id_usuario = v_id_usuario AND id_grupo = v_id_grupo
      AND id_estado = 1;

    -- Verificar si el usuario comentó en una respuesta de otro usuario
     SELECT COUNT(*) INTO v_tiene_comentario
        FROM foro_comentarios c
        INNER JOIN foro_respuestas r ON c.id_respuesta = r.id_respuesta
        INNER JOIN foro_preguntas p ON r.id_pregunta = p.id_pregunta
        WHERE c.id_usuario = v_id_usuario
          AND r.id_usuario <> v_id_usuario
          AND c.id_estado = 1
          AND p.id_evidencia = v_id_evidencia AND r.id_grupo = v_id_grupo;

    
    
   -- Si cumple ambas condiciones, actualizar resultados
    IF v_tiene_respuesta > 0 AND v_tiene_comentario > 0 THEN
    
    	IF EXISTS (
            SELECT 1 FROM resultados
            WHERE id_usuario = v_id_usuario AND id_evidencia = v_id_evidencia
        ) THEN
            UPDATE resultados
            SET nota = 5,  -- o el valor que quieras asignar
                fecha = NOW()
            WHERE id_usuario = v_id_usuario AND id_evidencia = v_id_evidencia;
        ELSE
            INSERT INTO resultados (id_evidencia, id_usuario, nota, fecha)
            VALUES (v_id_evidencia, v_id_usuario, 5, NOW());
        END IF;
    
    END IF;
    
    


   SET v_last_id = LAST_INSERT_ID();

    COMMIT;

    SET v_salida = JSON_OBJECT('status','OK','message','Respuesta registrada correctamente','data', JSON_OBJECT('id_respuesta', v_last_id));


END$$

CREATE DEFINER=`u205414965_admin`@`127.0.0.1` PROCEDURE `sp_insert_inscripcion` (IN `p_id_usuario` INT, IN `p_id_curso` INT, IN `p_fecha_inscripcion` TIMESTAMP)   BEGIN
    INSERT INTO inscripciones (id_usuario, id_curso, fecha_inscripcion)
    VALUES (p_id_usuario, p_id_curso, p_fecha_inscripcion);
END$$

CREATE DEFINER=`u205414965_admin`@`127.0.0.1` PROCEDURE `sp_insert_leccion` (IN `v_data` JSON, OUT `v_salida` JSON)   BEGIN
    DECLARE v_id_leccion INT;
    DECLARE v_id_modulo INT;
    DECLARE v_titulo VARCHAR(255);
    DECLARE v_descripcion TEXT;
    DECLARE v_duracion INT;
    DECLARE v_orden INT;
    DECLARE v_id_estado INT;
    DECLARE v_resultado JSON DEFAULT JSON_ARRAY();

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @msg = MESSAGE_TEXT;
        SET v_salida = JSON_OBJECT('status','ERROR','message',CONCAT('Error al crear lección: ',@msg),'data',NULL);
        ROLLBACK;
    END;

    -- Extraer valores del JSON
    SET v_id_modulo    = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_modulo'));
    SET v_titulo       = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.titulo'));
    SET v_descripcion  = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.descripcion'));
    SET v_duracion     = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.duracion'));
    SET v_orden        = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.orden'));
    SET v_id_estado    = IFNULL(JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_estado')),1);

    START TRANSACTION;
        INSERT INTO lecciones (id_modulo, titulo, descripcion, duracion, orden, id_estado)
        VALUES (v_id_modulo, v_titulo, v_descripcion, v_duracion, v_orden, v_id_estado);
        SET v_id_leccion = LAST_INSERT_ID();
    COMMIT;

    SET v_salida = JSON_OBJECT(
        'status','OK',
        'message','Lección creada correctamente',
        'data',JSON_OBJECT('id_leccion',v_id_leccion)
    );
END$$

CREATE DEFINER=`u205414965_admin`@`127.0.0.1` PROCEDURE `sp_insert_metodo_pago` (IN `p_metodo_nombre` VARCHAR(50))   BEGIN
    INSERT INTO metodos_pago (metodo_nombre)
    VALUES (p_metodo_nombre);
END$$

CREATE DEFINER=`u205414965_admin`@`127.0.0.1` PROCEDURE `sp_insert_modulo` (IN `v_data` JSON, OUT `v_salida` JSON)   BEGIN
    DECLARE v_id_modulo INT;
    DECLARE v_id_curso INT;
    DECLARE v_id_docente INT;
    DECLARE v_titulo VARCHAR(255);
    DECLARE v_descripcion TEXT;
    DECLARE v_orden INT;
    DECLARE v_id_estado INT;
    DECLARE v_resultado JSON DEFAULT JSON_ARRAY();

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @msg = MESSAGE_TEXT;
        SET v_salida = JSON_OBJECT('status','ERROR','message',CONCAT('Error al crear módulo: ',@msg),'data',NULL);
        ROLLBACK;
    END;

    -- Extraer valores del JSON
    SET v_id_curso     = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_curso'));
    SET v_id_docente   = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_docente'));
    SET v_titulo       = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.titulo'));
    SET v_descripcion  = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.descripcion'));
    SET v_orden        = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.orden'));
    SET v_id_estado    = IFNULL(JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_estado')),1);

    START TRANSACTION;
        INSERT INTO modulos (id_curso, id_docente, titulo, descripcion, orden, id_estado)
        VALUES (v_id_curso, v_id_docente, v_titulo, v_descripcion, v_orden, v_id_estado);
        SET v_id_modulo = LAST_INSERT_ID();
    COMMIT;

    SET v_salida = JSON_OBJECT(
        'status','OK',
        'message','Módulo creado correctamente',
        'data',JSON_OBJECT('id_modulo',v_id_modulo)
    );
END$$

CREATE DEFINER=`u205414965_admin`@`127.0.0.1` PROCEDURE `sp_insert_pago` (IN `p_id_inscripcion` INT, IN `p_monto` DECIMAL(10,2), IN `p_fecha` TIMESTAMP, IN `p_id_metodo` INT, IN `p_id_estado` INT)   BEGIN
    INSERT INTO pagos (id_inscripcion, monto, fecha, id_metodo, id_estado)
    VALUES (p_id_inscripcion, p_monto, p_fecha, p_id_metodo, p_id_estado);
END$$

CREATE DEFINER=`u205414965_admin`@`127.0.0.1` PROCEDURE `sp_insert_quiz` (IN `v_data` JSON, OUT `v_salida` JSON)   BEGIN
    DECLARE v_id_evidencia INT;
    DECLARE v_id_subleccion INT;
    DECLARE v_titulo VARCHAR(255);
    DECLARE v_descripcion TEXT;

    SET v_id_evidencia  = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_evidencia'));
    SET v_id_subleccion = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_subleccion'));
    SET v_titulo        = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.titulo'));
    SET v_descripcion   = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.descripcion'));

    INSERT INTO quiz (id_evidencia, id_subleccion, titulo, descripcion)
    VALUES (v_id_evidencia, v_id_subleccion, v_titulo, v_descripcion);

    SET v_salida = JSON_OBJECT('status','OK','message','Quiz creado','data',JSON_OBJECT('id_quiz',LAST_INSERT_ID()));
END$$

CREATE DEFINER=`u205414965_admin`@`127.0.0.1` PROCEDURE `sp_insert_quiz_pregunta` (IN `v_data` JSON, OUT `v_salida` JSON)   BEGIN
    DECLARE v_id_quiz INT;
    DECLARE v_pregunta TEXT;
    DECLARE v_opcion_a VARCHAR(255);
    DECLARE v_opcion_b VARCHAR(255);
    DECLARE v_opcion_c VARCHAR(255);
    DECLARE v_opcion_d VARCHAR(255);
    DECLARE v_correcta CHAR(1);

    SET v_id_quiz  = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_quiz'));
    SET v_pregunta = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.pregunta'));
    SET v_opcion_a = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.opcion_a'));
    SET v_opcion_b = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.opcion_b'));
    SET v_opcion_c = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.opcion_c'));
    SET v_opcion_d = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.opcion_d'));
    SET v_correcta = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.correcta'));

    INSERT INTO quiz_preguntas (id_quiz, pregunta, opcion_a, opcion_b, opcion_c, opcion_d, correcta)
    VALUES (v_id_quiz, v_pregunta, v_opcion_a, v_opcion_b, v_opcion_c, v_opcion_d, v_correcta);

    SET v_salida = JSON_OBJECT('status','OK','message','Pregunta de quiz agregada');
END$$

CREATE DEFINER=`u205414965_admin`@`127.0.0.1` PROCEDURE `sp_insert_subleccion` (IN `v_data` JSON, OUT `v_salida` JSON)   BEGIN
    DECLARE v_id_subleccion INT;
    DECLARE v_id_leccion INT;
    DECLARE v_titulo VARCHAR(255);
    DECLARE v_contenido TEXT;
    DECLARE v_video_url VARCHAR(500);
    DECLARE v_orden INT;
    DECLARE v_id_estado INT;
    DECLARE v_resultado JSON DEFAULT JSON_ARRAY();

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @msg = MESSAGE_TEXT;
        SET v_salida = JSON_OBJECT('status','ERROR','message',CONCAT('Error al crear sublección: ',@msg),'data',NULL);
        ROLLBACK;
    END;

    -- Extraer datos del JSON
    SET v_id_leccion = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_leccion'));
    SET v_titulo     = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.titulo'));
    SET v_contenido  = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.contenido'));
    SET v_video_url  = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.video_url'));
    SET v_orden      = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.orden'));
    SET v_id_estado  = IFNULL(JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_estado')),1);

    START TRANSACTION;
        INSERT INTO sublecciones (id_leccion, titulo, contenido, video_url, orden, id_estado)
        VALUES (v_id_leccion, v_titulo, v_contenido, v_video_url, v_orden, v_id_estado);
        SET v_id_subleccion = LAST_INSERT_ID();
    COMMIT;

    SET v_salida = JSON_OBJECT(
        'status','OK',
        'message','Sublección creada correctamente',
        'data',JSON_OBJECT('id_subleccion',v_id_subleccion)
    );
END$$

CREATE DEFINER=`u205414965_admin`@`127.0.0.1` PROCEDURE `sp_insert_usuario` (IN `v_data` JSON, OUT `v_salida` JSON)   BEGIN
    DECLARE v_id_usuario INT;
    DECLARE v_nombre VARCHAR(100);
    DECLARE v_apellido VARCHAR(100);
    DECLARE v_correo VARCHAR(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    DECLARE v_contrasena VARCHAR(255);
    DECLARE v_fecha_nacimiento DATE;
    DECLARE v_edad INT;
    DECLARE v_id_genero INT;
    DECLARE v_telefono VARCHAR(20);
    DECLARE v_direccion TEXT;
    DECLARE v_id_rol INT;
    DECLARE v_fecha_registro DATETIME;
    DECLARE v_id_estado INT;
    DECLARE v_count INT DEFAULT 0;

    DECLARE v_resultado JSON DEFAULT JSON_ARRAY();
    DECLARE done INT DEFAULT 0;

    -- Variables para cursor
    DECLARE v_id_usuario_cur INT;
    DECLARE v_correo_cur VARCHAR(150);

    DECLARE cur CURSOR FOR
        SELECT id_usuario, correo FROM usuarios;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    -- Manejo de errores
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            @p_sqlstate = RETURNED_SQLSTATE,
            @p_errno = MYSQL_ERRNO,
            @p_message = MESSAGE_TEXT;

        SET v_salida = JSON_OBJECT(
            'status', 'ERROR',
            'message', CONCAT('Error al crear usuario: ', @p_message),
            'data', NULL
        );
        ROLLBACK;
    END;

    -- Extraer datos del JSON
    SET v_nombre            = JSON_UNQUOTE(JSON_EXTRACT(v_data, '$.nombre'));
    SET v_apellido          = JSON_UNQUOTE(JSON_EXTRACT(v_data, '$.apellido'));
    SET v_correo            = JSON_UNQUOTE(JSON_EXTRACT(v_data, '$.correo'));
    SET v_contrasena        = JSON_UNQUOTE(JSON_EXTRACT(v_data, '$.contrasena'));
    SET v_fecha_nacimiento  = JSON_UNQUOTE(JSON_EXTRACT(v_data, '$.fecha_nacimiento'));
    SET v_edad              = JSON_UNQUOTE(JSON_EXTRACT(v_data, '$.edad'));
    SET v_id_genero         = JSON_UNQUOTE(JSON_EXTRACT(v_data, '$.id_genero'));
    SET v_telefono          = JSON_UNQUOTE(JSON_EXTRACT(v_data, '$.telefono'));
    SET v_direccion         = JSON_UNQUOTE(JSON_EXTRACT(v_data, '$.direccion'));
    SET v_id_rol            = IFNULL(JSON_UNQUOTE(JSON_EXTRACT(v_data, '$.id_rol')), 1);
    SET v_fecha_registro    = IFNULL(JSON_UNQUOTE(JSON_EXTRACT(v_data, '$.fecha_registro')), NOW());
    SET v_id_estado         = IFNULL(JSON_UNQUOTE(JSON_EXTRACT(v_data, '$.id_estado')), 1);

    -- Validar duplicado por correo
    SELECT COUNT(*) INTO v_count
    FROM usuarios
   WHERE correo = v_correo COLLATE utf8mb4_unicode_ci;

    IF v_count > 0 THEN
        SET v_salida = JSON_OBJECT(
            'status', 'ERROR',
            'message', 'El usuario ya está registrado con ese correo',
            'data', NULL
        );
    ELSE
        START TRANSACTION;

        INSERT INTO usuarios (
            nombre, apellido, correo, contrasena, fecha_nacimiento,
            edad, id_genero, telefono, direccion, id_rol,
            fecha_registro, id_estado
        ) VALUES (
            v_nombre, v_apellido, v_correo, v_contrasena, v_fecha_nacimiento,
            v_edad, v_id_genero, v_telefono, v_direccion, v_id_rol,
            v_fecha_registro, v_id_estado
        );

        SET v_id_usuario = LAST_INSERT_ID();

        -- Obtener lista de usuarios actualizada
        OPEN cur;

        read_loop: LOOP
            FETCH cur INTO v_id_usuario_cur, v_correo_cur;
            IF done THEN
                LEAVE read_loop;
            END IF;

            SET v_resultado = JSON_ARRAY_APPEND(
                v_resultado, '$',
                JSON_OBJECT(
                    'id_usuario', v_id_usuario_cur,
                    'correo', v_correo_cur
                )
            );
        END LOOP;

        CLOSE cur;

        COMMIT;

        SET v_salida = JSON_OBJECT(
            'status', 'OK',
            'message', 'Usuario creado con éxito',
            'data', JSON_EXTRACT(v_resultado, '$')
        );
    END IF;
END$$

CREATE DEFINER=`u205414965_admin`@`127.0.0.1` PROCEDURE `sp_update_categoria` (IN `v_data` JSON, OUT `v_salida` JSON)   BEGIN
    DECLARE v_id INT;
    DECLARE v_nombre VARCHAR(255);
    SET v_id = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_categoria'));
    SET v_nombre = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.nombre'));
    UPDATE categorias SET nombre = v_nombre WHERE id_categoria = v_id;
    SET v_salida = JSON_OBJECT('status','OK','message','Categoría actualizada');
END$$

CREATE DEFINER=`u205414965_admin`@`127.0.0.1` PROCEDURE `sp_update_curso` (IN `v_data` JSON, OUT `v_salida` JSON)   BEGIN
    DECLARE v_id_curso INT;
    DECLARE v_titulo VARCHAR(255);
    DECLARE v_descripcion TEXT;
    DECLARE v_precio DECIMAL(10,2);
    DECLARE v_id_estado INT;
    DECLARE v_portada TEXT;
    DECLARE v_id_categoria INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @msg = MESSAGE_TEXT;
        SET v_salida = JSON_OBJECT('status','ERROR','message',CONCAT('Error al actualizar curso: ',@msg),'data',NULL);
        ROLLBACK;
    END;

    SET v_id_curso     = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_curso'));
    SET v_titulo       = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.titulo'));
    SET v_descripcion  = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.descripcion'));
    SET v_precio       = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.precio'));
    SET v_id_estado    = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_estado'));
    SET v_portada      = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.portada'));
    SET v_id_categoria = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_categoria'));

    START TRANSACTION;
    UPDATE cursos 
    SET titulo = v_titulo, 
        descripcion = v_descripcion, 
        precio = v_precio, 
        id_estado = v_id_estado, 
        portada = v_portada,
        id_categoria = v_id_categoria
    WHERE id_curso = v_id_curso;
    COMMIT;

    SET v_salida = JSON_OBJECT('status','OK','message','Curso actualizado correctamente','data',JSON_OBJECT('id_curso',v_id_curso));
END$$

CREATE DEFINER=`u205414965_admin`@`127.0.0.1` PROCEDURE `sp_update_leccion` (IN `v_data` JSON, OUT `v_salida` JSON)   BEGIN
    DECLARE v_id_leccion INT;
    DECLARE v_titulo VARCHAR(255);
    DECLARE v_descripcion TEXT;
    DECLARE v_duracion INT;
    DECLARE v_orden INT;
    DECLARE v_id_estado INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @msg = MESSAGE_TEXT;
        SET v_salida = JSON_OBJECT('status','ERROR','message',CONCAT('Error al actualizar lección: ',@msg),'data',NULL);
        ROLLBACK;
    END;

    SET v_id_leccion   = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_leccion'));
    SET v_titulo      = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.titulo'));
    SET v_descripcion = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.descripcion'));
    SET v_duracion    = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.duracion'));
    SET v_orden       = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.orden'));
    SET v_id_estado   = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_estado'));

    START TRANSACTION;
    UPDATE lecciones 
    SET titulo = v_titulo,
        descripcion = v_descripcion,
        duracion = v_duracion,
        orden = v_orden,
        id_estado = v_id_estado
    WHERE id_leccion = v_id_leccion;
    COMMIT;

    SET v_salida = JSON_OBJECT('status','OK','message','Lección actualizada correctamente');
END$$

CREATE DEFINER=`u205414965_admin`@`127.0.0.1` PROCEDURE `sp_update_modulo` (IN `v_data` JSON, OUT `v_salida` JSON)   BEGIN
    DECLARE v_id_modulo INT;
    DECLARE v_id_docente INT;
    DECLARE v_titulo VARCHAR(255);
    DECLARE v_descripcion TEXT;
    DECLARE v_orden INT;
    DECLARE v_id_estado INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @msg = MESSAGE_TEXT;
        SET v_salida = JSON_OBJECT('status','ERROR','message',CONCAT('Error al actualizar módulo: ',@msg),'data',NULL);
        ROLLBACK;
    END;

    SET v_id_modulo   = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_modulo'));
    SET v_id_docente  = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_docente'));
    SET v_titulo      = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.titulo'));
    SET v_descripcion = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.descripcion'));
    SET v_orden       = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.orden'));
    SET v_id_estado   = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_estado'));

    START TRANSACTION;
    UPDATE modulos 
    SET id_docente = v_id_docente,
        titulo = v_titulo,
        descripcion = v_descripcion,
        orden = v_orden,
        id_estado = v_id_estado
    WHERE id_modulo = v_id_modulo;
    COMMIT;

    SET v_salida = JSON_OBJECT('status','OK','message','Módulo actualizado correctamente');
END$$

CREATE DEFINER=`u205414965_admin`@`127.0.0.1` PROCEDURE `sp_update_subleccion` (IN `v_data` JSON, OUT `v_salida` JSON)   BEGIN
    DECLARE v_id_subleccion INT;
    DECLARE v_titulo VARCHAR(255);
    DECLARE v_url_recurso VARCHAR(500);
    DECLARE v_orden INT;
    DECLARE v_id_estado INT;
    DECLARE v_tipo VARCHAR(50);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @msg = MESSAGE_TEXT;
        SET v_salida = JSON_OBJECT('status','ERROR','message',CONCAT('Error al actualizar sublección: ',@msg),'data',NULL);
        ROLLBACK;
    END;

    SET v_id_subleccion = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_subleccion'));
    SET v_titulo        = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.titulo'));
    SET v_url_recurso   = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.url_recurso'));
    SET v_orden         = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.orden'));
    SET v_id_estado     = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_estado'));
    SET v_tipo          = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.tipo'));

    START TRANSACTION;
    UPDATE sublecciones 
    SET titulo = v_titulo,
        url_recurso = v_url_recurso,
        orden = v_orden,
        id_estado = v_id_estado,
        tipo = v_tipo
    WHERE id_subleccion = v_id_subleccion;
    COMMIT;

    SET v_salida = JSON_OBJECT('status','OK','message','Sublección actualizada correctamente');
END$$

CREATE DEFINER=`u205414965_admin`@`127.0.0.1` PROCEDURE `sp_update_usuario_rol` (IN `v_data` JSON, OUT `v_salida` JSON)   BEGIN
    DECLARE v_id_usuario INT;
    DECLARE v_id_rol INT;

    SET v_id_usuario = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_usuario'));
    SET v_id_rol     = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_rol'));

    UPDATE usuarios SET id_rol = v_id_rol WHERE id_usuario = v_id_usuario;

    SET v_salida = JSON_OBJECT('status','OK','message','Rol de usuario actualizado correctamente');
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `categorias`
--

CREATE TABLE `categorias` (
  `id_categoria` int(11) NOT NULL,
  `nombre` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `categorias`
--

INSERT INTO `categorias` (`id_categoria`, `nombre`) VALUES
(1, 'Diseño Web'),
(2, 'Desarrollo Web'),
(3, 'Freelance'),
(4, 'Marketing'),
(5, 'Meditación'),
(6, 'Música'),
(7, 'Escuela Bíblica Integral');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `categorias_productos`
--

CREATE TABLE `categorias_productos` (
  `id` int(11) NOT NULL,
  `nombre` varchar(45) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `categorias_productos`
--

INSERT INTO `categorias_productos` (`id`, `nombre`) VALUES
(1, 'Games'),
(2, 'Corportivo'),
(3, 'Desarrollo');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cursos`
--

CREATE TABLE `cursos` (
  `id_curso` int(11) NOT NULL,
  `titulo` varchar(255) NOT NULL,
  `descripcion` text NOT NULL,
  `precio` decimal(10,2) DEFAULT 0.00,
  `fecha_creacion` timestamp NOT NULL DEFAULT current_timestamp(),
  `id_estado` int(11) NOT NULL DEFAULT 3,
  `portada` varchar(500) NOT NULL,
  `id_categoria` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `cursos`
--

INSERT INTO `cursos` (`id_curso`, `titulo`, `descripcion`, `precio`, `fecha_creacion`, `id_estado`, `portada`, `id_categoria`) VALUES
(1, 'Escuela de Formación Bíblica - Paso #1', 'Curso introductorio a la formación bíblica cristiana, con fundamentos esenciales para la fe.', 0.00, '2025-10-13 03:15:51', 2, 'assets/images/course/curso1.jpg\r\n', 7),
(2, 'Escuela Biblica Paso #2', 'Este es un curso introductorio diseñado para fortalecer las bases de la fe cristiana, comprender los principios fundamentales de la Biblia y desarrollar una relación más profunda con Dios a través del estudio y la reflexión.', 30000.00, '2025-10-13 17:07:58', 2, 'assets/images/course/curso2.jpg', 7),
(3, 'Paso 1 – Fundamentos de la Vida Cristiana', 'Descubre el inicio de una nueva vida en Jesús, aprende a crecer en fe, amor y comunidad, y construye una relación real con Dios.', 0.00, '2025-10-21 14:43:12', 1, 'assets/images/course/curso3.png', 7);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `docentes`
--

CREATE TABLE `docentes` (
  `id_docente` int(11) NOT NULL,
  `id_usuario` int(11) NOT NULL,
  `fecha_registro` timestamp NOT NULL DEFAULT current_timestamp(),
  `id_estado` int(11) NOT NULL DEFAULT 3
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `docentes`
--

INSERT INTO `docentes` (`id_docente`, `id_usuario`, `fecha_registro`, `id_estado`) VALUES
(1, 14, '2025-10-22 01:44:01', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `estados`
--

CREATE TABLE `estados` (
  `id_estado` int(11) NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `descripcion` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `estados`
--

INSERT INTO `estados` (`id_estado`, `nombre`, `descripcion`) VALUES
(1, 'activo', 'El registro está activo y funcional.'),
(2, 'inactivo', 'El registro está inhabilitado temporalmente.'),
(3, 'pendiente', 'El registro está en espera de aprobación o acción.');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `estados_pago`
--

CREATE TABLE `estados_pago` (
  `id_estado` int(11) NOT NULL,
  `estado_nombre` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `estados_pago`
--

INSERT INTO `estados_pago` (`id_estado`, `estado_nombre`) VALUES
(2, 'completado'),
(3, 'fallido'),
(1, 'pendiente');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `evidencias`
--

CREATE TABLE `evidencias` (
  `id_evidencia` int(11) NOT NULL,
  `id_leccion` int(11) NOT NULL,
  `id_subleccion` int(11) NOT NULL,
  `titulo` varchar(255) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `fecha` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `id_tipo` int(11) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `evidencias`
--

INSERT INTO `evidencias` (`id_evidencia`, `id_leccion`, `id_subleccion`, `titulo`, `descripcion`, `fecha`, `id_tipo`) VALUES
(1, 2, 3, 'La biblia y su proposito', 'La biblia y su proposito', '2025-10-17 23:06:39', 2),
(2, 3, 5, 'La oracion', 'La oracion', '2025-10-17 23:06:49', 2),
(3, 4, 7, 'La fe en accion', 'La fe en accion', '2025-10-17 23:07:00', 2),
(4, 5, 9, 'El amor cristiano', 'El amor cristiano', '2025-10-17 23:07:17', 2),
(5, 2, 2, 'Foro La biblia y su proposito\r\n', 'Responder el foro y comentar la opinión de uno o más compañeros ', '2025-10-19 23:00:26', 1),
(6, 3, 4, 'Foro La oracion', 'Redactar la repsuesta y comentar en a dos compañeros ', '2025-10-20 02:32:27', 1),
(7, 4, 6, 'Foro La fe en accion', 'Redactar la repsuesta y comentar en a dos compañeros ', '2025-10-20 02:32:58', 1),
(8, 5, 8, 'Foro El amor cristiano', 'Redactar la repsuesta y comentar en a dos compañeros', '2025-10-20 02:33:24', 1),
(9, 7, 16, 'Quiz: Lección 1 ¿Cómo crecer en la vida cristiana?', 'Quiz: Lección 1 ¿Cómo crecer en la vida cristiana?', '2025-10-22 20:51:47', 2),
(10, 7, 17, 'Foro: Lección 1 ¿Cómo crecer en la vida cristiana?', 'Escribe tu respuesta en el foro y comenta la publicación de un compañero, mencionando si estás de acuerdo o qué agregarías a su punto de vista.', '2025-10-22 20:51:58', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `foro_comentarios`
--

CREATE TABLE `foro_comentarios` (
  `id_comentario` int(11) NOT NULL,
  `id_respuesta` int(11) NOT NULL,
  `id_usuario` int(11) NOT NULL,
  `contenido` text NOT NULL,
  `fecha_creacion` timestamp NULL DEFAULT current_timestamp(),
  `id_estado` int(11) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `foro_comentarios`
--

INSERT INTO `foro_comentarios` (`id_comentario`, `id_respuesta`, `id_usuario`, `contenido`, `fecha_creacion`, `id_estado`) VALUES
(1, 3, 10, 'Prueba', '2025-10-15 04:18:56', 1),
(2, 3, 10, 'Prueba 2', '2025-10-15 04:19:06', 1),
(3, 4, 10, 'jjknkj', '2025-10-15 04:21:54', 1),
(4, 1, 10, 'sdfdf', '2025-10-17 21:37:55', 1),
(5, 3, 14, 'interesante', '2025-10-18 21:19:05', 1),
(6, 3, 14, 'Prueba', '2025-10-19 02:49:44', 1),
(7, 9, 10, 'Prueba', '2025-10-19 03:00:26', 1),
(8, 8, 10, 'Prueba', '2025-10-19 03:01:20', 1),
(9, 14, 14, 'gfdghg', '2025-10-20 00:33:51', 1),
(10, 15, 14, 'fghfdgh', '2025-10-20 00:34:07', 1),
(11, 15, 14, 'vbvcbnbn', '2025-10-20 00:34:44', 1),
(12, 14, 14, 'prueba', '2025-10-20 00:39:37', 1),
(13, 17, 10, 'Es importante tenerla presente en nuestra vida diaria', '2025-10-20 02:14:00', 1),
(14, 18, 19, 'Amén', '2025-10-20 02:15:13', 1),
(15, 17, 19, 'Dios es fiel', '2025-10-20 02:17:10', 1),
(16, 18, 19, 'D', '2025-10-20 02:17:18', 1),
(17, 16, 19, 'Zzzx', '2025-10-20 02:21:37', 1),
(18, 15, 19, 'Xxxx', '2025-10-20 02:21:50', 1),
(19, 14, 19, 'Hola', '2025-10-20 02:24:44', 1),
(20, 16, 10, 'Prueba', '2025-10-20 02:44:40', 1),
(21, 17, 15, 'Ok', '2025-10-21 15:03:27', 1),
(22, 23, 10, 'hla', '2025-10-21 10:41:39', 1),
(23, 23, 10, 'Hola', '2025-10-21 21:04:48', 1),
(24, 26, 10, 'Hola', '2025-10-22 08:26:01', 1),
(25, 26, 20, 'Hola', '2025-10-26 15:15:02', 1),
(26, 28, 22, 'Excelente', '2025-11-24 20:11:54', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `foro_preguntas`
--

CREATE TABLE `foro_preguntas` (
  `id_pregunta` int(11) NOT NULL,
  `id_curso` int(11) NOT NULL,
  `id_leccion` int(11) NOT NULL,
  `id_evidencia` int(11) NOT NULL,
  `id_usuario` int(11) NOT NULL,
  `titulo` varchar(255) NOT NULL,
  `contenido` text NOT NULL,
  `fecha_creacion` timestamp NULL DEFAULT current_timestamp(),
  `id_estado` int(11) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `foro_preguntas`
--

INSERT INTO `foro_preguntas` (`id_pregunta`, `id_curso`, `id_leccion`, `id_evidencia`, `id_usuario`, `titulo`, `contenido`, `fecha_creacion`, `id_estado`) VALUES
(1, 1, 4, 7, 10, 'Foro de formacion biblica paso #1', 'En que escenarios de la vida, podria aplicar la fe en accion?', '2025-10-15 01:28:18', 1),
(2, 1, 2, 5, 10, 'En que escenarios de la vida, aplica lo aprendido con la biblia', 'En que escenarios de la vida, aplica lo aprendido con la biblia', '2025-10-19 23:20:29', 1),
(3, 1, 3, 6, 10, 'En que escenarios de la vida, aplica la oracion', 'En que escenarios de la vida, aplica la oracion', '2025-10-19 23:22:31', 1),
(4, 1, 5, 8, 10, 'En que escenarios de la vida, aplica  el amor cristiano', '', '2025-10-19 23:23:05', 1),
(5, 3, 7, 10, 14, 'Según la lección, crecer en la vida cristiana es un proceso que incluye fe, amor, conocimiento y santidad. ¿Cuál de estas áreas consideras más importante para el crecimiento espiritual y por qué?\r\n', 'Escribe tu respuesta en el foro y comenta la publicación de un compañero, mencionando si estás de acuerdo o qué agregarías a su punto de vista.', '2025-10-22 13:09:57', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `foro_respuestas`
--

CREATE TABLE `foro_respuestas` (
  `id_respuesta` int(11) NOT NULL,
  `id_pregunta` int(11) NOT NULL,
  `id_usuario` int(11) NOT NULL,
  `id_grupo` int(11) NOT NULL,
  `contenido` text NOT NULL,
  `fecha_creacion` timestamp NULL DEFAULT current_timestamp(),
  `id_estado` int(11) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `foro_respuestas`
--

INSERT INTO `foro_respuestas` (`id_respuesta`, `id_pregunta`, `id_usuario`, `id_grupo`, `contenido`, `fecha_creacion`, `id_estado`) VALUES
(1, 1, 10, 1, 'Esta es una prueba desde base de datos', '2025-10-15 03:21:18', 1),
(3, 1, 10, 1, 'Prueba desde la app', '2025-10-15 04:08:11', 1),
(4, 1, 10, 1, 'jhvhvj', '2025-10-15 04:21:46', 1),
(5, 1, 10, 1, 'dfdfdf', '2025-10-17 21:37:58', 1),
(6, 1, 15, 1, 'En los momentos difíciles de. La vida', '2025-10-18 22:06:32', 1),
(7, 1, 10, 1, 'Respuesta para validar la calificacion', '2025-10-19 02:26:47', 1),
(8, 1, 14, 1, 'Prueba', '2025-10-19 02:50:02', 1),
(9, 1, 14, 1, 'Prueba', '2025-10-19 02:55:48', 1),
(10, 1, 15, 2, 'Hola buenos día cómo amaneciste cómo estás', '2025-10-19 21:30:19', 1),
(11, 1, 10, 1, 'Prueba nueva', '2025-10-19 23:14:27', 1),
(12, 1, 14, 2, 'prueba', '2025-10-19 23:17:55', 1),
(13, 2, 14, 2, 'prueba', '2025-10-19 23:21:41', 1),
(14, 3, 10, 1, 'Prueba', '2025-10-20 00:32:16', 1),
(15, 3, 10, 1, 'Hola', '2025-10-20 00:33:06', 1),
(16, 3, 14, 1, 'PRueba', '2025-10-20 00:39:10', 1),
(17, 2, 19, 1, 'En mi vida diaria', '2025-10-20 02:12:14', 1),
(18, 2, 10, 1, 'En casa situación que se nos presente', '2025-10-20 02:14:30', 1),
(19, 3, 19, 1, 'Xxx', '2025-10-20 02:20:52', 1),
(20, 3, 19, 1, 'Cxx', '2025-10-20 02:21:26', 1),
(21, 3, 19, 1, 'Prueba', '2025-10-20 02:25:50', 1),
(22, 2, 15, 1, 'En toda mi vida', '2025-10-21 15:03:43', 1),
(23, 2, 10, 1, 'Hola', '2025-10-21 10:41:26', 1),
(24, 3, 10, 1, 'Hola', '2025-10-21 21:05:25', 1),
(25, 5, 10, 1, 'Considero que el amor es el aspecto más importante para el crecimiento espiritual. La fe, el conocimiento y la santidad son fundamentales, pero el amor es el que les da sentido y equilibrio.', '2025-10-22 08:14:33', 1),
(26, 5, 19, 1, 'Xxxxx', '2025-10-22 08:23:23', 1),
(27, 5, 20, 1, 'Prueba', '2025-10-26 15:14:35', 1),
(28, 5, 22, 3, 'Pienso que todas las areas son importantes pero considero que para el crecimiento espiritual es mas importante la fe ya que ella es esa base sobre la que se construyen las demás areas y además sin fe no es posible agradar a Dios y empezar el proceso de transformación yo creo que todas las areas son esenciales e independientes pero la fe es ese motor inicial por que es la que da origen al proceso de crecimiento espiritual', '2025-11-13 17:54:31', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `generos`
--

CREATE TABLE `generos` (
  `id_genero` int(11) NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `descripcion` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `generos`
--

INSERT INTO `generos` (`id_genero`, `nombre`, `descripcion`) VALUES
(1, 'masculino', 'Genero que identifica a los hombres'),
(2, 'Femenino', NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `grupos`
--

CREATE TABLE `grupos` (
  `id_grupo` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `fecha_creacion` datetime DEFAULT current_timestamp(),
  `id_estado` int(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `grupos`
--

INSERT INTO `grupos` (`id_grupo`, `nombre`, `descripcion`, `fecha_creacion`, `id_estado`) VALUES
(1, 'Grupo #1', 'Grupo #1', '2025-10-19 19:53:41', 1),
(2, 'Grupo #2', 'Grupo #2', '2025-10-19 19:58:29', 1),
(3, 'Grupo #3', 'Grupo #3', '2025-11-06 21:38:11', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `grupo_lecciones`
--

CREATE TABLE `grupo_lecciones` (
  `id_grupo` int(11) NOT NULL,
  `id_leccion` int(11) NOT NULL,
  `activo` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `grupo_lecciones`
--

INSERT INTO `grupo_lecciones` (`id_grupo`, `id_leccion`, `activo`) VALUES
(1, 6, 1),
(1, 7, 1),
(3, 6, 1),
(3, 7, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `grupo_usuarios`
--

CREATE TABLE `grupo_usuarios` (
  `id_grupo` int(11) NOT NULL,
  `id_usuario` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `grupo_usuarios`
--

INSERT INTO `grupo_usuarios` (`id_grupo`, `id_usuario`) VALUES
(3, 10),
(1, 14),
(1, 15),
(1, 19),
(1, 20),
(3, 21),
(3, 22),
(3, 23);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `inscripciones`
--

CREATE TABLE `inscripciones` (
  `id_inscripcion` int(11) NOT NULL,
  `id_usuario` int(11) NOT NULL,
  `id_curso` int(11) NOT NULL,
  `fecha_inscripcion` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `inscripciones`
--

INSERT INTO `inscripciones` (`id_inscripcion`, `id_usuario`, `id_curso`, `fecha_inscripcion`) VALUES
(1, 10, 3, '2025-10-13 19:01:26'),
(3, 15, 1, '2025-10-18 22:00:52'),
(4, 14, 1, '2025-10-18 22:22:14'),
(5, 19, 1, '2025-10-20 02:10:12'),
(6, 10, 1, '2025-10-21 15:02:18'),
(7, 15, 3, '2025-10-21 15:02:29'),
(8, 19, 3, '2025-10-22 13:15:28'),
(9, 20, 3, '2025-10-26 20:13:03'),
(10, 21, 3, '2025-11-07 01:17:16'),
(11, 22, 3, '2025-11-07 01:17:27'),
(12, 22, 3, '2025-11-07 01:17:39');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `lecciones`
--

CREATE TABLE `lecciones` (
  `id_leccion` int(11) NOT NULL,
  `id_modulo` int(11) NOT NULL,
  `titulo` varchar(255) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `orden` int(11) DEFAULT NULL,
  `id_estado` int(11) NOT NULL DEFAULT 3
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `lecciones`
--

INSERT INTO `lecciones` (`id_leccion`, `id_modulo`, `titulo`, `descripcion`, `orden`, `id_estado`) VALUES
(1, 1, 'Introducción', 'Bienvenida al curso y orientación general.', 1, 1),
(2, 1, 'La Biblia y su propósito', 'Importancia y propósito de la Palabra de Dios.', 2, 1),
(3, 1, 'La oración', 'Conexión espiritual a través de la oración.', 3, 1),
(4, 1, 'La fe en acción', 'Aplicar la fe en la vida diaria.', 4, 1),
(5, 1, 'El amor cristiano', 'Vivir el amor de Cristo en comunidad.', 5, 1),
(6, 2, 'Introduccion', 'Introduccion', 1, 1),
(7, 2, '¿Cómo crecer en la vida cristiana?', 'Nuevo nacimiento y áreas de crecimiento (fe,\r\namor, conocimiento, santidad).', 2, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `metodos_pago`
--

CREATE TABLE `metodos_pago` (
  `id_metodo` int(11) NOT NULL,
  `metodo_nombre` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `modulos`
--

CREATE TABLE `modulos` (
  `id_modulo` int(11) NOT NULL,
  `id_curso` int(11) NOT NULL,
  `id_docente` int(11) NOT NULL,
  `titulo` varchar(255) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `orden` int(11) DEFAULT NULL,
  `id_estado` int(11) NOT NULL DEFAULT 3
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `modulos`
--

INSERT INTO `modulos` (`id_modulo`, `id_curso`, `id_docente`, `titulo`, `descripcion`, `orden`, `id_estado`) VALUES
(1, 1, 1, 'Fundamentos de la Fe', 'Módulo introductorio sobre los principios básicos de la vida cristiana.', 1, 1),
(2, 3, 1, 'Paso 1 – Fundamentos de la Vida Cristiana', 'Descubre el inicio de una nueva vida en Jesús, aprende a crecer en fe, amor y comunidad, y construye una relación real con Dios.', 1, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pagos`
--

CREATE TABLE `pagos` (
  `id_pago` int(11) NOT NULL,
  `id_inscripcion` int(11) NOT NULL,
  `monto` decimal(10,2) NOT NULL,
  `fecha` timestamp NOT NULL DEFAULT current_timestamp(),
  `id_metodo` int(11) NOT NULL,
  `id_estado` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `productos`
--

CREATE TABLE `productos` (
  `id` int(11) NOT NULL,
  `nombre` varchar(45) DEFAULT NULL,
  `precio` int(11) NOT NULL,
  `fecha_registro` datetime NOT NULL,
  `id_categoria` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `productos`
--

INSERT INTO `productos` (`id`, `nombre`, `precio`, `fecha_registro`, `id_categoria`) VALUES
(4, 'Teclado Razer mecánico', 550, '2025-11-25 00:00:00', 3),
(5, 'Notebook Omen HP', 2900, '2025-11-25 00:00:00', 3),
(6, 'Notebook Omen HP', 2900, '2025-11-25 00:00:00', 3),
(7, 'Notebook Omen HP', 2900, '2025-11-25 00:00:00', 3);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `progreso_curso`
--

CREATE TABLE `progreso_curso` (
  `id_progreso` int(11) NOT NULL,
  `id_usuario` int(11) NOT NULL,
  `id_curso` int(11) NOT NULL,
  `progreso` decimal(5,2) DEFAULT 0.00,
  `fecha_actualizacion` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `progreso_curso`
--

INSERT INTO `progreso_curso` (`id_progreso`, `id_usuario`, `id_curso`, `progreso`, `fecha_actualizacion`) VALUES
(1, 10, 1, 77.00, '2025-10-22 02:04:48'),
(3, 15, 1, 38.00, '2025-10-21 15:02:03'),
(5, 14, 1, 67.00, '2025-10-19 01:32:13'),
(6, 19, 1, 38.00, '2025-10-20 02:19:19'),
(7, 10, 3, 75.00, '2026-05-08 02:30:54'),
(8, 15, 3, 100.00, '2025-10-22 04:33:09'),
(9, 19, 3, 25.00, '2025-10-22 13:23:06'),
(10, 20, 3, 100.00, '2025-10-26 20:15:33'),
(11, 21, 3, 25.00, '2025-11-07 03:33:30'),
(12, 22, 3, 100.00, '2025-11-25 01:11:54');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `progreso_subleccion`
--

CREATE TABLE `progreso_subleccion` (
  `id_progreso` int(11) NOT NULL,
  `id_usuario` int(11) NOT NULL,
  `id_curso` int(11) NOT NULL,
  `id_leccion` int(11) NOT NULL,
  `id_subleccion` int(11) NOT NULL,
  `completado` tinyint(1) DEFAULT 0,
  `fecha_completado` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `progreso_subleccion`
--

INSERT INTO `progreso_subleccion` (`id_progreso`, `id_usuario`, `id_curso`, `id_leccion`, `id_subleccion`, `completado`, `fecha_completado`) VALUES
(1, 10, 1, 1, 1, 1, '2025-10-19 03:06:09'),
(2, 10, 1, 2, 3, 1, '2025-10-22 01:20:55'),
(3, 10, 1, 3, 5, 1, '2025-10-19 02:08:31'),
(4, 10, 1, 2, 2, 1, '2025-10-20 11:49:04'),
(5, 10, 1, 3, 4, 1, '2025-10-18 22:04:52'),
(6, 10, 1, 4, 6, 1, '2025-10-18 22:05:00'),
(7, 10, 1, 5, 9, 1, '2025-10-18 20:29:10'),
(8, 10, 1, 4, 7, 1, '2025-10-18 19:11:33'),
(9, 10, 1, 5, 8, 1, '2025-10-18 19:51:34'),
(10, 10, 1, 5, 8, 1, '2025-10-18 19:51:34'),
(20, 15, 1, 1, 1, 1, '2025-10-21 15:02:04'),
(21, 15, 1, 2, 2, 1, '2025-10-18 22:10:56'),
(22, 15, 1, 3, 4, 1, '2025-10-18 22:13:00'),
(23, 15, 1, 4, 6, 1, '2025-10-18 22:13:33'),
(24, 15, 1, 5, 8, 1, '2025-10-18 22:13:54'),
(25, 14, 1, 1, 1, 1, '2025-10-19 01:32:09'),
(26, 14, 1, 2, 2, 1, '2025-10-19 01:32:10'),
(27, 14, 1, 3, 4, 1, '2025-10-18 22:27:53'),
(28, 14, 1, 4, 6, 1, '2025-10-18 22:28:05'),
(29, 14, 1, 5, 8, 1, '2025-10-18 22:28:16'),
(30, 14, 1, 2, 3, 1, '2025-10-19 01:32:13'),
(31, 19, 1, 1, 1, 1, '2025-10-20 02:10:52'),
(32, 19, 1, 2, 2, 1, '2025-10-20 02:11:09'),
(33, 19, 1, 2, 3, 1, '2025-10-20 02:11:45'),
(34, 19, 1, 3, 4, 1, '2025-10-20 02:18:43'),
(35, 19, 1, 3, 5, 1, '2025-10-20 02:19:19'),
(37, 10, 1, 2, 10, 1, '2025-10-22 02:04:48'),
(38, 15, 3, 6, 14, 1, '2025-10-22 04:33:09'),
(39, 15, 3, 7, 15, 1, '2025-10-22 04:00:27'),
(41, 19, 3, 6, 14, 1, '2025-10-22 13:23:06'),
(44, 20, 3, 6, 14, 1, '2025-10-26 20:15:33'),
(45, 20, 3, 7, 15, 1, '2025-10-26 20:13:45'),
(46, 20, 3, 7, 16, 1, '2025-10-26 20:14:22'),
(47, 20, 3, 7, 17, 1, '2025-10-26 20:15:02'),
(48, 21, 3, 6, 14, 1, '2025-11-07 03:31:24'),
(49, 22, 3, 6, 14, 1, '2025-11-07 01:43:49'),
(50, 10, 3, 6, 14, 1, '2026-05-08 02:30:41'),
(51, 10, 3, 7, 15, 1, '2026-05-08 02:30:54'),
(53, 22, 3, 7, 15, 1, '2025-11-13 21:53:57'),
(54, 22, 3, 7, 16, 1, '2025-11-13 22:00:03'),
(55, 22, 3, 7, 17, 1, '2025-11-25 01:11:54'),
(56, 10, 3, 7, 16, 1, '2026-05-08 00:41:46');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `quiz`
--

CREATE TABLE `quiz` (
  `id_quiz` int(11) NOT NULL,
  `id_evidencia` int(11) NOT NULL,
  `id_subleccion` int(11) NOT NULL,
  `titulo` varchar(255) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `id_estado` int(11) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `quiz`
--

INSERT INTO `quiz` (`id_quiz`, `id_evidencia`, `id_subleccion`, `titulo`, `descripcion`, `id_estado`) VALUES
(1, 1, 3, 'Quiz: La Biblia y su propósito', 'Evaluación sobre la lección 2', 1),
(2, 2, 5, 'Quiz: La oración', 'Evaluación sobre la lección 3', 1),
(3, 3, 7, 'Quiz: La fe en acción', 'Evaluación sobre la lección 4', 1),
(4, 4, 9, 'Quiz: El amor cristiano', 'Evaluación sobre la lección 5', 1),
(5, 9, 16, 'Quiz: Lección 1 ¿Cómo crecer en la vida cristiana?', 'Quiz: Lección 1 ¿Cómo crecer en la vida cristiana?', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `quiz_preguntas`
--

CREATE TABLE `quiz_preguntas` (
  `id_pregunta` int(11) NOT NULL,
  `id_quiz` int(11) NOT NULL,
  `pregunta` text NOT NULL,
  `opcion_a` varchar(255) NOT NULL,
  `opcion_b` varchar(255) NOT NULL,
  `opcion_c` varchar(255) DEFAULT NULL,
  `opcion_d` varchar(255) DEFAULT NULL,
  `correcta` char(1) NOT NULL CHECK (`correcta` in ('A','B','C','D')),
  `id_estado` int(11) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `quiz_preguntas`
--

INSERT INTO `quiz_preguntas` (`id_pregunta`, `id_quiz`, `pregunta`, `opcion_a`, `opcion_b`, `opcion_c`, `opcion_d`, `correcta`, `id_estado`) VALUES
(1, 1, '¿Qué es la Biblia?', 'Un libro cualquiera', 'La Palabra de Dios', 'Una novela antigua', 'Un poema', 'B', 1),
(2, 1, '¿Cuántos testamentos tiene la Biblia?', '1', '2', '3', '4', 'B', 1),
(3, 1, '¿Quién inspiró la Biblia?', 'Los hombres', 'Dios', 'Los ángeles', 'Nadie', 'B', 1),
(4, 1, '¿Qué enseña la Biblia?', 'Filosofía humana', 'La verdad de Dios', 'Historia de Roma', 'Nada', 'B', 1),
(5, 1, '¿Qué significa \"Evangelio\"?', 'Buena noticia', 'Regla de vida', 'Historia', 'Ley', 'A', 1),
(6, 2, '¿Qué es la oración?', 'Hablar con Dios', 'Leer la Biblia', 'Ir a la iglesia', 'Cantar', 'A', 1),
(7, 2, '¿Por qué oramos?', 'Para pedir cosas', 'Para comunicarnos con Dios', 'Por costumbre', 'Para dormir', 'B', 1),
(8, 2, '¿Qué actitud debemos tener al orar?', 'Humildad', 'Orgullo', 'Indiferencia', 'Temor', 'A', 1),
(9, 2, '¿Quién nos enseñó a orar?', 'Jesús', 'Moisés', 'Pablo', 'Pedro', 'A', 1),
(10, 2, '¿Qué dice el Padre Nuestro?', 'Padre nuestro que estás en el cielo...', 'Salve María...', 'Amén...', 'Dios te salve...', 'A', 1),
(11, 3, '¿Qué es la fe?', 'Creer sin ver', 'Esperar lo imposible', 'Tener esperanza', 'Soñar', 'A', 1),
(12, 3, '¿Quién es el autor de la fe?', 'Pedro', 'Jesús', 'Pablo', 'Abraham', 'B', 1),
(13, 3, '¿Cómo se demuestra la fe?', 'Con palabras', 'Con obras', 'Con emociones', 'Con pensamientos', 'B', 1),
(14, 3, '¿Qué fortalece nuestra fe?', 'El miedo', 'La oración', 'El enojo', 'La duda', 'B', 1),
(15, 3, '¿Qué dice Hebreos 11:1?', 'La fe es la certeza de lo que se espera...', 'Dios es amor', 'El justo vivirá por fe', 'El Señor es mi pastor', 'A', 1),
(16, 4, '¿Qué es el amor cristiano?', 'Un sentimiento', 'Una decisión de amar como Cristo', 'Un deber social', 'Una emoción', 'B', 1),
(17, 4, '¿A quién debemos amar?', 'Solo a los amigos', 'A todos, incluso enemigos', 'Solo familia', 'A nadie', 'B', 1),
(18, 4, '¿Qué enseña 1 Corintios 13?', 'El camino del amor', 'El diezmo', 'La guerra espiritual', 'El juicio final', 'A', 1),
(19, 4, '¿Qué demuestra el amor?', 'Fe viva', 'Orgullo', 'Debilidad', 'Riqueza', 'A', 1),
(20, 4, '¿Quién es el modelo de amor?', 'Jesús', 'Pablo', 'Pedro', 'Juan', 'A', 1),
(21, 5, 'Según el texto, ¿cuál es el propósito final de la vida cristiana?', 'Asistir con frecuencia a la iglesia', 'Llegar a la estatura del varón perfecto, pareciéndose a Jesús', 'Aprender más sobre religión', 'Cumplir con normas morales', 'B', 1),
(22, 5, '¿Qué significa nacer de nuevo según Juan 3:1-21?', 'Cambiar de iglesia', 'Empezar una vida guiada por el Espíritu Santo', 'Repetir una oración pública', 'Cumplir mandamientos religiosos', 'B', 1),
(23, 5, '¿Cuál de los siguientes NO es un medio para crecer espiritualmente mencionado en la enseñanza?', 'La Palabra de Dios', 'La oración', 'La comunión con otros creyentes', 'La fama o el reconocimiento público', 'D', 1),
(24, 5, '¿Qué implica amar a Dios, según Marcos 12:28-31?', 'Cumplir reglas estrictas', 'Buscarlo, obedecerlo y adorarlo con todo el corazón', 'Tener conocimiento bíblico', 'Dar ofrendas generosas', 'B', 1),
(25, 5, 'Crecer en la vida cristiana es un proceso automático que sucede sin esfuerzo ni disciplina.', 'Verdadero', 'Falso', NULL, NULL, 'B', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `quiz_resultados`
--

CREATE TABLE `quiz_resultados` (
  `id_resultado` int(11) NOT NULL,
  `id_usuario` int(11) NOT NULL,
  `id_quiz` int(11) NOT NULL,
  `puntaje` decimal(5,2) NOT NULL,
  `fecha_realizacion` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `resultados`
--

CREATE TABLE `resultados` (
  `id_resultado` int(11) NOT NULL,
  `id_evidencia` int(11) NOT NULL,
  `id_usuario` int(11) NOT NULL,
  `nota` decimal(5,2) DEFAULT NULL,
  `fecha` timestamp NOT NULL DEFAULT current_timestamp(),
  `comentario` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `resultados`
--

INSERT INTO `resultados` (`id_resultado`, `id_evidencia`, `id_usuario`, `nota`, `fecha`, `comentario`) VALUES
(1, 1, 10, 0.00, '2025-10-22 01:20:55', NULL),
(2, 3, 10, 0.00, '2025-10-18 19:11:33', NULL),
(3, 2, 10, 0.00, '2025-10-19 02:08:31', NULL),
(4, 4, 10, 5.00, '2025-10-18 20:29:10', NULL),
(9, 1, 14, 0.00, '2025-10-19 01:32:13', NULL),
(10, 5, 14, 5.00, '2025-10-19 23:17:55', NULL),
(11, 5, 10, 5.00, '2025-10-22 02:04:48', NULL),
(12, 2, 14, 5.00, '2025-10-20 00:39:37', NULL),
(13, 1, 19, 5.00, '2025-10-20 02:11:45', NULL),
(14, 5, 19, 5.00, '2025-10-20 02:17:18', NULL),
(15, 2, 19, 5.00, '2025-10-20 02:25:50', NULL),
(16, 6, 10, 5.00, '2025-10-22 02:05:25', NULL),
(17, 5, 15, 5.00, '2025-10-21 15:03:43', NULL),
(18, 9, 10, 2.00, '2026-05-08 00:41:46', NULL),
(19, 10, 10, 5.00, '2025-10-22 13:26:01', NULL),
(20, 9, 20, 5.00, '2025-10-26 20:14:22', NULL),
(21, 10, 20, 5.00, '2025-10-26 20:15:02', NULL),
(22, 9, 22, 5.00, '2025-11-13 22:00:03', NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `roles`
--

CREATE TABLE `roles` (
  `id_rol` int(11) NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `id_estado` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `roles`
--

INSERT INTO `roles` (`id_rol`, `nombre`, `descripcion`, `id_estado`) VALUES
(1, 'administrador', 'ESTE ROL ES EL ENCARGADO DE ADMINISTRAR TODA LA APLICACION', 1),
(2, 'estudiante', 'Este rol podra consumir los servicios de la aplicacion', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `sublecciones`
--

CREATE TABLE `sublecciones` (
  `id_subleccion` int(11) NOT NULL,
  `id_leccion` int(11) NOT NULL,
  `titulo` varchar(255) NOT NULL,
  `url_recurso` varchar(255) DEFAULT NULL,
  `orden` int(11) DEFAULT NULL,
  `id_estado` int(11) NOT NULL DEFAULT 3,
  `tipo` enum('video','pdf','quiz','foro') NOT NULL DEFAULT 'video'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `sublecciones`
--

INSERT INTO `sublecciones` (`id_subleccion`, `id_leccion`, `titulo`, `url_recurso`, `orden`, `id_estado`, `tipo`) VALUES
(1, 1, 'Video de bienvenida', 'assets/images/course/video/introduccion.mp4', 1, 1, 'video'),
(2, 2, 'Video: La Biblia y su propósito', 'assets/images/course/video/introduccion.mp4', 1, 1, 'video'),
(3, 2, 'Quiz: La Biblia y su propósito', NULL, 2, 1, 'quiz'),
(4, 3, 'Video: La oración', 'assets/images/course/video/introduccion.mp4', 1, 1, 'video'),
(5, 3, 'Quiz: La oración', NULL, 2, 1, 'quiz'),
(6, 4, 'Video: La fe en acción', 'assets/images/course/video/introduccion.mp4', 1, 1, 'video'),
(7, 4, 'Quiz: La fe en acción', NULL, 2, 1, 'quiz'),
(8, 5, 'Video: El amor cristiano', 'assets/images/course/video/introduccion.mp4', 1, 1, 'video'),
(9, 5, 'Quiz: El amor cristiano', NULL, 2, 1, 'quiz'),
(10, 2, 'Foro La Biblia y su propósito', 'Foro La Biblia y su propósito', 3, 3, 'foro'),
(11, 3, 'Foro La oración', 'La oración', 3, 3, 'foro'),
(12, 4, 'Foro La Fe en accion ', 'Foro La Fe en accion ', 3, 3, 'foro'),
(13, 5, 'Foro El amor cristiano', 'Foro El amor cristiano', 3, 3, 'foro'),
(14, 6, 'Video De Bienvenida', 'assets/images/course/video/introduccion.mp4', 1, 1, 'video'),
(15, 7, '¿Cómo crecer en la vida cristiana?', 'assets/images/course/video/pasounoleccionuno.mp4', 1, 1, 'video'),
(16, 7, 'Quiz: Lección 1 ¿Cómo crecer en la vida cristiana?', NULL, 1, 3, 'quiz'),
(17, 7, 'Foro: Lección 1 ¿Cómo crecer en la vida cristiana?', NULL, 3, 1, 'foro');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipos_evidencia`
--

CREATE TABLE `tipos_evidencia` (
  `id_tipo` int(11) NOT NULL,
  `tipo_nombre` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `tipos_evidencia`
--

INSERT INTO `tipos_evidencia` (`id_tipo`, `tipo_nombre`) VALUES
(1, 'foro'),
(2, 'quiz');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuarios`
--

CREATE TABLE `usuarios` (
  `id_usuario` int(11) NOT NULL,
  `nombre` varchar(255) NOT NULL,
  `apellido` varchar(255) NOT NULL,
  `correo` varchar(255) NOT NULL,
  `contrasena` varchar(255) NOT NULL,
  `fecha_nacimiento` date DEFAULT NULL,
  `edad` int(11) DEFAULT NULL,
  `id_genero` int(11) DEFAULT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `direccion` text DEFAULT NULL,
  `id_rol` int(11) NOT NULL,
  `fecha_registro` timestamp NOT NULL DEFAULT current_timestamp(),
  `id_estado` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `usuarios`
--

INSERT INTO `usuarios` (`id_usuario`, `nombre`, `apellido`, `correo`, `contrasena`, `fecha_nacimiento`, `edad`, `id_genero`, `telefono`, `direccion`, `id_rol`, `fecha_registro`, `id_estado`) VALUES
(10, 'Gabriel', 'Betin Valdes', 'gabrielbetinvaldes@gmail.com', '$2y$10$6y6wnW8yHwp/zY7laAlZ.ehe5nmllzv0ql3zHCiJRkg/wuqiYqFNm', '2025-05-30', 21212, 1, '+573006924281', 'kra 6 a sur # 48g-62', 1, '2025-06-25 02:56:19', 1),
(14, 'Tatiana', 'Mejia', 'gabrielbetinvaldes@hotmail.com', '$2y$10$UwumNi64vEPNTJgQExXD4OYY7I.07gi5qp8rDCLYkOo9BXk2JK0Cy', '2025-10-18', 30, 1, '30069024281', 'calle 40 con 40', 2, '2025-10-18 21:12:10', 3),
(15, 'Jabin ', 'Caceres ', 'jabin54@hotmail.com', '$2y$10$O.TvQRlKMhnG79qyheV66eQkeRFN3vFbb9q2SFXn6mGGiaR6DfYyW', '1997-07-13', 37, 1, '3016672757', 'Calle 116 42b 91', 2, '2025-10-18 21:41:53', 3),
(19, 'Stefany', 'Coba blanco', 'stefanycobablanco@hotmail.com', '$2y$10$hwCTvzHHLLlG5G300ROExOlEsmrFaWmFchHQy.QcEpaCO9jPIREUq', '2025-10-19', 30, 2, '3107400211', 'Carrera 6 a sur 48', 2, '2025-10-20 02:04:44', 3),
(20, 'Samuel', 'Betin', 'gbetin@poligran.edu.co', '$2y$10$AJRkAIiTzzJ0AyFrQINaReTW0j8nBxoFAyo6d0oyUuwwhHul.YcVi', '2025-10-26', 30, 1, '+573006924281', 'Carrera 6a Sur # 48g-62', 2, '2025-10-26 20:10:02', 3),
(21, 'Naya ', 'Duran ', 'nabeduri@hotmail.com', '$2y$10$9W8H/r9dU84mS6Z45NjJy.VQ5ReWLAZQJuo/feJaWJCAksvJqzKBu', '1987-09-21', 38, 2, '3107306683 ', 'Carrera 4 sur #48-93 ', 2, '2025-11-07 01:04:22', 3),
(22, 'Luz', 'Fernández ', 'luzf14064@gmail.com', '$2y$10$KDeqY.HjkOLtTv78e7DP3e3VqCzdp0Zyt/7mHVqu7xBvuT5MOkp4G', '2006-09-29', 19, 2, '3225592648', 'Calle 48D #2 sur 22', 2, '2025-11-07 01:04:53', 3),
(23, 'Erica patricia', 'Martinez velez', 'shammadecoraciones26@gmail.com', '$2y$10$TpySAawJ80yi1tMZhwVUp.jS54sTmW5W80PqVIbpJYsIkCqrCNDE6', '2025-06-26', 52, 2, '3226596572', 'Kra 6asur#47b37', 2, '2025-11-07 01:05:08', 3);

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `categorias`
--
ALTER TABLE `categorias`
  ADD PRIMARY KEY (`id_categoria`);

--
-- Indices de la tabla `categorias_productos`
--
ALTER TABLE `categorias_productos`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `cursos`
--
ALTER TABLE `cursos`
  ADD PRIMARY KEY (`id_curso`),
  ADD UNIQUE KEY `titulo` (`titulo`),
  ADD KEY `fk_cursos_estado` (`id_estado`),
  ADD KEY `id_categoria` (`id_categoria`);

--
-- Indices de la tabla `docentes`
--
ALTER TABLE `docentes`
  ADD PRIMARY KEY (`id_docente`),
  ADD UNIQUE KEY `id_usuario` (`id_usuario`),
  ADD UNIQUE KEY `unique_id_usuario` (`id_usuario`),
  ADD KEY `fk_docentes_estado` (`id_estado`);

--
-- Indices de la tabla `estados`
--
ALTER TABLE `estados`
  ADD PRIMARY KEY (`id_estado`),
  ADD UNIQUE KEY `nombre` (`nombre`);

--
-- Indices de la tabla `estados_pago`
--
ALTER TABLE `estados_pago`
  ADD PRIMARY KEY (`id_estado`),
  ADD UNIQUE KEY `estado_nombre` (`estado_nombre`);

--
-- Indices de la tabla `evidencias`
--
ALTER TABLE `evidencias`
  ADD PRIMARY KEY (`id_evidencia`),
  ADD KEY `id_leccion` (`id_leccion`),
  ADD KEY `fk_evidencia_tipo` (`id_tipo`),
  ADD KEY `subleccion_fk` (`id_subleccion`);

--
-- Indices de la tabla `foro_comentarios`
--
ALTER TABLE `foro_comentarios`
  ADD PRIMARY KEY (`id_comentario`),
  ADD KEY `id_respuesta` (`id_respuesta`),
  ADD KEY `id_usuario` (`id_usuario`);

--
-- Indices de la tabla `foro_preguntas`
--
ALTER TABLE `foro_preguntas`
  ADD PRIMARY KEY (`id_pregunta`),
  ADD KEY `id_usuario` (`id_usuario`),
  ADD KEY `id_curso` (`id_curso`),
  ADD KEY `foro_evidencia_fk` (`id_evidencia`),
  ADD KEY `fk_foro_leccion` (`id_leccion`);

--
-- Indices de la tabla `foro_respuestas`
--
ALTER TABLE `foro_respuestas`
  ADD PRIMARY KEY (`id_respuesta`),
  ADD KEY `id_pregunta` (`id_pregunta`),
  ADD KEY `id_usuario` (`id_usuario`),
  ADD KEY `fk_grupo_respuestas` (`id_grupo`);

--
-- Indices de la tabla `generos`
--
ALTER TABLE `generos`
  ADD PRIMARY KEY (`id_genero`),
  ADD UNIQUE KEY `nombre` (`nombre`);

--
-- Indices de la tabla `grupos`
--
ALTER TABLE `grupos`
  ADD PRIMARY KEY (`id_grupo`),
  ADD KEY `estado_fk` (`id_estado`);

--
-- Indices de la tabla `grupo_lecciones`
--
ALTER TABLE `grupo_lecciones`
  ADD PRIMARY KEY (`id_grupo`,`id_leccion`),
  ADD KEY `id_leccion` (`id_leccion`);

--
-- Indices de la tabla `grupo_usuarios`
--
ALTER TABLE `grupo_usuarios`
  ADD PRIMARY KEY (`id_grupo`,`id_usuario`),
  ADD KEY `id_usuario` (`id_usuario`);

--
-- Indices de la tabla `inscripciones`
--
ALTER TABLE `inscripciones`
  ADD PRIMARY KEY (`id_inscripcion`),
  ADD KEY `id_usuario` (`id_usuario`),
  ADD KEY `id_curso` (`id_curso`);

--
-- Indices de la tabla `lecciones`
--
ALTER TABLE `lecciones`
  ADD PRIMARY KEY (`id_leccion`),
  ADD KEY `id_modulo` (`id_modulo`),
  ADD KEY `fk_lecciones_estado` (`id_estado`);

--
-- Indices de la tabla `metodos_pago`
--
ALTER TABLE `metodos_pago`
  ADD PRIMARY KEY (`id_metodo`),
  ADD UNIQUE KEY `metodo_nombre` (`metodo_nombre`);

--
-- Indices de la tabla `modulos`
--
ALTER TABLE `modulos`
  ADD PRIMARY KEY (`id_modulo`),
  ADD KEY `id_curso` (`id_curso`),
  ADD KEY `id_docente` (`id_docente`),
  ADD KEY `fk_modulos_estado` (`id_estado`);

--
-- Indices de la tabla `pagos`
--
ALTER TABLE `pagos`
  ADD PRIMARY KEY (`id_pago`),
  ADD UNIQUE KEY `unique_id_inscripcion` (`id_inscripcion`),
  ADD UNIQUE KEY `unique_id_inscripcion_pagos` (`id_inscripcion`),
  ADD KEY `id_metodo` (`id_metodo`),
  ADD KEY `id_estado` (`id_estado`);

--
-- Indices de la tabla `productos`
--
ALTER TABLE `productos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_productos` (`id_categoria`);

--
-- Indices de la tabla `progreso_curso`
--
ALTER TABLE `progreso_curso`
  ADD PRIMARY KEY (`id_progreso`),
  ADD UNIQUE KEY `uq_usuario_modulo` (`id_usuario`,`id_curso`),
  ADD KEY `id_curso` (`id_curso`);

--
-- Indices de la tabla `progreso_subleccion`
--
ALTER TABLE `progreso_subleccion`
  ADD PRIMARY KEY (`id_progreso`),
  ADD KEY `id_usuario` (`id_usuario`),
  ADD KEY `id_leccion` (`id_leccion`),
  ADD KEY `id_subleccion` (`id_subleccion`),
  ADD KEY `fk_progeso_subleccio_curso` (`id_curso`);

--
-- Indices de la tabla `quiz`
--
ALTER TABLE `quiz`
  ADD PRIMARY KEY (`id_quiz`),
  ADD KEY `id_evidencia` (`id_evidencia`),
  ADD KEY `fk_sublecciones_quiz` (`id_subleccion`);

--
-- Indices de la tabla `quiz_preguntas`
--
ALTER TABLE `quiz_preguntas`
  ADD PRIMARY KEY (`id_pregunta`),
  ADD KEY `id_quiz` (`id_quiz`);

--
-- Indices de la tabla `quiz_resultados`
--
ALTER TABLE `quiz_resultados`
  ADD PRIMARY KEY (`id_resultado`),
  ADD KEY `id_usuario` (`id_usuario`),
  ADD KEY `id_quiz` (`id_quiz`);

--
-- Indices de la tabla `resultados`
--
ALTER TABLE `resultados`
  ADD PRIMARY KEY (`id_resultado`),
  ADD KEY `id_evidencia` (`id_evidencia`),
  ADD KEY `id_usuario` (`id_usuario`);

--
-- Indices de la tabla `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`id_rol`),
  ADD UNIQUE KEY `nombre` (`nombre`),
  ADD KEY `fk_roles_estado` (`id_estado`);

--
-- Indices de la tabla `sublecciones`
--
ALTER TABLE `sublecciones`
  ADD PRIMARY KEY (`id_subleccion`),
  ADD KEY `id_leccion` (`id_leccion`),
  ADD KEY `fk_sublecciones_estado` (`id_estado`);

--
-- Indices de la tabla `tipos_evidencia`
--
ALTER TABLE `tipos_evidencia`
  ADD PRIMARY KEY (`id_tipo`),
  ADD UNIQUE KEY `tipo_nombre` (`tipo_nombre`);

--
-- Indices de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`id_usuario`),
  ADD UNIQUE KEY `correo` (`correo`),
  ADD KEY `id_sexo` (`id_genero`),
  ADD KEY `id_rol` (`id_rol`),
  ADD KEY `fk_usuarios_estado` (`id_estado`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `categorias`
--
ALTER TABLE `categorias`
  MODIFY `id_categoria` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT de la tabla `categorias_productos`
--
ALTER TABLE `categorias_productos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `cursos`
--
ALTER TABLE `cursos`
  MODIFY `id_curso` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT de la tabla `docentes`
--
ALTER TABLE `docentes`
  MODIFY `id_docente` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `evidencias`
--
ALTER TABLE `evidencias`
  MODIFY `id_evidencia` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `foro_comentarios`
--
ALTER TABLE `foro_comentarios`
  MODIFY `id_comentario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT de la tabla `foro_preguntas`
--
ALTER TABLE `foro_preguntas`
  MODIFY `id_pregunta` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `foro_respuestas`
--
ALTER TABLE `foro_respuestas`
  MODIFY `id_respuesta` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=29;

--
-- AUTO_INCREMENT de la tabla `grupos`
--
ALTER TABLE `grupos`
  MODIFY `id_grupo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `inscripciones`
--
ALTER TABLE `inscripciones`
  MODIFY `id_inscripcion` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT de la tabla `lecciones`
--
ALTER TABLE `lecciones`
  MODIFY `id_leccion` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT de la tabla `modulos`
--
ALTER TABLE `modulos`
  MODIFY `id_modulo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `productos`
--
ALTER TABLE `productos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT de la tabla `progreso_curso`
--
ALTER TABLE `progreso_curso`
  MODIFY `id_progreso` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT de la tabla `progreso_subleccion`
--
ALTER TABLE `progreso_subleccion`
  MODIFY `id_progreso` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=57;

--
-- AUTO_INCREMENT de la tabla `quiz`
--
ALTER TABLE `quiz`
  MODIFY `id_quiz` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `quiz_preguntas`
--
ALTER TABLE `quiz_preguntas`
  MODIFY `id_pregunta` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT de la tabla `quiz_resultados`
--
ALTER TABLE `quiz_resultados`
  MODIFY `id_resultado` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `resultados`
--
ALTER TABLE `resultados`
  MODIFY `id_resultado` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT de la tabla `roles`
--
ALTER TABLE `roles`
  MODIFY `id_rol` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `sublecciones`
--
ALTER TABLE `sublecciones`
  MODIFY `id_subleccion` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT de la tabla `tipos_evidencia`
--
ALTER TABLE `tipos_evidencia`
  MODIFY `id_tipo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `id_usuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `cursos`
--
ALTER TABLE `cursos`
  ADD CONSTRAINT `cursos_ibfk_1` FOREIGN KEY (`id_estado`) REFERENCES `estados` (`id_estado`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_curso_categoria` FOREIGN KEY (`id_categoria`) REFERENCES `categorias` (`id_categoria`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `docentes`
--
ALTER TABLE `docentes`
  ADD CONSTRAINT `docentes_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `evidencias`
--
ALTER TABLE `evidencias`
  ADD CONSTRAINT `evidencias_ibfk_1` FOREIGN KEY (`id_leccion`) REFERENCES `lecciones` (`id_leccion`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_evidencia_tipo` FOREIGN KEY (`id_tipo`) REFERENCES `tipos_evidencia` (`id_tipo`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `subleccion_fk` FOREIGN KEY (`id_subleccion`) REFERENCES `sublecciones` (`id_subleccion`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `foro_comentarios`
--
ALTER TABLE `foro_comentarios`
  ADD CONSTRAINT `foro_comentarios_ibfk_1` FOREIGN KEY (`id_respuesta`) REFERENCES `foro_respuestas` (`id_respuesta`),
  ADD CONSTRAINT `foro_comentarios_ibfk_2` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`);

--
-- Filtros para la tabla `foro_preguntas`
--
ALTER TABLE `foro_preguntas`
  ADD CONSTRAINT `fk_foro_leccion` FOREIGN KEY (`id_leccion`) REFERENCES `lecciones` (`id_leccion`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `foro_evidencia_fk` FOREIGN KEY (`id_evidencia`) REFERENCES `evidencias` (`id_evidencia`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `foro_preguntas_ibfk_2` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`),
  ADD CONSTRAINT `foro_preguntas_ibfk_3` FOREIGN KEY (`id_curso`) REFERENCES `cursos` (`id_curso`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `foro_respuestas`
--
ALTER TABLE `foro_respuestas`
  ADD CONSTRAINT `fk_grupo_respuestas` FOREIGN KEY (`id_grupo`) REFERENCES `grupos` (`id_grupo`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `foro_respuestas_ibfk_1` FOREIGN KEY (`id_pregunta`) REFERENCES `foro_preguntas` (`id_pregunta`),
  ADD CONSTRAINT `foro_respuestas_ibfk_2` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`);

--
-- Filtros para la tabla `grupos`
--
ALTER TABLE `grupos`
  ADD CONSTRAINT `estado_fk` FOREIGN KEY (`id_estado`) REFERENCES `estados` (`id_estado`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `grupo_lecciones`
--
ALTER TABLE `grupo_lecciones`
  ADD CONSTRAINT `grupo_lecciones_ibfk_1` FOREIGN KEY (`id_grupo`) REFERENCES `grupos` (`id_grupo`),
  ADD CONSTRAINT `grupo_lecciones_ibfk_2` FOREIGN KEY (`id_leccion`) REFERENCES `lecciones` (`id_leccion`);

--
-- Filtros para la tabla `grupo_usuarios`
--
ALTER TABLE `grupo_usuarios`
  ADD CONSTRAINT `grupo_usuarios_ibfk_1` FOREIGN KEY (`id_grupo`) REFERENCES `grupos` (`id_grupo`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `grupo_usuarios_ibfk_2` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `inscripciones`
--
ALTER TABLE `inscripciones`
  ADD CONSTRAINT `inscripciones_ibfk_1` FOREIGN KEY (`id_curso`) REFERENCES `cursos` (`id_curso`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `inscripciones_ibfk_2` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `lecciones`
--
ALTER TABLE `lecciones`
  ADD CONSTRAINT `lecciones_ibfk_1` FOREIGN KEY (`id_modulo`) REFERENCES `modulos` (`id_modulo`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `lecciones_ibfk_2` FOREIGN KEY (`id_estado`) REFERENCES `estados` (`id_estado`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `modulos`
--
ALTER TABLE `modulos`
  ADD CONSTRAINT `modulos_ibfk_1` FOREIGN KEY (`id_curso`) REFERENCES `cursos` (`id_curso`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `modulos_ibfk_2` FOREIGN KEY (`id_estado`) REFERENCES `estados` (`id_estado`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `pagos`
--
ALTER TABLE `pagos`
  ADD CONSTRAINT `pagos_ibfk_1` FOREIGN KEY (`id_inscripcion`) REFERENCES `inscripciones` (`id_inscripcion`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `pagos_ibfk_2` FOREIGN KEY (`id_estado`) REFERENCES `estados_pago` (`id_estado`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `pagos_ibfk_3` FOREIGN KEY (`id_metodo`) REFERENCES `metodos_pago` (`id_metodo`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `productos`
--
ALTER TABLE `productos`
  ADD CONSTRAINT `fk_productos` FOREIGN KEY (`id_categoria`) REFERENCES `categorias_productos` (`id`);

--
-- Filtros para la tabla `progreso_curso`
--
ALTER TABLE `progreso_curso`
  ADD CONSTRAINT `fk_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`),
  ADD CONSTRAINT `progreso_curso_ibfk_1` FOREIGN KEY (`id_curso`) REFERENCES `cursos` (`id_curso`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `progreso_subleccion`
--
ALTER TABLE `progreso_subleccion`
  ADD CONSTRAINT `fk_progeso_subleccio_curso` FOREIGN KEY (`id_curso`) REFERENCES `cursos` (`id_curso`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `progreso_subleccion_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`),
  ADD CONSTRAINT `progreso_subleccion_ibfk_2` FOREIGN KEY (`id_leccion`) REFERENCES `lecciones` (`id_leccion`),
  ADD CONSTRAINT `progreso_subleccion_ibfk_3` FOREIGN KEY (`id_subleccion`) REFERENCES `sublecciones` (`id_subleccion`);

--
-- Filtros para la tabla `quiz`
--
ALTER TABLE `quiz`
  ADD CONSTRAINT `fk_sublecciones_quiz` FOREIGN KEY (`id_subleccion`) REFERENCES `sublecciones` (`id_subleccion`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `quiz_ibfk_1` FOREIGN KEY (`id_evidencia`) REFERENCES `evidencias` (`id_evidencia`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `quiz_preguntas`
--
ALTER TABLE `quiz_preguntas`
  ADD CONSTRAINT `quiz_preguntas_ibfk_1` FOREIGN KEY (`id_quiz`) REFERENCES `quiz` (`id_quiz`) ON DELETE CASCADE;

--
-- Filtros para la tabla `quiz_resultados`
--
ALTER TABLE `quiz_resultados`
  ADD CONSTRAINT `quiz_resultados_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`),
  ADD CONSTRAINT `quiz_resultados_ibfk_2` FOREIGN KEY (`id_quiz`) REFERENCES `quiz` (`id_quiz`) ON DELETE CASCADE;

--
-- Filtros para la tabla `resultados`
--
ALTER TABLE `resultados`
  ADD CONSTRAINT `resultados_ibfk_1` FOREIGN KEY (`id_evidencia`) REFERENCES `evidencias` (`id_evidencia`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `resultados_ibfk_2` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `sublecciones`
--
ALTER TABLE `sublecciones`
  ADD CONSTRAINT `sublecciones_ibfk_1` FOREIGN KEY (`id_leccion`) REFERENCES `lecciones` (`id_leccion`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD CONSTRAINT `usuarios_ibfk_2` FOREIGN KEY (`id_genero`) REFERENCES `generos` (`id_genero`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `usuarios_ibfk_3` FOREIGN KEY (`id_rol`) REFERENCES `roles` (`id_rol`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `usuarios_ibfk_4` FOREIGN KEY (`id_estado`) REFERENCES `estados` (`id_estado`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
