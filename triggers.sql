USE success_mindset;

-- Creacion de las tablas de auditoria
CREATE TABLE AUD_USUARIO(
	id_audit INT AUTO_INCREMENT PRIMARY KEY,
    id_user INT UNIQUE,
	user VARCHAR(255) NOT NULL,
    date DATETIME NOT NULL
);

CREATE TABLE AUD_PUBLICACION(
	id_audit INT AUTO_INCREMENT PRIMARY KEY,
    id_publication INT UNIQUE,
    user VARCHAR(255) NOT NULL,
    date DATETIME NOT NULL
)

-- Creacion de los TRIGGERS
-- TR_CONTRASENA_SEGURA: este trigger sirve para generar el encriptado de la contrasena del usuario
-- al momento de insertar el registro
DELIMITER //
CREATE TRIGGER tr_contrasena_segura
BEFORE INSERT ON usuario
FOR EACH ROW
BEGIN
	DECLARE encrypted_password VARCHAR(255);
    SET encrypted_password = SHA2(NEW.user_password, 256);
    SET NEW.user_password = encrypted_password;
END//
DELIMITER ;

-- TR_NUEVO_USUARIO: este trigger sirve para llevar un trackeo de los usuarios que se van registrando en
-- la pagina web.
CREATE TRIGGER tr_nuevo_usuario
AFTER INSERT ON usuario
FOR EACH ROW
INSERT INTO AUD_USUARIO
VALUES (NULL, NEW.id_user, SESSION_USER(), CURRENT_TIMESTAMP());

-- TR_VALIDACIONES_PUBLICACION: este trigger sirve para realizar validaciones adicionales al momento de insertar
-- una publicacion, tales como control de cantidad de stock y de precios
DELIMITER //
CREATE TRIGGER tr_validaciones_publicacion
BEFORE INSERT ON publicacion
FOR EACH ROW
BEGIN
	IF NEW.stock <= 0 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El stock no puede ser un valor negativo o cero';
    END IF;
    IF NEW.price <= 0 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El precio no puede ser un valor negativo o cero';
    END IF;
END//
DELIMITER ;

-- TR_NUEVA_PUBLICACION: este trigger sirve para llevar un trackeo de las publicaciones nuevas en la pagina web
CREATE TRIGGER tr_nueva_publicacion
AFTER INSERT ON publicacion
FOR EACH ROW
INSERT INTO AUD_PUBLICACION
VALUES(NULL, NEW.id_publication, SESSION_USER(), CURRENT_TIMESTAMP());