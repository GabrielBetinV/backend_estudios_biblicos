DELIMITER $$

-- 0. Crear Curso
DROP PROCEDURE IF EXISTS `sp_insert_curso`$$
CREATE PROCEDURE `sp_insert_curso` (IN `v_data` JSON, OUT `v_salida` JSON)
BEGIN
    DECLARE v_titulo       VARCHAR(255);
    DECLARE v_descripcion  TEXT;
    DECLARE v_precio       DECIMAL(10,2);
    DECLARE v_portada      TEXT;
    DECLARE v_id_categoria INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @msg = MESSAGE_TEXT;
        SET v_salida = JSON_OBJECT('status','ERROR','message',CONCAT('Error al crear curso: ',@msg),'data',NULL);
    END;

    SET v_titulo       = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.titulo'));
    SET v_descripcion  = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.descripcion'));
    SET v_precio       = IFNULL(JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.precio')), 0);
    SET v_portada      = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.portada'));
    SET v_id_categoria = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_categoria'));

    INSERT INTO cursos (titulo, descripcion, precio, portada, id_categoria, id_estado)
    VALUES (v_titulo, v_descripcion, v_precio, v_portada, v_id_categoria, 2); -- 2 = Borrador

    SET v_salida = JSON_OBJECT('status','OK','message','Curso creado correctamente','data',JSON_OBJECT('id_curso',LAST_INSERT_ID()));
END$$

-- 0b. Cambiar estado del curso
DROP PROCEDURE IF EXISTS `sp_update_estado_curso`$$
CREATE PROCEDURE `sp_update_estado_curso` (IN `v_data` JSON, OUT `v_salida` JSON)
BEGIN
    DECLARE v_id_curso  INT;
    DECLARE v_id_estado INT;
    SET v_id_curso  = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_curso'));
    SET v_id_estado = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_estado'));
    UPDATE cursos SET id_estado = v_id_estado WHERE id_curso = v_id_curso;
    SET v_salida = JSON_OBJECT('status','OK','message','Estado del curso actualizado');
END$$

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
    SET v_orden       = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.orden'));
    SET v_id_estado   = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_estado'));

    START TRANSACTION;
    UPDATE lecciones 
    SET titulo = v_titulo,
        descripcion = v_descripcion,
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

-- 4.1 Insertar Módulo
DROP PROCEDURE IF EXISTS `sp_insert_modulo`$$
CREATE PROCEDURE `sp_insert_modulo` (IN `v_data` JSON, OUT `v_salida` JSON)
BEGIN
    DECLARE v_id_curso INT;
    DECLARE v_id_docente INT;
    DECLARE v_titulo VARCHAR(255);
    DECLARE v_descripcion TEXT;
    DECLARE v_orden INT;

    SET v_id_curso     = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_curso'));
    SET v_id_docente   = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_docente'));
    SET v_titulo       = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.titulo'));
    SET v_descripcion  = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.descripcion'));
    SET v_orden        = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.orden'));

    INSERT INTO modulos (id_curso, id_docente, titulo, descripcion, orden, id_estado)
    VALUES (v_id_curso, v_id_docente, v_titulo, v_descripcion, v_orden, 1);

    SET v_salida = JSON_OBJECT('status','OK','message','Módulo creado','data',JSON_OBJECT('id_modulo',LAST_INSERT_ID()));
END$$

-- 4.2 Insertar Lección
DROP PROCEDURE IF EXISTS `sp_insert_leccion`$$
CREATE PROCEDURE `sp_insert_leccion` (IN `v_data` JSON, OUT `v_salida` JSON)
BEGIN
    DECLARE v_id_modulo INT;
    DECLARE v_titulo VARCHAR(255);
    DECLARE v_descripcion TEXT;
    DECLARE v_orden INT;

    SET v_id_modulo   = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_modulo'));
    SET v_titulo      = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.titulo'));
    SET v_descripcion = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.descripcion'));
    SET v_orden       = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.orden'));

    INSERT INTO lecciones (id_modulo, titulo, descripcion, orden, id_estado)
    VALUES (v_id_modulo, v_titulo, v_descripcion, v_orden, 1);

    SET v_salida = JSON_OBJECT('status','OK','message','Lección creada','data',JSON_OBJECT('id_leccion',LAST_INSERT_ID()));
END$$

-- 4.3 Insertar Sublección
DROP PROCEDURE IF EXISTS `sp_insert_subleccion`$$
CREATE PROCEDURE `sp_insert_subleccion` (IN `v_data` JSON, OUT `v_salida` JSON)
BEGIN
    DECLARE v_id_leccion INT;
    DECLARE v_titulo VARCHAR(255);
    DECLARE v_url_recurso VARCHAR(500);
    DECLARE v_orden INT;
    DECLARE v_tipo VARCHAR(50);

    SET v_id_leccion   = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_leccion'));
    SET v_titulo      = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.titulo'));
    SET v_url_recurso = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.url_recurso'));
    SET v_orden       = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.orden'));
    SET v_tipo        = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.tipo'));

    INSERT INTO sublecciones (id_leccion, titulo, url_recurso, orden, id_estado, tipo)
    VALUES (v_id_leccion, v_titulo, v_url_recurso, v_orden, 1, v_tipo);

    SET v_salida = JSON_OBJECT('status','OK','message','Sublección creada','data',JSON_OBJECT('id_subleccion',LAST_INSERT_ID()));
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

-- 6.1b Actualizar Estado de Usuario
DROP PROCEDURE IF EXISTS `sp_update_usuario_estado`$$
CREATE PROCEDURE `sp_update_usuario_estado` (IN `v_data` JSON, OUT `v_salida` JSON)
BEGIN
    DECLARE v_id_usuario INT;
    DECLARE v_id_estado INT;

    SET v_id_usuario = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_usuario'));
    SET v_id_estado  = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_estado'));

    UPDATE usuarios SET id_estado = v_id_estado WHERE id_usuario = v_id_usuario;

    SET v_salida = JSON_OBJECT(
        'status','OK',
        'message', IF(v_id_estado = 1, 'Usuario activado correctamente', 'Usuario inactivado correctamente')
    );
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

-- 6.3 Obtener Detalle de Curso Completo (Admin)
DROP PROCEDURE IF EXISTS `sp_get_curso_detalle_admin`$$
CREATE PROCEDURE `sp_get_curso_detalle_admin` (IN `v_data` JSON, OUT `v_salida` JSON)
BEGIN
    DECLARE v_curso JSON;
    DECLARE v_id_curso INT;

    SET v_id_curso = JSON_UNQUOTE(JSON_EXTRACT(v_data, '$.id_curso'));

    -- Obtener info base del curso y anidar módulos, lecciones y sublecciones
    SELECT JSON_OBJECT(
        'id_curso', c.id_curso,
        'titulo', c.titulo,
        'descripcion', c.descripcion,
        'precio', c.precio,
        'id_estado', c.id_estado,
        'portada', c.portada,
        'modulos', (
            SELECT JSON_ARRAYAGG(
                JSON_OBJECT(
                    'id_modulo', m.id_modulo,
                    'titulo', m.titulo,
                    'descripcion', m.descripcion,
                    'orden', m.orden,
                    'lecciones', (
                        SELECT JSON_ARRAYAGG(
                            JSON_OBJECT(
                                'id_leccion', l.id_leccion,
                                'titulo', l.titulo,
                                'descripcion', l.descripcion,
                                'orden', l.orden,
                                'sublecciones', (
                                    SELECT JSON_ARRAYAGG(
                                        JSON_OBJECT(
                                            'id_subleccion', s.id_subleccion,
                                            'titulo', s.titulo,
                                            'url_recurso', s.url_recurso,
                                            'tipo', s.tipo,
                                            'orden', s.orden,
                                            'quiz', (
                                                SELECT JSON_OBJECT(
                                                    'id_quiz', q.id_quiz,
                                                    'titulo', q.titulo,
                                                    'descripcion', q.descripcion,
                                                    'preguntas', (
                                                        SELECT JSON_ARRAYAGG(
                                                            JSON_OBJECT(
                                                                'id_pregunta', qp.id_pregunta,
                                                                'pregunta', qp.pregunta,
                                                                'opcion_a', qp.opcion_a,
                                                                'opcion_b', qp.opcion_b,
                                                                'opcion_c', qp.opcion_c,
                                                                'opcion_d', qp.opcion_d,
                                                                'correcta', qp.correcta
                                                            )
                                                        )
                                                        FROM quiz_preguntas qp WHERE qp.id_quiz = q.id_quiz
                                                    )
                                                )
                                                FROM quiz q WHERE q.id_subleccion = s.id_subleccion LIMIT 1
                                            ),
                                            'foro', (
                                                SELECT JSON_OBJECT(
                                                    'id_pregunta', fp.id_pregunta,
                                                    'titulo', fp.titulo,
                                                    'contenido', fp.contenido
                                                )
                                                FROM foro_preguntas fp
                                                INNER JOIN evidencias e ON fp.id_evidencia = e.id_evidencia
                                                WHERE e.id_subleccion = s.id_subleccion LIMIT 1
                                            )
                                        )
                                    )
                                    FROM sublecciones s WHERE s.id_leccion = l.id_leccion
                                )
                            )
                        )
                        FROM lecciones l WHERE l.id_modulo = m.id_modulo
                    )
                )
            )
            FROM modulos m WHERE m.id_curso = c.id_curso
        )
    ) INTO v_curso
    FROM cursos c
    WHERE c.id_curso = v_id_curso;

    IF v_curso IS NOT NULL THEN
        SET v_salida = JSON_OBJECT(
            'status', 'OK',
            'message', 'Detalle de curso obtenido correctamente',
            'data', JSON_ARRAY(JSON_EXTRACT(v_curso, '$'))
        );
    ELSE
        SET v_salida = JSON_OBJECT(
            'status', 'ERROR',
            'message', 'Curso no encontrado',
            'data', NULL
        );
    END IF;
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

-- 11. Gestionar Grupos
DROP PROCEDURE IF EXISTS `sp_get_grupos_admin`$$
CREATE PROCEDURE `sp_get_grupos_admin` (OUT `v_salida` JSON)
BEGIN
    DECLARE v_resultado JSON DEFAULT JSON_ARRAY();
    SELECT JSON_ARRAYAGG(
        JSON_OBJECT(
            'id_grupo', id_grupo,
            'nombre', nombre,
            'descripcion', descripcion,
            'fecha_creacion', fecha_creacion,
            'id_estado', id_estado
        )
    ) INTO v_resultado FROM grupos;
    SET v_salida = JSON_OBJECT('status','OK','message','Grupos obtenidos','data', JSON_EXTRACT(IFNULL(v_resultado, JSON_ARRAY()), '$'));
END$$

DROP PROCEDURE IF EXISTS `sp_insert_grupo`$$
CREATE PROCEDURE `sp_insert_grupo` (IN `v_data` JSON, OUT `v_salida` JSON)
BEGIN
    DECLARE v_nombre VARCHAR(100);
    DECLARE v_descripcion TEXT;
    SET v_nombre = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.nombre'));
    SET v_descripcion = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.descripcion'));
    INSERT INTO grupos (nombre, descripcion) VALUES (v_nombre, v_descripcion);
    SET v_salida = JSON_OBJECT('status','OK','message','Grupo creado','data', JSON_OBJECT('id_grupo', LAST_INSERT_ID()));
END$$

-- 12. Gestionar Inscripciones
DROP PROCEDURE IF EXISTS `sp_get_inscripciones_admin`$$
CREATE PROCEDURE `sp_get_inscripciones_admin` (OUT `v_salida` JSON)
BEGIN
    DECLARE v_resultado JSON DEFAULT JSON_ARRAY();
    SELECT JSON_ARRAYAGG(
        JSON_OBJECT(
            'id_inscripcion', i.id_inscripcion,
            'id_usuario', i.id_usuario,
            'id_curso', i.id_curso,
            'fecha_inscripcion', i.fecha_inscripcion,
            'usuario_nombre', CONCAT(u.nombre, ' ', u.apellido),
            'curso_titulo', c.titulo
        )
    ) INTO v_resultado 
    FROM inscripciones i
    JOIN usuarios u ON i.id_usuario = u.id_usuario
    JOIN cursos c ON i.id_curso = c.id_curso;
    SET v_salida = JSON_OBJECT('status','OK','message','Inscripciones obtenidas','data', JSON_EXTRACT(IFNULL(v_resultado, JSON_ARRAY()), '$'));
END$$

DROP PROCEDURE IF EXISTS `sp_insert_inscripcion`$$
CREATE PROCEDURE `sp_insert_inscripcion` (IN `v_data` JSON, OUT `v_salida` JSON)
BEGIN
    DECLARE v_id_usuario INT;
    DECLARE v_id_curso INT;
    SET v_id_usuario = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_usuario'));
    SET v_id_curso = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_curso'));
    
    IF EXISTS (SELECT 1 FROM inscripciones WHERE id_usuario = v_id_usuario AND id_curso = v_id_curso) THEN
        SET v_salida = JSON_OBJECT('status','ERROR','message','El usuario ya está inscrito en este curso');
    ELSE
        INSERT INTO inscripciones (id_usuario, id_curso) VALUES (v_id_usuario, v_id_curso);
        SET v_salida = JSON_OBJECT('status','OK','message','Inscripción exitosa');
    END IF;
END$$

DROP PROCEDURE IF EXISTS `sp_delete_inscripcion`$$
CREATE PROCEDURE `sp_delete_inscripcion` (IN `v_data` JSON, OUT `v_salida` JSON)
BEGIN
    DECLARE v_id_inscripcion INT;
    SET v_id_inscripcion = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_inscripcion'));
    DELETE FROM inscripciones WHERE id_inscripcion = v_id_inscripcion;
    SET v_salida = JSON_OBJECT('status','OK','message','Inscripción eliminada correctamente');
END$$

-- 13. Gestionar Grupo-Usuarios
DROP PROCEDURE IF EXISTS `sp_get_grupo_usuarios`$$
CREATE PROCEDURE `sp_get_grupo_usuarios` (IN `v_data` JSON, OUT `v_salida` JSON)
BEGIN
    DECLARE v_id_grupo INT;
    DECLARE v_resultado JSON DEFAULT JSON_ARRAY();
    SET v_id_grupo = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_grupo'));
    SELECT JSON_ARRAYAGG(
        JSON_OBJECT(
            'id_usuario', gu.id_usuario,
            'nombre_completo', CONCAT(u.nombre, ' ', u.apellido),
            'correo', u.correo
        )
    ) INTO v_resultado
    FROM grupo_usuarios gu
    JOIN usuarios u ON gu.id_usuario = u.id_usuario
    WHERE gu.id_grupo = v_id_grupo;
    SET v_salida = JSON_OBJECT('status','OK','data', JSON_EXTRACT(IFNULL(v_resultado, JSON_ARRAY()), '$'));
END$$

DROP PROCEDURE IF EXISTS `sp_assign_usuario_grupo`$$
CREATE PROCEDURE `sp_assign_usuario_grupo` (IN `v_data` JSON, OUT `v_salida` JSON)
BEGIN
    DECLARE v_id_grupo INT;
    DECLARE v_id_usuario INT;
    SET v_id_grupo = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_grupo'));
    SET v_id_usuario = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_usuario'));
    INSERT IGNORE INTO grupo_usuarios (id_grupo, id_usuario) VALUES (v_id_grupo, v_id_usuario);
    SET v_salida = JSON_OBJECT('status','OK','message','Usuario asignado al grupo');
END$$

DROP PROCEDURE IF EXISTS `sp_remove_usuario_grupo`$$
CREATE PROCEDURE `sp_remove_usuario_grupo` (IN `v_data` JSON, OUT `v_salida` JSON)
BEGIN
    DECLARE v_id_grupo INT;
    DECLARE v_id_usuario INT;
    SET v_id_grupo = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_grupo'));
    SET v_id_usuario = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_usuario'));
    DELETE FROM grupo_usuarios WHERE id_grupo = v_id_grupo AND id_usuario = v_id_usuario;
    SET v_salida = JSON_OBJECT('status','OK','message','Usuario removido del grupo');
END$$

-- 14. Gestionar Grupo-Lecciones
DROP PROCEDURE IF EXISTS `sp_get_lecciones_full`$$
CREATE PROCEDURE `sp_get_lecciones_full` (OUT `v_salida` JSON)
BEGIN
    DECLARE v_resultado JSON DEFAULT JSON_ARRAY();
    SELECT JSON_ARRAYAGG(
        JSON_OBJECT(
            'id_leccion', l.id_leccion,
            'titulo_leccion', l.titulo,
            'titulo_modulo', m.titulo,
            'titulo_curso', c.titulo
        )
    ) INTO v_resultado
    FROM lecciones l
    JOIN modulos m ON l.id_modulo = m.id_modulo
    JOIN cursos c ON m.id_curso = c.id_curso;
    SET v_salida = JSON_OBJECT('status','OK','data', JSON_EXTRACT(IFNULL(v_resultado, JSON_ARRAY()), '$'));
END$$

DROP PROCEDURE IF EXISTS `sp_get_grupo_lecciones`$$
CREATE PROCEDURE `sp_get_grupo_lecciones` (IN `v_data` JSON, OUT `v_salida` JSON)
BEGIN
    DECLARE v_id_grupo INT;
    DECLARE v_resultado JSON DEFAULT JSON_ARRAY();
    SET v_id_grupo = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_grupo'));
    SELECT JSON_ARRAYAGG(
        JSON_OBJECT(
            'id_leccion', gl.id_leccion,
            'titulo_leccion', l.titulo,
            'titulo_modulo', m.titulo,
            'titulo_curso', c.titulo,
            'activo', gl.activo
        )
    ) INTO v_resultado
    FROM grupo_lecciones gl
    JOIN lecciones l ON gl.id_leccion = l.id_leccion
    JOIN modulos m ON l.id_modulo = m.id_modulo
    JOIN cursos c ON m.id_curso = c.id_curso
    WHERE gl.id_grupo = v_id_grupo;
    SET v_salida = JSON_OBJECT('status','OK','data', JSON_EXTRACT(IFNULL(v_resultado, JSON_ARRAY()), '$'));
END$$

DROP PROCEDURE IF EXISTS `sp_assign_leccion_grupo`$$
CREATE PROCEDURE `sp_assign_leccion_grupo` (IN `v_data` JSON, OUT `v_salida` JSON)
BEGIN
    DECLARE v_id_grupo INT;
    DECLARE v_id_leccion INT;
    SET v_id_grupo = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_grupo'));
    SET v_id_leccion = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_leccion'));
    INSERT INTO grupo_lecciones (id_grupo, id_leccion, activo) 
    VALUES (v_id_grupo, v_id_leccion, 1)
    ON DUPLICATE KEY UPDATE activo = 1;
    SET v_salida = JSON_OBJECT('status','OK','message','Lección habilitada para el grupo');
END$$

DROP PROCEDURE IF EXISTS `sp_remove_leccion_grupo`$$
CREATE PROCEDURE `sp_remove_leccion_grupo` (IN `v_data` JSON, OUT `v_salida` JSON)
BEGIN
    DECLARE v_id_grupo INT;
    DECLARE v_id_leccion INT;
    SET v_id_grupo = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_grupo'));
    SET v_id_leccion = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_leccion'));
    DELETE FROM grupo_lecciones WHERE id_grupo = v_id_grupo AND id_leccion = v_id_leccion;
    SET v_salida = JSON_OBJECT('status','OK','message','Lección removida del grupo');
END$$

-- ============================================
-- 15. GESTIÓN DE ROLES Y PERMISOS
-- ============================================

-- 15.1 Obtener todos los roles
DROP PROCEDURE IF EXISTS `sp_get_roles_admin`$$
CREATE PROCEDURE `sp_get_roles_admin` (OUT `v_salida` JSON)
BEGIN
    DECLARE v_resultado JSON DEFAULT JSON_ARRAY();
    SELECT JSON_ARRAYAGG(
        JSON_OBJECT(
            'id_rol', r.id_rol,
            'nombre', r.nombre,
            'descripcion', r.descripcion,
            'id_estado', r.id_estado,
            'permisos', (
                SELECT JSON_ARRAYAGG(
                    JSON_OBJECT(
                        'id_permiso', p.id_permiso,
                        'nombre', p.nombre,
                        'modulo', p.modulo,
                        'descripcion', p.descripcion
                    )
                )
                FROM rol_permisos rp
                INNER JOIN permisos p ON rp.id_permiso = p.id_permiso
                WHERE rp.id_rol = r.id_rol
            )
        )
    ) INTO v_resultado
    FROM roles r;
    SET v_salida = JSON_OBJECT('status','OK','message','Roles obtenidos correctamente','data', JSON_EXTRACT(IFNULL(v_resultado, JSON_ARRAY()), '$'));
END$$

-- 15.2 Obtener todos los permisos disponibles
DROP PROCEDURE IF EXISTS `sp_get_permisos`$$
CREATE PROCEDURE `sp_get_permisos` (OUT `v_salida` JSON)
BEGIN
    DECLARE v_resultado JSON DEFAULT JSON_ARRAY();
    SELECT JSON_ARRAYAGG(
        JSON_OBJECT(
            'id_permiso', id_permiso,
            'nombre', nombre,
            'modulo', modulo,
            'descripcion', descripcion
        )
    ) INTO v_resultado
    FROM permisos;
    SET v_salida = JSON_OBJECT('status','OK','message','Permisos obtenidos correctamente','data', JSON_EXTRACT(IFNULL(v_resultado, JSON_ARRAY()), '$'));
END$$

-- 15.3 Obtener permisos de un rol específico
DROP PROCEDURE IF EXISTS `sp_get_rol_permisos`$$
CREATE PROCEDURE `sp_get_rol_permisos` (IN `v_data` JSON, OUT `v_salida` JSON)
BEGIN
    DECLARE v_id_rol INT;
    DECLARE v_resultado JSON DEFAULT JSON_ARRAY();
    SET v_id_rol = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_rol'));
    SELECT JSON_ARRAYAGG(
        JSON_OBJECT('id_permiso', p.id_permiso, 'nombre', p.nombre)
    ) INTO v_resultado
    FROM rol_permisos rp
    INNER JOIN permisos p ON rp.id_permiso = p.id_permiso
    WHERE rp.id_rol = v_id_rol;
    SET v_salida = JSON_OBJECT('status','OK','data', JSON_EXTRACT(IFNULL(v_resultado, JSON_ARRAY()), '$'));
END$$

-- 15.4 Obtener permisos de un usuario por su id_rol
DROP PROCEDURE IF EXISTS `sp_get_permisos_by_rol`$$
CREATE PROCEDURE `sp_get_permisos_by_rol` (IN `v_data` JSON, OUT `v_salida` JSON)
BEGIN
    DECLARE v_id_rol INT;
    DECLARE v_resultado JSON DEFAULT JSON_ARRAY();
    SET v_id_rol = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_rol'));
    SELECT JSON_ARRAYAGG(p.nombre) INTO v_resultado
    FROM rol_permisos rp
    INNER JOIN permisos p ON rp.id_permiso = p.id_permiso
    WHERE rp.id_rol = v_id_rol;
    SET v_salida = JSON_OBJECT('status','OK','data', JSON_EXTRACT(IFNULL(v_resultado, JSON_ARRAY()), '$'));
END$$

-- 15.5 Crear rol
DROP PROCEDURE IF EXISTS `sp_insert_rol`$$
CREATE PROCEDURE `sp_insert_rol` (IN `v_data` JSON, OUT `v_salida` JSON)
BEGIN
    DECLARE v_nombre VARCHAR(50);
    DECLARE v_descripcion TEXT;
    DECLARE v_nuevo_id INT;
    DECLARE v_permisos JSON;
    DECLARE v_i INT DEFAULT 0;
    DECLARE v_id_permiso INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @msg = MESSAGE_TEXT;
        SET v_salida = JSON_OBJECT('status','ERROR','message',CONCAT('Error al crear rol: ',@msg),'data',NULL);
        ROLLBACK;
    END;

    SET v_nombre      = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.nombre'));
    SET v_descripcion = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.descripcion'));
    SET v_permisos    = JSON_EXTRACT(v_data,'$.permisos');

    START TRANSACTION;
    INSERT INTO roles (nombre, descripcion, id_estado) VALUES (v_nombre, v_descripcion, 1);
    SET v_nuevo_id = LAST_INSERT_ID();

    -- Asignar permisos si vienen en el JSON
    IF v_permisos IS NOT NULL AND JSON_LENGTH(v_permisos) > 0 THEN
        SET v_i = 0;
        WHILE v_i < JSON_LENGTH(v_permisos) DO
            SET v_id_permiso = JSON_UNQUOTE(JSON_EXTRACT(v_permisos, CONCAT('$[', v_i, ']')));
            INSERT INTO rol_permisos (id_rol, id_permiso) VALUES (v_nuevo_id, v_id_permiso);
            SET v_i = v_i + 1;
        END WHILE;
    END IF;
    COMMIT;

    SET v_salida = JSON_OBJECT('status','OK','message','Rol creado correctamente','data',JSON_OBJECT('id_rol',v_nuevo_id));
END$$

-- 15.6 Actualizar rol
DROP PROCEDURE IF EXISTS `sp_update_rol`$$
CREATE PROCEDURE `sp_update_rol` (IN `v_data` JSON, OUT `v_salida` JSON)
BEGIN
    DECLARE v_id_rol INT;
    DECLARE v_nombre VARCHAR(50);
    DECLARE v_descripcion TEXT;
    DECLARE v_id_estado INT;
    DECLARE v_permisos JSON;
    DECLARE v_i INT DEFAULT 0;
    DECLARE v_id_permiso INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @msg = MESSAGE_TEXT;
        SET v_salida = JSON_OBJECT('status','ERROR','message',CONCAT('Error al actualizar rol: ',@msg),'data',NULL);
        ROLLBACK;
    END;

    SET v_id_rol      = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_rol'));
    SET v_nombre      = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.nombre'));
    SET v_descripcion = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.descripcion'));
    SET v_id_estado   = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_estado'));
    SET v_permisos    = JSON_EXTRACT(v_data,'$.permisos');

    START TRANSACTION;
    UPDATE roles SET nombre = v_nombre, descripcion = v_descripcion
        WHERE id_rol = v_id_rol;

    -- Actualizar estado si se envió
    IF v_id_estado IS NOT NULL AND v_id_estado > 0 THEN
        UPDATE roles SET id_estado = v_id_estado WHERE id_rol = v_id_rol;
    END IF;

    -- Re-asignar permisos: borrar existentes
    DELETE FROM rol_permisos WHERE id_rol = v_id_rol;

    -- Insertar nuevos permisos si vienen en el JSON
    IF v_permisos IS NOT NULL AND JSON_LENGTH(v_permisos) > 0 THEN
        SET v_i = 0;
        WHILE v_i < JSON_LENGTH(v_permisos) DO
            SET v_id_permiso = JSON_UNQUOTE(JSON_EXTRACT(v_permisos, CONCAT('$[', v_i, ']')));
            INSERT INTO rol_permisos (id_rol, id_permiso) VALUES (v_id_rol, v_id_permiso);
            SET v_i = v_i + 1;
        END WHILE;
    END IF;
    COMMIT;

    SET v_salida = JSON_OBJECT('status','OK','message','Rol actualizado correctamente');
END$$

-- 15.7 Eliminar rol (solo si no tiene usuarios asignados)
DROP PROCEDURE IF EXISTS `sp_delete_rol`$$
CREATE PROCEDURE `sp_delete_rol` (IN `v_data` JSON, OUT `v_salida` JSON)
BEGIN
    DECLARE v_id_rol INT;
    DECLARE v_total INT;

    SET v_id_rol = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_rol'));

    SELECT COUNT(*) INTO v_total FROM usuarios WHERE id_rol = v_id_rol;

    IF v_total > 0 THEN
        SET v_salida = JSON_OBJECT('status','ERROR','message','No se puede eliminar el rol porque tiene usuarios asignados. Cambia el rol de los usuarios primero.');
    ELSE
        DELETE FROM roles WHERE id_rol = v_id_rol;
        SET v_salida = JSON_OBJECT('status','OK','message','Rol eliminado correctamente');
    END IF;
END$$

-- 15.8 Cambiar estado del rol
DROP PROCEDURE IF EXISTS `sp_update_rol_estado`$$
CREATE PROCEDURE `sp_update_rol_estado` (IN `v_data` JSON, OUT `v_salida` JSON)
BEGIN
    DECLARE v_id_rol INT;
    DECLARE v_id_estado INT;
    SET v_id_rol = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_rol'));
    SET v_id_estado = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_estado'));
    UPDATE roles SET id_estado = v_id_estado WHERE id_rol = v_id_rol;
    SET v_salida = JSON_OBJECT('status','OK','message','Estado del rol actualizado');
END$$

-- ============================================
-- 16. CRUD DE PERMISOS
-- ============================================

-- 16.1 Insertar permiso
DROP PROCEDURE IF EXISTS `sp_insert_permiso`$$
CREATE PROCEDURE `sp_insert_permiso` (IN `v_data` JSON, OUT `v_salida` JSON)
BEGIN
    DECLARE v_nombre VARCHAR(100);
    DECLARE v_modulo VARCHAR(50);
    DECLARE v_descripcion VARCHAR(255);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @msg = MESSAGE_TEXT;
        SET v_salida = JSON_OBJECT('status','ERROR','message',CONCAT('Error al crear permiso: ',@msg));
    END;

    SET v_nombre      = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.nombre'));
    SET v_modulo      = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.modulo'));
    SET v_descripcion = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.descripcion'));

    INSERT INTO permisos (nombre, modulo, descripcion) VALUES (v_nombre, v_modulo, v_descripcion);
    SET v_salida = JSON_OBJECT('status','OK','message','Permiso creado','data',JSON_OBJECT('id_permiso',LAST_INSERT_ID()));
END$$

-- 16.2 Actualizar permiso
DROP PROCEDURE IF EXISTS `sp_update_permiso`$$
CREATE PROCEDURE `sp_update_permiso` (IN `v_data` JSON, OUT `v_salida` JSON)
BEGIN
    DECLARE v_id_permiso INT;
    DECLARE v_nombre VARCHAR(100);
    DECLARE v_modulo VARCHAR(50);
    DECLARE v_descripcion VARCHAR(255);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @msg = MESSAGE_TEXT;
        SET v_salida = JSON_OBJECT('status','ERROR','message',CONCAT('Error al actualizar permiso: ',@msg));
    END;

    SET v_id_permiso  = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_permiso'));
    SET v_nombre      = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.nombre'));
    SET v_modulo      = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.modulo'));
    SET v_descripcion = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.descripcion'));

    UPDATE permisos SET nombre = v_nombre, modulo = v_modulo, descripcion = v_descripcion WHERE id_permiso = v_id_permiso;
    SET v_salida = JSON_OBJECT('status','OK','message','Permiso actualizado');
END$$

-- 16.3 Eliminar permiso
DROP PROCEDURE IF EXISTS `sp_delete_permiso`$$
CREATE PROCEDURE `sp_delete_permiso` (IN `v_data` JSON, OUT `v_salida` JSON)
BEGIN
    DECLARE v_id_permiso INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @msg = MESSAGE_TEXT;
        SET v_salida = JSON_OBJECT('status','ERROR','message',CONCAT('Error al eliminar permiso: ',@msg));
    END;

    SET v_id_permiso = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_permiso'));

    DELETE FROM rol_permisos WHERE id_permiso = v_id_permiso;
    DELETE FROM permisos WHERE id_permiso = v_id_permiso;
    SET v_salida = JSON_OBJECT('status','OK','message','Permiso eliminado');
END$$

-- ============================================
-- 17. CRUD DE TIPOS DE EVIDENCIA
-- ============================================

DROP PROCEDURE IF EXISTS `sp_get_tipos_evidencia`$$
CREATE PROCEDURE `sp_get_tipos_evidencia` (OUT `v_salida` JSON)
BEGIN
    DECLARE v_resultado JSON DEFAULT JSON_ARRAY();
    SELECT JSON_ARRAYAGG(JSON_OBJECT('id_tipo', id_tipo, 'tipo_nombre', tipo_nombre))
    INTO v_resultado FROM tipos_evidencia;
    SET v_salida = JSON_OBJECT('status','OK','data', JSON_EXTRACT(IFNULL(v_resultado, JSON_ARRAY()), '$'));
END$$

DROP PROCEDURE IF EXISTS `sp_insert_tipo_evidencia`$$
CREATE PROCEDURE `sp_insert_tipo_evidencia` (IN `v_data` JSON, OUT `v_salida` JSON)
BEGIN
    DECLARE v_nombre VARCHAR(50);
    SET v_nombre = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.tipo_nombre'));
    INSERT INTO tipos_evidencia (tipo_nombre) VALUES (v_nombre);
    SET v_salida = JSON_OBJECT('status','OK','message','Tipo de evidencia creado','data',JSON_OBJECT('id_tipo',LAST_INSERT_ID()));
END$$

DROP PROCEDURE IF EXISTS `sp_update_tipo_evidencia`$$
CREATE PROCEDURE `sp_update_tipo_evidencia` (IN `v_data` JSON, OUT `v_salida` JSON)
BEGIN
    DECLARE v_id_tipo INT;
    DECLARE v_nombre VARCHAR(50);
    SET v_id_tipo = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_tipo'));
    SET v_nombre  = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.tipo_nombre'));
    UPDATE tipos_evidencia SET tipo_nombre = v_nombre WHERE id_tipo = v_id_tipo;
    SET v_salida = JSON_OBJECT('status','OK','message','Tipo de evidencia actualizado');
END$$

DROP PROCEDURE IF EXISTS `sp_delete_tipo_evidencia`$$
CREATE PROCEDURE `sp_delete_tipo_evidencia` (IN `v_data` JSON, OUT `v_salida` JSON)
BEGIN
    DECLARE v_id_tipo INT;
    DECLARE v_total INT;
    SET v_id_tipo = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_tipo'));
    SELECT COUNT(*) INTO v_total FROM evidencias WHERE id_tipo = v_id_tipo;
    IF v_total > 0 THEN
        SET v_salida = JSON_OBJECT('status','ERROR','message','No se puede eliminar: hay evidencias usando este tipo.');
    ELSE
        DELETE FROM tipos_evidencia WHERE id_tipo = v_id_tipo;
        SET v_salida = JSON_OBJECT('status','OK','message','Tipo de evidencia eliminado');
    END IF;
END$$

-- ============================================
-- 18. CRUD DE EVIDENCIAS
-- ============================================

DROP PROCEDURE IF EXISTS `sp_get_evidencias_admin`$$
CREATE PROCEDURE `sp_get_evidencias_admin` (OUT `v_salida` JSON)
BEGIN
    DECLARE v_resultado JSON DEFAULT JSON_ARRAY();
    SELECT JSON_ARRAYAGG(
        JSON_OBJECT(
            'id_evidencia', e.id_evidencia,
            'titulo', e.titulo,
            'descripcion', e.descripcion,
            'fecha', e.fecha,
            'id_tipo', e.id_tipo,
            'tipo_nombre', te.tipo_nombre,
            'id_leccion', e.id_leccion,
            'id_subleccion', e.id_subleccion,
            'leccion_titulo', l.titulo,
            'subleccion_titulo', s.titulo
        )
    ) INTO v_resultado
    FROM evidencias e
    LEFT JOIN tipos_evidencia te ON e.id_tipo = te.id_tipo
    LEFT JOIN lecciones l ON e.id_leccion = l.id_leccion
    LEFT JOIN sublecciones s ON e.id_subleccion = s.id_subleccion;
    SET v_salida = JSON_OBJECT('status','OK','data', JSON_EXTRACT(IFNULL(v_resultado, JSON_ARRAY()), '$'));
END$$

DROP PROCEDURE IF EXISTS `sp_get_evidencia`$$
CREATE PROCEDURE `sp_get_evidencia` (IN `v_data` JSON, OUT `v_salida` JSON)
BEGIN
    DECLARE v_id INT;
    DECLARE v_resultado JSON;
    SET v_id = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_evidencia'));
    SELECT JSON_OBJECT(
        'id_evidencia', e.id_evidencia,
        'titulo', e.titulo,
        'descripcion', e.descripcion,
        'id_tipo', e.id_tipo,
        'id_leccion', e.id_leccion,
        'id_subleccion', e.id_subleccion
    ) INTO v_resultado
    FROM evidencias e WHERE e.id_evidencia = v_id;
    SET v_salida = JSON_OBJECT('status','OK','data', v_resultado);
END$$

DROP PROCEDURE IF EXISTS `sp_update_evidencia`$$
CREATE PROCEDURE `sp_update_evidencia` (IN `v_data` JSON, OUT `v_salida` JSON)
BEGIN
    DECLARE v_id_evidencia INT;
    DECLARE v_titulo VARCHAR(255);
    DECLARE v_descripcion TEXT;
    DECLARE v_id_tipo INT;
    DECLARE v_id_leccion INT;
    DECLARE v_id_subleccion INT;

    SET v_id_evidencia  = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_evidencia'));
    SET v_titulo        = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.titulo'));
    SET v_descripcion   = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.descripcion'));
    SET v_id_tipo       = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_tipo'));
    SET v_id_leccion    = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_leccion'));
    SET v_id_subleccion = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_subleccion'));

    UPDATE evidencias
    SET titulo = v_titulo, descripcion = v_descripcion, id_tipo = v_id_tipo,
        id_leccion = v_id_leccion, id_subleccion = v_id_subleccion
    WHERE id_evidencia = v_id_evidencia;
    SET v_salida = JSON_OBJECT('status','OK','message','Evidencia actualizada');
END$$

DROP PROCEDURE IF EXISTS `sp_delete_evidencia`$$
CREATE PROCEDURE `sp_delete_evidencia` (IN `v_data` JSON, OUT `v_salida` JSON)
BEGIN
    DECLARE v_id INT;
    SET v_id = JSON_UNQUOTE(JSON_EXTRACT(v_data,'$.id_evidencia'));
    DELETE FROM evidencias WHERE id_evidencia = v_id;
    SET v_salida = JSON_OBJECT('status','OK','message','Evidencia eliminada');
END$$

-- ============================================
-- 19. AVANCE DE ESTUDIANTES
-- ============================================

DROP PROCEDURE IF EXISTS `sp_get_avance_estudiantes`$$
CREATE PROCEDURE `sp_get_avance_estudiantes` (OUT `v_salida` JSON)
BEGIN
    DECLARE v_resultado JSON DEFAULT JSON_ARRAY();
    SELECT JSON_ARRAYAGG(
        JSON_OBJECT(
            'id_usuario', u.id_usuario,
            'nombre', CONCAT(u.nombre, ' ', u.apellido),
            'correo', u.correo,
            'cursos', (
                SELECT JSON_ARRAYAGG(
                    JSON_OBJECT(
                        'id_curso', c.id_curso,
                        'titulo', c.titulo,
                        'progreso', COALESCE(pc.progreso, 0),
                        'fecha_inscripcion', i.fecha_inscripcion
                    )
                )
                FROM inscripciones i
                INNER JOIN cursos c ON i.id_curso = c.id_curso
                LEFT JOIN progreso_curso pc ON pc.id_usuario = u.id_usuario AND pc.id_curso = c.id_curso
                WHERE i.id_usuario = u.id_usuario
            )
        )
    ) INTO v_resultado
    FROM usuarios u
    WHERE u.id_rol = 2
    ORDER BY u.nombre;
    SET v_salida = JSON_OBJECT('status','OK','data', JSON_EXTRACT(IFNULL(v_resultado, JSON_ARRAY()), '$'));
END$$

-- ============================================
-- 20. SUBLECCIONES PARA ADMIN
-- ============================================

DROP PROCEDURE IF EXISTS `sp_get_sublecciones_admin`$$
CREATE PROCEDURE `sp_get_sublecciones_admin` (OUT `v_salida` JSON)
BEGIN
    DECLARE v_resultado JSON DEFAULT JSON_ARRAY();
    SELECT JSON_ARRAYAGG(
        JSON_OBJECT(
            'id_subleccion', s.id_subleccion,
            'titulo', s.titulo,
            'id_leccion', s.id_leccion,
            'leccion_titulo', l.titulo,
            'modulo_titulo', m.titulo,
            'curso_titulo', c.titulo
        )
    ) INTO v_resultado
    FROM sublecciones s
    JOIN lecciones l ON s.id_leccion = l.id_leccion
    JOIN modulos m ON l.id_modulo = m.id_modulo
    JOIN cursos c ON m.id_curso = c.id_curso;
    SET v_salida = JSON_OBJECT('status','OK','data', JSON_EXTRACT(IFNULL(v_resultado, JSON_ARRAY()), '$'));
END$$

-- ============================================
-- 21. ELIMINAR GRUPO (con dependencias)
-- ============================================

DROP PROCEDURE IF EXISTS `sp_delete_grupo`$$
CREATE PROCEDURE `sp_delete_grupo` (IN `v_data` JSON, OUT `v_salida` JSON)
BEGIN
    DECLARE v_id_grupo INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @msg = MESSAGE_TEXT;
        SET v_salida = JSON_OBJECT('status','ERROR','message',CONCAT('Error al eliminar grupo: ',@msg),'data',NULL);
        ROLLBACK;
    END;

    SET v_id_grupo = JSON_UNQUOTE(JSON_EXTRACT(v_data, '$.id_grupo'));

    START TRANSACTION;
    DELETE FROM grupo_usuarios WHERE id_grupo = v_id_grupo;
    DELETE FROM grupo_lecciones WHERE id_grupo = v_id_grupo;
    DELETE FROM grupos WHERE id_grupo = v_id_grupo;
    COMMIT;

    SET v_salida = JSON_OBJECT('status','OK','message','Grupo eliminado correctamente','data',JSON_OBJECT('id_grupo',v_id_grupo));
END$$

DELIMITER ;
