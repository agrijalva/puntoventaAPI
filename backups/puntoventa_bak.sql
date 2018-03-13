-- phpMyAdmin SQL Dump
-- version 4.6.5.2
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 13-12-2017 a las 16:40:17
-- Versión del servidor: 10.1.21-MariaDB
-- Versión de PHP: 5.6.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `puntoventa`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `LISTAPRECIOEDITAR_SP` (IN `nombre` VARCHAR(300) CHARSET utf8, IN `descripcion` VARCHAR(1000) CHARSET utf8, IN `listaPrecio` INT)  BEGIN
	UPDATE listaprecio 
	SET lpr_nombre 		= nombre,
		lpr_descripcion = descripcion
	WHERE idListaPrecio = listaPrecio;
    
    SELECT 1 AS 'success', 'Se ha actualizado correctamente la lista de precios.' AS 'msg';
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `LISTAPRECIOELIMINAR_SP` (IN `listaPrecio` INT)  BEGIN
	UPDATE listaprecio 
	SET lpr_estatus 	= 0
	WHERE idListaPrecio = listaPrecio;
    
    SELECT 1 AS 'success', 'Se ha eliminado correctamente la lista de precios.' AS 'msg';
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `LISTAPRECIOMUESTRA_SP` (IN `empresa` INT)  BEGIN
    SELECT * 
	FROM listaprecio LP
	INNER JOIN sucursal SUC ON LP.idSucursal = SUC.idSucursal
	WHERE LP.idEmpresa = empresa AND lpr_estatus = 1;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `LISTAPRECIONUEVO_SP` (IN `nombre` VARCHAR(300) CHARSET utf8, IN `descripcion` VARCHAR(1000) CHARSET utf8, IN `Empresa` INT, IN `Sucursal` INT)  BEGIN
	INSERT INTO listaprecio(lpr_nombre, lpr_descripcion, idEmpresa, idSucursal) 
    VALUES(nombre, descripcion, Empresa, Sucursal);
    
    SELECT 1 AS 'success', 'Se ha registrado correctamente una lista de precios.' AS 'msg', LAST_INSERT_ID() as 'LastId';
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `LISTAPRECIOREGISTRAR_SP` (IN `listaPrecio` INT, IN `producto` INT, IN `precioCompra` FLOAT, IN `precioVenta` FLOAT)  BEGIN
	DECLARE precio INT;
    SET precio = ( SELECT idPrecio FROM precio WHERE idListaPrecio = listaPrecio AND idProducto = producto );
    
    IF( precio IS NULL ) THEN
		INSERT INTO precio(idListaPrecio, idProducto, precio_compra, precio_venta, pre_estatus )
		VALUES ( listaPrecio, producto, precioCompra, precioVenta, 1 );
        
        SELECT 1 AS 'success', 'Precio registrado' AS 'msg';
    ELSE
		UPDATE precio 
        SET precio_compra = precioCompra,
			precio_venta  = precioVenta
		WHERE idPrecio = precio;
        
        SELECT 1 AS 'success', 'Precio actualizado' AS 'msg';
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `LISTAPRECIO_SP` (IN `idListaPrecio` INT)  BEGIN
	SELECT * 
	FROM listaprecio LP
	INNER JOIN sucursal SUC ON LP.idSucursal = SUC.idSucursal
	WHERE idListaPrecio = idListaPrecio;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `LOGIN_SP` (IN `usuario` VARCHAR(200) CHARSET utf8, IN `contrasenia` VARCHAR(200) CHARSET utf8)  BEGIN    
    SELECT * 
	FROM usuario USU
	INNER JOIN empresa EMP 					ON USU.idEmpresa = EMP.idEmpresa
	INNER JOIN configuracionempresa CONF 	ON EMP.idEmpresa = CONF.idEmpresa
	WHERE usu_usuario = usuario 
          AND usu_password = contrasenia;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `PRODUCTOEDITAR_SP` (IN `sku` VARCHAR(100) CHARSET utf8, IN `nombre` VARCHAR(500) CHARSET utf8, IN `descripcion` VARCHAR(1000) CHARSET utf8, IN `unidad` VARCHAR(300) CHARSET utf8, IN `productoID` INT)  BEGIN
	UPDATE producto 
    SET pro_sku 		= sku,
		pro_nombre 		= nombre,
        pro_descripcion	= descripcion,
        pro_unidad		= unidad
	WHERE idProducto = productoID;	
    
    SELECT 1 AS 'success', 'Se ha actualizado correctamente el producto.' AS 'msg';
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `PRODUCTOELIMINAR_SP` (IN `productoID` INT)  BEGIN
	UPDATE producto SET pro_estatus = 0	WHERE idProducto = productoID;    
    SELECT 1 AS 'success', 'El producto se ha eliminado correctamente.' AS 'msg';
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `PRODUCTOMUESTRA_SP` (IN `empresaID` INT)  BEGIN
	SELECT * FROM producto WHERE idEmpresa = empresaID AND pro_estatus = 1;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `PRODUCTONUEVO_SP` (IN `sku` VARCHAR(100) CHARSET utf8, IN `nombre` VARCHAR(500) CHARSET utf8, IN `descripcion` VARCHAR(1000) CHARSET utf8, IN `unidad` VARCHAR(300) CHARSET utf8, IN `empresa` INT)  BEGIN
	INSERT INTO producto( pro_sku, pro_nombre, pro_descripcion, pro_unidad, idEmpresa ) 
    VALUES( sku, nombre, descripcion, unidad, empresa );
    
    SELECT 1 AS 'success', 'Se ha registrado correctamente un producto nuevo.' AS 'msg', LAST_INSERT_ID() as 'LastId';
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `PRODUCTOPRECIO_SP` (IN `listaPrecio` INT, IN `empresa` INT)  BEGIN
	SELECT PRO.*, precio_compra AS precioCosto, precio_venta AS precioVenta
	FROM producto PRO
	LEFT JOIN precio PRE ON PRO.idProducto = PRE.idProducto AND PRE.idListaPrecio = listaPrecio
	WHERE idEmpresa = empresa AND pro_estatus = 1
	ORDER BY idProducto ASC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SUCURSALMOSTRAR_SP` (IN `empresa` INT)  BEGIN
	SELECT * FROM sucursal WHERE idEmpresa = empresa;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `caja`
--

CREATE TABLE `caja` (
  `idCaja` int(11) NOT NULL,
  `idEmpresa` int(11) NOT NULL,
  `idSucursal` int(11) NOT NULL,
  `idUsuario` int(11) NOT NULL,
  `caja_fechaApertura` datetime NOT NULL,
  `caja_fechaCierre` varchar(45) DEFAULT NULL,
  `caja_monto` float NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `catalogousuario`
--

CREATE TABLE `catalogousuario` (
  `idCatalogoUsuario` int(11) NOT NULL,
  `cu_rol` varchar(45) COLLATE latin1_spanish_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci COMMENT='Tipos de usuario de momento encontramos\nSuperAdministrador\nAdministrador\nAgente\nCliente';

--
-- Volcado de datos para la tabla `catalogousuario`
--

INSERT INTO `catalogousuario` (`idCatalogoUsuario`, `cu_rol`) VALUES
(1, 'Administrador'),
(2, 'Empleado'),
(3, 'Encargado');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `checkin`
--

CREATE TABLE `checkin` (
  `idCheckIn` int(11) NOT NULL,
  `chi_descripcion` varchar(500) DEFAULT NULL,
  `chi_estatus` int(11) DEFAULT '1',
  `idTipoCheckIn` int(11) NOT NULL,
  `idUsuario` int(11) NOT NULL,
  `idEmpresa` int(11) NOT NULL,
  `idSucursal` int(11) NOT NULL,
  `timestamp` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `checkindetalle`
--

CREATE TABLE `checkindetalle` (
  `idCheckInDetalle` int(11) NOT NULL,
  `idCheckIn` int(11) NOT NULL,
  `idProducto` int(11) NOT NULL,
  `cod_cantidad` float NOT NULL,
  `cod_observaciones` varchar(500) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `checkout`
--

CREATE TABLE `checkout` (
  `idCheckOut` int(11) NOT NULL,
  `cho_descripcion` varchar(500) DEFAULT NULL,
  `cho_estatus` int(11) DEFAULT '1',
  `idTipoCheckOut` int(11) NOT NULL,
  `idUsuario` int(11) NOT NULL,
  `idEmpresa` int(11) NOT NULL,
  `idSucursal` int(11) NOT NULL,
  `timestamp` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `checkoutdetalle`
--

CREATE TABLE `checkoutdetalle` (
  `idCheckOutDetalle` int(11) NOT NULL,
  `idCheckOut` int(11) NOT NULL,
  `idProducto` int(11) NOT NULL,
  `cod_cantidad` float NOT NULL DEFAULT '0',
  `cod_precio` float DEFAULT '0',
  `cod_observaciones` varchar(500) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cliente`
--

CREATE TABLE `cliente` (
  `idCliente` int(11) NOT NULL,
  `cli_rfc` varchar(18) COLLATE latin1_spanish_ci DEFAULT NULL,
  `cli_rason_social` varchar(255) COLLATE latin1_spanish_ci DEFAULT NULL,
  `cli_estatus` int(11) DEFAULT '1',
  `key` varchar(60) COLLATE latin1_spanish_ci DEFAULT NULL,
  `timestamp` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `idEmpresa` int(11) NOT NULL,
  `cli_observaciones` varchar(500) COLLATE latin1_spanish_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `configuracionempresa`
--

CREATE TABLE `configuracionempresa` (
  `idConfiguracionEmpresa` int(11) NOT NULL,
  `idEmpresa` int(11) NOT NULL,
  `conf_integracion` int(11) DEFAULT '1',
  `conf_caduca` int(11) DEFAULT '1',
  `conf_fecha_caduca` date DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;

--
-- Volcado de datos para la tabla `configuracionempresa`
--

INSERT INTO `configuracionempresa` (`idConfiguracionEmpresa`, `idEmpresa`, `conf_integracion`, `conf_caduca`, `conf_fecha_caduca`, `timestamp`) VALUES
(2, 1, 0, 0, NULL, '2017-12-05 15:33:01');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `empresa`
--

CREATE TABLE `empresa` (
  `idEmpresa` int(11) NOT NULL,
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

INSERT INTO `empresa` (`idEmpresa`, `emp_rason_social`, `emp_rfc`, `emp_contacto_nombre`, `emp_contacto_email`, `emp_contacto_telefono`, `emp_contacto_direccion`, `emp_estatus`, `timestamp`) VALUES
(1, 'Forrajera As de Oros', 'ASORO0001', 'Octavio Reyes Ortega', 'contacto@email.com', '5500000000', 'Actopan Hidalgo', 1, '2017-12-05 15:32:27');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `gastos`
--

CREATE TABLE `gastos` (
  `idGastos` int(11) NOT NULL,
  `gas_monto` float DEFAULT NULL,
  `caja_idCaja` int(11) NOT NULL,
  `timestamp` datetime DEFAULT CURRENT_TIMESTAMP,
  `gas_descripcion` varchar(1000) DEFAULT NULL,
  `idGastoTipo` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `gastotipo`
--

CREATE TABLE `gastotipo` (
  `idGastoTipo` int(11) NOT NULL,
  `gati_descripcion` varchar(200) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `listaprecio`
--

CREATE TABLE `listaprecio` (
  `idListaPrecio` int(11) NOT NULL,
  `lpr_nombre` varchar(45) DEFAULT NULL,
  `lpr_descripcion` varchar(45) DEFAULT NULL,
  `lpr_estatus` int(11) DEFAULT '1',
  `idEmpresa` int(11) NOT NULL,
  `idSucursal` int(11) DEFAULT '0',
  `timestamp` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `listaprecio`
--

INSERT INTO `listaprecio` (`idListaPrecio`, `lpr_nombre`, `lpr_descripcion`, `lpr_estatus`, `idEmpresa`, `idSucursal`, `timestamp`) VALUES
(1, 'LISTA PRECIOS ACTOPAN 2018', 'LISTA PRECIOS', 1, 1, 1, '2017-12-12 20:59:48'),
(2, 'LISTA PRECIOS IXMIQUILPAN 2018', 'LISTA PRECIOS', 1, 1, 2, '2017-12-13 01:37:09'),
(3, 'LISTA PRECIOS ATOTONILCO 2018', 'LISTA PRECIOS', 1, 1, 3, '2017-12-13 09:23:07');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `mezcla`
--

CREATE TABLE `mezcla` (
  `idMezcla` int(11) NOT NULL,
  `timestamp` datetime DEFAULT CURRENT_TIMESTAMP,
  `idCheckOut` int(11) NOT NULL,
  `checkin_idCheckIn` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `precio`
--

CREATE TABLE `precio` (
  `idPrecio` int(11) NOT NULL,
  `idListaPrecio` int(11) NOT NULL,
  `idProducto` int(11) NOT NULL,
  `precio_compra` float DEFAULT NULL,
  `precio_venta` float DEFAULT NULL,
  `pre_estatus` varchar(45) DEFAULT NULL,
  `timestamp` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `precio`
--

INSERT INTO `precio` (`idPrecio`, `idListaPrecio`, `idProducto`, `precio_compra`, `precio_venta`, `pre_estatus`, `timestamp`) VALUES
(1, 1, 2, 0, 350, '1', '2017-12-12 23:48:40'),
(2, 1, 1, 0, 175, '1', '2017-12-12 23:48:40'),
(3, 1, 3, 0, 1100, '1', '2017-12-12 23:48:40'),
(4, 1, 4, 0, 800, '1', '2017-12-12 23:48:40'),
(5, 1, 5, 0, 350, '1', '2017-12-12 23:48:40'),
(6, 1, 7, 0, 210, '1', '2017-12-12 23:48:40'),
(7, 1, 10, 0, 265, '1', '2017-12-12 23:48:40'),
(8, 1, 11, 0, 170, '1', '2017-12-12 23:48:40'),
(9, 1, 6, 0, 200, '1', '2017-12-12 23:48:40'),
(10, 1, 12, 0, 105, '1', '2017-12-12 23:48:40'),
(11, 1, 13, 0, 0, '1', '2017-12-12 23:48:40'),
(12, 1, 17, 0, 0, '1', '2017-12-12 23:48:40'),
(13, 1, 15, 0, 0, '1', '2017-12-12 23:48:40'),
(14, 1, 14, 0, 260, '1', '2017-12-12 23:48:40'),
(15, 1, 16, 0, 250, '1', '2017-12-12 23:48:40'),
(16, 1, 18, 0, 240, '1', '2017-12-12 23:48:41'),
(17, 1, 19, 0, 180, '1', '2017-12-12 23:48:41'),
(18, 1, 21, 0, 0, '1', '2017-12-12 23:48:41'),
(19, 1, 22, 0, 225, '1', '2017-12-12 23:48:41'),
(20, 1, 20, 0, 300, '1', '2017-12-12 23:48:41'),
(21, 1, 23, 0, 275, '1', '2017-12-12 23:48:41'),
(22, 1, 24, 0, 150, '1', '2017-12-12 23:48:41'),
(23, 1, 25, 0, 135, '1', '2017-12-12 23:48:41'),
(24, 1, 26, 0, 220, '1', '2017-12-12 23:48:41'),
(25, 1, 28, 0, 210, '1', '2017-12-12 23:48:41'),
(26, 1, 27, 0, 145, '1', '2017-12-12 23:48:41'),
(27, 1, 31, 0, 245, '1', '2017-12-12 23:48:41'),
(28, 1, 29, 0, 320, '1', '2017-12-12 23:48:41'),
(29, 1, 30, 0, 280, '1', '2017-12-12 23:48:41'),
(30, 1, 32, 0, 0, '1', '2017-12-12 23:48:41'),
(31, 1, 33, 0, 200, '1', '2017-12-12 23:48:41'),
(32, 1, 34, 0, 190, '1', '2017-12-12 23:48:41'),
(33, 1, 35, 0, 200, '1', '2017-12-12 23:48:41'),
(34, 1, 36, 0, 175, '1', '2017-12-12 23:48:41'),
(35, 1, 38, 0, 150, '1', '2017-12-12 23:48:42'),
(36, 1, 39, 0, 180, '1', '2017-12-12 23:48:42'),
(37, 1, 40, 0, 340, '1', '2017-12-12 23:48:42'),
(38, 1, 37, 0, 175, '1', '2017-12-12 23:48:42'),
(39, 1, 43, 0, 175, '1', '2017-12-12 23:48:42'),
(40, 1, 44, 0, 140, '1', '2017-12-12 23:48:42'),
(41, 1, 42, 0, 135, '1', '2017-12-12 23:48:42'),
(42, 1, 45, 0, 7.8, '1', '2017-12-12 23:48:42'),
(43, 1, 46, 0, 185, '1', '2017-12-12 23:48:42'),
(44, 1, 41, 0, 1.5, '1', '2017-12-12 23:48:42'),
(45, 1, 48, 0, 200, '1', '2017-12-12 23:48:42'),
(46, 1, 50, 0, 195, '1', '2017-12-12 23:48:42'),
(47, 1, 49, 0, 175, '1', '2017-12-12 23:48:42'),
(48, 1, 47, 0, 190, '1', '2017-12-12 23:48:42'),
(49, 1, 51, 0, 3.5, '1', '2017-12-12 23:48:42'),
(50, 1, 52, 0, 5, '1', '2017-12-13 01:33:01'),
(51, 1, 53, 0, 0, '1', '2017-12-13 01:33:01'),
(52, 2, 1, 0, 175, '1', '2017-12-13 01:41:26'),
(53, 2, 3, 0, 1100, '1', '2017-12-13 01:41:26'),
(54, 2, 2, 0, 350, '1', '2017-12-13 01:41:26'),
(55, 2, 5, 0, 350, '1', '2017-12-13 01:41:26'),
(56, 2, 4, 0, 800, '1', '2017-12-13 01:41:26'),
(57, 2, 6, 0, 200, '1', '2017-12-13 01:41:26'),
(58, 2, 7, 0, 210, '1', '2017-12-13 01:41:26'),
(59, 2, 11, 0, 170, '1', '2017-12-13 01:41:27'),
(60, 2, 10, 0, 265, '1', '2017-12-13 01:41:27'),
(61, 2, 12, 0, 105, '1', '2017-12-13 01:41:27'),
(62, 2, 16, 0, 250, '1', '2017-12-13 01:41:27'),
(63, 2, 14, 0, 260, '1', '2017-12-13 01:41:27'),
(64, 2, 15, 0, 0, '1', '2017-12-13 01:41:27'),
(65, 2, 13, 0, 0, '1', '2017-12-13 01:41:27'),
(66, 2, 18, 0, 240, '1', '2017-12-13 01:41:27'),
(67, 2, 17, 0, 0, '1', '2017-12-13 01:41:27'),
(68, 2, 19, 0, 180, '1', '2017-12-13 01:41:27'),
(69, 2, 20, 0, 300, '1', '2017-12-13 01:41:27'),
(70, 2, 23, 0, 275, '1', '2017-12-13 01:41:28'),
(71, 2, 22, 0, 225, '1', '2017-12-13 01:41:28'),
(72, 2, 21, 0, 0, '1', '2017-12-13 01:41:28'),
(73, 2, 26, 0, 220, '1', '2017-12-13 01:41:28'),
(74, 2, 24, 0, 150, '1', '2017-12-13 01:41:28'),
(75, 2, 25, 0, 135, '1', '2017-12-13 01:41:28'),
(76, 2, 28, 0, 210, '1', '2017-12-13 01:41:28'),
(77, 2, 27, 0, 145, '1', '2017-12-13 01:41:28'),
(78, 2, 29, 0, 320, '1', '2017-12-13 01:41:28'),
(79, 2, 31, 0, 245, '1', '2017-12-13 01:41:28'),
(80, 2, 30, 0, 280, '1', '2017-12-13 01:41:28'),
(81, 2, 32, 0, 0, '1', '2017-12-13 01:41:28'),
(82, 2, 33, 0, 200, '1', '2017-12-13 01:41:28'),
(83, 2, 34, 0, 190, '1', '2017-12-13 01:41:28'),
(84, 2, 35, 0, 200, '1', '2017-12-13 01:41:28'),
(85, 2, 37, 0, 175, '1', '2017-12-13 01:41:28'),
(86, 2, 38, 0, 150, '1', '2017-12-13 01:41:28'),
(87, 2, 39, 0, 180, '1', '2017-12-13 01:41:28'),
(88, 2, 36, 0, 175, '1', '2017-12-13 01:41:28'),
(89, 2, 40, 0, 340, '1', '2017-12-13 01:41:28'),
(90, 2, 42, 0, 135, '1', '2017-12-13 01:41:29'),
(91, 2, 41, 0, 1.5, '1', '2017-12-13 01:41:29'),
(92, 2, 43, 0, 175, '1', '2017-12-13 01:41:29'),
(93, 2, 46, 0, 185, '1', '2017-12-13 01:41:29'),
(94, 2, 44, 0, 140, '1', '2017-12-13 01:41:29'),
(95, 2, 48, 0, 200, '1', '2017-12-13 01:41:29'),
(96, 2, 47, 0, 190, '1', '2017-12-13 01:41:29'),
(97, 2, 49, 0, 175, '1', '2017-12-13 01:41:29'),
(98, 2, 45, 0, 7.8, '1', '2017-12-13 01:41:29'),
(99, 2, 50, 0, 195, '1', '2017-12-13 01:41:29'),
(100, 2, 51, 0, 3.5, '1', '2017-12-13 01:41:29'),
(101, 2, 53, 0, 0, '1', '2017-12-13 01:41:29'),
(102, 2, 52, 0, 5, '1', '2017-12-13 01:41:29'),
(103, 3, 1, 0, 175, '1', '2017-12-13 09:26:35'),
(104, 3, 3, 0, 1100, '1', '2017-12-13 09:26:35'),
(105, 3, 2, 0, 350, '1', '2017-12-13 09:26:35'),
(106, 3, 5, 0, 350, '1', '2017-12-13 09:26:35'),
(107, 3, 4, 0, 800, '1', '2017-12-13 09:26:35'),
(108, 3, 6, 0, 200, '1', '2017-12-13 09:26:35'),
(109, 3, 7, 0, 210, '1', '2017-12-13 09:26:35'),
(110, 3, 11, 0, 170, '1', '2017-12-13 09:26:35'),
(111, 3, 10, 0, 265, '1', '2017-12-13 09:26:35'),
(112, 3, 12, 0, 105, '1', '2017-12-13 09:26:35'),
(113, 3, 16, 0, 250, '1', '2017-12-13 09:26:35'),
(114, 3, 14, 0, 260, '1', '2017-12-13 09:26:35'),
(115, 3, 15, 0, 0, '1', '2017-12-13 09:26:35'),
(116, 3, 13, 0, 0, '1', '2017-12-13 09:26:35'),
(117, 3, 18, 0, 240, '1', '2017-12-13 09:26:35'),
(118, 3, 17, 0, 0, '1', '2017-12-13 09:26:35'),
(119, 3, 19, 0, 180, '1', '2017-12-13 09:26:35'),
(120, 3, 20, 0, 300, '1', '2017-12-13 09:26:35'),
(121, 3, 23, 0, 275, '1', '2017-12-13 09:26:35'),
(122, 3, 22, 0, 225, '1', '2017-12-13 09:26:35'),
(123, 3, 21, 0, 0, '1', '2017-12-13 09:26:35'),
(124, 3, 26, 0, 220, '1', '2017-12-13 09:26:35'),
(125, 3, 24, 0, 150, '1', '2017-12-13 09:26:35'),
(126, 3, 25, 0, 135, '1', '2017-12-13 09:26:35'),
(127, 3, 28, 0, 210, '1', '2017-12-13 09:26:35'),
(128, 3, 27, 0, 145, '1', '2017-12-13 09:26:35'),
(129, 3, 29, 0, 320, '1', '2017-12-13 09:26:35'),
(130, 3, 31, 0, 245, '1', '2017-12-13 09:26:35'),
(131, 3, 30, 0, 280, '1', '2017-12-13 09:26:35'),
(132, 3, 32, 0, 0, '1', '2017-12-13 09:26:35'),
(133, 3, 33, 0, 200, '1', '2017-12-13 09:26:35'),
(134, 3, 34, 0, 190, '1', '2017-12-13 09:26:35'),
(135, 3, 35, 0, 200, '1', '2017-12-13 09:26:35'),
(136, 3, 37, 0, 175, '1', '2017-12-13 09:26:35'),
(137, 3, 38, 0, 150, '1', '2017-12-13 09:26:35'),
(138, 3, 39, 0, 180, '1', '2017-12-13 09:26:35'),
(139, 3, 36, 0, 175, '1', '2017-12-13 09:26:35'),
(140, 3, 40, 0, 340, '1', '2017-12-13 09:26:35'),
(141, 3, 42, 0, 135, '1', '2017-12-13 09:26:35'),
(142, 3, 41, 0, 1.5, '1', '2017-12-13 09:26:35'),
(143, 3, 43, 0, 175, '1', '2017-12-13 09:26:35'),
(144, 3, 46, 0, 185, '1', '2017-12-13 09:26:35'),
(145, 3, 44, 0, 140, '1', '2017-12-13 09:26:35'),
(146, 3, 48, 0, 200, '1', '2017-12-13 09:26:35'),
(147, 3, 47, 0, 190, '1', '2017-12-13 09:26:35'),
(148, 3, 49, 0, 175, '1', '2017-12-13 09:26:35'),
(149, 3, 45, 0, 7.8, '1', '2017-12-13 09:26:35'),
(150, 3, 50, 0, 195, '1', '2017-12-13 09:26:35'),
(151, 3, 51, 0, 3.5, '1', '2017-12-13 09:26:35'),
(152, 3, 53, 0, 0, '1', '2017-12-13 09:26:35'),
(153, 3, 52, 0, 5, '1', '2017-12-13 09:26:35');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `producto`
--

CREATE TABLE `producto` (
  `idProducto` int(11) NOT NULL,
  `pro_sku` varchar(20) DEFAULT NULL,
  `pro_nombre` varchar(250) DEFAULT NULL,
  `pro_descripcion` varchar(500) DEFAULT NULL,
  `pro_unidad` varchar(45) DEFAULT NULL,
  `pro_estatus` int(11) DEFAULT '1',
  `idEmpresa` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `producto`
--

INSERT INTO `producto` (`idProducto`, `pro_sku`, `pro_nombre`, `pro_descripcion`, `pro_unidad`, `pro_estatus`, `idEmpresa`) VALUES
(1, '', 'BASE BORREGO', '25 KILOGRAMOS', 'bulto', 1, 1),
(2, '', 'BASE CABALLO', '5 KILOGRAMOS', 'bulto', 1, 1),
(3, '', 'BASE CC', '30 KILOGRAMOS', 'bulto', 1, 1),
(4, '', 'BASE CE', '30 KILOGRAMOS', 'bulto', 1, 1),
(5, '', 'BASE LECHERO', '20 KILOGRAMOS', 'bulto', 1, 1),
(6, '', 'BORREGO', '40 KILOGRAMOS', 'bulto', 1, 1),
(7, '', 'CABALLO', '40 KILOGRAMOS', 'bulto', 1, 1),
(8, '', 'asdasd', 'asdasd', 'bulto', 0, 1),
(9, '2112', '12', 'ASDASD', 'caja', 0, 1),
(10, '', 'CANOLA', '40 KILOGRAMOS', 'bulto', 1, 1),
(11, '', 'CASCARILLA DE SOYA', '40 KILOGRAMOS', 'bulto', 1, 1),
(12, '', 'CEMA', '28 KILOGRAMOS', 'bulto', 1, 1),
(13, '', 'CERDO ENGORDA 2000', '40 KILOGRAMOS', 'bulto', 1, 1),
(14, '', 'CERDO CRECE AS', '40 KILOGRAMOS', 'bulto', 1, 1),
(15, '', 'CERDO CRECE UNION', '40 KILOGRAMOS', 'bulto', 1, 1),
(16, '', 'CERDO ENGORDA AS', '40 KILOGRAMOS', 'bulto', 1, 1),
(17, '', 'CERDO ENGORDA UNION', '40 KILOGRAMOS', 'bulto', 1, 1),
(18, '', 'CEVADA ENTERA', '40 KILOGRAMOS', 'bulto', 1, 1),
(19, '', 'CEVADA ROLADA', '30 KILOGRAMOS', 'bulto', 1, 1),
(20, '', 'CHOCO', '30 KILOGRAMOS', 'bulto', 1, 1),
(21, '', 'CHOCO GRAMOS', '5 KILOGRAMOS', 'bulto', 1, 1),
(22, '', 'CHOCO KILOS', '1 KILOGRAMO', 'kg', 1, 1),
(23, '', 'DESTETE CERDO', '40 KILOGRAMOS', 'bulto', 1, 1),
(24, '', 'FRITURA', '40 KILOGRAMOS', 'bulto', 1, 1),
(25, '', 'GALLETA', '40 KILOGRAMOS', 'bulto', 1, 1),
(26, '', 'GESTACION CERDA', '40 KILOGRAMOS', 'bulto', 1, 1),
(27, '', 'GRANILLO', '30 KILOGRAMOS', 'bulto', 1, 1),
(28, '', 'GRANO SECO DDG', '40 KILOGRAMOS', 'bulto', 1, 1),
(29, '', 'GRASA DE SOBREPASO', '25 KILOGRAMOS', 'bulto', 1, 1),
(30, '', 'INICIADOR CERDO', '40 KILOGRAMOS', 'bulto', 1, 1),
(31, '', 'LACTANCIA CERDA', '40 KILOGRAMOS', 'bulto', 1, 1),
(32, '', 'LECHERO AS', '40 KILOGRAMOS', 'bulto', 1, 1),
(33, '', 'MAIZ QUEBRADO', '40 KILOGRAMOS', 'bulto', 1, 1),
(34, '', 'MAIZ MOLIDO', '40 KILOGRAMOS', 'bulto', 1, 1),
(35, '', 'MAIZ ROLADO', '40 KILOGRAMOS', 'bulto', 1, 1),
(36, '', 'MAIZ BLANCO', '40 KILOGRAMOS', 'bulto', 1, 1),
(37, '', 'MELAZA', '30 KILOGRAMOS', 'bulto', 1, 1),
(38, '', 'NARANJA', '40 KILOGRAMOS', 'bulto', 1, 1),
(39, '', 'NUTRIMEX MAIZ TOSTADO', '40 KILOGRAMOS', 'bulto', 1, 1),
(40, '', 'PASTA DE SOYA', '40 KILOGRAMOS', 'bulto', 1, 1),
(41, '', 'POLLINAZA', '1 KILOGRAMO', 'kg', 1, 1),
(42, '', 'PULIDO DE ARROZ', '35 KILOGRAMOS', 'bulto', 1, 1),
(43, '', 'SAL MINERAL', '25 KILOGRAMOS', 'bulto', 1, 1),
(44, '', 'SALVADO', '40 KILOGRAMOS', 'bulto', 1, 1),
(45, '', 'SEMILLA DE ALGOD&Oacute;N', '35 KILOGRAMOS', 'bulto', 1, 1),
(46, '', 'SORGO', '40 KILOGRAMOS', 'bulto', 1, 1),
(47, '', 'SORGO ENTERO', '40 KILOGRAMOS', 'bulto', 1, 1),
(48, '', 'SORGO ROLADO', '40 KILOGRAMOS', 'bulto', 1, 1),
(49, '', 'TORO CRECE', '40 KILOGRAMOS', 'bulto', 1, 1),
(50, '', 'TORO ENGORDA', '40 KILOGRAMOS', 'bulto', 1, 1),
(51, '', 'ZACAMEL', '1 KILOGRAMO', 'kg', 1, 1),
(52, '', 'FORMULA BORREGO', 'VENTA POR KILO', 'kg', 1, 1),
(53, '', 'FORMULA BORREGO CONSUMO', 'CONSUMO PROPIO', 'kg', 1, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `stock`
--

CREATE TABLE `stock` (
  `idStock` int(11) NOT NULL,
  `idProducto` int(11) NOT NULL,
  `idEmpresa` int(11) NOT NULL,
  `idSucursal` int(11) NOT NULL,
  `sto_cantidad` float DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `stockhistorial`
--

CREATE TABLE `stockhistorial` (
  `idStockHistorial` int(11) NOT NULL,
  `sto_cantidad` varchar(45) DEFAULT NULL,
  `fecha` date DEFAULT NULL,
  `timestamp` datetime DEFAULT CURRENT_TIMESTAMP,
  `idStock` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `sucursal`
--

CREATE TABLE `sucursal` (
  `idSucursal` int(11) NOT NULL,
  `suc_nombre` varchar(45) DEFAULT NULL,
  `suc_descripcion` varchar(500) DEFAULT NULL,
  `suc_estatus` int(11) DEFAULT '1',
  `idEmpresa` int(11) NOT NULL,
  `suc_matriz` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `sucursal`
--

INSERT INTO `sucursal` (`idSucursal`, `suc_nombre`, `suc_descripcion`, `suc_estatus`, `idEmpresa`, `suc_matriz`) VALUES
(1, 'Actopan', 'Actopan Hidalgo', 1, 1, 1),
(2, 'Ixmiquilpan', 'Ixmiquilpan Hidalgo', 1, 1, 0),
(3, 'Atotonilco', 'Atotonilco Hidalgo', 1, 1, 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipocheckin`
--

CREATE TABLE `tipocheckin` (
  `idTipoCheckIn` int(11) NOT NULL,
  `tchi_tipo` varchar(100) DEFAULT NULL,
  `tchi_estatus` int(11) DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `tipocheckin`
--

INSERT INTO `tipocheckin` (`idTipoCheckIn`, `tchi_tipo`, `tchi_estatus`) VALUES
(1, 'Compra', 1),
(2, 'Traspaso', 1),
(3, 'Mezclas', 1),
(4, 'Ajuste', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipocheckout`
--

CREATE TABLE `tipocheckout` (
  `idTipoCheckOut` int(11) NOT NULL,
  `tcho_tipo` varchar(100) DEFAULT NULL,
  `tcho_estatus` int(11) DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `tipocheckout`
--

INSERT INTO `tipocheckout` (`idTipoCheckOut`, `tcho_tipo`, `tcho_estatus`) VALUES
(1, 'Venta', 1),
(2, 'Traspaso', 1),
(3, 'Mezclas', 1),
(4, 'Ajuste', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `traspaso`
--

CREATE TABLE `traspaso` (
  `idTraspaso` int(11) NOT NULL,
  `idSucursalOrigen` int(11) NOT NULL,
  `idSucursalDestino` int(11) NOT NULL,
  `idUsuario` int(11) NOT NULL,
  `tra_observaciones` varchar(45) DEFAULT NULL,
  `timestamp` varchar(45) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `traspasocheckin`
--

CREATE TABLE `traspasocheckin` (
  `idTraspasoCheckIn` int(11) NOT NULL,
  `idTraspaso` int(11) NOT NULL,
  `idCheckIn` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `traspasocheckout`
--

CREATE TABLE `traspasocheckout` (
  `idTraspasoCheckOut` int(11) NOT NULL,
  `idTraspaso` int(11) NOT NULL,
  `idCheckOut` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `traspasodetalle`
--

CREATE TABLE `traspasodetalle` (
  `idTraspasoDetalle` int(11) NOT NULL,
  `idStock` int(11) NOT NULL,
  `trde_cantidad` float NOT NULL,
  `trde_observaciones` varchar(500) DEFAULT NULL,
  `timestamp` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `idTraspaso` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario`
--

CREATE TABLE `usuario` (
  `idUsuario` int(11) NOT NULL,
  `usu_nombre` varchar(500) COLLATE latin1_spanish_ci DEFAULT NULL,
  `usu_usuario` varchar(150) COLLATE latin1_spanish_ci DEFAULT NULL,
  `usu_password` varchar(50) COLLATE latin1_spanish_ci DEFAULT NULL,
  `usu_estatus` int(11) DEFAULT '1',
  `idCatalogoUsuario` int(11) NOT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `idEmpresa` int(11) DEFAULT NULL,
  `idSucursal` varchar(45) COLLATE latin1_spanish_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;

--
-- Volcado de datos para la tabla `usuario`
--

INSERT INTO `usuario` (`idUsuario`, `usu_nombre`, `usu_usuario`, `usu_password`, `usu_estatus`, `idCatalogoUsuario`, `timestamp`, `idEmpresa`, `idSucursal`) VALUES
(1, 'Octavio Reyes Ortega', 'asdeoros', 'qwerty', 1, 1, '2017-12-05 15:37:55', 1, '0');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `venta`
--

CREATE TABLE `venta` (
  `idVenta` int(11) NOT NULL,
  `timestamp` datetime DEFAULT CURRENT_TIMESTAMP,
  `idCaja` int(11) NOT NULL,
  `idCheckOut` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `caja`
--
ALTER TABLE `caja`
  ADD PRIMARY KEY (`idCaja`),
  ADD KEY `fk_caja_empresa1_idx` (`idEmpresa`),
  ADD KEY `fk_caja_sucursal1_idx` (`idSucursal`),
  ADD KEY `fk_caja_usuario1_idx` (`idUsuario`);

--
-- Indices de la tabla `catalogousuario`
--
ALTER TABLE `catalogousuario`
  ADD PRIMARY KEY (`idCatalogoUsuario`);

--
-- Indices de la tabla `checkin`
--
ALTER TABLE `checkin`
  ADD PRIMARY KEY (`idCheckIn`),
  ADD KEY `fk_checkin_tipocheckin1_idx` (`idTipoCheckIn`),
  ADD KEY `fk_checkin_empresa1_idx` (`idEmpresa`),
  ADD KEY `fk_checkin_sucursal1_idx` (`idSucursal`),
  ADD KEY `fk_checkin_usuario1_idx` (`idUsuario`);

--
-- Indices de la tabla `checkindetalle`
--
ALTER TABLE `checkindetalle`
  ADD PRIMARY KEY (`idCheckInDetalle`),
  ADD KEY `fk_checkindetalle_producto1_idx` (`idProducto`),
  ADD KEY `fk_checkindetalle_checkin1_idx` (`idCheckIn`);

--
-- Indices de la tabla `checkout`
--
ALTER TABLE `checkout`
  ADD PRIMARY KEY (`idCheckOut`),
  ADD KEY `fk_checkout_tipocheckout1_idx` (`idTipoCheckOut`),
  ADD KEY `fk_checkout_empresa1_idx` (`idEmpresa`),
  ADD KEY `fk_checkout_sucursal1_idx` (`idSucursal`),
  ADD KEY `fk_checkout_usuario1_idx` (`idUsuario`);

--
-- Indices de la tabla `checkoutdetalle`
--
ALTER TABLE `checkoutdetalle`
  ADD PRIMARY KEY (`idCheckOutDetalle`),
  ADD KEY `fk_checkoutdetalle_producto1_idx` (`idProducto`),
  ADD KEY `fk_checkoutdetalle_checkout1_idx` (`idCheckOut`);

--
-- Indices de la tabla `cliente`
--
ALTER TABLE `cliente`
  ADD PRIMARY KEY (`idCliente`),
  ADD KEY `fk_cliente_empresa1_idx` (`idEmpresa`);

--
-- Indices de la tabla `configuracionempresa`
--
ALTER TABLE `configuracionempresa`
  ADD PRIMARY KEY (`idConfiguracionEmpresa`),
  ADD KEY `fk_configuracionempresa_empresa1_idx` (`idEmpresa`);

--
-- Indices de la tabla `empresa`
--
ALTER TABLE `empresa`
  ADD PRIMARY KEY (`idEmpresa`);

--
-- Indices de la tabla `gastos`
--
ALTER TABLE `gastos`
  ADD PRIMARY KEY (`idGastos`),
  ADD KEY `fk_cajadetalle_caja1_idx` (`caja_idCaja`),
  ADD KEY `fk_gastos_gastostipo1_idx` (`idGastoTipo`);

--
-- Indices de la tabla `gastotipo`
--
ALTER TABLE `gastotipo`
  ADD PRIMARY KEY (`idGastoTipo`);

--
-- Indices de la tabla `listaprecio`
--
ALTER TABLE `listaprecio`
  ADD PRIMARY KEY (`idListaPrecio`),
  ADD KEY `fk_listaprecio_empresa1_idx` (`idEmpresa`);

--
-- Indices de la tabla `mezcla`
--
ALTER TABLE `mezcla`
  ADD PRIMARY KEY (`idMezcla`),
  ADD KEY `fk_mezcla_checkout1_idx` (`idCheckOut`),
  ADD KEY `fk_mezcla_checkin1_idx` (`checkin_idCheckIn`);

--
-- Indices de la tabla `precio`
--
ALTER TABLE `precio`
  ADD PRIMARY KEY (`idPrecio`),
  ADD KEY `fk_precio_listaprecio1_idx` (`idListaPrecio`),
  ADD KEY `fk_precio_producto1_idx` (`idProducto`);

--
-- Indices de la tabla `producto`
--
ALTER TABLE `producto`
  ADD PRIMARY KEY (`idProducto`),
  ADD KEY `fk_producto_empresa1_idx` (`idEmpresa`);

--
-- Indices de la tabla `stock`
--
ALTER TABLE `stock`
  ADD PRIMARY KEY (`idStock`),
  ADD KEY `fk_stock_producto1_idx` (`idProducto`),
  ADD KEY `fk_stock_empresa1_idx` (`idEmpresa`),
  ADD KEY `fk_stock_sucursal1_idx` (`idSucursal`);

--
-- Indices de la tabla `stockhistorial`
--
ALTER TABLE `stockhistorial`
  ADD PRIMARY KEY (`idStockHistorial`),
  ADD KEY `fk_stokhistorial_stock1_idx` (`idStock`);

--
-- Indices de la tabla `sucursal`
--
ALTER TABLE `sucursal`
  ADD PRIMARY KEY (`idSucursal`),
  ADD KEY `fk_sucursal_empresa1_idx` (`idEmpresa`);

--
-- Indices de la tabla `tipocheckin`
--
ALTER TABLE `tipocheckin`
  ADD PRIMARY KEY (`idTipoCheckIn`);

--
-- Indices de la tabla `tipocheckout`
--
ALTER TABLE `tipocheckout`
  ADD PRIMARY KEY (`idTipoCheckOut`);

--
-- Indices de la tabla `traspaso`
--
ALTER TABLE `traspaso`
  ADD PRIMARY KEY (`idTraspaso`),
  ADD KEY `fk_traspaso_sucursal1_idx` (`idSucursalOrigen`),
  ADD KEY `fk_traspaso_sucursal2_idx` (`idSucursalDestino`),
  ADD KEY `fk_traspaso_usuario1_idx` (`idUsuario`);

--
-- Indices de la tabla `traspasocheckin`
--
ALTER TABLE `traspasocheckin`
  ADD PRIMARY KEY (`idTraspasoCheckIn`),
  ADD KEY `fk_traspasocheckin_traspaso1_idx` (`idTraspaso`),
  ADD KEY `fk_traspasocheckin_checkin1_idx` (`idCheckIn`);

--
-- Indices de la tabla `traspasocheckout`
--
ALTER TABLE `traspasocheckout`
  ADD PRIMARY KEY (`idTraspasoCheckOut`),
  ADD KEY `fk_traspasocheckout_traspaso1_idx` (`idTraspaso`),
  ADD KEY `fk_traspasocheckout_checkout1_idx` (`idCheckOut`);

--
-- Indices de la tabla `traspasodetalle`
--
ALTER TABLE `traspasodetalle`
  ADD PRIMARY KEY (`idTraspasoDetalle`),
  ADD KEY `fk_traspaso_stock1_idx` (`idStock`),
  ADD KEY `fk_traspaso_traspaso1_idx` (`idTraspaso`);

--
-- Indices de la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`idUsuario`),
  ADD KEY `fk_usuario_catalogousuario_idx` (`idCatalogoUsuario`);

--
-- Indices de la tabla `venta`
--
ALTER TABLE `venta`
  ADD PRIMARY KEY (`idVenta`),
  ADD KEY `fk_venta_caja1_idx` (`idCaja`),
  ADD KEY `fk_venta_checkout1_idx` (`idCheckOut`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `caja`
--
ALTER TABLE `caja`
  MODIFY `idCaja` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT de la tabla `catalogousuario`
--
ALTER TABLE `catalogousuario`
  MODIFY `idCatalogoUsuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;
--
-- AUTO_INCREMENT de la tabla `checkin`
--
ALTER TABLE `checkin`
  MODIFY `idCheckIn` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT de la tabla `checkindetalle`
--
ALTER TABLE `checkindetalle`
  MODIFY `idCheckInDetalle` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT de la tabla `checkout`
--
ALTER TABLE `checkout`
  MODIFY `idCheckOut` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT de la tabla `checkoutdetalle`
--
ALTER TABLE `checkoutdetalle`
  MODIFY `idCheckOutDetalle` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT de la tabla `cliente`
--
ALTER TABLE `cliente`
  MODIFY `idCliente` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT de la tabla `configuracionempresa`
--
ALTER TABLE `configuracionempresa`
  MODIFY `idConfiguracionEmpresa` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
--
-- AUTO_INCREMENT de la tabla `empresa`
--
ALTER TABLE `empresa`
  MODIFY `idEmpresa` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT de la tabla `gastos`
--
ALTER TABLE `gastos`
  MODIFY `idGastos` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT de la tabla `gastotipo`
--
ALTER TABLE `gastotipo`
  MODIFY `idGastoTipo` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT de la tabla `listaprecio`
--
ALTER TABLE `listaprecio`
  MODIFY `idListaPrecio` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;
--
-- AUTO_INCREMENT de la tabla `precio`
--
ALTER TABLE `precio`
  MODIFY `idPrecio` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=166;
--
-- AUTO_INCREMENT de la tabla `producto`
--
ALTER TABLE `producto`
  MODIFY `idProducto` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=54;
--
-- AUTO_INCREMENT de la tabla `stock`
--
ALTER TABLE `stock`
  MODIFY `idStock` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT de la tabla `stockhistorial`
--
ALTER TABLE `stockhistorial`
  MODIFY `idStockHistorial` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT de la tabla `sucursal`
--
ALTER TABLE `sucursal`
  MODIFY `idSucursal` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;
--
-- AUTO_INCREMENT de la tabla `tipocheckin`
--
ALTER TABLE `tipocheckin`
  MODIFY `idTipoCheckIn` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;
--
-- AUTO_INCREMENT de la tabla `tipocheckout`
--
ALTER TABLE `tipocheckout`
  MODIFY `idTipoCheckOut` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;
--
-- AUTO_INCREMENT de la tabla `traspaso`
--
ALTER TABLE `traspaso`
  MODIFY `idTraspaso` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT de la tabla `traspasocheckin`
--
ALTER TABLE `traspasocheckin`
  MODIFY `idTraspasoCheckIn` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT de la tabla `traspasocheckout`
--
ALTER TABLE `traspasocheckout`
  MODIFY `idTraspasoCheckOut` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT de la tabla `traspasodetalle`
--
ALTER TABLE `traspasodetalle`
  MODIFY `idTraspasoDetalle` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT de la tabla `usuario`
--
ALTER TABLE `usuario`
  MODIFY `idUsuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT de la tabla `venta`
--
ALTER TABLE `venta`
  MODIFY `idVenta` int(11) NOT NULL AUTO_INCREMENT;
--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `caja`
--
ALTER TABLE `caja`
  ADD CONSTRAINT `fk_caja_empresa1` FOREIGN KEY (`idEmpresa`) REFERENCES `empresa` (`idEmpresa`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_caja_sucursal1` FOREIGN KEY (`idSucursal`) REFERENCES `sucursal` (`idSucursal`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_caja_usuario1` FOREIGN KEY (`idUsuario`) REFERENCES `usuario` (`idUsuario`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `checkin`
--
ALTER TABLE `checkin`
  ADD CONSTRAINT `fk_checkin_empresa1` FOREIGN KEY (`idEmpresa`) REFERENCES `empresa` (`idEmpresa`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_checkin_sucursal1` FOREIGN KEY (`idSucursal`) REFERENCES `sucursal` (`idSucursal`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_checkin_tipocheckin1` FOREIGN KEY (`idTipoCheckIn`) REFERENCES `tipocheckin` (`idTipoCheckIn`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_checkin_usuario1` FOREIGN KEY (`idUsuario`) REFERENCES `usuario` (`idUsuario`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `checkindetalle`
--
ALTER TABLE `checkindetalle`
  ADD CONSTRAINT `fk_checkindetalle_checkin1` FOREIGN KEY (`idCheckIn`) REFERENCES `checkin` (`idCheckIn`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_checkindetalle_producto1` FOREIGN KEY (`idProducto`) REFERENCES `producto` (`idProducto`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `checkout`
--
ALTER TABLE `checkout`
  ADD CONSTRAINT `fk_checkout_empresa1` FOREIGN KEY (`idEmpresa`) REFERENCES `empresa` (`idEmpresa`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_checkout_sucursal1` FOREIGN KEY (`idSucursal`) REFERENCES `sucursal` (`idSucursal`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_checkout_tipocheckout1` FOREIGN KEY (`idTipoCheckOut`) REFERENCES `tipocheckout` (`idTipoCheckOut`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_checkout_usuario1` FOREIGN KEY (`idUsuario`) REFERENCES `usuario` (`idUsuario`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `checkoutdetalle`
--
ALTER TABLE `checkoutdetalle`
  ADD CONSTRAINT `fk_checkoutdetalle_checkout1` FOREIGN KEY (`idCheckOut`) REFERENCES `checkout` (`idCheckOut`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_checkoutdetalle_producto1` FOREIGN KEY (`idProducto`) REFERENCES `producto` (`idProducto`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `cliente`
--
ALTER TABLE `cliente`
  ADD CONSTRAINT `fk_cliente_empresa1` FOREIGN KEY (`idEmpresa`) REFERENCES `empresa` (`idEmpresa`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `configuracionempresa`
--
ALTER TABLE `configuracionempresa`
  ADD CONSTRAINT `fk_configuracionempresa_empresa1` FOREIGN KEY (`idEmpresa`) REFERENCES `empresa` (`idEmpresa`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `gastos`
--
ALTER TABLE `gastos`
  ADD CONSTRAINT `fk_cajadetalle_caja1` FOREIGN KEY (`caja_idCaja`) REFERENCES `caja` (`idCaja`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_gastos_gastostipo1` FOREIGN KEY (`idGastoTipo`) REFERENCES `gastotipo` (`idGastoTipo`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `listaprecio`
--
ALTER TABLE `listaprecio`
  ADD CONSTRAINT `fk_listaprecio_empresa1` FOREIGN KEY (`idEmpresa`) REFERENCES `empresa` (`idEmpresa`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `mezcla`
--
ALTER TABLE `mezcla`
  ADD CONSTRAINT `fk_mezcla_checkin1` FOREIGN KEY (`checkin_idCheckIn`) REFERENCES `checkin` (`idCheckIn`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_mezcla_checkout1` FOREIGN KEY (`idCheckOut`) REFERENCES `checkout` (`idCheckOut`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `precio`
--
ALTER TABLE `precio`
  ADD CONSTRAINT `fk_precio_listaprecio1` FOREIGN KEY (`idListaPrecio`) REFERENCES `listaprecio` (`idListaPrecio`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_precio_producto1` FOREIGN KEY (`idProducto`) REFERENCES `producto` (`idProducto`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `producto`
--
ALTER TABLE `producto`
  ADD CONSTRAINT `fk_producto_empresa1` FOREIGN KEY (`idEmpresa`) REFERENCES `empresa` (`idEmpresa`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `stock`
--
ALTER TABLE `stock`
  ADD CONSTRAINT `fk_stock_empresa1` FOREIGN KEY (`idEmpresa`) REFERENCES `empresa` (`idEmpresa`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_stock_producto1` FOREIGN KEY (`idProducto`) REFERENCES `producto` (`idProducto`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_stock_sucursal1` FOREIGN KEY (`idSucursal`) REFERENCES `sucursal` (`idSucursal`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `stockhistorial`
--
ALTER TABLE `stockhistorial`
  ADD CONSTRAINT `fk_stokhistorial_stock1` FOREIGN KEY (`idStock`) REFERENCES `stock` (`idStock`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `sucursal`
--
ALTER TABLE `sucursal`
  ADD CONSTRAINT `fk_sucursal_empresa1` FOREIGN KEY (`idEmpresa`) REFERENCES `empresa` (`idEmpresa`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `traspaso`
--
ALTER TABLE `traspaso`
  ADD CONSTRAINT `fk_traspaso_sucursal1` FOREIGN KEY (`idSucursalOrigen`) REFERENCES `sucursal` (`idSucursal`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_traspaso_sucursal2` FOREIGN KEY (`idSucursalDestino`) REFERENCES `sucursal` (`idSucursal`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_traspaso_usuario1` FOREIGN KEY (`idUsuario`) REFERENCES `usuario` (`idUsuario`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `traspasocheckin`
--
ALTER TABLE `traspasocheckin`
  ADD CONSTRAINT `fk_traspasocheckin_checkin1` FOREIGN KEY (`idCheckIn`) REFERENCES `checkin` (`idCheckIn`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_traspasocheckin_traspaso1` FOREIGN KEY (`idTraspaso`) REFERENCES `traspaso` (`idTraspaso`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `traspasocheckout`
--
ALTER TABLE `traspasocheckout`
  ADD CONSTRAINT `fk_traspasocheckout_checkout1` FOREIGN KEY (`idCheckOut`) REFERENCES `checkout` (`idCheckOut`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_traspasocheckout_traspaso1` FOREIGN KEY (`idTraspaso`) REFERENCES `traspaso` (`idTraspaso`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `traspasodetalle`
--
ALTER TABLE `traspasodetalle`
  ADD CONSTRAINT `fk_traspaso_stock1` FOREIGN KEY (`idStock`) REFERENCES `stock` (`idStock`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_traspaso_traspaso1` FOREIGN KEY (`idTraspaso`) REFERENCES `traspaso` (`idTraspaso`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD CONSTRAINT `fk_usuario_catalogousuario` FOREIGN KEY (`idCatalogoUsuario`) REFERENCES `catalogousuario` (`idCatalogoUsuario`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `venta`
--
ALTER TABLE `venta`
  ADD CONSTRAINT `fk_venta_caja1` FOREIGN KEY (`idCaja`) REFERENCES `caja` (`idCaja`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_venta_checkout1` FOREIGN KEY (`idCheckOut`) REFERENCES `checkout` (`idCheckOut`) ON DELETE NO ACTION ON UPDATE NO ACTION;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
