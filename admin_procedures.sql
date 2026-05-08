DELIMITER $$

-- 1. Actualizar Curso
DROP PROCEDURE IF EXISTS `sp_update_curso`$$
CREATE PROCEDURE `sp_update_curso` (IN `v_data` JSON, OUT `v_salida` JSON)
BEGIN
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

-- 2. Actualizar Módulo
DROP PROCEDURE IF EXISTS `sp_update_modulo`$$
CREATE PROCEDURE `sp_update_modulo` (IN `v_data` JSON, OUT `v_salida` JSON)
BEGIN
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

-- 3. Actualizar Lección
DROP PROCEDURE IF EXISTS `sp_update_leccion`$$
CREATE PROCEDURE `sp_update_leccion` (IN `v_data` JSON, OUT `v_salida` JSON)
BEGIN
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

-- 4. Actualizar Sublección
DROP PROCEDURE IF EXISTS `sp_update_subleccion`$$
CREATE PROCEDURE `sp_update_subleccion` (IN `v_data` JSON, OUT `v_salida` JSON)
BEGIN
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

-- 5. Estadísticas del Dashboard
DROP PROCEDURE IF EXISTS `sp_get_admin_stats`$$
CREATE PROCEDURE `sp_get_admin_stats` (OUT `v_salida` JSON)
BEGIN
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

-- 6. Obtener Usuarios para Admin
DROP PROCEDURE IF EXISTS `sp_get_all_usuarios_admin`$$
CREATE PROCEDURE `sp_get_all_usuarios_admin` (OUT `v_salida` JSON)
BEGIN
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

-- 6.1 Actualizar Rol de Usuario
DROP PROCEDURE IF EXISTS `sp_update_usuario_rol`$$
CREATE PROCEDURE `sp_update_usuario_rol` (IN `v_data` JSON, OUT `v_salida` JSON)
BEGIN
    DECLARE v_id_usuario INT;
    DECLARE v_id_rol INT;

    SET v_id_usuario = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_usuario'));
    SET v_id_rol     = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_rol'));

    UPDATE usuarios SET id_rol = v_id_rol WHERE id_usuario = v_id_usuario;

    SET v_salida = JSON_OBJECT('status','OK','message','Rol de usuario actualizado correctamente');
END$$

-- 6.2 Obtener todos los Cursos para Admin
DROP PROCEDURE IF EXISTS `sp_get_cursos_admin`$$
CREATE PROCEDURE `sp_get_cursos_admin` (OUT `v_salida` JSON)
BEGIN
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

-- 7. Gestionar Categorías
DROP PROCEDURE IF EXISTS `sp_insert_categoria`$$
CREATE PROCEDURE `sp_insert_categoria` (IN `v_data` JSON, OUT `v_salida` JSON)
BEGIN
    DECLARE v_nombre VARCHAR(255);
    SET v_nombre = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.nombre'));
    INSERT INTO categorias (nombre) VALUES (v_nombre);
    SET v_salida = JSON_OBJECT('status','OK','message','Categoría creada','data',JSON_OBJECT('id_categoria',LAST_INSERT_ID()));
END$$

DROP PROCEDURE IF EXISTS `sp_update_categoria`$$
CREATE PROCEDURE `sp_update_categoria` (IN `v_data` JSON, OUT `v_salida` JSON)
BEGIN
    DECLARE v_id INT;
    DECLARE v_nombre VARCHAR(255);
    SET v_id = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_categoria'));
    SET v_nombre = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.nombre'));
    UPDATE categorias SET nombre = v_nombre WHERE id_categoria = v_id;
    SET v_salida = JSON_OBJECT('status','OK','message','Categoría actualizada');
END$$

-- 8. Gestionar Foro Preguntas
DROP PROCEDURE IF EXISTS `sp_insert_foro_pregunta_admin`$$
CREATE PROCEDURE `sp_insert_foro_pregunta_admin` (IN `v_data` JSON, OUT `v_salida` JSON)
BEGIN
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

-- 9. Gestionar Evidencias
DROP PROCEDURE IF EXISTS `sp_insert_evidencia`$$
CREATE PROCEDURE `sp_insert_evidencia` (IN `v_data` JSON, OUT `v_salida` JSON)
BEGIN
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

-- 10. Gestionar Quizzes
DROP PROCEDURE IF EXISTS `sp_insert_quiz`$$
CREATE PROCEDURE `sp_insert_quiz` (IN `v_data` JSON, OUT `v_salida` JSON)
BEGIN
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

DROP PROCEDURE IF EXISTS `sp_insert_quiz_pregunta`$$
CREATE PROCEDURE `sp_insert_quiz_pregunta` (IN `v_data` JSON, OUT `v_salida` JSON)
BEGIN
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

DELIMITER ;
