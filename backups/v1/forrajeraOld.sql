-- phpMyAdmin SQL Dump
-- version 4.6.5.2
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 28-11-2017 a las 02:13:15
-- Versión del servidor: 10.1.21-MariaDB
-- Versión de PHP: 5.6.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `forrajera`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `ADM_LOGIN_SP` (IN `_user` VARCHAR(255) CHARSET utf8, IN `_pass` VARCHAR(255) CHARSET utf8)  BEGIN
	SELECT * FROM usuario 			 USU
	INNER JOIN empresa 				 EMP   ON USU.emp_id = EMP.emp_id
    INNER JOIN catalogousuario 		 CU 	  ON USU.cu_id = CU.cu_id
    INNER JOIN configuracionempresa  CONF  ON CONF.emp_id = EMP.emp_id
	WHERE CU.cu_id = 2
		  AND usu_usuario = _user
		  AND usu_password = _pass
		  AND usu_estatus = 1;
END$$

DELIMITER ;

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
(1, 'Super Usuario'),
(2, 'Encargado'),
(3, 'Empleado');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `checkin`
--

CREATE TABLE `checkin` (
  `idCheckIn` int(11) NOT NULL,
  `chi_descripcion` varchar(500) DEFAULT NULL,
  `chi_estatus` int(11) DEFAULT '1',
  `idTipoCheckout` int(11) DEFAULT NULL,
  `idUsuario` int(11) DEFAULT NULL,
  `idEmpresa` int(11) DEFAULT NULL,
  `idSucursal` int(11) DEFAULT NULL,
  `timestamp` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `checkindetalle`
--

CREATE TABLE `checkindetalle` (
  `idCheckInDetalle` int(11) NOT NULL,
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
  `idTipoCheckout` int(11) DEFAULT NULL,
  `idUsuario` int(11) DEFAULT NULL,
  `idEmpresa` int(11) DEFAULT NULL,
  `idSucursal` int(11) DEFAULT NULL,
  `timestamp` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `checkoutdetalle`
--

CREATE TABLE `checkoutdetalle` (
  `idCheckOutDetalle` int(11) NOT NULL,
  `idProducto` int(11) NOT NULL,
  `cod_cantidad` float NOT NULL DEFAULT '0',
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
  `cli_estatus` int(11) DEFAULT NULL,
  `idEmpresa` int(11) DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `key` varchar(60) COLLATE latin1_spanish_ci DEFAULT NULL,
  `idSucursal` varchar(45) COLLATE latin1_spanish_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;

--
-- Volcado de datos para la tabla `cliente`
--

INSERT INTO `cliente` (`idCliente`, `cli_rfc`, `cli_rason_social`, `cli_estatus`, `idEmpresa`, `timestamp`, `key`, `idSucursal`) VALUES
(1, 'GRI8704216N5', 'GRIANT S.A. DE C.V.', 1, 1, '2017-10-24 17:02:45', '71aa1b8bfc17343e747876606d820ae8', NULL),
(2, 'GOSQ1398212', 'GOSSIP', 1, 1, '2017-10-24 19:42:33', 'ba789c1ea67bc30e2c35f78cda8694e4', NULL),
(3, 'PROT871234', 'PROTAGON', 1, 1, '2017-10-24 19:44:41', '4ef5edec684ec441bb81cd4af48e9076', NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `configuracionempresa`
--

CREATE TABLE `configuracionempresa` (
  `idConfiguracionEmpresa` int(11) NOT NULL,
  `idEmpresa` int(11) DEFAULT NULL,
  `conf_integracion` int(11) DEFAULT '1',
  `conf_caduca` int(11) DEFAULT '1',
  `conf_fecha_caduca` date DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;

--
-- Volcado de datos para la tabla `configuracionempresa`
--

INSERT INTO `configuracionempresa` (`idConfiguracionEmpresa`, `idEmpresa`, `conf_integracion`, `conf_caduca`, `conf_fecha_caduca`, `timestamp`) VALUES
(1, 1, 0, 0, NULL, '2017-11-27 23:37:30');

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
(1, 'FORRAJERA AS DE OROS', 'ASOROS0001', 'Nombre de Contacto', 'contacto@asdeoros.com', '7710000000', 'Pachuca', 1, '2017-11-27 23:33:32');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `listaprecio`
--

CREATE TABLE `listaprecio` (
  `idListaPrecio` int(11) NOT NULL,
  `lpr_nombre` varchar(45) DEFAULT NULL,
  `lpr_descripcion` varchar(45) DEFAULT NULL,
  `lpr_estatus` int(11) DEFAULT '1',
  `idEmpresa` int(11) DEFAULT NULL,
  `idSucursal` int(11) DEFAULT '0',
  `timestamp` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `precio`
--

CREATE TABLE `precio` (
  `idPrecio` int(11) NOT NULL,
  `idProducto` int(11) DEFAULT NULL,
  `precio_compra` float DEFAULT NULL,
  `precio_venta` float DEFAULT NULL,
  `pre_estatus` varchar(45) DEFAULT NULL,
  `timestamp` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

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
  `idEmpresa` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `stock`
--

CREATE TABLE `stock` (
  `idStock` int(11) NOT NULL,
  `idProducto` int(11) DEFAULT NULL,
  `idEmpresa` int(11) DEFAULT NULL,
  `idSucursal` int(11) DEFAULT NULL,
  `sto_cantidad` float DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `stokhistorial`
--

CREATE TABLE `stokhistorial` (
  `idstokhistorial` int(11) NOT NULL,
  `idProducto` varchar(45) DEFAULT NULL,
  `idEmpresa` varchar(45) DEFAULT NULL,
  `idSucursal` varchar(45) DEFAULT NULL,
  `sto_cantidad` varchar(45) DEFAULT NULL,
  `fecha` date DEFAULT NULL,
  `timestamp` datetime DEFAULT CURRENT_TIMESTAMP
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
  `idEmpresa` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `sucursal`
--

INSERT INTO `sucursal` (`idSucursal`, `suc_nombre`, `suc_descripcion`, `suc_estatus`, `idEmpresa`) VALUES
(1, 'Pachuca', NULL, 1, 1),
(2, 'Atotonilco', NULL, 1, 1),
(3, 'Actopan', NULL, 1, 1);

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
(2, 'Ajuste', 1),
(3, 'Traspaso', 1);

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
(3, 'Merma', 1),
(4, 'Perdida', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario`
--

CREATE TABLE `usuario` (
  `idUsuario` int(11) NOT NULL,
  `usu_usuario` varchar(150) COLLATE latin1_spanish_ci DEFAULT NULL,
  `usu_password` varchar(50) COLLATE latin1_spanish_ci DEFAULT NULL,
  `usu_estatus` int(11) DEFAULT '1',
  `idCatalogoUsuario` int(11) DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `idEmpresa` int(11) DEFAULT NULL,
  `idSucursal` varchar(45) COLLATE latin1_spanish_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `catalogousuario`
--
ALTER TABLE `catalogousuario`
  ADD PRIMARY KEY (`idCatalogoUsuario`);

--
-- Indices de la tabla `checkin`
--
ALTER TABLE `checkin`
  ADD PRIMARY KEY (`idCheckIn`);

--
-- Indices de la tabla `checkindetalle`
--
ALTER TABLE `checkindetalle`
  ADD PRIMARY KEY (`idCheckInDetalle`);

--
-- Indices de la tabla `checkout`
--
ALTER TABLE `checkout`
  ADD PRIMARY KEY (`idCheckOut`);

--
-- Indices de la tabla `checkoutdetalle`
--
ALTER TABLE `checkoutdetalle`
  ADD PRIMARY KEY (`idCheckOutDetalle`);

--
-- Indices de la tabla `cliente`
--
ALTER TABLE `cliente`
  ADD PRIMARY KEY (`idCliente`);

--
-- Indices de la tabla `configuracionempresa`
--
ALTER TABLE `configuracionempresa`
  ADD PRIMARY KEY (`idConfiguracionEmpresa`);

--
-- Indices de la tabla `empresa`
--
ALTER TABLE `empresa`
  ADD PRIMARY KEY (`idEmpresa`);

--
-- Indices de la tabla `listaprecio`
--
ALTER TABLE `listaprecio`
  ADD PRIMARY KEY (`idListaPrecio`);

--
-- Indices de la tabla `precio`
--
ALTER TABLE `precio`
  ADD PRIMARY KEY (`idPrecio`);

--
-- Indices de la tabla `producto`
--
ALTER TABLE `producto`
  ADD PRIMARY KEY (`idProducto`);

--
-- Indices de la tabla `stock`
--
ALTER TABLE `stock`
  ADD PRIMARY KEY (`idStock`);

--
-- Indices de la tabla `stokhistorial`
--
ALTER TABLE `stokhistorial`
  ADD PRIMARY KEY (`idstokhistorial`);

--
-- Indices de la tabla `sucursal`
--
ALTER TABLE `sucursal`
  ADD PRIMARY KEY (`idSucursal`);

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
-- Indices de la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`idUsuario`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

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
  MODIFY `idCliente` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;
--
-- AUTO_INCREMENT de la tabla `configuracionempresa`
--
ALTER TABLE `configuracionempresa`
  MODIFY `idConfiguracionEmpresa` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT de la tabla `empresa`
--
ALTER TABLE `empresa`
  MODIFY `idEmpresa` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT de la tabla `listaprecio`
--
ALTER TABLE `listaprecio`
  MODIFY `idListaPrecio` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT de la tabla `precio`
--
ALTER TABLE `precio`
  MODIFY `idPrecio` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT de la tabla `stock`
--
ALTER TABLE `stock`
  MODIFY `idStock` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT de la tabla `stokhistorial`
--
ALTER TABLE `stokhistorial`
  MODIFY `idstokhistorial` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT de la tabla `sucursal`
--
ALTER TABLE `sucursal`
  MODIFY `idSucursal` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;
--
-- AUTO_INCREMENT de la tabla `tipocheckin`
--
ALTER TABLE `tipocheckin`
  MODIFY `idTipoCheckIn` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;
--
-- AUTO_INCREMENT de la tabla `tipocheckout`
--
ALTER TABLE `tipocheckout`
  MODIFY `idTipoCheckOut` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;
--
-- AUTO_INCREMENT de la tabla `usuario`
--
ALTER TABLE `usuario`
  MODIFY `idUsuario` int(11) NOT NULL AUTO_INCREMENT;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
