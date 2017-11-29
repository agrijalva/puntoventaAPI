-- phpMyAdmin SQL Dump
-- version 4.6.5.2
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 27-11-2017 a las 23:22:46
-- Versión del servidor: 10.1.21-MariaDB
-- Versión de PHP: 5.6.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `asesoria`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE PROCEDURE `ADM_CTC_SP` ()  BEGIN
	SELECT * FROM catalogotipocliente;
END$$

CREATE PROCEDURE `ADM_LOGIN_SP` (IN `_user` VARCHAR(255) CHARSET utf8, IN `_pass` VARCHAR(255) CHARSET utf8)  BEGIN
	SELECT * FROM usuario 			 USU
	INNER JOIN empresa 				 EMP   ON USU.emp_id = EMP.emp_id
    INNER JOIN catalogousuario 		 CU 	  ON USU.cu_id = CU.cu_id
    INNER JOIN configuracionempresa  CONF  ON CONF.emp_id = EMP.emp_id
	WHERE CU.cu_id = 2
		  AND usu_usuario = _user
		  AND usu_password = _pass
		  AND usu_estatus = 1;
END$$

CREATE PROCEDURE `ARE_CLIENTES_TODOS_BY_EJE_SP` (IN `idEjecutivo` INT(30))  BEGIN
	SELECT DISTINCT(CAT.ca_id), CAT.ca_nombre
	FROM clientearea CA 
	INNER JOIN catalogoarea CAT ON CA.ca_id = CAT.ca_id
	INNER JOIN cliente CLI ON CLI.cli_id = CA.cli_id
	INNER JOIN clienteejecutivo CE ON CE.cli_id = CLI.cli_id
	WHERE eje_id = idEjecutivo AND clej_estatus = 1 AND clar_estatus =1;
END$$

CREATE PROCEDURE `ARE_POR_EMPRESA_SP` (IN `idEmpresa` INT(30), IN `idCliente` INT)  BEGIN	
	SELECT *,
    (SELECT COUNT(clar_id) FROM clientearea WHERE cli_id = idCliente AND ca_id = CA.ca_id AND clar_estatus = 1) as checked
	FROM empresaarea EMPAR
	INNER JOIN catalogoarea CA ON EMPAR.ca_id = CA.ca_id
	WHERE emp_id = idEmpresa;
	
END$$

CREATE PROCEDURE `CHAT_GET_CLIENTE_SP` (IN `_IdRep` INTEGER, IN `_IdEje` INTEGER, IN `LastId` INTEGER)  BEGIN
	SELECT men_id, rep_id, men_tipo_usuario as autor, men_mensaje as mensaje, 'Yo' as nombre, `timestamp` as fecha      FROM mensajes
	WHERE men_id > LastId 
		  AND eje_id = _IdEje 
          AND rep_id = _IdRep
	LIMIT 1;
END$$

CREATE PROCEDURE `CHAT_GET_EJECUTIVOBUCLE_SP` (IN `_IdEje` INTEGER, IN `LastId` INTEGER)  BEGIN
	SELECT *, TIME(timestamp),CONCAT(HOUR(timestamp),':', MINUTE(timestamp)) AS Hora  FROM mensajes
	WHERE men_id > LastId AND  eje_id = _IdEje
    ORDER BY rep_id, timestamp;
END$$

CREATE PROCEDURE `CHAT_GET_EJECUTIVO_SP` (IN `_IdEje` INTEGER, IN `_IdRep` INTEGER, IN `LastId` INTEGER)  BEGIN
	DECLARE limite INT;
    DECLARE tope INT;
    
    SET limite = ( SELECT COUNT(men_id) men_id FROM mensajes WHERE men_id > LastId AND  eje_id = _IdEje AND rep_id = _IdRep );
    SET tope = 10;
    SET limite = (limite - tope);
    
	SELECT *, TIME(timestamp),CONCAT(HOUR(timestamp),':', MINUTE(timestamp)) AS Hora  FROM mensajes
	WHERE men_id > LastId AND  eje_id = _IdEje AND rep_id = _IdRep
    ORDER BY rep_id, timestamp
    LIMIT limite, tope;

	/*
	-- Declare local variables
   DECLARE done BOOLEAN DEFAULT 0;
   DECLARE idRep INT;
   DECLARE limite INT;
   DECLARE margenLimite INT;
   
	-- declare cursor for employee email
	DEClARE representantes CURSOR FOR 
	SELECT DISTINCT(rep_id) AS Rep FROM mensajes WHERE men_id > LastId AND  eje_id = _IdEje ORDER BY rep_id, timestamp;
	
    -- Declare continue handler
    DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done=1;
   
    OPEN representantes;
		REPEAT
		  -- Get order number
		  FETCH representantes INTO idRep;
          -- select idRep as 'valor';
			SET limite = (  SELECT COUNT(men_id) FROM mensajes
							WHERE men_id > LastId AND  eje_id = _IdEje AND rep_id = idRep);
                            
			SET margenLimite = limite - 50;
            
            IF( limite < 50 ) THEN
				SELECT * FROM mensajes
				WHERE men_id > LastId AND  eje_id = _IdEje AND rep_id = idRep ORDER BY rep_id, timestamp;
            ELSE
				SELECT * FROM mensajes
				WHERE men_id > LastId AND  eje_id = _IdEje AND rep_id = idRep ORDER BY rep_id, timestamp LIMIT margenLimite, limite;
            END IF;
            
            
	   -- End of loop
	    UNTIL done END REPEAT;
    CLOSE representantes;
    
    */
END$$

CREATE PROCEDURE `CHAT_GUARDA_MENSAJE_SP` (IN `_mensaje` VARCHAR(1000) CHARSET utf8, IN `_IdRep` INTEGER, IN `_IdEje` INTEGER, IN `_Tipo` INTEGER, IN `_Empresa` INTEGER)  BEGIN
	INSERT INTO mensajes(men_mensaje, rep_id, eje_id, men_tipo_usuario, emp_id) VALUES(_mensaje, _IdRep, _IdEje, _Tipo, _Empresa);
    SELECT 1 AS success, LAST_INSERT_ID() as LastID;
END$$

CREATE PROCEDURE `CLI_ACTUALIZAR_SP` (IN `idCliente` INT(20), IN `_razon` VARCHAR(250) CHARSET utf8, IN `_rfc` VARCHAR(50) CHARSET utf8)  BEGIN
	
    UPDATE cliente SET
						cli_rason_social = _razon,
                        cli_rfc = _rfc
	WHERE cli_id = idCliente;
    SELECT 1 AS 'success', 'Cliente actualizado correctamente' AS 'msg';
    
   
END$$

CREATE PROCEDURE `CLI_AGENTEPRINCIPAL_SP` (IN `idClej` INT)  BEGIN
	DECLARE idCliente INT;
    SET idCliente = (SELECT cli_id FROM clienteejecutivo WHERE clej_id = idClej);
    
    UPDATE clienteejecutivo SET clej_primario = 2 WHERE cli_id = idCliente;
    UPDATE clienteejecutivo SET clej_primario = 1 WHERE clej_id = idClej;
    
    SELECT 1 AS success, 'Se ha asignado un nuevo agente principal de forma correcta' AS msg;
END$$

CREATE PROCEDURE `CLI_ASIGNAAGENTE_SP` (IN `idCliente` INT, IN `idEjecutivo` INT)  BEGIN
	INSERT INTO clienteejecutivo(cli_id, eje_id, clej_estatus, clej_primario) values( idCliente, idEjecutivo, 1, 2 );
    SELECT 1 AS success, 'Se ha asignado un nuevo agente' AS msg;
END$$

CREATE PROCEDURE `CLI_ASIGNA_AREA_SP` (IN `idCliente` INT, IN `idArea` INT, IN `Estatus` INT)  BEGIN        
	DECLARE idClar INT;
    SET idClar = ( SELECT clar_id FROM clientearea WHERE cli_id = idCliente AND ca_id = idArea);
        
    IF( idClar IS NULL )THEN
		INSERT INTO clientearea(cli_id, ca_id, clar_estatus) VALUES( idCliente, idArea, Estatus);
		SELECT 'Área asignada.' as msg;
	ELSE
		UPDATE clientearea SET clar_estatus = Estatus WHERE clar_id = idClar;
        IF( Estatus = 1 )THEN
			SELECT 'Se ha asignado.' as msg;
        ELSE
			SELECT 'Se ha desvinculado.' as msg;
        END IF;
    END IF;
END$$

CREATE PROCEDURE `CLI_CONTROLACTIVIDAD_SP` (IN `idCliente` INT)  BEGIN
	DECLARE estatus INT;
    DECLARE msg VARCHAR(300);
    SET estatus = (SELECT cli_estatus FROM cliente WHERE cli_id = idCliente);
    
    IF( estatus = 0 )THEN
		SET estatus = 1;
        SET msg = 'El cliente se ha activado nuevamente';
    ELSE
		SET estatus = 0;
        SET msg = 'El cliente se ha desactivado';
    END IF;
    
	UPDATE cliente SET cli_estatus = estatus WHERE cli_id = idCliente;
	SELECT 1 as 'success', msg as 'msg';
END$$

CREATE PROCEDURE `CLI_GET_ONE_SP` (IN `_Key` VARCHAR(50) CHARSET utf8)  BEGIN  
	DECLARE idCliente INT(30);
    DECLARE idRelacion INT;
        
    SET idCliente = ( SELECT cli_id FROM cliente WHERE `key` = _Key );    
    SELECT * FROM cliente CLI WHERE `key` = _Key;
    -- SET idRelacion = ( SELECT clej_id FROM clienteejecutivo WHERE clej_estatus = 1 AND cli_id = idCliente );
    /*
    IF( idRelacion IS NULL )THEN
		SELECT * FROM cliente CLI WHERE `key` = _Key;
    ELSE
		SELECT CLI.*, eje_id  FROM cliente CLI
		LEFT JOIN clienteejecutivo CLEJ ON CLI.cli_id = CLEJ.cli_id
		WHERE `key` = _Key AND clej_estatus = 1 AND clej_primario = 1;
    END IF;*/
END$$

CREATE PROCEDURE `CLI_INSERTAR_NUEVO_SP` (IN `idEmpresa` INT(20), IN `_razon` VARCHAR(250) CHARSET utf8, IN `_rfc` VARCHAR(50) CHARSET utf8, IN `_email` VARCHAR(60) CHARSET utf8)  BEGIN
	DECLARE idRep INT(20);
    DECLARE _key VARCHAR(100);
    
    SET idRep = ( SELECT rep_id FROM representante WHERE rep_email = _email );
    SET _key  = MD5( CURRENT_TIMESTAMP );	
    
    IF( idRep IS NOT NULL )THEN
		SELECT 0 AS 'success', 'El email que proporciona ya esta registrado en la base de datos' AS 'msg';
    ELSE
		INSERT INTO cliente(cli_rason_social, cli_rfc, `key`, cli_estatus, emp_id) VALUES(_razon, _rfc, _key, 1, idEmpresa);
        SELECT 1 AS 'success', 'Se ha registrado correctamente un nuevo cliente' AS 'msg', LAST_INSERT_ID() as 'LastId', _key as 'key';
        
        -- INSERT INTO usuario(usu_usuario, usu_password, usu_estatus, cu_id, emp_id) values(_email, _pass, 1, 4, idEmpresa );
    END IF;
END$$

CREATE PROCEDURE `CLI_LOGIN_SP` (IN `user` VARCHAR(150) CHARSET utf8, IN `pass` VARCHAR(150) CHARSET utf8)  BEGIN
	SELECT * FROM usuario USU
	INNER JOIN representante REP ON usu_usuario = rep_email
	INNER JOIN clienteejecutivo CE ON REP.cli_id = CE.cli_id
	INNER JOIN ejecutivo EJE ON CE.eje_id = EJE.eje_id
	WHERE cu_id = 4
		  AND usu_usuario = user
		  AND usu_password = pass
		  AND CE.clej_estatus = 1
		  AND clej_primario = 1;
	/*SELECT * FROM usuario USU
	INNER JOIN cliente CLI ON usu_usuario = cli_email
	INNER JOIN clienteejecutivo CE ON CLI.cli_id = CE.cli_id
	INNER JOIN ejecutivo EJE ON CE.eje_id = EJE.eje_id
	WHERE cu_id = 4
		  AND usu_usuario = user
		  AND usu_password = pass
		  AND CE.clej_estatus = 1;*/
END$$

CREATE PROCEDURE `CLI_POR_EJECUTIVO_SP` (IN `idEje` INT(60))  BEGIN
	/*SELECT *
	FROM clienteejecutivo CE
	INNER JOIN cliente CLI ON CE.cli_id = CLI.cli_id
	WHERE `eje_id` = idEje AND clej_estatus != 0;*/
    SELECT *
	FROM representante REP
	INNER JOIN clienteejecutivo CE ON REP.cli_id = CE.cli_id
	INNER JOIN cliente CLI ON CE.cli_id = CLI.cli_id
	WHERE `eje_id` = idEje AND clej_estatus != 0;
END$$

CREATE PROCEDURE `CLI_POR_EJECUTIVO_SP_TEST` (IN `_Ideje` VARCHAR(255) CHARSET utf8, IN `_Tpro` VARCHAR(255) CHARSET utf8)  BEGIN
	SET @baseCliente = 'informacionspf';
	SET @Query = CONCAT('SELECT * FROM ',@baseCliente,'.clientes CLI 
							LEFT JOIN ',@baseCliente,'.treg ON CLI.Treg = treg.Idtr
                            LEFT JOIN ',@baseCliente,'.tpro ON CLI.Tpro = tpro.Idto
                            LEFT JOIN ',@baseCliente,'.ttip ON CLI.Ttip = ttip.Idtp
                            LEFT JOIN ',@baseCliente,'.ejecutivos EJE ON CLI.Ideje = EJE.Ideje
                            WHERE CLI.Ideje = ', _Ideje);
	
    IF( _Tpro <> 0 ) THEN
		SET @Query = CONCAT( @Query , ' AND Tpro = ', _Tpro );
    END IF;
    
	PREPARE smpt FROM @Query;
	EXECUTE smpt;
	DEALLOCATE PREPARE smpt;
END$$

CREATE PROCEDURE `CLI_POR_EMPRESA_AREAS_SP` (IN `idCliente` INT(30))  BEGIN
	SELECT  CA.*, 
			ARE.*
    FROM cliente CLI
	INNER JOIN clientearea CA       ON CLI.cli_id = CA.cli_id
	INNER JOIN catalogoarea ARE 	ON ARE.ca_id = CA.ca_id
	WHERE CA.cli_id = idCliente 
		  AND cli_estatus = 1;
END$$

CREATE PROCEDURE `CLI_POR_EMPRESA_SP` (IN `idEmpresa` INT(30))  BEGIN
	SELECT  *,
			(SELECT COUNT(clar_id) FROM clientearea
			 WHERE cli_id = CLI.cli_id AND clar_estatus = 1) AS Areas_Count,
			IFNULL( (SELECT eje_id FROM clienteejecutivo
			 WHERE cli_id = CLI.cli_id AND clej_estatus = 1 AND clej_primario = 1), 0) AS idEjecutivo,
			3 as noResponsable
	FROM cliente CLI
			WHERE emp_id = idEmpresa 
		  AND cli_estatus IN (0,1);
END$$

CREATE PROCEDURE `CLI_QUITARAGENTE_SP` (IN `idClej` INT)  BEGIN
	DELETE FROM clienteejecutivo WHERE clej_id= idClej;
    SELECT 1 AS success, 'Se ha eliminado de forma correcta' AS msg;
END$$

CREATE PROCEDURE `CLI_UPD_EDITAR_SP` (IN `idCliente` INT, IN `_razon` VARCHAR(500) CHARSET utf8, IN `_rfc` VARCHAR(20) CHARSET utf8)  BEGIN
	UPDATE Cliente SET cli_rfc = _rfc, cli_rason_social = _razon WHERE cli_id = idCliente;
    SELECT 1 AS 'success', 'Se ha actualizado correctamente la informacion del cliente' AS 'msg';
END$$

CREATE PROCEDURE `CLI_USOAREA_SP` (IN `idCliente` INT, IN `idArea` INT)  BEGIN
	SELECT COUNT(EJAR.ejar_id) total FROM ejecutivoarea EJAR
	INNER JOIN ejecutivo EJE ON EJAR.eje_id = EJE.eje_id
	INNER JOIN clienteejecutivo CLEJ ON CLEJ.eje_id = EJE.eje_id
	WHERE CLEJ.cli_id = idCliente AND EJAR.ejar_estatus = 1 AND EJAR.ca_id = idArea;
END$$

CREATE PROCEDURE `EJE_ACTUALIZAR_INFO_SP` (IN `idEjecutivo` INT(30), IN `eje_nombre` VARCHAR(250) CHARSET utf8, IN `eje_email` VARCHAR(250) CHARSET utf8, IN `eje_telefono` VARCHAR(150) CHARSET utf8, IN `eje_celular` VARCHAR(150) CHARSET utf8)  BEGIN
	UPDATE ejecutivo SET `eje_nombre` = eje_nombre, `eje_email` = eje_email, `eje_telefono` = eje_telefono, `eje_celular` = eje_celular WHERE eje_id = idEjecutivo;
    SELECT 1 'success';
END$$

CREATE PROCEDURE `EJE_AREA_EJECUTIVO_SP` (IN `aje_id` NUMERIC(30))  BEGIN    
	SELECT EJAR.*, CA.* FROM ejecutivoarea EJAR
	INNER JOIN ejecutivo EJE ON EJAR.eje_id = EJE.eje_id
	INNER JOIN catalogoarea CA ON EJAR.ca_id = CA.ca_id
	WHERE EJE.eje_id = aje_id;
END$$

CREATE PROCEDURE `EJE_ASIGNAR_AREA_SP` (IN `idEjecutivo` INT(30), IN `idArea` INT(30), IN `estatus` INT(1))  BEGIN
	DECLARE idRel INT(30);
    DECLARE estatus_actual INT(30);
    
    SET idRel = ( SELECT ejar_id FROM ejecutivoarea WHERE eje_id = idEjecutivo AND ca_id = idArea );    
	SET estatus_actual = ( SELECT ejar_estatus FROM ejecutivoarea WHERE eje_id = idEjecutivo AND ca_id = idArea );
    
    IF(idRel IS NULL)THEN
		IF( estatus = 1 ) THEN
			INSERT INTO ejecutivoarea(eje_id, ca_id, ejar_estatus) values( idEjecutivo, idArea, 1 );
			SELECT 'Se ha asignado el &aacute;rea al ejecutivo.' as msg, 'success' as label;
        ELSE
			SELECT 'Sin cambios.' as msg, 'default' as label;
        END IF;
    ELSE
		IF( estatus_actual = estatus ) THEN
			SELECT 'Sin cambios.' as msg, 'default' as label;
        ELSE
			UPDATE ejecutivoarea SET ejar_estatus = estatus WHERE ejar_id = idRel;
			IF( estatus = 2 ) THEN
				SELECT 'Se ha deshabilitado esta &aacute;rea.' as msg, 'warning' as label;
			ELSE
				SELECT 'Se ha vuelo a reasignar el &aacute;rea.' as msg, 'success' as label;
			END IF;
        END IF;
    END IF;
END$$

CREATE PROCEDURE `EJE_ASIGNAR_CLIENTE_SP` (IN `idEjecutivo` INT(30), IN `idCliente` INT(30), IN `estatus` INT(1))  BEGIN
	DECLARE idRel INT(30);
    DECLARE estatus_actual INT(30);
        
    SET idRel = ( SELECT clej_id FROM clienteejecutivo WHERE cli_id = idCliente AND eje_id = idEjecutivo );
	SET estatus_actual = ( SELECT clej_estatus FROM clienteejecutivo WHERE cli_id = idCliente AND eje_id = idEjecutivo );
        
    IF(idRel IS NULL)THEN
		IF( estatus = 1 ) THEN
			UPDATE clienteejecutivo SET clej_estatus = 2 WHERE cli_id = idCliente;
			INSERT INTO clienteejecutivo(cli_id, eje_id, clej_estatus) values( idCliente, idEjecutivo, 1 );
			SELECT 'Se ha asignado el cliente al ejecutivo.' as msg, 'success' as label;
        ELSE
			SELECT 'Sin cambios.' as msg, 'default' as label;
        END IF;
    ELSE
		IF( estatus_actual = estatus ) THEN
			SELECT 'Sin cambios.' as msg, 'default' as label;
        ELSE
			DELETE FROM clienteejecutivo WHERE cli_id = idCliente;
            SELECT 'Cliente desvinculado' as msg, 'warning' as label;
            /*
			UPDATE clienteejecutivo SET clej_estatus = 2 WHERE cli_id = idCliente;
			UPDATE clienteejecutivo SET clej_estatus = estatus WHERE clej_id = idRel;
			IF( estatus = 2 ) THEN
				SELECT 'Cliente desvinculado' as msg, 'warning' as label;
			ELSE
				SELECT 'Cliente Asignado' as msg, 'success' as label;
			END IF;
            */
        END IF;
    END IF;
END$$

CREATE PROCEDURE `EJE_BY_AREAS_AND_CUSTOMER_SP` (IN `idArea` VARCHAR(250) CHARSET utf8, IN `idEmpresa` INT, IN `idEjecutivo` INT)  BEGIN
	SET @Query = CONCAT('SELECT DISTINCT( eje_nombre ) Nombre, EJE.eje_id, 
						 CASE EJE.eje_id WHEN ',idEjecutivo,' THEN 1 ELSE 0 END as Selected
						 FROM ejecutivoarea ARE
						 INNER JOIN ejecutivo EJE ON ARE.eje_id = EJE.eje_id
						 WHERE ejar_estatus = 1 AND EJE.emp_id = ', idEmpresa ,' AND ca_id IN (', idArea,');');
	    
	PREPARE smpt FROM @Query;
	EXECUTE smpt;
	DEALLOCATE PREPARE smpt;
END$$

CREATE PROCEDURE `EJE_BY_AREAS_SP` (IN `idArea` VARCHAR(250) CHARSET utf8, IN `idEmpresa` INT)  BEGIN        
	SET @Query = CONCAT('SELECT DISTINCT( eje_nombre ) Nombre, EJE.eje_id FROM ejecutivoarea ARE
						 INNER JOIN ejecutivo EJE ON ARE.eje_id = EJE.eje_id
						 WHERE ejar_estatus = 1 AND EJE.emp_id = ', idEmpresa ,' AND ca_id IN (', idArea,');');
	    
	PREPARE smpt FROM @Query;
	EXECUTE smpt;
	DEALLOCATE PREPARE smpt;
    
END$$

CREATE PROCEDURE `EJE_CAMBIO_ESTATUS_SP` (IN `idEje` INT(30), IN `idEstatus` INT(1))  BEGIN
	DECLARE idHistorico INT(30);
    SET idHistorico = ( SELECT hee_id FROM historialestatusejecutivo WHERE eje_id = idEje ORDER BY hee_id DESC LIMIT 1 );
    
    IF( idHistorico IS NOT NULL ) THEN
		UPDATE historialestatusejecutivo SET hee_fecha_fin = NOW() WHERE hee_id = idHistorico;
    END IF;
    
    UPDATE ejecutivo SET ese_id = idEstatus WHERE eje_id = idEje;
    INSERT INTO historialestatusejecutivo( eje_id, ese_id, hee_fecha_inicio ) VALUES( idEje, idEstatus, NOW() );
    
    SELECT 1 'success';
END$$

CREATE PROCEDURE `EJE_GET_ALL_SP` (IN `emp_id` NUMERIC(30), IN `eje_id` NUMERIC(30))  BEGIN    
	SET @Query = CONCAT('SELECT *,
				  (SELECT COUNT(clej_id) Total FROM clienteejecutivo CLEJ 
					INNER JOIN cliente CLI ON CLI.cli_id = CLEJ.cli_id
					INNER JOIN ejecutivo EJE ON EJE.eje_id = CLEJ.eje_id
					WHERE EJE.eje_id = EJEC.eje_id AND clej_estatus = 1 AND cli_estatus = 1) Clientes_Asignados,
				  (SELECT COUNT(ejar_id) Total FROM ejecutivoarea EJAR
					INNER JOIN ejecutivo EJE ON EJAR.eje_id = EJE.eje_id
					INNER JOIN catalogoarea CA ON EJAR.ca_id = CA.ca_id
					WHERE EJE.eje_id = EJEC.eje_id AND ejar_estatus = 1) Areas_Asignadas
				  FROM ejecutivo EJEC 
				  WHERE emp_id = ', emp_id);
	
    IF( eje_id <> 0 ) THEN
		SET @Query = CONCAT( @Query , ' AND eje_id = ', eje_id );
    END IF;
        
	PREPARE smpt FROM @Query;
	EXECUTE smpt;
	DEALLOCATE PREPARE smpt;
END$$

CREATE PROCEDURE `EJE_GET_BY_CLIENTE_SP` (IN `idCliente` VARCHAR(60) CHARSET utf8)  BEGIN    
	SELECT *,
	  (SELECT COUNT(clej_id) Total FROM clienteejecutivo CLEJ 
		INNER JOIN cliente CLI ON CLI.cli_id = CLEJ.cli_id
		INNER JOIN ejecutivo EJE ON EJE.eje_id = CLEJ.eje_id
		WHERE EJE.eje_id = EJEC.eje_id AND clej_estatus = 1) Clientes_Asignados,
	  (SELECT COUNT(ejar_id) Total FROM ejecutivoarea EJAR
		INNER JOIN ejecutivo EJE ON EJAR.eje_id = EJE.eje_id
		INNER JOIN catalogoarea CA ON EJAR.ca_id = CA.ca_id
		WHERE EJE.eje_id = EJEC.eje_id AND ejar_estatus = 1) Areas_Asignadas
	FROM ejecutivo EJEC
    INNER JOIN clienteejecutivo CLEJ ON EJEC.eje_id = CLEJ.eje_id
	WHERE CLEJ.cli_id = idCliente AND CLEJ.clej_estatus != 0;
END$$

CREATE PROCEDURE `EJE_GET_BY_ID_SP` (IN `idEje` VARCHAR(60) CHARSET utf8)  BEGIN    
	SELECT *,
	  (SELECT COUNT(clej_id) Total FROM clienteejecutivo CLEJ 
		INNER JOIN cliente CLI ON CLI.cli_id = CLEJ.cli_id
		INNER JOIN ejecutivo EJE ON EJE.eje_id = CLEJ.eje_id
		WHERE EJE.eje_id = EJEC.eje_id AND clej_estatus = 1) Clientes_Asignados,
	  (SELECT COUNT(ejar_id) Total FROM ejecutivoarea EJAR
		INNER JOIN ejecutivo EJE ON EJAR.eje_id = EJE.eje_id
		INNER JOIN catalogoarea CA ON EJAR.ca_id = CA.ca_id
		WHERE EJE.eje_id = EJEC.eje_id AND ejar_estatus = 1) Areas_Asignadas
	FROM ejecutivo EJEC
	WHERE eje_id = idEje; 
END$$

CREATE PROCEDURE `EJE_GET_BY_KEY_SP` (IN `clave` VARCHAR(60) CHARSET utf8)  BEGIN    
	SELECT *,
	  (SELECT COUNT(clej_id) Total FROM clienteejecutivo CLEJ 
		INNER JOIN cliente CLI ON CLI.cli_id = CLEJ.cli_id
		INNER JOIN ejecutivo EJE ON EJE.eje_id = CLEJ.eje_id
		WHERE EJE.eje_id = EJEC.eje_id AND clej_estatus = 1) Clientes_Asignados,
	  (SELECT COUNT(ejar_id) Total FROM ejecutivoarea EJAR
		INNER JOIN ejecutivo EJE ON EJAR.eje_id = EJE.eje_id
		INNER JOIN catalogoarea CA ON EJAR.ca_id = CA.ca_id
		WHERE EJE.eje_id = EJEC.eje_id AND ejar_estatus = 1) Areas_Asignadas
	FROM ejecutivo EJEC
	WHERE `key` = clave; 
END$$

CREATE PROCEDURE `EJE_INSERTAR_NUEVO_SP` (IN `_nombre` VARCHAR(250) CHARSET utf8, IN `_telefono` VARCHAR(50) CHARSET utf8, IN `_celular` VARCHAR(50) CHARSET utf8, IN `_email` VARCHAR(50) CHARSET utf8, IN `_idEmp` VARCHAR(50) CHARSET utf8, IN `_key` VARCHAR(50) CHARSET utf8)  BEGIN
	DECLARE idEje INT(20);
    DECLARE _pass VARCHAR(20);
    
    SET idEje  = ( SELECT eje_id FROM ejecutivo WHERE eje_email = _email );
        SET _pass  = 'qwerty';
    
    IF( idEje IS NOT NULL )THEN
		SELECT 0 AS 'success', 'El email que proporciona ya esta registrado en la base de datos' AS 'msg';
    ELSE
		INSERT INTO ejecutivo(eje_nombre, eje_telefono, eje_celular, eje_email, ese_id, emp_id, `key`) VALUES(_nombre, _telefono, _celular, _email, 1, _idEmp, _key);
        SELECT 1 AS 'success', 'Se ha registrado correctamente un nuevo ejecutivo' AS 'msg', LAST_INSERT_ID() as 'LastId', _key as 'key', _pass as 'pass';
        
        INSERT INTO usuario(usu_usuario, usu_password, usu_estatus, cu_id, emp_id) values(_email, _pass, 1, 3, _idEmp );
    END IF;
    
END$$

CREATE PROCEDURE `EJE_LOGIN_SP` (IN `user` VARCHAR(150) CHARSET utf8, IN `pass` VARCHAR(150) CHARSET utf8)  BEGIN
    SELECT * FROM usuario USU
	INNER JOIN ejecutivo EJE ON usu_usuario = eje_email
	WHERE cu_id = 3
		  AND usu_usuario = user
		  AND usu_password = pass;
END$$

CREATE PROCEDURE `REP_ACTUALIZAR_SP` (IN `idRepresentante` INT, IN `rNombre` VARCHAR(250) CHARSET utf8, IN `rTelefono` VARCHAR(30) CHARSET utf8)  BEGIN
	UPDATE representante SET rep_nombre = rNombre, rep_telefono = rTelefono WHERE rep_id = idRepresentante;
    SELECT 1 as 'success', 'Se ha actualizado de forma correcta' as 'msg';
END$$

CREATE PROCEDURE `RESTORE_DATA` ()  BEGIN
	TRUNCATE `cliente`;
    Select 'Restaurando tabla cliente' as  'msg';
    
	TRUNCATE `clientearea`;
    Select 'Restaurando tabla clientearea' as  'msg';
    
	TRUNCATE `clienteejecutivo`;
    Select 'Restaurando tabla clienteejecutivo' as  'msg';
    
	TRUNCATE `ejecutivo`;
    Select 'Restaurando tabla ejecutivo' as  'msg';
    
	TRUNCATE `ejecutivoarea`;
    Select 'Restaurando tabla ejecutivoarea' as  'msg';
    
	TRUNCATE `mensajes`;
    Select 'Restaurando tabla mensajes' as  'msg';
    
	TRUNCATE `representante`;
    Select 'Restaurando tabla representante' as  'msg';
    
    DELETE FROM usuario WHERE usu_id > 2;
    Select 'Restaurando tabla usuarios' as  'msg';
END$$

CREATE PROCEDURE `RES_DELETE_SP` (IN `idRep` INT)  BEGIN
	UPDATE representante SET rep_estatus = 0 WHERE rep_id = idRep;
    SELECT 1 as 'success', 'Se ha eliminado de forma correcta' as 'msg';
END$$

CREATE PROCEDURE `RES_GET_BY_CLIENTE_SP` (IN `idCliente` INT)  BEGIN
	SELECT REP.*, CTC.* FROM representante REP
	INNER JOIN cliente CLI ON REP.cli_id = CLI.cli_id
	INNER JOIN catalogotipocliente CTC ON CTC.ctc_id = REP.ctc_id
	WHERE CLI.cli_id = idCliente AND REP.rep_estatus != 0;
END$$

CREATE PROCEDURE `RES_INSERTAR_NUEVO_SP` (IN `idCliente` INT(20), IN `_nombre` VARCHAR(250) CHARSET utf8, IN `_email` VARCHAR(250) CHARSET utf8, IN `_telefono` VARCHAR(250) CHARSET utf8, IN `idEmpresa` INT(20), IN `idCtc` INT(20))  BEGIN
	DECLARE idRep INT(20);
	DECLARE _pass VARCHAR(20);
    DECLARE _key VARCHAR(100);
    
    SET idRep = ( SELECT rep_id FROM representante WHERE rep_email = _email );
    SET _pass = 'qwerty';
    SET _key  = MD5( CURRENT_TIMESTAMP );
    
    IF( idRep IS NOT NULL )THEN
		SELECT 0 AS 'success', 'El email que proporciona ya esta registrado en la base de datos' AS 'msg';
    ELSE
		INSERT INTO representante(`rep_nombre`, `rep_email`, `rep_telefono`, `rep_estatus`, `ctc_id`, `key`, `emp_id`, `cli_id`) VALUES( _nombre, _email, _telefono, 1, idCtc, _key, idEmpresa, idCliente );
		INSERT INTO usuario(usu_usuario, usu_password, usu_estatus, cu_id, emp_id) values(_email, _pass, 1, 4, idEmpresa );
    
		SELECT 1 AS 'success', 'Se ha registrado correctamente un nuevo cliente' AS 'msg', _pass as 'pass';
	END IF;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `catalogoarea`
--

CREATE TABLE `catalogoarea` (
  `ca_id` int(11) NOT NULL,
  `ca_nombre` varchar(60) COLLATE latin1_spanish_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;

--
-- Volcado de datos para la tabla `catalogoarea`
--

INSERT INTO `catalogoarea` (`ca_id`, `ca_nombre`) VALUES
(1, 'Juridico'),
(2, 'Fiscal'),
(3, 'Contable'),
(4, 'Soporte Tecnico'),
(5, 'Soporte Asesorias');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `catalogotipocliente`
--

CREATE TABLE `catalogotipocliente` (
  `ctc_id` int(11) NOT NULL,
  `ctc_nombre` varchar(45) COLLATE latin1_spanish_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;

--
-- Volcado de datos para la tabla `catalogotipocliente`
--

INSERT INTO `catalogotipocliente` (`ctc_id`, `ctc_nombre`) VALUES
(1, 'Directivo'),
(2, 'Representante');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `catalogousuario`
--

CREATE TABLE `catalogousuario` (
  `cu_id` int(11) NOT NULL,
  `cu_rol` varchar(45) COLLATE latin1_spanish_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci COMMENT='Tipos de usuario de momento encontramos\nSuperAdministrador\nAdministrador\nAgente\nCliente';

--
-- Volcado de datos para la tabla `catalogousuario`
--

INSERT INTO `catalogousuario` (`cu_id`, `cu_rol`) VALUES
(1, 'Super Administrador'),
(2, 'Administrador'),
(3, 'Ejecutivo'),
(4, 'Cliente');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cliente`
--

CREATE TABLE `cliente` (
  `cli_id` int(11) NOT NULL,
  `cli_rfc` varchar(18) COLLATE latin1_spanish_ci DEFAULT NULL,
  `cli_rason_social` varchar(255) COLLATE latin1_spanish_ci DEFAULT NULL,
  `cli_estatus` int(11) DEFAULT NULL,
  `emp_id` int(11) DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `key` varchar(60) COLLATE latin1_spanish_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;

--
-- Volcado de datos para la tabla `cliente`
--

INSERT INTO `cliente` (`cli_id`, `cli_rfc`, `cli_rason_social`, `cli_estatus`, `emp_id`, `timestamp`, `key`) VALUES
(1, 'GRI8704216N5', 'GRIANT S.A. DE C.V.', 1, 1, '2017-10-24 17:02:45', '71aa1b8bfc17343e747876606d820ae8'),
(2, 'GOSQ1398212', 'GOSSIP', 1, 1, '2017-10-24 19:42:33', 'ba789c1ea67bc30e2c35f78cda8694e4'),
(3, 'PROT871234', 'PROTAGON', 1, 1, '2017-10-24 19:44:41', '4ef5edec684ec441bb81cd4af48e9076');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `clientearea`
--

CREATE TABLE `clientearea` (
  `clar_id` int(11) NOT NULL,
  `cli_id` int(11) DEFAULT NULL,
  `ca_id` int(11) DEFAULT NULL,
  `clar_estatus` int(11) DEFAULT '1',
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;

--
-- Volcado de datos para la tabla `clientearea`
--

INSERT INTO `clientearea` (`clar_id`, `cli_id`, `ca_id`, `clar_estatus`, `timestamp`) VALUES
(1, 1, 3, 1, '2017-10-24 17:02:46'),
(2, 1, 2, 1, '2017-10-24 17:02:46'),
(3, 1, 1, 1, '2017-10-24 17:02:46'),
(4, 2, 3, 1, '2017-10-24 19:42:34'),
(5, 2, 2, 1, '2017-10-24 19:42:34'),
(6, 2, 1, 2, '2017-10-24 19:42:34'),
(7, 3, 2, 1, '2017-10-24 19:44:42'),
(8, 3, 1, 1, '2017-10-24 19:44:42'),
(9, 3, 3, 1, '2017-10-24 19:44:42');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `clienteejecutivo`
--

CREATE TABLE `clienteejecutivo` (
  `clej_id` int(11) NOT NULL,
  `cli_id` int(11) DEFAULT NULL,
  `eje_id` int(11) DEFAULT NULL,
  `clej_estatus` int(11) DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `clej_primario` int(11) DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;

--
-- Volcado de datos para la tabla `clienteejecutivo`
--

INSERT INTO `clienteejecutivo` (`clej_id`, `cli_id`, `eje_id`, `clej_estatus`, `timestamp`, `clej_primario`) VALUES
(6, 2, 2, 1, '2017-10-25 23:17:35', 1),
(33, 2, 1, 1, '2017-11-07 06:56:52', 2),
(34, 3, 2, 1, '2017-11-07 06:57:32', 1),
(39, 1, 2, 1, '2017-11-07 22:27:45', 2),
(40, 1, 1, 1, '2017-11-07 22:28:45', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `configuracionempresa`
--

CREATE TABLE `configuracionempresa` (
  `conf_id` int(11) NOT NULL,
  `emp_id` int(11) DEFAULT NULL,
  `conf_integracion` int(11) DEFAULT '1',
  `conf_api` text COLLATE latin1_spanish_ci,
  `conf_caduca` int(11) DEFAULT '1',
  `conf_fecha_caduca` date DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;

--
-- Volcado de datos para la tabla `configuracionempresa`
--

INSERT INTO `configuracionempresa` (`conf_id`, `emp_id`, `conf_integracion`, `conf_api`, `conf_caduca`, `conf_fecha_caduca`, `timestamp`) VALUES
(1, 1, 1, 'http://localhost/api/', 0, NULL, '2017-06-15 01:28:58'),
(2, 2, 1, 'http://localhost/api/', 0, NULL, '2017-07-06 15:57:33');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ejecutivo`
--

CREATE TABLE `ejecutivo` (
  `eje_id` int(11) NOT NULL,
  `eje_nombre` varchar(150) COLLATE latin1_spanish_ci DEFAULT NULL,
  `eje_telefono` varchar(45) COLLATE latin1_spanish_ci DEFAULT NULL,
  `eje_celular` varchar(45) COLLATE latin1_spanish_ci DEFAULT NULL,
  `eje_email` varchar(150) COLLATE latin1_spanish_ci DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ese_id` int(11) DEFAULT '1',
  `emp_id` int(11) DEFAULT NULL,
  `key` varchar(100) COLLATE latin1_spanish_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;

--
-- Volcado de datos para la tabla `ejecutivo`
--

INSERT INTO `ejecutivo` (`eje_id`, `eje_nombre`, `eje_telefono`, `eje_celular`, `eje_email`, `timestamp`, `ese_id`, `emp_id`, `key`) VALUES
(1, 'Leonardo de Jesus Oronzor', '51432627716', '8187687126', 'leonardo@loladisenio.com.mx', '2017-10-24 16:34:13', 3, 1, '3db9936748d079d68d7e7f8b78d8be5c'),
(2, 'Norma Lilia Sanchez Ferrer', '123123123', '123123123123', 'normita@griant.mx', '2017-10-24 19:46:31', 1, 1, '3d158adce7de132bb3e0e845e95872bd');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ejecutivoarea`
--

CREATE TABLE `ejecutivoarea` (
  `ejar_id` int(11) NOT NULL,
  `eje_id` int(11) DEFAULT NULL,
  `ca_id` int(11) DEFAULT NULL,
  `ejar_estatus` int(11) DEFAULT '1',
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;

--
-- Volcado de datos para la tabla `ejecutivoarea`
--

INSERT INTO `ejecutivoarea` (`ejar_id`, `eje_id`, `ca_id`, `ejar_estatus`, `timestamp`) VALUES
(1, 1, 1, 2, '2017-10-24 16:34:26'),
(2, 1, 2, 2, '2017-10-24 16:34:26'),
(3, 1, 3, 1, '2017-10-24 16:34:26'),
(4, 2, 3, 2, '2017-10-24 19:46:40'),
(5, 2, 2, 1, '2017-10-24 19:46:52'),
(6, 2, 1, 1, '2017-10-24 19:46:52');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `empresa`
--

CREATE TABLE `empresa` (
  `emp_id` int(11) NOT NULL,
  `emp_rason_social` varchar(255) COLLATE latin1_spanish_ci DEFAULT NULL,
  `emp_rfc` varchar(15) COLLATE latin1_spanish_ci DEFAULT NULL,
  `emp_contacto_nombre` varchar(150) COLLATE latin1_spanish_ci DEFAULT NULL,
  `emp_contacto_email` varchar(150) COLLATE latin1_spanish_ci DEFAULT NULL,
  `emp_contacto_telefono` varchar(50) COLLATE latin1_spanish_ci DEFAULT NULL,
  `emp_contacto_direccion` varchar(255) COLLATE latin1_spanish_ci DEFAULT NULL,
  `emp_estatus` int(11) DEFAULT '1',
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;

--
-- Volcado de datos para la tabla `empresa`
--

INSERT INTO `empresa` (`emp_id`, `emp_rason_social`, `emp_rfc`, `emp_contacto_nombre`, `emp_contacto_email`, `emp_contacto_telefono`, `emp_contacto_direccion`, `emp_estatus`, `timestamp`) VALUES
(1, 'PLANETA FISCAL', 'PFISCAL0001', 'ESTEBAN MORENO VARGAS', 'esteban@loladisenio.com.mx', '555555555', 'sin direccion', 1, '2017-06-14 23:36:20'),
(2, 'GRIANT SA DE CV', 'GIIA8704216N5', 'ALEJANDRO GRIJALVA ANTONIO', 'alex9abril@gmail.com', '555555555', 'sin direccion', 1, '2017-07-06 15:54:41');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `empresaarea`
--

CREATE TABLE `empresaarea` (
  `empar_id` int(11) NOT NULL,
  `emp_id` int(11) DEFAULT NULL,
  `ca_id` int(11) DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `empar_estatus` int(11) DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;

--
-- Volcado de datos para la tabla `empresaarea`
--

INSERT INTO `empresaarea` (`empar_id`, `emp_id`, `ca_id`, `timestamp`, `empar_estatus`) VALUES
(1, 1, 1, '2017-06-15 01:43:26', 1),
(2, 1, 2, '2017-06-15 01:43:26', 1),
(3, 1, 3, '2017-06-15 01:43:26', 1),
(4, 2, 4, '2017-07-06 15:59:18', 1),
(5, 2, 5, '2017-07-06 15:59:18', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `estatuscliente`
--

CREATE TABLE `estatuscliente` (
  `esc_id` int(11) NOT NULL,
  `esc_estatus` varchar(45) COLLATE latin1_spanish_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;

--
-- Volcado de datos para la tabla `estatuscliente`
--

INSERT INTO `estatuscliente` (`esc_id`, `esc_estatus`) VALUES
(1, 'Nuevo sin configurar'),
(2, 'Activo'),
(3, 'Standby'),
(4, 'Eliminado');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `estatusejecutivo`
--

CREATE TABLE `estatusejecutivo` (
  `ese_id` int(11) NOT NULL,
  `ese_estatus` varchar(50) COLLATE latin1_spanish_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;

--
-- Volcado de datos para la tabla `estatusejecutivo`
--

INSERT INTO `estatusejecutivo` (`ese_id`, `ese_estatus`) VALUES
(1, 'Nuevo'),
(2, 'Deshabilitado'),
(3, 'Por Iniciar'),
(4, 'Conectado'),
(5, 'Desconectado'),
(6, 'Ocupado');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `historialestatusejecutivo`
--

CREATE TABLE `historialestatusejecutivo` (
  `hee_id` int(11) NOT NULL,
  `eje_id` int(11) DEFAULT NULL,
  `ese_id` int(11) DEFAULT NULL,
  `hee_fecha_inicio` datetime DEFAULT NULL,
  `hee_fecha_fin` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;

--
-- Volcado de datos para la tabla `historialestatusejecutivo`
--

INSERT INTO `historialestatusejecutivo` (`hee_id`, `eje_id`, `ese_id`, `hee_fecha_inicio`, `hee_fecha_fin`) VALUES
(1, 1, 2, '2017-10-25 17:25:26', '2017-10-25 17:25:38'),
(2, 1, 3, '2017-10-25 17:25:38', '2017-11-03 12:56:44'),
(3, 1, 2, '2017-11-03 12:56:44', '2017-11-03 12:56:59'),
(4, 1, 3, '2017-11-03 12:56:59', '2017-11-03 13:12:24'),
(5, 1, 2, '2017-11-03 13:12:24', '2017-11-03 13:12:30'),
(6, 1, 3, '2017-11-03 13:12:30', '2017-11-03 13:33:22'),
(7, 1, 2, '2017-11-03 13:33:22', '2017-11-03 13:36:01'),
(8, 1, 3, '2017-11-03 13:36:01', '2017-11-06 10:34:21'),
(9, 1, 2, '2017-11-06 10:34:21', '2017-11-06 10:34:39'),
(10, 1, 3, '2017-11-06 10:34:39', NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `mensajes`
--

CREATE TABLE `mensajes` (
  `men_id` int(11) NOT NULL,
  `men_mensaje` varchar(1000) COLLATE latin1_spanish_ci DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `rep_id` int(11) DEFAULT NULL,
  `eje_id` int(11) DEFAULT NULL,
  `men_tipo_usuario` int(11) DEFAULT NULL,
  `emp_id` int(11) DEFAULT NULL,
  `men_tipo` int(11) DEFAULT '1',
  `men_formato` varchar(45) COLLATE latin1_spanish_ci DEFAULT NULL,
  `men_url` varchar(500) COLLATE latin1_spanish_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;

--
-- Volcado de datos para la tabla `mensajes`
--

INSERT INTO `mensajes` (`men_id`, `men_mensaje`, `timestamp`, `rep_id`, `eje_id`, `men_tipo_usuario`, `emp_id`, `men_tipo`, `men_formato`, `men_url`) VALUES
(201, 'woooooooola', '2017-11-09 15:44:19', 1, 1, 2, 1, 1, NULL, NULL),
(202, 'hoooola', '2017-11-14 21:39:58', 1, 1, 1, 1, 1, NULL, NULL),
(203, 'que pedo', '2017-11-14 21:40:01', 1, 1, 1, 1, 1, NULL, NULL),
(204, 'como estas', '2017-11-14 21:40:10', 1, 1, 1, 1, 3, 'doc', '2017_06_28_MAT_sep11_C.doc'),
(205, 'esta es la imagen que te decia', '2017-11-14 21:40:16', 1, 1, 2, 1, 2, 'img', 'Asesoria Image 2017-11-14 at 8.48.20 AM.jpg'),
(206, 'estas ahi', '2017-11-14 23:52:20', 1, 1, 2, 1, 1, NULL, NULL),
(207, 'hola', '2017-11-15 00:00:18', 2, 1, 2, 1, 1, NULL, NULL),
(208, 'te mando el SS de la interfaz we', '2017-11-15 17:29:13', 1, 1, 2, 1, 2, NULL, '01 - Login.png'),
(209, 'Tambien te mando una foto de iconitos', '2017-11-15 17:29:47', 1, 1, 2, 1, 2, NULL, '40_best_apps_lead.png'),
(210, 'y el logo de protagon', '2017-11-15 17:30:03', 1, 1, 1, 1, 1, 'img', ''),
(211, '', '2017-11-15 17:30:35', 1, 1, 1, 1, 2, 'img', 'iso-pro.png'),
(212, 'este es un mensaje de texto', '2017-11-15 17:48:21', 4, 1, 1, 1, 1, NULL, NULL),
(213, 'lkjajsh dlaksjd laskjd lkasjd alksdj laskjd laskjd laksj dlaksjd laksj dlkasjd laksjd lkasjd lkasjd lkasj dlaksjd lkasjd lkasjd lkasj dlkasj dlkajs dlkajs lkdjas lkdj alkjd alskdj laskjd laksjd lkasjd lkasj dlkasj dlkajs dlkjas ldkjas kldja slkdj alskjd alksjd lkasjd lkasjd laks djas lkdja slkdj alksjd alksjd laksjd laskjd laksjd laksjd laksjd lasjdl kasjd lkasjd lkaj dlkajs ldkajs ldkjas ldkjas lkdj aslkdj laskdj laksjd laksjd lkasj dlkasj dlkasj dlkasj dlkajs dlkajs dlkajs ldkajs ldkjas ldkj alskjd lakjs dlaksj dlkasj dlkajs ldkajs lkdja slkdj alskjd laksj dlkasjd lkasldkja slkdj alskjd laksjd laksjd lkasjd laksjd lkasjd lkasjd lkajs dlkajsd lkasj dlkajs dlkajs dlkjas ldkjas lkdj asldjas', '2017-11-15 17:49:02', 4, 1, 2, 1, 1, NULL, NULL),
(214, 'alejandro grijalva antonio es un chingon', '2017-11-15 23:42:33', 1, 1, 2, 1, 1, NULL, NULL),
(215, 'hola mundo', '2017-11-16 16:34:49', 1, 1, 1, 1, 1, NULL, NULL),
(216, 'que pedo', '2017-11-16 16:36:05', 1, 1, 1, 1, 1, NULL, NULL),
(217, 'Hola norma', '2017-11-16 16:36:58', 5, 1, 1, 1, 1, NULL, NULL),
(218, 'como estas', '2017-11-16 16:37:00', 5, 1, 1, 1, 1, NULL, NULL),
(219, 'hola', '2017-11-16 16:47:46', 1, 1, 1, 1, 1, NULL, NULL),
(220, 'que paso chavoz', '2017-11-16 16:48:48', 1, 1, 1, 1, 1, NULL, NULL),
(221, 'hola mundo', '2017-11-16 16:52:12', 1, 1, 1, 1, 1, NULL, NULL),
(222, 'hola mundo', '2017-11-16 16:53:24', 1, 1, 1, 1, 1, NULL, NULL),
(223, 'hola mundo', '2017-11-16 16:58:16', 1, 1, 1, 1, 1, NULL, NULL),
(224, '123', '2017-11-16 16:59:47', 1, 1, 1, 1, 1, NULL, NULL),
(225, '456', '2017-11-16 17:06:34', 1, 1, 1, 1, 1, NULL, NULL),
(226, '789', '2017-11-16 17:24:18', 1, 1, 1, 1, 1, NULL, NULL),
(227, 'hola que tal como estas', '2017-11-16 18:12:41', 2, 1, 1, 1, 1, NULL, NULL),
(228, 'espero que chingon', '2017-11-16 18:14:21', 2, 1, 1, 1, 1, NULL, NULL),
(229, 'ching&oacute;n', '2017-11-16 18:14:26', 2, 1, 1, 1, 1, NULL, NULL),
(230, 'que pedro dijo juan ni&ntilde;o', '2017-11-16 18:20:40', 2, 1, 1, 1, 1, NULL, NULL),
(231, 'hola pa', '2017-11-16 18:24:04', 7, 1, 1, 1, 1, NULL, NULL),
(232, 'que tal p&aacute;', '2017-11-16 18:24:39', 7, 1, 1, 1, 1, NULL, NULL),
(233, 'hola', '2017-11-16 18:28:02', 1, 1, 1, 1, 1, NULL, NULL),
(234, 'hola', '2017-11-16 18:28:51', 1, 1, 1, 1, 1, NULL, NULL),
(235, 'como estas', '2017-11-16 18:28:55', 1, 1, 1, 1, 1, NULL, NULL),
(236, 'espero que chingon', '2017-11-16 18:28:58', 1, 1, 1, 1, 1, NULL, NULL),
(237, 'te escribo para hacer pruebas de usuario', '2017-11-16 18:29:10', 1, 1, 1, 1, 1, NULL, NULL),
(238, 'para verificar que si realmente estoy guardando los mensajes', '2017-11-16 18:29:30', 1, 1, 1, 1, 1, NULL, NULL),
(239, 'Hola como estas', '2017-11-16 18:35:08', 6, 1, 1, 1, 1, NULL, NULL),
(240, 'holaaaa', '2017-11-16 18:35:18', 6, 1, 1, 1, 1, NULL, NULL),
(241, 'como estas', '2017-11-16 18:35:21', 6, 1, 1, 1, 1, NULL, NULL),
(242, 'perra mamita chula', '2017-11-16 18:35:23', 6, 1, 1, 1, 1, NULL, NULL),
(243, 'hola', '2017-11-16 23:00:09', 1, 1, 1, 1, 1, NULL, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `representante`
--

CREATE TABLE `representante` (
  `rep_id` int(11) NOT NULL,
  `rep_nombre` varchar(300) COLLATE latin1_spanish_ci DEFAULT NULL,
  `rep_email` varchar(100) COLLATE latin1_spanish_ci DEFAULT NULL,
  `rep_telefono` varchar(30) COLLATE latin1_spanish_ci DEFAULT NULL,
  `rep_estatus` int(11) DEFAULT NULL,
  `ctc_id` int(11) DEFAULT NULL,
  `timestamp` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `key` varchar(60) COLLATE latin1_spanish_ci DEFAULT NULL,
  `emp_id` int(11) DEFAULT NULL,
  `cli_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;

--
-- Volcado de datos para la tabla `representante`
--

INSERT INTO `representante` (`rep_id`, `rep_nombre`, `rep_email`, `rep_telefono`, `rep_estatus`, `ctc_id`, `timestamp`, `key`, `emp_id`, `cli_id`) VALUES
(1, 'Alejandro Grijalva Antonio', 'alejandro@griant.mx', '5548671990', 1, 1, '2017-10-24 17:02:45', '71aa1b8bfc17343e747876606d820ae8', 1, 1),
(2, 'Luis Antonio Garcia Perrusquia', 'luis@griant.mx', '546789090', 1, 1, '2017-10-24 19:42:33', 'ba789c1ea67bc30e2c35f78cda8694e4', 1, 2),
(3, 'Mariso Rodriguez', 'marisol@griant.mx', '12312312312', 1, 1, '2017-10-24 19:44:41', '4ef5edec684ec441bb81cd4af48e9076', 1, 3),
(4, 'Jose Javier Grijalva Antonio', 'javivi@griant.mx', '344567890', 1, 2, '2017-11-03 01:27:02', '94f737165cc1217d256d2cd9ef4de114', 1, 1),
(5, 'Norma Lilia Sanchez Ferrer', 'lilia@griant.mx', '87127878923', 1, 2, '2017-11-03 17:05:55', 'fa6277e0b4a433a85a91ef08cf824cb1', 1, 1),
(6, 'Josefina Antonio Contreras', 'jose@griant.mx', '65897908', 1, 2, '2017-11-03 17:10:14', '92cbc8df959d93d85d28df7702ab3f9a', 1, 1),
(7, 'Cresencio Grijalva Carrizal', 'chencho@griant.mx', '34567890', 1, 2, '2017-11-03 17:13:15', '4c1c6a88de3c3afd5dacecaab1e5b02f', 1, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario`
--

CREATE TABLE `usuario` (
  `usu_id` int(11) NOT NULL,
  `usu_usuario` varchar(150) COLLATE latin1_spanish_ci DEFAULT NULL,
  `usu_password` varchar(50) COLLATE latin1_spanish_ci DEFAULT NULL,
  `usu_estatus` int(11) DEFAULT '1',
  `cu_id` int(11) DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `emp_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;

--
-- Volcado de datos para la tabla `usuario`
--

INSERT INTO `usuario` (`usu_id`, `usu_usuario`, `usu_password`, `usu_estatus`, `cu_id`, `timestamp`, `emp_id`) VALUES
(1, 'esteban@loladisenio.com.mx', 'qwerty', 1, 2, '2017-10-24 16:15:22', 1),
(2, 'alejandro@griant.mx', 'qwerty', 1, 2, '2017-10-24 16:15:22', 2),
(4, 'leonardo@loladisenio.com.mx', 'qwerty', 1, 3, '2017-10-24 16:34:13', 1),
(8, 'alejandro@griant.mx', 'qwerty', 1, 4, '2017-10-24 17:02:45', 1),
(9, 'luis@griant.mx', 'qwerty', 1, 4, '2017-10-24 19:42:33', 1),
(10, 'marisol@griant.mx', 'qwerty', 1, 4, '2017-10-24 19:44:41', 1),
(11, 'normita@griant.mx', 'qwerty', 1, 3, '2017-10-24 19:46:31', 1),
(12, 'javivi@griant.mx', 'qwerty', 1, 4, '2017-11-03 01:27:02', 1),
(13, 'lilia@griant.mx', 'qwerty', 1, 4, '2017-11-03 17:05:55', 1),
(14, 'jose@griant.mx', 'qwerty', 1, 4, '2017-11-03 17:10:14', 1),
(15, 'chencho@griant.mx', 'qwerty', 1, 4, '2017-11-03 17:13:15', 1);

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `catalogoarea`
--
ALTER TABLE `catalogoarea`
  ADD PRIMARY KEY (`ca_id`);

--
-- Indices de la tabla `catalogotipocliente`
--
ALTER TABLE `catalogotipocliente`
  ADD PRIMARY KEY (`ctc_id`);

--
-- Indices de la tabla `catalogousuario`
--
ALTER TABLE `catalogousuario`
  ADD PRIMARY KEY (`cu_id`);

--
-- Indices de la tabla `cliente`
--
ALTER TABLE `cliente`
  ADD PRIMARY KEY (`cli_id`);

--
-- Indices de la tabla `clientearea`
--
ALTER TABLE `clientearea`
  ADD PRIMARY KEY (`clar_id`);

--
-- Indices de la tabla `clienteejecutivo`
--
ALTER TABLE `clienteejecutivo`
  ADD PRIMARY KEY (`clej_id`);

--
-- Indices de la tabla `configuracionempresa`
--
ALTER TABLE `configuracionempresa`
  ADD PRIMARY KEY (`conf_id`);

--
-- Indices de la tabla `ejecutivo`
--
ALTER TABLE `ejecutivo`
  ADD PRIMARY KEY (`eje_id`);

--
-- Indices de la tabla `ejecutivoarea`
--
ALTER TABLE `ejecutivoarea`
  ADD PRIMARY KEY (`ejar_id`);

--
-- Indices de la tabla `empresa`
--
ALTER TABLE `empresa`
  ADD PRIMARY KEY (`emp_id`);

--
-- Indices de la tabla `empresaarea`
--
ALTER TABLE `empresaarea`
  ADD PRIMARY KEY (`empar_id`);

--
-- Indices de la tabla `estatuscliente`
--
ALTER TABLE `estatuscliente`
  ADD PRIMARY KEY (`esc_id`);

--
-- Indices de la tabla `estatusejecutivo`
--
ALTER TABLE `estatusejecutivo`
  ADD PRIMARY KEY (`ese_id`);

--
-- Indices de la tabla `historialestatusejecutivo`
--
ALTER TABLE `historialestatusejecutivo`
  ADD PRIMARY KEY (`hee_id`);

--
-- Indices de la tabla `mensajes`
--
ALTER TABLE `mensajes`
  ADD PRIMARY KEY (`men_id`);

--
-- Indices de la tabla `representante`
--
ALTER TABLE `representante`
  ADD PRIMARY KEY (`rep_id`);

--
-- Indices de la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`usu_id`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `catalogoarea`
--
ALTER TABLE `catalogoarea`
  MODIFY `ca_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;
--
-- AUTO_INCREMENT de la tabla `catalogotipocliente`
--
ALTER TABLE `catalogotipocliente`
  MODIFY `ctc_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
--
-- AUTO_INCREMENT de la tabla `cliente`
--
ALTER TABLE `cliente`
  MODIFY `cli_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;
--
-- AUTO_INCREMENT de la tabla `clientearea`
--
ALTER TABLE `clientearea`
  MODIFY `clar_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;
--
-- AUTO_INCREMENT de la tabla `clienteejecutivo`
--
ALTER TABLE `clienteejecutivo`
  MODIFY `clej_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=41;
--
-- AUTO_INCREMENT de la tabla `configuracionempresa`
--
ALTER TABLE `configuracionempresa`
  MODIFY `conf_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
--
-- AUTO_INCREMENT de la tabla `ejecutivo`
--
ALTER TABLE `ejecutivo`
  MODIFY `eje_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
--
-- AUTO_INCREMENT de la tabla `ejecutivoarea`
--
ALTER TABLE `ejecutivoarea`
  MODIFY `ejar_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;
--
-- AUTO_INCREMENT de la tabla `empresa`
--
ALTER TABLE `empresa`
  MODIFY `emp_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
--
-- AUTO_INCREMENT de la tabla `empresaarea`
--
ALTER TABLE `empresaarea`
  MODIFY `empar_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;
--
-- AUTO_INCREMENT de la tabla `estatuscliente`
--
ALTER TABLE `estatuscliente`
  MODIFY `esc_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;
--
-- AUTO_INCREMENT de la tabla `estatusejecutivo`
--
ALTER TABLE `estatusejecutivo`
  MODIFY `ese_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;
--
-- AUTO_INCREMENT de la tabla `historialestatusejecutivo`
--
ALTER TABLE `historialestatusejecutivo`
  MODIFY `hee_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;
--
-- AUTO_INCREMENT de la tabla `mensajes`
--
ALTER TABLE `mensajes`
  MODIFY `men_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=244;
--
-- AUTO_INCREMENT de la tabla `representante`
--
ALTER TABLE `representante`
  MODIFY `rep_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;
--
-- AUTO_INCREMENT de la tabla `usuario`
--
ALTER TABLE `usuario`
  MODIFY `usu_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
