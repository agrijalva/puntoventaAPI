-- phpMyAdmin SQL Dump
-- version 4.6.5.2
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 31-01-2018 a las 16:48:15
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
CREATE PROCEDURE `CAJAAPERTURA_SP` (IN `Empresa` INT, IN `Sucursal` INT, IN `Usuario` INT, IN `monto` FLOAT)  BEGIN
	DECLARE current_caja INT;
    DECLARE nueva_caja INT;
    SET current_caja = ( SELECT idCaja FROM caja WHERE idUsuario = Usuario AND idSucursal = Sucursal AND caja_fechaCierre IS NULL );
    
    IF( current_caja IS NULL ) THEN
		INSERT INTO caja(idEmpresa, idSucursal, idUsuario, caja_fechaApertura, caja_monto)
		VALUES (Empresa, Sucursal, Usuario, CURRENT_TIMESTAMP(), monto);
        
        SET nueva_caja = LAST_INSERT_ID();
        
        INSERT INTO stockaperturacaja(idStock,idProducto,idEmpresa,idSucursal,sto_cantidad,idCaja)
		SELECT *, nueva_caja as idCaja FROM stock WHERE idSucursal = Sucursal;
        
        SELECT 1 AS 'success', 'Apertura de caja exitosa' AS 'msg', nueva_caja as 'LastId';
    ELSE
		SELECT 1 AS 'success', 'La caja estaba abierta' AS 'msg', current_caja as 'LastId';
    END IF;
	
    
    
END$$

CREATE PROCEDURE `CAJACIERRE_SP` (IN `caja` INT, IN `tipo` INT)  BEGIN
	IF( tipo = 1 )THEN 
		SELECT * FROM caja WHERE idCaja = caja;
    ELSEIF( tipo = 2 )THEN
		SELECT * FROM venta WHERE idCaja = caja;
    ELSEIF( tipo = 3 )THEN
		SELECT GAS.*, TIP.gati_descripcion
		FROM gastos GAS
		INNER JOIN gastotipo TIP ON GAS.idGastoTipo = TIP.idGastoTipo
		WHERE idCaja = caja;
    END IF;
END$$

CREATE PROCEDURE `CAJARESUMEN_SP` (IN `caja` INT)  BEGIN
	DECLARE montoInicial FLOAT;
    DECLARE ventas FLOAT;
    DECLARE gastos FLOAT;
    DECLARE total FLOAT;
    
    SET montoInicial 	= ( SELECT caja_monto FROM caja WHERE idCaja = caja );
    SET ventas 			= ( SELECT SUM( ven_monto ) venta FROM venta WHERE idCaja = caja );
    SET gastos 			= ( SELECT SUM( gas_monto ) gasto FROM gastos WHERE idCaja = caja );
    
    IF( ventas IS NULL AND gastos IS NULL )THEN 
		SET total = montoInicial;
	ELSEIF(ventas IS NULL)THEN
		SET total = montoInicial - gastos;
	ELSEIF(gastos IS NULL)THEN
		SET total = montoInicial + ventas;
	ELSE
		SET total = montoInicial - gastos + ventas;
    END IF;
    
    SELECT
		montoInicial as 'montoInicial',
        ventas as 'ventas',
        gastos as 'gastos',
        total as 'total';
END$$

CREATE PROCEDURE `CAJASETFECHA_SP` (IN `caja` INT)  BEGIN
	UPDATE caja SET caja_fechaCierre = CURRENT_TIMESTAMP() WHERE idCaja = caja;
    SELECT 1 as 'success';
END$$

CREATE PROCEDURE `ENTRADACABECERA_SP` (IN `descripcion` VARCHAR(500) CHARSET utf8, IN `Usuario` INT, IN `Empresa` INT, IN `Sucursal` INT)  BEGIN
	DECLARE CheckIn INT;
	INSERT INTO checkin(chi_descripcion, idTipoCheckIn, idUsuario, idEmpresa, idSucursal) 
	VALUES(descripcion, 1, Usuario, Empresa, Sucursal);
    SET CheckIn = LAST_INSERT_ID();
    
    SELECT 1 AS 'success', 'Venta realizada con exito' AS 'msg', CheckIn as 'LastId', CheckIn as 'folio';
END$$

CREATE PROCEDURE `ENTRADADETALLE_SP` (IN `CheckIn` INT, IN `Producto` INT, IN `cantidad` FLOAT, IN `observaciones` VARCHAR(500) CHARSET utf8)  BEGIN
	DECLARE stockCantidad INT;
    DECLARE sucursal INT;
    
	INSERT INTO checkindetalle(idCheckIn, idProducto, cod_cantidad, cod_observaciones)
    VALUES(CheckIn, Producto, cantidad, observaciones);
    
    SET sucursal 	  = ( SELECT idSucursal FROM checkin WHERE idCheckin = CheckIn );
    SET stockCantidad = ( SELECT sto_cantidad FROM stock WHERE idSucursal = sucursal AND idProducto = Producto );
    
    UPDATE stock SET sto_cantidad  = (stockCantidad + cantidad) WHERE idSucursal = sucursal AND idProducto = Producto;
    
    SELECT 1 AS 'success', 'Listo!' AS 'msg';
END$$

CREATE PROCEDURE `GASTOREGISTRO_SP` (IN `monto` FLOAT, IN `caja` INT, IN `descripcion` VARCHAR(500) CHARSET utf8, IN `gastoTipo` INT)  BEGIN
	INSERT INTO gastos( gas_monto, idCaja, gas_descripcion, idGastoTipo )
    VALUES( monto, caja, descripcion, gastoTipo );
    
    SELECT 1 AS 'success', 'Gasto registrado con exito' AS 'msg', LAST_INSERT_ID() as 'LastId';
END$$

CREATE PROCEDURE `GASTOTIPO_SP` ()  BEGIN
	SELECT * FROM gastotipo ORDER BY gati_orden;
END$$

CREATE PROCEDURE `INVENTARIOCIERRE_SP` (IN `inventario` INT)  BEGIN
	UPDATE inventario
    SET inv_estatus 	= 2
	WHERE idInventario  = inventario;
    
    SELECT 1 AS 'success', 'Se ha cerrado el inventario para esta sucursal, ya no se podrá hacer cambios al menos que lo solicite a su administrador.' AS 'msg';
END$$

CREATE PROCEDURE `INVENTARIODETALLE_SP` (IN `inventario` INT)  BEGIN
	SELECT * 
	FROM inventario INV
	INNER JOIN sucursal SUC ON INV.idSucursal = SUC.idSucursal
	WHERE INV.idInventario = inventario;
END$$

CREATE PROCEDURE `INVENTARIOEDITAR_SP` (IN `inventario` INT, IN `nombre` VARCHAR(500) CHARSET utf8, IN `descripcion` VARCHAR(1000) CHARSET utf8)  BEGIN
	UPDATE inventario
    SET inv_nombre 		= nombre,
		inv_descripcion = descripcion
	WHERE idInventario  = inventario;
    
    SELECT 1 AS 'success', 'Se ha actualizado la información del inventario.' AS 'msg';
END$$

CREATE PROCEDURE `INVENTARIOELIMINAR_SP` (IN `inventario` INT)  BEGIN
	UPDATE inventario
    SET inv_estatus 	= 0
	WHERE idInventario  = inventario;
    
    SELECT 1 AS 'success', 'Se ha eliminado un inventario, esta acción no repercutira en procesos más adelante.' AS 'msg';
END$$

CREATE PROCEDURE `INVENTARIOMUESTRA_SP` (IN `empresa` INT)  BEGIN
	SELECT * 
	FROM inventario INV
	INNER JOIN sucursal SUC ON INV.idSucursal = SUC.idSucursal
	WHERE INV.idEmpresa = empresa AND inv_estatus != 0;
END$$

CREATE PROCEDURE `INVENTARIONUEVO_SP` (IN `nombre` VARCHAR(500) CHARSET utf8, IN `descripcion` VARCHAR(1000) CHARSET utf8, IN `sucursal` INT, IN `empresa` INT, IN `usuario` INT)  BEGIN
	INSERT INTO inventario(inv_nombre, inv_descripcion, idSucursal, idEmpresa, idUsuario)
    VALUES( nombre, descripcion, sucursal, empresa, usuario );
    
    SELECT 1 AS 'success', 'Se ha abierto un inventario nuevo.' AS 'msg', LAST_INSERT_ID() as 'LastId';
END$$

CREATE PROCEDURE `INVENTARIOREGISTRAR_SP` (IN `inventario` INT, IN `producto` INT, IN `cantidad` FLOAT, IN `descripcion` VARCHAR(1000) CHARSET utf8)  BEGIN
	DECLARE empresa INT;
    DECLARE sucursal INT;
    DECLARE usuario INT;
    DECLARE stock INT;
    DECLARE stockhis INT;
    DECLARE cantidadSistema FLOAT;
    DECLARE checkin INT;
    DECLARE checkout INT;
    DECLARE caja INT;
    
    SET empresa  = (SELECT idEmpresa FROM inventario WHERE idInventario = inventario);
    SET sucursal = (SELECT idSucursal FROM inventario WHERE idInventario = inventario);
    SET usuario  = (SELECT idUsuario FROM inventario WHERE idInventario = inventario);
    SET stock	 = (SELECT idStock FROM stock STO WHERE idProducto = producto AND idSucursal = sucursal);
    SET caja 	 = (SELECT COUNT(idCaja) FROM caja WHERE idSucursal = sucursal AND caja_fechaCierre IS NULL);
    
    IF( caja = 0 ) THEN
		IF( stock IS NULL )THEN
			SET checkin = (SELECT idCheckIn FROM checkin WHERE chi_descripcion = inventario AND idSucursal = sucursal AND idTipoCheckIn = 5);
			
			IF( checkin IS NULL )THEN
				INSERT INTO checkin(chi_descripcion, idTipoCheckIn, idUsuario, idEmpresa, idSucursal) 
				VALUES(inventario, 5, usuario, empresa, sucursal);
				
				SET checkin = LAST_INSERT_ID();
			END IF;
			
			INSERT INTO checkindetalle( idCheckIn, idProducto, cod_cantidad, cod_observaciones ) 
			VALUES( checkin, producto, cantidad, descripcion );
			
			INSERT INTO stock( idProducto, idEmpresa, idSucursal, sto_cantidad ) 
			VALUES( producto, empresa, sucursal, cantidad );
			
			SET stock	 = LAST_INSERT_ID();
			
			INSERT INTO stockhistorial(sto_cantidad, sto_observaciones, fecha, idStock, idInventario) 
			VALUES( cantidad, descripcion, CURDATE(), stock, inventario );
			
			SELECT 1 as 'success';
		ELSE
			SET cantidadSistema = ( SELECT sto_cantidad FROM stock WHERE idStock = stock );
			
			IF( cantidadSistema < cantidad )THEN  		-- Hacer CheckIn
				SET checkin = (SELECT idCheckIn FROM checkin WHERE chi_descripcion = inventario AND idSucursal = sucursal AND idTipoCheckIn = 5);
			
				IF( checkin IS NULL )THEN
					INSERT INTO checkin(chi_descripcion, idTipoCheckIn, idUsuario, idEmpresa, idSucursal) 
					VALUES(inventario, 5, usuario, empresa, sucursal);
					
					SET checkin = LAST_INSERT_ID();
				END IF;
				
				INSERT INTO checkindetalle( idCheckIn, idProducto, cod_cantidad, cod_observaciones ) 
				VALUES( checkin, producto, (cantidad - cantidadSistema), descripcion );
				
				UPDATE stock SET sto_cantidad = cantidad WHERE idStock = stock;
				
				SET stockhis = ( SELECT idStockHistorial FROM stockhistorial WHERE idStock = stock AND idInventario = inventario );
				IF ( stockhis IS NOT NULL ) THEN
					UPDATE stockhistorial
					SET sto_cantidad = cantidad,
						sto_observaciones = descripcion,
						fecha = CURDATE()
					WHERE idStockHistorial = stockhis;
				ELSE
					INSERT INTO stockhistorial(sto_cantidad, sto_observaciones, fecha, idStock, idInventario) 
					VALUES( cantidad, descripcion, CURDATE(), stock, inventario );
				END IF;
				
				SELECT 1 as 'success';
			ELSEIF( cantidadSistema > cantidad ) THEN   -- Hacer CheckOut
				SET checkout = (SELECT idCheckOut FROM checkout WHERE cho_descripcion = inventario AND idSucursal = sucursal AND idTipoCheckOut = 5);
			
				IF( checkout IS NULL )THEN
					INSERT INTO checkout(cho_descripcion, idTipoCheckOut, idUsuario, idEmpresa, idSucursal) 
					VALUES(inventario, 5, usuario, empresa, sucursal);
					
					SET checkout = LAST_INSERT_ID();
				END IF;
				
				INSERT INTO checkoutdetalle( idCheckOut, idProducto, cod_cantidad, cod_precio, cod_observaciones ) 
				VALUES( checkout, producto, (cantidadSistema - cantidad), 0, descripcion );
				
				UPDATE stock SET sto_cantidad = cantidad WHERE idStock = stock;
				
				SET stockhis = ( SELECT idStockHistorial FROM stockhistorial WHERE idStock = stock AND idInventario = inventario );
				IF ( stockhis IS NOT NULL ) THEN
					UPDATE stockhistorial
					SET sto_cantidad = cantidad,
						sto_observaciones = descripcion,
						fecha = CURDATE()
					WHERE idStockHistorial = stockhis;
				ELSE
					INSERT INTO stockhistorial(sto_cantidad, sto_observaciones, fecha, idStock, idInventario) 
					VALUES( cantidad, descripcion, CURDATE(), stock, inventario );
				END IF;
				
				SELECT 1 as 'success';
			ELSE										-- Solo hacer Inventario
				SET stockhis = ( SELECT idStockHistorial FROM stockhistorial WHERE idStock = stock AND idInventario = inventario );
				IF ( stockhis IS NOT NULL ) THEN
					UPDATE stockhistorial
					SET sto_cantidad = cantidad,
						sto_observaciones = descripcion,
						fecha = CURDATE()
					WHERE idStockHistorial = stockhis;
				ELSE
					INSERT INTO stockhistorial(sto_cantidad, sto_observaciones, fecha, idStock, idInventario) 
					VALUES( cantidad, descripcion, CURDATE(), stock, inventario );
				END IF;
				
				SELECT 1 as 'success';
			END IF;
		END IF; 
    ELSE
		SELECT '0' as 'success', 'Para registrar inventario se deben cerrar todas las cajas abiertas' as 'msg';
    END IF;
       
END$$

CREATE PROCEDURE `LISTAPRECIOACTIVAR_SP` (IN `listaPrecio` INT)  BEGIN
	DECLARE sucursal INT;
    SET sucursal = (SELECT idSucursal FROM listaprecio WHERE idListaPrecio = listaPrecio);
    
    UPDATE listaprecio SET lpr_estatus = 3 WHERE lpr_estatus = 2 AND idSucursal = sucursal;
    UPDATE listaprecio SET lpr_estatus = 2 WHERE idListaPrecio = listaPrecio;
    
    SELECT 1 AS 'success', 'Se ha activado una nueva lista de precios, la lista anterior quedara como historico.' AS 'msg';
END$$

CREATE PROCEDURE `LISTAPRECIOEDITAR_SP` (IN `nombre` VARCHAR(300) CHARSET utf8, IN `descripcion` VARCHAR(1000) CHARSET utf8, IN `listaPrecio` INT)  BEGIN
	UPDATE listaprecio 
	SET lpr_nombre 		= nombre,
		lpr_descripcion = descripcion
	WHERE idListaPrecio = listaPrecio;
    
    SELECT 1 AS 'success', 'Se ha actualizado correctamente la lista de precios.' AS 'msg';
END$$

CREATE PROCEDURE `LISTAPRECIOELIMINAR_SP` (IN `listaPrecio` INT)  BEGIN
	DELETE FROM precio WHERE idListaPrecio = listaPrecio;
    DELETE FROM listaprecio WHERE idListaPrecio = listaPrecio;
    
    SELECT 1 AS 'success', 'Se ha eliminado correctamente la lista de precios.' AS 'msg';
END$$

CREATE PROCEDURE `LISTAPRECIOMUESTRA_SP` (IN `empresa` INT)  BEGIN
    SELECT
		* ,
		(SELECT count(idPrecio) total FROM precio PRE INNER JOIN producto PRO ON PRE.idProducto = PRO.idProducto WHERE idListaPrecio = LP.idListaPrecio AND pro_estatus != 0) totalPrecios,
		(SELECT count(idProducto) total FROM producto WHERE idEmpresa = LP.idEmpresa AND pro_estatus = 1) totalProductos,
        NULL as 'successLista'
	FROM listaprecio LP
	INNER JOIN sucursal SUC ON LP.idSucursal = SUC.idSucursal
	WHERE LP.idEmpresa = empresa AND lpr_estatus != 0;
END$$

CREATE PROCEDURE `LISTAPRECIONUEVO_SP` (IN `nombre` VARCHAR(300) CHARSET utf8, IN `descripcion` VARCHAR(1000) CHARSET utf8, IN `Empresa` INT, IN `Sucursal` INT)  BEGIN
	INSERT INTO listaprecio(lpr_nombre, lpr_descripcion, idEmpresa, idSucursal) 
    VALUES(nombre, descripcion, Empresa, Sucursal);
    
    SELECT 1 AS 'success', 'Se ha registrado correctamente una lista de precios.' AS 'msg', LAST_INSERT_ID() as 'LastId';
END$$

CREATE PROCEDURE `LISTAPRECIOREGISTRAR_SP` (IN `listaPrecio` INT, IN `producto` INT, IN `precioCompra` FLOAT, IN `precioVenta` FLOAT)  BEGIN
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

CREATE PROCEDURE `LISTAPRECIO_SP` (IN `listaPrecio` INT)  BEGIN
	DECLARE empresa INT;
    DECLARE totalPrecios INT; 
    DECLARE totalProductos INT;
    DECLARE successLista INT;
    
    SET empresa		   = (SELECT idEmpresa FROM listaprecio WHERE idListaPrecio = listaPrecio);
    SET totalPrecios   = (SELECT count(idPrecio) total FROM precio WHERE idListaPrecio = listaPrecio);
    SET totalProductos = (SELECT count(idProducto) total FROM producto WHERE idEmpresa = empresa AND pro_estatus = 1);
    
    IF( totalPrecios = 0 )THEN -- No existen precios en esta lista
		SET successLista = 0;
    ELSEIF ( totalPrecios = totalProductos )THEN -- Ya existen todos los precios de los productos
		SET successLista = 1;
    ELSE -- Existen solo unos pocos precios
		SET successLista = 2;
    END IF;
    
	SELECT *, successLista as 'successLista'
	FROM listaprecio LP
	INNER JOIN sucursal SUC ON LP.idSucursal = SUC.idSucursal
	WHERE idListaPrecio = listaPrecio;
END$$

CREATE PROCEDURE `LOGIN_SP` (IN `usuario` VARCHAR(200) CHARSET utf8, IN `contrasenia` VARCHAR(200) CHARSET utf8)  BEGIN    
    SELECT * 
	FROM usuario USU
	INNER JOIN empresa EMP 					ON USU.idEmpresa = EMP.idEmpresa
	INNER JOIN configuracionempresa CONF 	ON EMP.idEmpresa = CONF.idEmpresa
	WHERE usu_usuario = usuario 
          AND usu_password = contrasenia;
END$$

CREATE PROCEDURE `MEZCLACABECERA_SP` (IN `descripcion` VARCHAR(500) CHARSET utf8, IN `Usuario` INT, IN `Empresa` INT, IN `Sucursal` INT)  BEGIN
	DECLARE CheckIn INT;
    DECLARE CheckOut INT;
    DECLARE Mezcla INT;
    
    INSERT INTO checkin(chi_descripcion, idTipoCheckIn, idUsuario, idEmpresa, idSucursal) 
	VALUES(descripcion, 3, Usuario, Empresa, Sucursal);
	SET CheckIn = LAST_INSERT_ID();
	
    INSERT INTO checkout(cho_descripcion, idTipoCheckOut, idUsuario, idEmpresa, idSucursal) 
	VALUES(descripcion, 3, Usuario, Empresa, Sucursal);
	SET CheckOut = LAST_INSERT_ID();
    
    INSERT INTO mezcla( idCheckOut, idCheckIn ) VALUES( CheckOut, CheckIn );
    SET Mezcla = LAST_INSERT_ID();
    
    SELECT 1 AS 'success', 'Mezcla procesada correctamente' AS 'msg', CheckIn as 'idCheckIn', CheckOut as 'idCheckOut', Mezcla as 'folio';
END$$

CREATE PROCEDURE `MEZCLAINDETALLE_SP` (IN `CheckIn` INT, IN `Producto` INT, IN `cantidad` FLOAT, IN `observaciones` VARCHAR(500) CHARSET utf8)  BEGIN
	DECLARE stockCantidad INT;
	DECLARE sucursal INT;
    
	INSERT INTO checkindetalle(idCheckIn, idProducto, cod_cantidad, cod_observaciones)
	VALUES(CheckIn, Producto, cantidad, observaciones);
    
    SET sucursal 	  = ( SELECT idSucursal FROM checkin WHERE idCheckin = CheckIn );
	SET stockCantidad = ( SELECT sto_cantidad FROM stock WHERE idSucursal = sucursal AND idProducto = Producto );
    
    UPDATE stock SET sto_cantidad = (stockCantidad + cantidad) WHERE idSucursal = sucursal AND idProducto = Producto;
    
    SELECT 1 AS 'success', 'Listo!' AS 'msg';
END$$

CREATE PROCEDURE `MEZCLAOUTDETALLE_SP` (IN `CheckOut` INT, IN `Producto` INT, IN `cantidad` FLOAT, IN `observaciones` VARCHAR(500) CHARSET utf8)  BEGIN
	DECLARE stockCantidad INT;
	DECLARE sucursal INT;
    
	INSERT INTO checkoutdetalle(idCheckOut, idProducto, cod_cantidad, cod_observaciones)
	VALUES(CheckOut, Producto, cantidad, observaciones);
    
    SET sucursal 	  = ( SELECT idSucursal FROM checkout WHERE idCheckout = CheckOut );
	SET stockCantidad = ( SELECT sto_cantidad FROM stock WHERE idSucursal = sucursal AND idProducto = Producto );
    
    UPDATE stock SET sto_cantidad = (stockCantidad - cantidad) WHERE idSucursal = sucursal AND idProducto = Producto;
    
    SELECT 1 AS 'success', 'Listo!' AS 'msg';
END$$

CREATE PROCEDURE `PRODUCTOEDITAR_SP` (IN `sku` VARCHAR(100) CHARSET utf8, IN `nombre` VARCHAR(500) CHARSET utf8, IN `descripcion` VARCHAR(1000) CHARSET utf8, IN `unidad` VARCHAR(300) CHARSET utf8, IN `productoID` INT)  BEGIN
	UPDATE producto 
    SET pro_sku 		= sku,
		pro_nombre 		= nombre,
        pro_descripcion	= descripcion,
        pro_unidad		= unidad
	WHERE idProducto = productoID;	
    
    SELECT 1 AS 'success', 'Se ha actualizado correctamente el producto.' AS 'msg';
END$$

CREATE PROCEDURE `PRODUCTOELIMINAR_SP` (IN `productoID` INT)  BEGIN
	UPDATE producto SET pro_estatus = 0	WHERE idProducto = productoID;    
    SELECT 1 AS 'success', 'El producto se ha eliminado correctamente.' AS 'msg';
END$$

CREATE PROCEDURE `PRODUCTOINVENTARIOINIT_SP` (IN `empresa` INT, IN `sucursal` INT)  BEGIN
	SELECT PRO.*, (
			CASE 
				WHEN idStock IS NULL
				THEN 0
				ELSE sto_cantidad
			END
		  ) AS cantidadSistema,
          (
			CASE 
				WHEN idStock IS NULL
				THEN 0
				ELSE sto_cantidad
			END
		  ) AS cantidadFisico,
          (CASE 
				WHEN idStock IS NULL
				THEN ''
				ELSE (SELECT sto_observaciones FROM stockhistorial WHERE idStock = STO.idStock)
			END
		  ) AS descripcion,
          NULL AS 'request'
	FROM producto PRO
	LEFT JOIN stock STO ON PRO.idProducto = STO.idProducto AND STO.idSucursal = sucursal
	WHERE PRO.idEmpresa = empresa AND pro_estatus = 1
	ORDER BY PRO.idProducto ASC;
END$$

CREATE PROCEDURE `PRODUCTOMUESTRA_SP` (IN `empresaID` INT)  BEGIN
	SELECT *, 1 as cantidad FROM producto WHERE idEmpresa = empresaID AND pro_estatus = 1;
END$$

CREATE PROCEDURE `PRODUCTONUEVO_SP` (IN `sku` VARCHAR(100) CHARSET utf8, IN `nombre` VARCHAR(500) CHARSET utf8, IN `descripcion` VARCHAR(1000) CHARSET utf8, IN `unidad` VARCHAR(300) CHARSET utf8, IN `empresa` INT)  BEGIN
	INSERT INTO producto( pro_sku, pro_nombre, pro_descripcion, pro_unidad, idEmpresa ) 
    VALUES( sku, nombre, descripcion, unidad, empresa );
    
    SELECT 1 AS 'success', 'Se ha registrado correctamente un producto nuevo.' AS 'msg', LAST_INSERT_ID() as 'LastId';
END$$

CREATE PROCEDURE `PRODUCTOPRECIOVENTA_SP` (IN `sucursal` INT)  BEGIN
	SELECT PRO.*, PRE.*, 1 as cantidad, STO.sto_cantidad, '' as entrada_descripcion
	FROM listaprecio LPR
	INNER JOIN precio PRE ON LPR.idListaPrecio = PRE.idListaPrecio
	INNER JOIN producto PRO ON PRE.idProducto = PRO.idProducto
    INNER JOIN stock STO ON STO.idProducto = PRO.idProducto AND STO.idSucursal = sucursal
	WHERE LPR.idSucursal = sucursal
		  AND lpr_estatus = 2
		  AND pro_estatus = 1;
END$$

CREATE PROCEDURE `PRODUCTOPRECIO_SP` (IN `listaPrecio` INT, IN `empresa` INT)  BEGIN
	DECLARE sucursal INT;
    SET sucursal = (SELECT idSucursal FROM listaprecio WHERE idListaPrecio = listaPrecio);
    
	SELECT PRO.*,
		   precio_compra AS precioCosto,
		   precio_venta AS precioVenta,
		   (SELECT precio_venta FROM precio P
			INNER JOIN listaprecio L ON P.idListaPrecio = L.idListaPrecio
			WHERE idProducto = PRO.idProducto
				  AND idSucursal = sucursal
				  AND lpr_estatus = 2) as precioVentaPrevio,
			NULL AS 'request'
	FROM producto PRO
	LEFT JOIN precio PRE ON PRO.idProducto = PRE.idProducto AND idListaPrecio = listaPrecio
	LEFT JOIN listaprecio LIS ON PRE.idListaPrecio = LIS.idListaPrecio
	WHERE PRO.idEmpresa = empresa AND pro_estatus = 1
	ORDER BY PRO.idProducto ASC;

	/*SELECT PRO.*, precio_compra AS precioCosto, precio_venta AS precioVenta
	FROM producto PRO
	LEFT JOIN precio PRE ON PRO.idProducto = PRE.idProducto AND PRE.idListaPrecio = listaPrecio
	WHERE idEmpresa = empresa AND pro_estatus = 1
	ORDER BY idProducto ASC;*/
END$$

CREATE PROCEDURE `PRODUCTOSVENDIDOS_SP` (IN `caja` INT)  BEGIN
  	DECLARE sucursal INT;
	
  	CREATE TEMPORARY TABLE productosvendidos(
        	id INT(11) NOT NULL AUTO_INCREMENT,
    	cantidadVendida FLOAT,
    	idProducto INT,
    	nombreProducto VARCHAR(300),
    	PRIMARY KEY (id)
	);
	
	INSERT INTO productosvendidos (cantidadVendida, idProducto, nombreProducto)
	SELECT SUM( cod_cantidad ) Vendido, D.idProducto, CONCAT_WS(' ', P.pro_nombre, P.pro_descripcion) as Nombre
  	FROM venta V, checkout O, checkoutdetalle D, producto P
  	WHERE V.idCheckOut = O.idCheckOut
        	  AND O.idCheckOut = D.idCheckOut
        	  AND D.idProducto = P.idProducto
        	  AND V.idCaja = caja
  	GROUP BY D.idProducto;
	
	SET sucursal = ( SELECT idSucursal FROM caja WHERE idCaja = caja );
	SELECT
        	idProducto,
    	nombreProducto,
        	( 	SELECT sto_cantidad
              	FROM stockaperturacaja
        	WHERE idProducto = TEMP.idProducto
                    	  AND idCaja = caja
        	) as cantidadInicial,
    	cantidadVendida,
    	CASE WHEN ( SELECT idCaja FROM caja WHERE idCaja > caja LIMIT 1 ) IS NULL
                    	THEN (  	SELECT sto_cantidad
                               	FROM stock
                               	WHERE idProducto = TEMP.idProducto
                                     	  AND idSucursal = sucursal )
              	 ELSE ( 	SELECT sto_cantidad
                               	FROM stockaperturacaja
                               	WHERE idProducto = TEMP.idProducto
                                     	  AND idCaja = ( SELECT idCaja FROM caja WHERE idCaja > caja LIMIT 1 ) )
        	END as cantidadFinal
	FROM productosvendidos TEMP;
	
	DROP TABLE productosvendidos;	
END$$

CREATE PROCEDURE `SUCURSALMOSTRAR_SP` (IN `empresa` INT)  BEGIN
	SELECT * FROM sucursal WHERE idEmpresa = empresa;
END$$

CREATE PROCEDURE `TRASPASOCABECERA_SP` (IN `descripcion` VARCHAR(500) CHARSET utf8, IN `Usuario` INT, IN `Empresa` INT, IN `Sucursal` INT, IN `Tipo` INT, IN `sucOrigen` INT, IN `sucDestino` INT)  BEGIN
	DECLARE CheckIn INT;
    DECLARE CheckOut INT;
    DECLARE Traspaso INT;
    
    IF( Tipo = 1 )THEN  -- Entrada
		INSERT INTO checkin(chi_descripcion, idTipoCheckIn, idUsuario, idEmpresa, idSucursal) 
		VALUES(descripcion, 2, Usuario, Empresa, Sucursal);
		SET CheckIn = LAST_INSERT_ID();
        
        INSERT INTO traspaso( idSucursalOrigen, idSucursalDestino, idUsuario, tra_observaciones ) 
        VALUES( sucOrigen, sucDestino, Usuario, descripcion );
        SET Traspaso = LAST_INSERT_ID();
        
        INSERT INTO traspasocheckin(idTraspaso, idCheckIn) VALUES ( Traspaso, CheckIn );
		
		SELECT 1 AS 'success', 'Venta realizada con exito' AS 'msg', CheckIn as 'LastId', Traspaso as 'folio', Traspaso as 'Traspaso';
    ELSEIF( Tipo = 0 )THEN   -- Salida
		INSERT INTO checkout(cho_descripcion, idTipoCheckOut, idUsuario, idEmpresa, idSucursal) 
		VALUES(descripcion, 2, Usuario, Empresa, Sucursal);
		SET CheckOut = LAST_INSERT_ID();
                
        INSERT INTO traspaso( idSucursalOrigen, idSucursalDestino, idUsuario, tra_observaciones ) 
        VALUES( sucOrigen, sucDestino, Usuario, descripcion );
        SET Traspaso = LAST_INSERT_ID();
        
        INSERT INTO traspasocheckout(idTraspaso, idCheckOut) VALUES ( Traspaso, CheckOut );
		
		SELECT 1 AS 'success', 'Venta realizada con exito' AS 'msg', CheckOut as 'LastId', Traspaso as 'folio', Traspaso as 'Traspaso';
    END IF;
END$$

CREATE PROCEDURE `TRASPASODETALLE_SP` (IN `CheckId` INT, IN `Producto` INT, IN `cantidad` FLOAT, IN `observaciones` VARCHAR(500) CHARSET utf8, IN `Tipo` INT, IN `Traspado` INT)  BEGIN
	DECLARE stockCantidad INT;
    DECLARE sucursal INT;
    DECLARE stockId INT;
    
    IF( Tipo = 1 )THEN  -- Entrada
		INSERT INTO checkindetalle(idCheckIn, idProducto, cod_cantidad, cod_observaciones)
		VALUES(CheckId, Producto, cantidad, observaciones);
		
		SET sucursal 	  = ( SELECT idSucursal FROM checkin WHERE idCheckin = CheckId );
		SET stockCantidad = ( SELECT sto_cantidad FROM stock WHERE idSucursal = sucursal AND idProducto = Producto );
		SET stockId		  = ( SELECT idStock FROM stock WHERE idSucursal = sucursal AND idProducto = Producto );
        
		UPDATE stock SET sto_cantidad  = (stockCantidad + cantidad) WHERE idSucursal = sucursal AND idProducto = Producto;
        
        INSERT INTO traspasodetalle( idStock, trde_cantidad, trde_observaciones, idTraspaso )
        VALUES( stockId, cantidad, observaciones, Traspado );
		
		SELECT 1 AS 'success', 'Listo!' AS 'msg';
    ELSEIF( Tipo = 0 )THEN   -- Salida
		INSERT INTO checkoutdetalle(idCheckOut, idProducto, cod_cantidad, cod_observaciones)
		VALUES(CheckId, Producto, cantidad, observaciones);
		
		SET sucursal 	  = ( SELECT idSucursal FROM checkout WHERE idCheckout = CheckId );
		SET stockCantidad = ( SELECT sto_cantidad FROM stock WHERE idSucursal = sucursal AND idProducto = Producto );
        SET stockId		  = ( SELECT idStock FROM stock WHERE idSucursal = sucursal AND idProducto = Producto );
		
		UPDATE stock SET sto_cantidad  = (stockCantidad - cantidad) WHERE idSucursal = sucursal AND idProducto = Producto;
        
        INSERT INTO traspasodetalle( idStock, trde_cantidad, trde_observaciones, idTraspaso )
        VALUES( stockId, cantidad, observaciones, Traspado );
		
		SELECT 1 AS 'success', 'Listo!' AS 'msg';
    END IF;
END$$

CREATE PROCEDURE `VENTACABECERA_SP` (IN `descripcion` VARCHAR(500) CHARSET utf8, IN `Usuario` INT, IN `Empresa` INT, IN `Sucursal` INT, IN `Caja` INT, IN `Cliente` INT, IN `Monto` FLOAT)  BEGIN
	DECLARE CheckOut INT;
    DECLARE Venta INT;
    
	INSERT INTO checkout(cho_descripcion, cho_estatus, idTipoCheckOut, idUsuario, idEmpresa, idSucursal) 
	VALUES(descripcion, 1, 1, Usuario, Empresa, Sucursal);
    SET CheckOut = LAST_INSERT_ID();
    
    INSERT INTO venta( idCaja, idCheckOut, idCliente, ven_monto ) VALUES( Caja, CheckOut, Cliente, Monto);
    SET Venta = LAST_INSERT_ID();
    
    SELECT 1 AS 'success', 'Venta realizada con exito' AS 'msg', CheckOut as 'LastId', Venta as 'folio';
END$$

CREATE PROCEDURE `VENTADETALLE_SP` (IN `CheckOut` INT, IN `Producto` INT, IN `cantidad` FLOAT, IN `precio` FLOAT, IN `observaciones` VARCHAR(500) CHARSET utf8)  BEGIN
	DECLARE stockCantidad INT;
    DECLARE sucursal INT;
    
	INSERT INTO checkoutdetalle(idCheckOut, idProducto, cod_cantidad, cod_precio, cod_observaciones)
    VALUES(CheckOut, Producto, cantidad, precio, observaciones);
    
    SET sucursal 	  = ( SELECT idSucursal FROM checkout WHERE idCheckout = CheckOut );
    SET stockCantidad = ( SELECT sto_cantidad FROM stock WHERE idSucursal = sucursal AND idProducto = Producto );
    
    UPDATE stock SET sto_cantidad  = (stockCantidad - cantidad) WHERE idSucursal = sucursal AND idProducto = Producto;
    
    SELECT 1 AS 'success', 'Listo!' AS 'msg';
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

--
-- Volcado de datos para la tabla `caja`
--

INSERT INTO `caja` (`idCaja`, `idEmpresa`, `idSucursal`, `idUsuario`, `caja_fechaApertura`, `caja_fechaCierre`, `caja_monto`) VALUES
(1, 1, 2, 1, '2018-01-16 16:39:47', '2018-01-17 12:17:07', 1000),
(2, 1, 1, 1, '2018-01-17 12:37:49', '2018-01-17 12:45:36', 1),
(3, 1, 1, 1, '2018-01-17 13:00:01', '2018-01-17 13:01:19', 0),
(4, 1, 1, 1, '2018-01-18 12:38:36', '2018-01-18 12:46:54', 0),
(5, 1, 1, 1, '2018-01-18 12:49:00', '2018-01-31 00:46:09', 0),
(6, 1, 1, 1, '2018-01-31 00:47:00', '2018-01-31 01:27:49', 1000),
(7, 1, 1, 1, '2018-01-31 01:28:23', '2018-01-31 01:52:03', 1000),
(8, 1, 1, 1, '2018-01-31 02:03:55', '2018-01-31 02:04:40', 1001),
(9, 1, 1, 1, '2018-01-31 02:04:52', '2018-01-31 02:23:39', 1002),
(10, 1, 1, 1, '2018-01-31 02:31:06', '2018-01-31 02:31:22', 1000),
(11, 1, 1, 1, '2018-01-31 02:35:59', '2018-01-31 02:37:12', 200),
(12, 1, 1, 1, '2018-01-31 02:43:12', '2018-01-31 02:44:03', 300),
(13, 1, 1, 1, '2018-01-31 02:47:01', '2018-01-31 02:47:44', 200),
(14, 1, 1, 1, '2018-01-31 02:49:42', '2018-01-31 02:50:42', 304);

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

--
-- Volcado de datos para la tabla `checkin`
--

INSERT INTO `checkin` (`idCheckIn`, `chi_descripcion`, `chi_estatus`, `idTipoCheckIn`, `idUsuario`, `idEmpresa`, `idSucursal`, `timestamp`) VALUES
(1, '1', 1, 5, 1, 1, 1, '2018-01-16 16:39:05'),
(2, 'ejemplo chingon', 1, 2, 1, 1, 1, '2018-01-31 00:05:16');

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

--
-- Volcado de datos para la tabla `checkindetalle`
--

INSERT INTO `checkindetalle` (`idCheckInDetalle`, `idCheckIn`, `idProducto`, `cod_cantidad`, `cod_observaciones`) VALUES
(1, 1, 1, 15, 'precio inicial'),
(2, 1, 2, 15, 'precio inicial'),
(3, 1, 3, 10, 'precio inicial'),
(4, 1, 4, 5, 'precio inicial'),
(5, 1, 5, 10, 'precio inicial'),
(6, 1, 6, 10, 'precio inicial'),
(7, 1, 7, 10, 'precio inicial'),
(8, 1, 10, 10, 'precio inicial'),
(9, 1, 11, 10, 'precio inicial'),
(10, 1, 12, 10, 'precio inicial'),
(11, 1, 13, 10, 'precio inicial'),
(12, 1, 14, 10, 'precio inicial'),
(13, 1, 15, 10, 'precio inicial'),
(14, 1, 16, 10, 'precio inicial'),
(15, 1, 17, 10, 'precio inicial'),
(16, 1, 18, 10, 'precio inicial'),
(17, 1, 19, 10, 'precio inicial'),
(18, 1, 20, 10, 'precio inicial'),
(19, 1, 21, 10, 'precio inicial'),
(20, 1, 22, 10, 'precio inicial'),
(21, 1, 23, 10, 'precio inicial'),
(22, 1, 24, 10, 'precio inicial'),
(23, 1, 25, 10, 'precio inicial'),
(24, 1, 26, 10, 'precio inicial'),
(25, 1, 27, 10, 'precio inicial'),
(26, 1, 28, 10, 'precio inicial'),
(27, 1, 29, 10, 'precio inicial'),
(28, 1, 30, 10, 'precio inicial'),
(29, 1, 31, 10, 'precio inicial'),
(30, 1, 32, 10, 'precio inicial'),
(31, 1, 33, 10, 'precio inicial'),
(32, 1, 34, 10, 'precio inicial'),
(33, 1, 35, 10, 'precio inicial'),
(34, 1, 36, 10, 'precio inicial'),
(35, 1, 37, 10, 'precio inicial'),
(36, 1, 38, 10, 'precio inicial'),
(37, 1, 39, 10, 'precio inicial'),
(38, 1, 40, 10, 'precio inicial'),
(39, 1, 41, 10, 'precio inicial'),
(40, 1, 42, 10, 'precio inicial'),
(41, 1, 43, 10, 'precio inicial'),
(42, 1, 44, 10, 'precio inicial'),
(43, 1, 45, 10, 'precio inicial'),
(44, 1, 46, 10, 'precio inicial'),
(45, 1, 47, 10, 'precio inicial'),
(46, 1, 48, 10, 'precio inicial'),
(47, 1, 49, 10, 'precio inicial'),
(48, 1, 50, 10, 'precio inicial'),
(49, 1, 51, 10, 'precio inicial'),
(50, 1, 52, 10, 'precio inicial'),
(51, 1, 53, 10, 'precio inicial'),
(52, 2, 12, 5, 'ejemplo de entrada');

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

--
-- Volcado de datos para la tabla `checkout`
--

INSERT INTO `checkout` (`idCheckOut`, `cho_descripcion`, `cho_estatus`, `idTipoCheckOut`, `idUsuario`, `idEmpresa`, `idSucursal`, `timestamp`) VALUES
(1, 'Venta de mostrador', 1, 1, 1, 1, 1, '2018-01-18 12:50:06'),
(2, 'Venta de mostrador', 1, 1, 1, 1, 1, '2018-01-18 12:50:50'),
(3, 'ejemplo', 1, 2, 1, 1, 1, '2018-01-31 00:03:19'),
(4, 'Venta de mostrador', 1, 1, 1, 1, 1, '2018-01-31 00:06:01'),
(5, 'Venta de mostrador', 1, 1, 1, 1, 1, '2018-01-31 00:44:03'),
(6, 'Venta de mostrador', 1, 1, 1, 1, 1, '2018-01-31 00:47:37'),
(7, 'Venta de mostrador', 1, 1, 1, 1, 1, '2018-01-31 00:49:13'),
(8, 'Venta de mostrador', 1, 1, 1, 1, 1, '2018-01-31 01:30:11'),
(9, 'Venta de mostrador', 1, 1, 1, 1, 1, '2018-01-31 02:04:16'),
(10, 'Venta de mostrador', 1, 1, 1, 1, 1, '2018-01-31 02:05:22'),
(11, 'Venta de mostrador', 1, 1, 1, 1, 1, '2018-01-31 02:31:14'),
(12, 'Venta de mostrador', 1, 1, 1, 1, 1, '2018-01-31 02:36:18'),
(13, 'Venta de mostrador', 1, 1, 1, 1, 1, '2018-01-31 02:36:43'),
(14, 'Venta de mostrador', 1, 1, 1, 1, 1, '2018-01-31 02:37:02'),
(15, 'Venta de mostrador', 1, 1, 1, 1, 1, '2018-01-31 02:43:27'),
(16, 'Venta de mostrador', 1, 1, 1, 1, 1, '2018-01-31 02:43:55'),
(17, 'Venta de mostrador', 1, 1, 1, 1, 1, '2018-01-31 02:47:35'),
(18, 'Venta de mostrador', 1, 1, 1, 1, 1, '2018-01-31 02:50:23');

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

--
-- Volcado de datos para la tabla `checkoutdetalle`
--

INSERT INTO `checkoutdetalle` (`idCheckOutDetalle`, `idCheckOut`, `idProducto`, `cod_cantidad`, `cod_precio`, `cod_observaciones`) VALUES
(1, 1, 12, 10, 10, ''),
(2, 2, 34, 10, 10, ''),
(3, 2, 2, 15, 10, ''),
(4, 4, 12, 2, 10, ''),
(5, 5, 52, 4, 10, ''),
(6, 5, 53, 6, 10, ''),
(7, 6, 52, 3, 10, ''),
(8, 6, 5, 2, 10, ''),
(9, 6, 53, 1, 10, ''),
(10, 6, 12, 1, 10, ''),
(11, 7, 52, 3, 10, ''),
(12, 7, 50, 8, 10, ''),
(13, 8, 1, 6, 10, ''),
(14, 8, 41, 1, 10, ''),
(15, 9, 1, 2, 10, ''),
(16, 9, 41, 1, 10, ''),
(17, 10, 13, 3, 10, ''),
(18, 10, 1, 5, 10, ''),
(19, 10, 41, 3, 10, ''),
(20, 11, 12, 1, 10, ''),
(21, 12, 12, 1, 10, ''),
(22, 12, 1, 2, 10, ''),
(23, 13, 13, 3, 10, ''),
(24, 13, 50, 1, 10, ''),
(25, 14, 13, 2, 10, ''),
(26, 14, 15, 3, 10, ''),
(27, 15, 15, 3, 10, ''),
(28, 15, 13, 1, 10, ''),
(29, 16, 15, 1, 10, ''),
(30, 16, 16, 3, 10, ''),
(31, 17, 14, 3, 10, ''),
(32, 17, 16, 1, 10, ''),
(33, 17, 15, 1, 10, ''),
(34, 17, 17, 1, 10, ''),
(35, 17, 23, 2, 10, ''),
(36, 17, 13, 1, 10, ''),
(37, 17, 26, 6, 10, ''),
(38, 18, 3, 1, 10, ''),
(39, 18, 4, 1, 10, ''),
(40, 18, 5, 1, 10, ''),
(41, 18, 53, 1, 10, '');

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

--
-- Volcado de datos para la tabla `cliente`
--

INSERT INTO `cliente` (`idCliente`, `cli_rfc`, `cli_rason_social`, `cli_estatus`, `key`, `timestamp`, `idEmpresa`, `cli_observaciones`) VALUES
(1, 'XAXX010101000', 'Cliente de Mostrador', 1, '2cad0e41d51169a0ebf434ccf66a22b5', '2017-12-22 11:05:09', 1, 'VENTAS DE MOSTRADOR');

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
  `idCaja` int(11) NOT NULL,
  `timestamp` datetime DEFAULT CURRENT_TIMESTAMP,
  `gas_descripcion` varchar(1000) DEFAULT NULL,
  `idGastoTipo` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `gastos`
--

INSERT INTO `gastos` (`idGastos`, `gas_monto`, `idCaja`, `timestamp`, `gas_descripcion`, `idGastoTipo`) VALUES
(1, 110, 5, '2018-01-18 12:49:41', 'Solo purebas', 3);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `gastotipo`
--

CREATE TABLE `gastotipo` (
  `idGastoTipo` int(11) NOT NULL,
  `gati_descripcion` varchar(200) NOT NULL,
  `gati_orden` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `gastotipo`
--

INSERT INTO `gastotipo` (`idGastoTipo`, `gati_descripcion`, `gati_orden`) VALUES
(1, 'Pago de proveedor', 0),
(2, 'Pago de empleados', 0),
(3, 'Pago de servicios', 0),
(4, 'Alimentos', 0),
(5, 'Limpeza', 0),
(6, 'Otro', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `inventario`
--

CREATE TABLE `inventario` (
  `idInventario` int(11) NOT NULL,
  `inv_nombre` varchar(500) DEFAULT NULL,
  `inv_descripcion` varchar(1000) DEFAULT NULL,
  `timestamp` datetime DEFAULT CURRENT_TIMESTAMP,
  `idSucursal` int(11) NOT NULL,
  `idEmpresa` int(11) NOT NULL,
  `idUsuario` int(11) NOT NULL,
  `inv_estatus` int(11) DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `inventario`
--

INSERT INTO `inventario` (`idInventario`, `inv_nombre`, `inv_descripcion`, `timestamp`, `idSucursal`, `idEmpresa`, `idUsuario`, `inv_estatus`) VALUES
(1, 'ACTOPAN', 'HOLA', '2018-01-16 16:37:04', 1, 1, 1, 1);

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
(1, 'PRECIOS', '123', 2, 1, 1, '2018-01-16 16:33:40');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `mezcla`
--

CREATE TABLE `mezcla` (
  `idMezcla` int(11) NOT NULL,
  `timestamp` datetime DEFAULT CURRENT_TIMESTAMP,
  `idCheckOut` int(11) NOT NULL,
  `idCheckIn` int(11) NOT NULL
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
(1, 1, 3, 0, 10, '1', '2018-01-16 16:36:25'),
(2, 1, 6, 0, 10, '1', '2018-01-16 16:36:25'),
(3, 1, 2, 0, 10, '1', '2018-01-16 16:36:25'),
(4, 1, 5, 0, 10, '1', '2018-01-16 16:36:25'),
(5, 1, 4, 0, 10, '1', '2018-01-16 16:36:26'),
(6, 1, 11, 0, 10, '1', '2018-01-16 16:36:26'),
(7, 1, 1, 0, 10, '1', '2018-01-16 16:36:26'),
(8, 1, 7, 0, 10, '1', '2018-01-16 16:36:26'),
(9, 1, 10, 0, 10, '1', '2018-01-16 16:36:26'),
(10, 1, 12, 0, 10, '1', '2018-01-16 16:36:26'),
(11, 1, 13, 0, 10, '1', '2018-01-16 16:36:26'),
(12, 1, 15, 0, 10, '1', '2018-01-16 16:36:26'),
(13, 1, 16, 0, 10, '1', '2018-01-16 16:36:26'),
(14, 1, 14, 0, 10, '1', '2018-01-16 16:36:26'),
(15, 1, 17, 0, 10, '1', '2018-01-16 16:36:26'),
(16, 1, 18, 0, 10, '1', '2018-01-16 16:36:26'),
(17, 1, 22, 0, 10, '1', '2018-01-16 16:36:26'),
(18, 1, 19, 0, 10, '1', '2018-01-16 16:36:26'),
(19, 1, 20, 0, 10, '1', '2018-01-16 16:36:27'),
(20, 1, 21, 0, 10, '1', '2018-01-16 16:36:27'),
(21, 1, 23, 0, 10, '1', '2018-01-16 16:36:27'),
(22, 1, 24, 0, 10, '1', '2018-01-16 16:36:27'),
(23, 1, 25, 0, 10, '1', '2018-01-16 16:36:27'),
(24, 1, 27, 0, 10, '1', '2018-01-16 16:36:27'),
(25, 1, 28, 0, 10, '1', '2018-01-16 16:36:27'),
(26, 1, 26, 0, 10, '1', '2018-01-16 16:36:27'),
(27, 1, 29, 0, 10, '1', '2018-01-16 16:36:27'),
(28, 1, 30, 0, 10, '1', '2018-01-16 16:36:27'),
(29, 1, 31, 0, 10, '1', '2018-01-16 16:36:27'),
(30, 1, 32, 0, 10, '1', '2018-01-16 16:36:27'),
(31, 1, 33, 0, 10, '1', '2018-01-16 16:36:27'),
(32, 1, 34, 0, 10, '1', '2018-01-16 16:36:27'),
(33, 1, 35, 0, 10, '1', '2018-01-16 16:36:27'),
(34, 1, 36, 0, 10, '1', '2018-01-16 16:36:27'),
(35, 1, 37, 0, 10, '1', '2018-01-16 16:36:27'),
(36, 1, 38, 0, 10, '1', '2018-01-16 16:36:27'),
(37, 1, 39, 0, 10, '1', '2018-01-16 16:36:27'),
(38, 1, 41, 0, 10, '1', '2018-01-16 16:36:27'),
(39, 1, 40, 0, 10, '1', '2018-01-16 16:36:27'),
(40, 1, 43, 0, 10, '1', '2018-01-16 16:36:27'),
(41, 1, 44, 0, 10, '1', '2018-01-16 16:36:27'),
(42, 1, 42, 0, 10, '1', '2018-01-16 16:36:27'),
(43, 1, 45, 0, 10, '1', '2018-01-16 16:36:28'),
(44, 1, 46, 0, 10, '1', '2018-01-16 16:36:28'),
(45, 1, 47, 0, 10, '1', '2018-01-16 16:36:28'),
(46, 1, 48, 0, 10, '1', '2018-01-16 16:36:28'),
(47, 1, 50, 0, 10, '1', '2018-01-16 16:36:28'),
(48, 1, 49, 0, 10, '1', '2018-01-16 16:36:28'),
(49, 1, 51, 0, 10, '1', '2018-01-16 16:36:28'),
(50, 1, 52, 0, 10, '1', '2018-01-16 16:36:28'),
(51, 1, 53, 0, 10, '1', '2018-01-16 16:36:28');

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
(53, '', 'FORMULA BORREGO CONSUMO', 'CONSUMO PROPIO', 'kg', 1, 1),
(54, '', 'PRODUCTO EJEMPLO', '121212', 'kg', 0, 1);

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

--
-- Volcado de datos para la tabla `stock`
--

INSERT INTO `stock` (`idStock`, `idProducto`, `idEmpresa`, `idSucursal`, `sto_cantidad`) VALUES
(1, 1, 1, 1, 0),
(2, 2, 1, 1, 0),
(3, 3, 1, 1, 9),
(4, 4, 1, 1, 4),
(5, 5, 1, 1, 7),
(6, 6, 1, 1, 10),
(7, 7, 1, 1, 10),
(8, 10, 1, 1, 10),
(9, 11, 1, 1, 10),
(10, 12, 1, 1, 0),
(11, 13, 1, 1, 0),
(12, 14, 1, 1, 7),
(13, 15, 1, 1, 2),
(14, 16, 1, 1, 6),
(15, 17, 1, 1, 9),
(16, 18, 1, 1, 10),
(17, 19, 1, 1, 10),
(18, 20, 1, 1, 10),
(19, 21, 1, 1, 10),
(20, 22, 1, 1, 10),
(21, 23, 1, 1, 8),
(22, 24, 1, 1, 10),
(23, 25, 1, 1, 10),
(24, 26, 1, 1, 4),
(25, 27, 1, 1, 10),
(26, 28, 1, 1, 10),
(27, 29, 1, 1, 10),
(28, 30, 1, 1, 10),
(29, 31, 1, 1, 10),
(30, 32, 1, 1, 10),
(31, 33, 1, 1, 10),
(32, 34, 1, 1, 0),
(33, 35, 1, 1, 10),
(34, 36, 1, 1, 10),
(35, 37, 1, 1, 10),
(36, 38, 1, 1, 10),
(37, 39, 1, 1, 10),
(38, 40, 1, 1, 10),
(39, 41, 1, 1, 5),
(40, 42, 1, 1, 10),
(41, 43, 1, 1, 10),
(42, 44, 1, 1, 10),
(43, 45, 1, 1, 10),
(44, 46, 1, 1, 10),
(45, 47, 1, 1, 10),
(46, 48, 1, 1, 10),
(47, 49, 1, 1, 10),
(48, 50, 1, 1, 1),
(49, 51, 1, 1, 10),
(50, 52, 1, 1, 0),
(51, 53, 1, 1, 2);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `stockaperturacaja`
--

CREATE TABLE `stockaperturacaja` (
  `idStockAperturaCaja` int(11) NOT NULL,
  `idStock` int(11) NOT NULL,
  `idProducto` int(11) NOT NULL,
  `idEmpresa` int(11) NOT NULL,
  `idSucursal` int(11) NOT NULL,
  `sto_cantidad` float DEFAULT '0',
  `idCaja` int(11) NOT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `stockaperturacaja`
--

INSERT INTO `stockaperturacaja` (`idStockAperturaCaja`, `idStock`, `idProducto`, `idEmpresa`, `idSucursal`, `sto_cantidad`, `idCaja`, `timestamp`) VALUES
(1, 1, 1, 1, 1, 15, 7, '2018-01-31 07:28:23'),
(2, 2, 2, 1, 1, 0, 7, '2018-01-31 07:28:23'),
(3, 3, 3, 1, 1, 10, 7, '2018-01-31 07:28:23'),
(4, 4, 4, 1, 1, 5, 7, '2018-01-31 07:28:23'),
(5, 5, 5, 1, 1, 8, 7, '2018-01-31 07:28:23'),
(6, 6, 6, 1, 1, 10, 7, '2018-01-31 07:28:23'),
(7, 7, 7, 1, 1, 10, 7, '2018-01-31 07:28:23'),
(8, 8, 10, 1, 1, 10, 7, '2018-01-31 07:28:23'),
(9, 9, 11, 1, 1, 10, 7, '2018-01-31 07:28:23'),
(10, 10, 12, 1, 1, 2, 7, '2018-01-31 07:28:23'),
(11, 11, 13, 1, 1, 10, 7, '2018-01-31 07:28:23'),
(12, 12, 14, 1, 1, 10, 7, '2018-01-31 07:28:23'),
(13, 13, 15, 1, 1, 10, 7, '2018-01-31 07:28:23'),
(14, 14, 16, 1, 1, 10, 7, '2018-01-31 07:28:23'),
(15, 15, 17, 1, 1, 10, 7, '2018-01-31 07:28:23'),
(16, 16, 18, 1, 1, 10, 7, '2018-01-31 07:28:23'),
(17, 17, 19, 1, 1, 10, 7, '2018-01-31 07:28:23'),
(18, 18, 20, 1, 1, 10, 7, '2018-01-31 07:28:23'),
(19, 19, 21, 1, 1, 10, 7, '2018-01-31 07:28:23'),
(20, 20, 22, 1, 1, 10, 7, '2018-01-31 07:28:23'),
(21, 21, 23, 1, 1, 10, 7, '2018-01-31 07:28:23'),
(22, 22, 24, 1, 1, 10, 7, '2018-01-31 07:28:23'),
(23, 23, 25, 1, 1, 10, 7, '2018-01-31 07:28:23'),
(24, 24, 26, 1, 1, 10, 7, '2018-01-31 07:28:23'),
(25, 25, 27, 1, 1, 10, 7, '2018-01-31 07:28:23'),
(26, 26, 28, 1, 1, 10, 7, '2018-01-31 07:28:23'),
(27, 27, 29, 1, 1, 10, 7, '2018-01-31 07:28:23'),
(28, 28, 30, 1, 1, 10, 7, '2018-01-31 07:28:23'),
(29, 29, 31, 1, 1, 10, 7, '2018-01-31 07:28:23'),
(30, 30, 32, 1, 1, 10, 7, '2018-01-31 07:28:23'),
(31, 31, 33, 1, 1, 10, 7, '2018-01-31 07:28:23'),
(32, 32, 34, 1, 1, 0, 7, '2018-01-31 07:28:23'),
(33, 33, 35, 1, 1, 10, 7, '2018-01-31 07:28:23'),
(34, 34, 36, 1, 1, 10, 7, '2018-01-31 07:28:23'),
(35, 35, 37, 1, 1, 10, 7, '2018-01-31 07:28:23'),
(36, 36, 38, 1, 1, 10, 7, '2018-01-31 07:28:23'),
(37, 37, 39, 1, 1, 10, 7, '2018-01-31 07:28:23'),
(38, 38, 40, 1, 1, 10, 7, '2018-01-31 07:28:23'),
(39, 39, 41, 1, 1, 10, 7, '2018-01-31 07:28:23'),
(40, 40, 42, 1, 1, 10, 7, '2018-01-31 07:28:23'),
(41, 41, 43, 1, 1, 10, 7, '2018-01-31 07:28:23'),
(42, 42, 44, 1, 1, 10, 7, '2018-01-31 07:28:23'),
(43, 43, 45, 1, 1, 10, 7, '2018-01-31 07:28:23'),
(44, 44, 46, 1, 1, 10, 7, '2018-01-31 07:28:23'),
(45, 45, 47, 1, 1, 10, 7, '2018-01-31 07:28:23'),
(46, 46, 48, 1, 1, 10, 7, '2018-01-31 07:28:23'),
(47, 47, 49, 1, 1, 10, 7, '2018-01-31 07:28:23'),
(48, 48, 50, 1, 1, 2, 7, '2018-01-31 07:28:23'),
(49, 49, 51, 1, 1, 10, 7, '2018-01-31 07:28:23'),
(50, 50, 52, 1, 1, 0, 7, '2018-01-31 07:28:23'),
(51, 51, 53, 1, 1, 3, 7, '2018-01-31 07:28:23'),
(64, 1, 1, 1, 1, 9, 8, '2018-01-31 08:03:55'),
(65, 2, 2, 1, 1, 0, 8, '2018-01-31 08:03:55'),
(66, 3, 3, 1, 1, 10, 8, '2018-01-31 08:03:55'),
(67, 4, 4, 1, 1, 5, 8, '2018-01-31 08:03:55'),
(68, 5, 5, 1, 1, 8, 8, '2018-01-31 08:03:55'),
(69, 6, 6, 1, 1, 10, 8, '2018-01-31 08:03:55'),
(70, 7, 7, 1, 1, 10, 8, '2018-01-31 08:03:55'),
(71, 8, 10, 1, 1, 10, 8, '2018-01-31 08:03:55'),
(72, 9, 11, 1, 1, 10, 8, '2018-01-31 08:03:55'),
(73, 10, 12, 1, 1, 2, 8, '2018-01-31 08:03:55'),
(74, 11, 13, 1, 1, 10, 8, '2018-01-31 08:03:55'),
(75, 12, 14, 1, 1, 10, 8, '2018-01-31 08:03:55'),
(76, 13, 15, 1, 1, 10, 8, '2018-01-31 08:03:55'),
(77, 14, 16, 1, 1, 10, 8, '2018-01-31 08:03:55'),
(78, 15, 17, 1, 1, 10, 8, '2018-01-31 08:03:55'),
(79, 16, 18, 1, 1, 10, 8, '2018-01-31 08:03:55'),
(80, 17, 19, 1, 1, 10, 8, '2018-01-31 08:03:55'),
(81, 18, 20, 1, 1, 10, 8, '2018-01-31 08:03:55'),
(82, 19, 21, 1, 1, 10, 8, '2018-01-31 08:03:55'),
(83, 20, 22, 1, 1, 10, 8, '2018-01-31 08:03:55'),
(84, 21, 23, 1, 1, 10, 8, '2018-01-31 08:03:55'),
(85, 22, 24, 1, 1, 10, 8, '2018-01-31 08:03:55'),
(86, 23, 25, 1, 1, 10, 8, '2018-01-31 08:03:55'),
(87, 24, 26, 1, 1, 10, 8, '2018-01-31 08:03:55'),
(88, 25, 27, 1, 1, 10, 8, '2018-01-31 08:03:55'),
(89, 26, 28, 1, 1, 10, 8, '2018-01-31 08:03:55'),
(90, 27, 29, 1, 1, 10, 8, '2018-01-31 08:03:55'),
(91, 28, 30, 1, 1, 10, 8, '2018-01-31 08:03:55'),
(92, 29, 31, 1, 1, 10, 8, '2018-01-31 08:03:55'),
(93, 30, 32, 1, 1, 10, 8, '2018-01-31 08:03:55'),
(94, 31, 33, 1, 1, 10, 8, '2018-01-31 08:03:55'),
(95, 32, 34, 1, 1, 0, 8, '2018-01-31 08:03:55'),
(96, 33, 35, 1, 1, 10, 8, '2018-01-31 08:03:55'),
(97, 34, 36, 1, 1, 10, 8, '2018-01-31 08:03:55'),
(98, 35, 37, 1, 1, 10, 8, '2018-01-31 08:03:55'),
(99, 36, 38, 1, 1, 10, 8, '2018-01-31 08:03:55'),
(100, 37, 39, 1, 1, 10, 8, '2018-01-31 08:03:55'),
(101, 38, 40, 1, 1, 10, 8, '2018-01-31 08:03:55'),
(102, 39, 41, 1, 1, 9, 8, '2018-01-31 08:03:55'),
(103, 40, 42, 1, 1, 10, 8, '2018-01-31 08:03:55'),
(104, 41, 43, 1, 1, 10, 8, '2018-01-31 08:03:55'),
(105, 42, 44, 1, 1, 10, 8, '2018-01-31 08:03:55'),
(106, 43, 45, 1, 1, 10, 8, '2018-01-31 08:03:55'),
(107, 44, 46, 1, 1, 10, 8, '2018-01-31 08:03:55'),
(108, 45, 47, 1, 1, 10, 8, '2018-01-31 08:03:55'),
(109, 46, 48, 1, 1, 10, 8, '2018-01-31 08:03:55'),
(110, 47, 49, 1, 1, 10, 8, '2018-01-31 08:03:55'),
(111, 48, 50, 1, 1, 2, 8, '2018-01-31 08:03:55'),
(112, 49, 51, 1, 1, 10, 8, '2018-01-31 08:03:55'),
(113, 50, 52, 1, 1, 0, 8, '2018-01-31 08:03:55'),
(114, 51, 53, 1, 1, 3, 8, '2018-01-31 08:03:55'),
(127, 1, 1, 1, 1, 7, 9, '2018-01-31 08:04:52'),
(128, 2, 2, 1, 1, 0, 9, '2018-01-31 08:04:52'),
(129, 3, 3, 1, 1, 10, 9, '2018-01-31 08:04:52'),
(130, 4, 4, 1, 1, 5, 9, '2018-01-31 08:04:52'),
(131, 5, 5, 1, 1, 8, 9, '2018-01-31 08:04:52'),
(132, 6, 6, 1, 1, 10, 9, '2018-01-31 08:04:52'),
(133, 7, 7, 1, 1, 10, 9, '2018-01-31 08:04:52'),
(134, 8, 10, 1, 1, 10, 9, '2018-01-31 08:04:52'),
(135, 9, 11, 1, 1, 10, 9, '2018-01-31 08:04:52'),
(136, 10, 12, 1, 1, 2, 9, '2018-01-31 08:04:52'),
(137, 11, 13, 1, 1, 10, 9, '2018-01-31 08:04:52'),
(138, 12, 14, 1, 1, 10, 9, '2018-01-31 08:04:52'),
(139, 13, 15, 1, 1, 10, 9, '2018-01-31 08:04:52'),
(140, 14, 16, 1, 1, 10, 9, '2018-01-31 08:04:52'),
(141, 15, 17, 1, 1, 10, 9, '2018-01-31 08:04:52'),
(142, 16, 18, 1, 1, 10, 9, '2018-01-31 08:04:52'),
(143, 17, 19, 1, 1, 10, 9, '2018-01-31 08:04:52'),
(144, 18, 20, 1, 1, 10, 9, '2018-01-31 08:04:52'),
(145, 19, 21, 1, 1, 10, 9, '2018-01-31 08:04:52'),
(146, 20, 22, 1, 1, 10, 9, '2018-01-31 08:04:52'),
(147, 21, 23, 1, 1, 10, 9, '2018-01-31 08:04:52'),
(148, 22, 24, 1, 1, 10, 9, '2018-01-31 08:04:52'),
(149, 23, 25, 1, 1, 10, 9, '2018-01-31 08:04:52'),
(150, 24, 26, 1, 1, 10, 9, '2018-01-31 08:04:52'),
(151, 25, 27, 1, 1, 10, 9, '2018-01-31 08:04:52'),
(152, 26, 28, 1, 1, 10, 9, '2018-01-31 08:04:52'),
(153, 27, 29, 1, 1, 10, 9, '2018-01-31 08:04:52'),
(154, 28, 30, 1, 1, 10, 9, '2018-01-31 08:04:52'),
(155, 29, 31, 1, 1, 10, 9, '2018-01-31 08:04:52'),
(156, 30, 32, 1, 1, 10, 9, '2018-01-31 08:04:52'),
(157, 31, 33, 1, 1, 10, 9, '2018-01-31 08:04:52'),
(158, 32, 34, 1, 1, 0, 9, '2018-01-31 08:04:52'),
(159, 33, 35, 1, 1, 10, 9, '2018-01-31 08:04:52'),
(160, 34, 36, 1, 1, 10, 9, '2018-01-31 08:04:52'),
(161, 35, 37, 1, 1, 10, 9, '2018-01-31 08:04:52'),
(162, 36, 38, 1, 1, 10, 9, '2018-01-31 08:04:52'),
(163, 37, 39, 1, 1, 10, 9, '2018-01-31 08:04:52'),
(164, 38, 40, 1, 1, 10, 9, '2018-01-31 08:04:52'),
(165, 39, 41, 1, 1, 8, 9, '2018-01-31 08:04:52'),
(166, 40, 42, 1, 1, 10, 9, '2018-01-31 08:04:52'),
(167, 41, 43, 1, 1, 10, 9, '2018-01-31 08:04:52'),
(168, 42, 44, 1, 1, 10, 9, '2018-01-31 08:04:52'),
(169, 43, 45, 1, 1, 10, 9, '2018-01-31 08:04:52'),
(170, 44, 46, 1, 1, 10, 9, '2018-01-31 08:04:52'),
(171, 45, 47, 1, 1, 10, 9, '2018-01-31 08:04:52'),
(172, 46, 48, 1, 1, 10, 9, '2018-01-31 08:04:52'),
(173, 47, 49, 1, 1, 10, 9, '2018-01-31 08:04:52'),
(174, 48, 50, 1, 1, 2, 9, '2018-01-31 08:04:52'),
(175, 49, 51, 1, 1, 10, 9, '2018-01-31 08:04:52'),
(176, 50, 52, 1, 1, 0, 9, '2018-01-31 08:04:52'),
(177, 51, 53, 1, 1, 3, 9, '2018-01-31 08:04:52'),
(190, 1, 1, 1, 1, 2, 10, '2018-01-31 08:31:07'),
(191, 2, 2, 1, 1, 0, 10, '2018-01-31 08:31:07'),
(192, 3, 3, 1, 1, 10, 10, '2018-01-31 08:31:07'),
(193, 4, 4, 1, 1, 5, 10, '2018-01-31 08:31:07'),
(194, 5, 5, 1, 1, 8, 10, '2018-01-31 08:31:07'),
(195, 6, 6, 1, 1, 10, 10, '2018-01-31 08:31:07'),
(196, 7, 7, 1, 1, 10, 10, '2018-01-31 08:31:07'),
(197, 8, 10, 1, 1, 10, 10, '2018-01-31 08:31:07'),
(198, 9, 11, 1, 1, 10, 10, '2018-01-31 08:31:07'),
(199, 10, 12, 1, 1, 2, 10, '2018-01-31 08:31:07'),
(200, 11, 13, 1, 1, 7, 10, '2018-01-31 08:31:07'),
(201, 12, 14, 1, 1, 10, 10, '2018-01-31 08:31:07'),
(202, 13, 15, 1, 1, 10, 10, '2018-01-31 08:31:07'),
(203, 14, 16, 1, 1, 10, 10, '2018-01-31 08:31:07'),
(204, 15, 17, 1, 1, 10, 10, '2018-01-31 08:31:07'),
(205, 16, 18, 1, 1, 10, 10, '2018-01-31 08:31:07'),
(206, 17, 19, 1, 1, 10, 10, '2018-01-31 08:31:07'),
(207, 18, 20, 1, 1, 10, 10, '2018-01-31 08:31:07'),
(208, 19, 21, 1, 1, 10, 10, '2018-01-31 08:31:07'),
(209, 20, 22, 1, 1, 10, 10, '2018-01-31 08:31:07'),
(210, 21, 23, 1, 1, 10, 10, '2018-01-31 08:31:07'),
(211, 22, 24, 1, 1, 10, 10, '2018-01-31 08:31:07'),
(212, 23, 25, 1, 1, 10, 10, '2018-01-31 08:31:07'),
(213, 24, 26, 1, 1, 10, 10, '2018-01-31 08:31:07'),
(214, 25, 27, 1, 1, 10, 10, '2018-01-31 08:31:07'),
(215, 26, 28, 1, 1, 10, 10, '2018-01-31 08:31:07'),
(216, 27, 29, 1, 1, 10, 10, '2018-01-31 08:31:07'),
(217, 28, 30, 1, 1, 10, 10, '2018-01-31 08:31:07'),
(218, 29, 31, 1, 1, 10, 10, '2018-01-31 08:31:07'),
(219, 30, 32, 1, 1, 10, 10, '2018-01-31 08:31:07'),
(220, 31, 33, 1, 1, 10, 10, '2018-01-31 08:31:07'),
(221, 32, 34, 1, 1, 0, 10, '2018-01-31 08:31:07'),
(222, 33, 35, 1, 1, 10, 10, '2018-01-31 08:31:07'),
(223, 34, 36, 1, 1, 10, 10, '2018-01-31 08:31:07'),
(224, 35, 37, 1, 1, 10, 10, '2018-01-31 08:31:07'),
(225, 36, 38, 1, 1, 10, 10, '2018-01-31 08:31:07'),
(226, 37, 39, 1, 1, 10, 10, '2018-01-31 08:31:07'),
(227, 38, 40, 1, 1, 10, 10, '2018-01-31 08:31:07'),
(228, 39, 41, 1, 1, 5, 10, '2018-01-31 08:31:07'),
(229, 40, 42, 1, 1, 10, 10, '2018-01-31 08:31:07'),
(230, 41, 43, 1, 1, 10, 10, '2018-01-31 08:31:07'),
(231, 42, 44, 1, 1, 10, 10, '2018-01-31 08:31:07'),
(232, 43, 45, 1, 1, 10, 10, '2018-01-31 08:31:07'),
(233, 44, 46, 1, 1, 10, 10, '2018-01-31 08:31:07'),
(234, 45, 47, 1, 1, 10, 10, '2018-01-31 08:31:07'),
(235, 46, 48, 1, 1, 10, 10, '2018-01-31 08:31:07'),
(236, 47, 49, 1, 1, 10, 10, '2018-01-31 08:31:07'),
(237, 48, 50, 1, 1, 2, 10, '2018-01-31 08:31:07'),
(238, 49, 51, 1, 1, 10, 10, '2018-01-31 08:31:07'),
(239, 50, 52, 1, 1, 0, 10, '2018-01-31 08:31:07'),
(240, 51, 53, 1, 1, 3, 10, '2018-01-31 08:31:07'),
(253, 1, 1, 1, 1, 2, 11, '2018-01-31 08:35:59'),
(254, 2, 2, 1, 1, 0, 11, '2018-01-31 08:35:59'),
(255, 3, 3, 1, 1, 10, 11, '2018-01-31 08:35:59'),
(256, 4, 4, 1, 1, 5, 11, '2018-01-31 08:35:59'),
(257, 5, 5, 1, 1, 8, 11, '2018-01-31 08:35:59'),
(258, 6, 6, 1, 1, 10, 11, '2018-01-31 08:35:59'),
(259, 7, 7, 1, 1, 10, 11, '2018-01-31 08:35:59'),
(260, 8, 10, 1, 1, 10, 11, '2018-01-31 08:35:59'),
(261, 9, 11, 1, 1, 10, 11, '2018-01-31 08:35:59'),
(262, 10, 12, 1, 1, 1, 11, '2018-01-31 08:35:59'),
(263, 11, 13, 1, 1, 7, 11, '2018-01-31 08:35:59'),
(264, 12, 14, 1, 1, 10, 11, '2018-01-31 08:35:59'),
(265, 13, 15, 1, 1, 10, 11, '2018-01-31 08:35:59'),
(266, 14, 16, 1, 1, 10, 11, '2018-01-31 08:35:59'),
(267, 15, 17, 1, 1, 10, 11, '2018-01-31 08:35:59'),
(268, 16, 18, 1, 1, 10, 11, '2018-01-31 08:35:59'),
(269, 17, 19, 1, 1, 10, 11, '2018-01-31 08:35:59'),
(270, 18, 20, 1, 1, 10, 11, '2018-01-31 08:35:59'),
(271, 19, 21, 1, 1, 10, 11, '2018-01-31 08:35:59'),
(272, 20, 22, 1, 1, 10, 11, '2018-01-31 08:35:59'),
(273, 21, 23, 1, 1, 10, 11, '2018-01-31 08:35:59'),
(274, 22, 24, 1, 1, 10, 11, '2018-01-31 08:35:59'),
(275, 23, 25, 1, 1, 10, 11, '2018-01-31 08:35:59'),
(276, 24, 26, 1, 1, 10, 11, '2018-01-31 08:35:59'),
(277, 25, 27, 1, 1, 10, 11, '2018-01-31 08:35:59'),
(278, 26, 28, 1, 1, 10, 11, '2018-01-31 08:35:59'),
(279, 27, 29, 1, 1, 10, 11, '2018-01-31 08:35:59'),
(280, 28, 30, 1, 1, 10, 11, '2018-01-31 08:35:59'),
(281, 29, 31, 1, 1, 10, 11, '2018-01-31 08:35:59'),
(282, 30, 32, 1, 1, 10, 11, '2018-01-31 08:35:59'),
(283, 31, 33, 1, 1, 10, 11, '2018-01-31 08:35:59'),
(284, 32, 34, 1, 1, 0, 11, '2018-01-31 08:35:59'),
(285, 33, 35, 1, 1, 10, 11, '2018-01-31 08:35:59'),
(286, 34, 36, 1, 1, 10, 11, '2018-01-31 08:35:59'),
(287, 35, 37, 1, 1, 10, 11, '2018-01-31 08:35:59'),
(288, 36, 38, 1, 1, 10, 11, '2018-01-31 08:35:59'),
(289, 37, 39, 1, 1, 10, 11, '2018-01-31 08:35:59'),
(290, 38, 40, 1, 1, 10, 11, '2018-01-31 08:35:59'),
(291, 39, 41, 1, 1, 5, 11, '2018-01-31 08:35:59'),
(292, 40, 42, 1, 1, 10, 11, '2018-01-31 08:35:59'),
(293, 41, 43, 1, 1, 10, 11, '2018-01-31 08:35:59'),
(294, 42, 44, 1, 1, 10, 11, '2018-01-31 08:35:59'),
(295, 43, 45, 1, 1, 10, 11, '2018-01-31 08:35:59'),
(296, 44, 46, 1, 1, 10, 11, '2018-01-31 08:35:59'),
(297, 45, 47, 1, 1, 10, 11, '2018-01-31 08:35:59'),
(298, 46, 48, 1, 1, 10, 11, '2018-01-31 08:35:59'),
(299, 47, 49, 1, 1, 10, 11, '2018-01-31 08:35:59'),
(300, 48, 50, 1, 1, 2, 11, '2018-01-31 08:35:59'),
(301, 49, 51, 1, 1, 10, 11, '2018-01-31 08:35:59'),
(302, 50, 52, 1, 1, 0, 11, '2018-01-31 08:35:59'),
(303, 51, 53, 1, 1, 3, 11, '2018-01-31 08:35:59'),
(316, 1, 1, 1, 1, 0, 12, '2018-01-31 08:43:12'),
(317, 2, 2, 1, 1, 0, 12, '2018-01-31 08:43:12'),
(318, 3, 3, 1, 1, 10, 12, '2018-01-31 08:43:12'),
(319, 4, 4, 1, 1, 5, 12, '2018-01-31 08:43:12'),
(320, 5, 5, 1, 1, 8, 12, '2018-01-31 08:43:12'),
(321, 6, 6, 1, 1, 10, 12, '2018-01-31 08:43:12'),
(322, 7, 7, 1, 1, 10, 12, '2018-01-31 08:43:12'),
(323, 8, 10, 1, 1, 10, 12, '2018-01-31 08:43:12'),
(324, 9, 11, 1, 1, 10, 12, '2018-01-31 08:43:12'),
(325, 10, 12, 1, 1, 0, 12, '2018-01-31 08:43:12'),
(326, 11, 13, 1, 1, 2, 12, '2018-01-31 08:43:12'),
(327, 12, 14, 1, 1, 10, 12, '2018-01-31 08:43:12'),
(328, 13, 15, 1, 1, 7, 12, '2018-01-31 08:43:12'),
(329, 14, 16, 1, 1, 10, 12, '2018-01-31 08:43:12'),
(330, 15, 17, 1, 1, 10, 12, '2018-01-31 08:43:12'),
(331, 16, 18, 1, 1, 10, 12, '2018-01-31 08:43:12'),
(332, 17, 19, 1, 1, 10, 12, '2018-01-31 08:43:12'),
(333, 18, 20, 1, 1, 10, 12, '2018-01-31 08:43:12'),
(334, 19, 21, 1, 1, 10, 12, '2018-01-31 08:43:12'),
(335, 20, 22, 1, 1, 10, 12, '2018-01-31 08:43:12'),
(336, 21, 23, 1, 1, 10, 12, '2018-01-31 08:43:12'),
(337, 22, 24, 1, 1, 10, 12, '2018-01-31 08:43:12'),
(338, 23, 25, 1, 1, 10, 12, '2018-01-31 08:43:12'),
(339, 24, 26, 1, 1, 10, 12, '2018-01-31 08:43:12'),
(340, 25, 27, 1, 1, 10, 12, '2018-01-31 08:43:12'),
(341, 26, 28, 1, 1, 10, 12, '2018-01-31 08:43:12'),
(342, 27, 29, 1, 1, 10, 12, '2018-01-31 08:43:12'),
(343, 28, 30, 1, 1, 10, 12, '2018-01-31 08:43:12'),
(344, 29, 31, 1, 1, 10, 12, '2018-01-31 08:43:12'),
(345, 30, 32, 1, 1, 10, 12, '2018-01-31 08:43:12'),
(346, 31, 33, 1, 1, 10, 12, '2018-01-31 08:43:12'),
(347, 32, 34, 1, 1, 0, 12, '2018-01-31 08:43:12'),
(348, 33, 35, 1, 1, 10, 12, '2018-01-31 08:43:12'),
(349, 34, 36, 1, 1, 10, 12, '2018-01-31 08:43:12'),
(350, 35, 37, 1, 1, 10, 12, '2018-01-31 08:43:12'),
(351, 36, 38, 1, 1, 10, 12, '2018-01-31 08:43:12'),
(352, 37, 39, 1, 1, 10, 12, '2018-01-31 08:43:12'),
(353, 38, 40, 1, 1, 10, 12, '2018-01-31 08:43:12'),
(354, 39, 41, 1, 1, 5, 12, '2018-01-31 08:43:12'),
(355, 40, 42, 1, 1, 10, 12, '2018-01-31 08:43:12'),
(356, 41, 43, 1, 1, 10, 12, '2018-01-31 08:43:12'),
(357, 42, 44, 1, 1, 10, 12, '2018-01-31 08:43:12'),
(358, 43, 45, 1, 1, 10, 12, '2018-01-31 08:43:12'),
(359, 44, 46, 1, 1, 10, 12, '2018-01-31 08:43:12'),
(360, 45, 47, 1, 1, 10, 12, '2018-01-31 08:43:12'),
(361, 46, 48, 1, 1, 10, 12, '2018-01-31 08:43:12'),
(362, 47, 49, 1, 1, 10, 12, '2018-01-31 08:43:12'),
(363, 48, 50, 1, 1, 1, 12, '2018-01-31 08:43:12'),
(364, 49, 51, 1, 1, 10, 12, '2018-01-31 08:43:12'),
(365, 50, 52, 1, 1, 0, 12, '2018-01-31 08:43:12'),
(366, 51, 53, 1, 1, 3, 12, '2018-01-31 08:43:12'),
(379, 1, 1, 1, 1, 0, 13, '2018-01-31 08:47:01'),
(380, 2, 2, 1, 1, 0, 13, '2018-01-31 08:47:01'),
(381, 3, 3, 1, 1, 10, 13, '2018-01-31 08:47:01'),
(382, 4, 4, 1, 1, 5, 13, '2018-01-31 08:47:01'),
(383, 5, 5, 1, 1, 8, 13, '2018-01-31 08:47:01'),
(384, 6, 6, 1, 1, 10, 13, '2018-01-31 08:47:01'),
(385, 7, 7, 1, 1, 10, 13, '2018-01-31 08:47:01'),
(386, 8, 10, 1, 1, 10, 13, '2018-01-31 08:47:01'),
(387, 9, 11, 1, 1, 10, 13, '2018-01-31 08:47:01'),
(388, 10, 12, 1, 1, 0, 13, '2018-01-31 08:47:01'),
(389, 11, 13, 1, 1, 1, 13, '2018-01-31 08:47:01'),
(390, 12, 14, 1, 1, 10, 13, '2018-01-31 08:47:01'),
(391, 13, 15, 1, 1, 3, 13, '2018-01-31 08:47:01'),
(392, 14, 16, 1, 1, 7, 13, '2018-01-31 08:47:01'),
(393, 15, 17, 1, 1, 10, 13, '2018-01-31 08:47:01'),
(394, 16, 18, 1, 1, 10, 13, '2018-01-31 08:47:01'),
(395, 17, 19, 1, 1, 10, 13, '2018-01-31 08:47:01'),
(396, 18, 20, 1, 1, 10, 13, '2018-01-31 08:47:01'),
(397, 19, 21, 1, 1, 10, 13, '2018-01-31 08:47:01'),
(398, 20, 22, 1, 1, 10, 13, '2018-01-31 08:47:01'),
(399, 21, 23, 1, 1, 10, 13, '2018-01-31 08:47:01'),
(400, 22, 24, 1, 1, 10, 13, '2018-01-31 08:47:01'),
(401, 23, 25, 1, 1, 10, 13, '2018-01-31 08:47:01'),
(402, 24, 26, 1, 1, 10, 13, '2018-01-31 08:47:01'),
(403, 25, 27, 1, 1, 10, 13, '2018-01-31 08:47:01'),
(404, 26, 28, 1, 1, 10, 13, '2018-01-31 08:47:01'),
(405, 27, 29, 1, 1, 10, 13, '2018-01-31 08:47:01'),
(406, 28, 30, 1, 1, 10, 13, '2018-01-31 08:47:01'),
(407, 29, 31, 1, 1, 10, 13, '2018-01-31 08:47:01'),
(408, 30, 32, 1, 1, 10, 13, '2018-01-31 08:47:01'),
(409, 31, 33, 1, 1, 10, 13, '2018-01-31 08:47:01'),
(410, 32, 34, 1, 1, 0, 13, '2018-01-31 08:47:01'),
(411, 33, 35, 1, 1, 10, 13, '2018-01-31 08:47:01'),
(412, 34, 36, 1, 1, 10, 13, '2018-01-31 08:47:01'),
(413, 35, 37, 1, 1, 10, 13, '2018-01-31 08:47:01'),
(414, 36, 38, 1, 1, 10, 13, '2018-01-31 08:47:01'),
(415, 37, 39, 1, 1, 10, 13, '2018-01-31 08:47:01'),
(416, 38, 40, 1, 1, 10, 13, '2018-01-31 08:47:01'),
(417, 39, 41, 1, 1, 5, 13, '2018-01-31 08:47:01'),
(418, 40, 42, 1, 1, 10, 13, '2018-01-31 08:47:01'),
(419, 41, 43, 1, 1, 10, 13, '2018-01-31 08:47:01'),
(420, 42, 44, 1, 1, 10, 13, '2018-01-31 08:47:01'),
(421, 43, 45, 1, 1, 10, 13, '2018-01-31 08:47:01'),
(422, 44, 46, 1, 1, 10, 13, '2018-01-31 08:47:01'),
(423, 45, 47, 1, 1, 10, 13, '2018-01-31 08:47:01'),
(424, 46, 48, 1, 1, 10, 13, '2018-01-31 08:47:01'),
(425, 47, 49, 1, 1, 10, 13, '2018-01-31 08:47:01'),
(426, 48, 50, 1, 1, 1, 13, '2018-01-31 08:47:01'),
(427, 49, 51, 1, 1, 10, 13, '2018-01-31 08:47:01'),
(428, 50, 52, 1, 1, 0, 13, '2018-01-31 08:47:01'),
(429, 51, 53, 1, 1, 3, 13, '2018-01-31 08:47:01'),
(442, 1, 1, 1, 1, 0, 14, '2018-01-31 08:49:42'),
(443, 2, 2, 1, 1, 0, 14, '2018-01-31 08:49:42'),
(444, 3, 3, 1, 1, 10, 14, '2018-01-31 08:49:42'),
(445, 4, 4, 1, 1, 5, 14, '2018-01-31 08:49:42'),
(446, 5, 5, 1, 1, 8, 14, '2018-01-31 08:49:42'),
(447, 6, 6, 1, 1, 10, 14, '2018-01-31 08:49:42'),
(448, 7, 7, 1, 1, 10, 14, '2018-01-31 08:49:42'),
(449, 8, 10, 1, 1, 10, 14, '2018-01-31 08:49:42'),
(450, 9, 11, 1, 1, 10, 14, '2018-01-31 08:49:42'),
(451, 10, 12, 1, 1, 0, 14, '2018-01-31 08:49:42'),
(452, 11, 13, 1, 1, 0, 14, '2018-01-31 08:49:42'),
(453, 12, 14, 1, 1, 7, 14, '2018-01-31 08:49:42'),
(454, 13, 15, 1, 1, 2, 14, '2018-01-31 08:49:42'),
(455, 14, 16, 1, 1, 6, 14, '2018-01-31 08:49:42'),
(456, 15, 17, 1, 1, 9, 14, '2018-01-31 08:49:42'),
(457, 16, 18, 1, 1, 10, 14, '2018-01-31 08:49:42'),
(458, 17, 19, 1, 1, 10, 14, '2018-01-31 08:49:42'),
(459, 18, 20, 1, 1, 10, 14, '2018-01-31 08:49:42'),
(460, 19, 21, 1, 1, 10, 14, '2018-01-31 08:49:42'),
(461, 20, 22, 1, 1, 10, 14, '2018-01-31 08:49:42'),
(462, 21, 23, 1, 1, 8, 14, '2018-01-31 08:49:42'),
(463, 22, 24, 1, 1, 10, 14, '2018-01-31 08:49:42'),
(464, 23, 25, 1, 1, 10, 14, '2018-01-31 08:49:42'),
(465, 24, 26, 1, 1, 4, 14, '2018-01-31 08:49:42'),
(466, 25, 27, 1, 1, 10, 14, '2018-01-31 08:49:42'),
(467, 26, 28, 1, 1, 10, 14, '2018-01-31 08:49:42'),
(468, 27, 29, 1, 1, 10, 14, '2018-01-31 08:49:42'),
(469, 28, 30, 1, 1, 10, 14, '2018-01-31 08:49:42'),
(470, 29, 31, 1, 1, 10, 14, '2018-01-31 08:49:42'),
(471, 30, 32, 1, 1, 10, 14, '2018-01-31 08:49:42'),
(472, 31, 33, 1, 1, 10, 14, '2018-01-31 08:49:42'),
(473, 32, 34, 1, 1, 0, 14, '2018-01-31 08:49:42'),
(474, 33, 35, 1, 1, 10, 14, '2018-01-31 08:49:42'),
(475, 34, 36, 1, 1, 10, 14, '2018-01-31 08:49:42'),
(476, 35, 37, 1, 1, 10, 14, '2018-01-31 08:49:42'),
(477, 36, 38, 1, 1, 10, 14, '2018-01-31 08:49:42'),
(478, 37, 39, 1, 1, 10, 14, '2018-01-31 08:49:42'),
(479, 38, 40, 1, 1, 10, 14, '2018-01-31 08:49:42'),
(480, 39, 41, 1, 1, 5, 14, '2018-01-31 08:49:42'),
(481, 40, 42, 1, 1, 10, 14, '2018-01-31 08:49:42'),
(482, 41, 43, 1, 1, 10, 14, '2018-01-31 08:49:42'),
(483, 42, 44, 1, 1, 10, 14, '2018-01-31 08:49:42'),
(484, 43, 45, 1, 1, 10, 14, '2018-01-31 08:49:42'),
(485, 44, 46, 1, 1, 10, 14, '2018-01-31 08:49:42'),
(486, 45, 47, 1, 1, 10, 14, '2018-01-31 08:49:42'),
(487, 46, 48, 1, 1, 10, 14, '2018-01-31 08:49:42'),
(488, 47, 49, 1, 1, 10, 14, '2018-01-31 08:49:42'),
(489, 48, 50, 1, 1, 1, 14, '2018-01-31 08:49:42'),
(490, 49, 51, 1, 1, 10, 14, '2018-01-31 08:49:42'),
(491, 50, 52, 1, 1, 0, 14, '2018-01-31 08:49:42'),
(492, 51, 53, 1, 1, 3, 14, '2018-01-31 08:49:42');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `stockhistorial`
--

CREATE TABLE `stockhistorial` (
  `idStockHistorial` int(11) NOT NULL,
  `sto_cantidad` varchar(45) DEFAULT NULL,
  `sto_observaciones` varchar(1000) DEFAULT NULL,
  `fecha` date DEFAULT NULL,
  `timestamp` datetime DEFAULT CURRENT_TIMESTAMP,
  `idStock` int(11) NOT NULL,
  `idInventario` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `stockhistorial`
--

INSERT INTO `stockhistorial` (`idStockHistorial`, `sto_cantidad`, `sto_observaciones`, `fecha`, `timestamp`, `idStock`, `idInventario`) VALUES
(1, '15', 'precio inicial', '2018-01-18', '2018-01-16 16:39:05', 1, 1),
(2, '15', 'precio inicial', '2018-01-18', '2018-01-16 16:39:05', 2, 1),
(3, '10', 'precio inicial', '2018-01-18', '2018-01-16 16:39:06', 3, 1),
(4, '5', 'precio inicial', '2018-01-18', '2018-01-16 16:39:06', 4, 1),
(5, '10', 'precio inicial', '2018-01-18', '2018-01-16 16:39:07', 5, 1),
(6, '10', 'precio inicial', '2018-01-18', '2018-01-16 16:39:07', 6, 1),
(7, '10', 'precio inicial', '2018-01-18', '2018-01-16 16:39:07', 7, 1),
(8, '10', 'precio inicial', '2018-01-18', '2018-01-16 16:39:08', 8, 1),
(9, '10', 'precio inicial', '2018-01-18', '2018-01-16 16:39:08', 9, 1),
(10, '10', 'precio inicial', '2018-01-18', '2018-01-16 16:39:08', 10, 1),
(11, '10', 'precio inicial', '2018-01-18', '2018-01-16 16:39:09', 11, 1),
(12, '10', 'precio inicial', '2018-01-18', '2018-01-16 16:39:09', 12, 1),
(13, '10', 'precio inicial', '2018-01-18', '2018-01-16 16:39:10', 13, 1),
(14, '10', 'precio inicial', '2018-01-18', '2018-01-16 16:39:10', 14, 1),
(15, '10', 'precio inicial', '2018-01-18', '2018-01-16 16:39:10', 15, 1),
(16, '10', 'precio inicial', '2018-01-18', '2018-01-16 16:39:11', 16, 1),
(17, '10', 'precio inicial', '2018-01-18', '2018-01-16 16:39:11', 17, 1),
(18, '10', 'precio inicial', '2018-01-18', '2018-01-16 16:39:12', 18, 1),
(19, '10', 'precio inicial', '2018-01-18', '2018-01-16 16:39:12', 19, 1),
(20, '10', 'precio inicial', '2018-01-18', '2018-01-16 16:39:12', 20, 1),
(21, '10', 'precio inicial', '2018-01-18', '2018-01-16 16:39:13', 21, 1),
(22, '10', 'precio inicial', '2018-01-18', '2018-01-16 16:39:13', 22, 1),
(23, '10', 'precio inicial', '2018-01-18', '2018-01-16 16:39:13', 23, 1),
(24, '10', 'precio inicial', '2018-01-18', '2018-01-16 16:39:14', 24, 1),
(25, '10', 'precio inicial', '2018-01-18', '2018-01-16 16:39:14', 25, 1),
(26, '10', 'precio inicial', '2018-01-18', '2018-01-16 16:39:15', 26, 1),
(27, '10', 'precio inicial', '2018-01-18', '2018-01-16 16:39:15', 27, 1),
(28, '10', 'precio inicial', '2018-01-18', '2018-01-16 16:39:15', 28, 1),
(29, '10', 'precio inicial', '2018-01-18', '2018-01-16 16:39:16', 29, 1),
(30, '10', 'precio inicial', '2018-01-18', '2018-01-16 16:39:16', 30, 1),
(31, '10', 'precio inicial', '2018-01-18', '2018-01-16 16:39:16', 31, 1),
(32, '10', 'precio inicial', '2018-01-18', '2018-01-16 16:39:17', 32, 1),
(33, '10', 'precio inicial', '2018-01-18', '2018-01-16 16:39:17', 33, 1),
(34, '10', 'precio inicial', '2018-01-18', '2018-01-16 16:39:17', 34, 1),
(35, '10', 'precio inicial', '2018-01-18', '2018-01-16 16:39:18', 35, 1),
(36, '10', 'precio inicial', '2018-01-18', '2018-01-16 16:39:18', 36, 1),
(37, '10', 'precio inicial', '2018-01-18', '2018-01-16 16:39:19', 37, 1),
(38, '10', 'precio inicial', '2018-01-18', '2018-01-16 16:39:19', 38, 1),
(39, '10', 'precio inicial', '2018-01-18', '2018-01-16 16:39:19', 39, 1),
(40, '10', 'precio inicial', '2018-01-18', '2018-01-16 16:39:20', 40, 1),
(41, '10', 'precio inicial', '2018-01-18', '2018-01-16 16:39:20', 41, 1),
(42, '10', 'precio inicial', '2018-01-18', '2018-01-16 16:39:20', 42, 1),
(43, '10', 'precio inicial', '2018-01-18', '2018-01-16 16:39:21', 43, 1),
(44, '10', 'precio inicial', '2018-01-18', '2018-01-16 16:39:21', 44, 1),
(45, '10', 'precio inicial', '2018-01-18', '2018-01-16 16:39:21', 45, 1),
(46, '10', 'precio inicial', '2018-01-18', '2018-01-16 16:39:22', 46, 1),
(47, '10', 'precio inicial', '2018-01-18', '2018-01-16 16:39:22', 47, 1),
(48, '10', 'precio inicial', '2018-01-18', '2018-01-16 16:39:22', 48, 1),
(49, '10', 'precio inicial', '2018-01-18', '2018-01-16 16:39:23', 49, 1),
(50, '10', 'precio inicial', '2018-01-18', '2018-01-16 16:39:23', 50, 1),
(51, '10', 'precio inicial', '2018-01-18', '2018-01-16 16:39:24', 51, 1);

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
  `suc_matriz` int(11) DEFAULT NULL,
  `suc_nombreCorto` varchar(3) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `sucursal`
--

INSERT INTO `sucursal` (`idSucursal`, `suc_nombre`, `suc_descripcion`, `suc_estatus`, `idEmpresa`, `suc_matriz`, `suc_nombreCorto`) VALUES
(1, 'Actopan', 'Actopan Hidalgo', 1, 1, 1, 'AC'),
(2, 'Ixmiquilpan', 'Ixmiquilpan Hidalgo', 1, 1, 0, 'IX'),
(3, 'Atotonilco', 'Atotonilco Hidalgo', 1, 1, 0, 'AT');

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
(4, 'Ajuste', 1),
(5, 'Inventario', 1);

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
(4, 'Ajuste', 1),
(5, 'Inventario', 1);

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
  `timestamp` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `traspaso`
--

INSERT INTO `traspaso` (`idTraspaso`, `idSucursalOrigen`, `idSucursalDestino`, `idUsuario`, `tra_observaciones`, `timestamp`) VALUES
(1, 1, 2, 1, 'ejemplo', '2018-01-31 00:03:19'),
(2, 2, 1, 1, 'ejemplo chingon', '2018-01-31 00:05:16');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `traspasocheckin`
--

CREATE TABLE `traspasocheckin` (
  `idTraspasoCheckIn` int(11) NOT NULL,
  `idTraspaso` int(11) NOT NULL,
  `idCheckIn` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `traspasocheckin`
--

INSERT INTO `traspasocheckin` (`idTraspasoCheckIn`, `idTraspaso`, `idCheckIn`) VALUES
(1, 2, 2);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `traspasocheckout`
--

CREATE TABLE `traspasocheckout` (
  `idTraspasoCheckOut` int(11) NOT NULL,
  `idTraspaso` int(11) NOT NULL,
  `idCheckOut` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `traspasocheckout`
--

INSERT INTO `traspasocheckout` (`idTraspasoCheckOut`, `idTraspaso`, `idCheckOut`) VALUES
(1, 1, 3);

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

--
-- Volcado de datos para la tabla `traspasodetalle`
--

INSERT INTO `traspasodetalle` (`idTraspasoDetalle`, `idStock`, `trde_cantidad`, `trde_observaciones`, `timestamp`, `idTraspaso`) VALUES
(1, 10, 5, 'ejemplo de entrada', '2018-01-31 00:05:17', 2);

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
(1, 'Octavio Reyes Ortega', 'asdeoros', 'qwerty', 1, 1, '2017-12-05 15:37:55', 1, '1'),
(2, 'Alejandro Grijalva', 'empleado', 'qwerty', 1, 3, '2018-01-07 20:09:28', 1, '1');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `venta`
--

CREATE TABLE `venta` (
  `idVenta` int(11) NOT NULL,
  `timestamp` datetime DEFAULT CURRENT_TIMESTAMP,
  `idCaja` int(11) NOT NULL,
  `idCheckOut` int(11) NOT NULL,
  `idCliente` int(11) NOT NULL,
  `ven_monto` float NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `venta`
--

INSERT INTO `venta` (`idVenta`, `timestamp`, `idCaja`, `idCheckOut`, `idCliente`, `ven_monto`) VALUES
(1, '2018-01-18 12:50:07', 5, 1, 1, 100),
(2, '2018-01-18 12:50:51', 5, 2, 1, 250),
(3, '2018-01-31 00:06:01', 5, 4, 1, 20),
(4, '2018-01-31 00:44:03', 5, 5, 1, 100),
(5, '2018-01-31 00:47:38', 6, 6, 1, 70),
(6, '2018-01-31 00:49:13', 6, 7, 1, 110),
(7, '2018-01-31 01:30:11', 7, 8, 1, 70),
(8, '2018-01-31 02:04:16', 8, 9, 1, 30),
(9, '2018-01-31 02:05:22', 9, 10, 1, 110),
(10, '2018-01-31 02:31:14', 10, 11, 1, 10),
(11, '2018-01-31 02:36:18', 11, 12, 1, 30),
(12, '2018-01-31 02:36:43', 11, 13, 1, 40),
(13, '2018-01-31 02:37:02', 11, 14, 1, 50),
(14, '2018-01-31 02:43:27', 12, 15, 1, 40),
(15, '2018-01-31 02:43:55', 12, 16, 1, 40),
(16, '2018-01-31 02:47:35', 13, 17, 1, 150),
(17, '2018-01-31 02:50:23', 14, 18, 1, 40);

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
  ADD KEY `fk_cajadetalle_caja1_idx` (`idCaja`),
  ADD KEY `fk_gastos_gastostipo1_idx` (`idGastoTipo`);

--
-- Indices de la tabla `gastotipo`
--
ALTER TABLE `gastotipo`
  ADD PRIMARY KEY (`idGastoTipo`);

--
-- Indices de la tabla `inventario`
--
ALTER TABLE `inventario`
  ADD PRIMARY KEY (`idInventario`),
  ADD KEY `fk_inventario_sucursal1_idx` (`idSucursal`),
  ADD KEY `fk_inventario_empresa1_idx` (`idEmpresa`),
  ADD KEY `fk_inventario_usuario1_idx` (`idUsuario`);

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
  ADD KEY `fk_mezcla_checkin1_idx` (`idCheckIn`);

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
-- Indices de la tabla `stockaperturacaja`
--
ALTER TABLE `stockaperturacaja`
  ADD PRIMARY KEY (`idStockAperturaCaja`);

--
-- Indices de la tabla `stockhistorial`
--
ALTER TABLE `stockhistorial`
  ADD PRIMARY KEY (`idStockHistorial`),
  ADD KEY `fk_stokhistorial_stock1_idx` (`idStock`),
  ADD KEY `fk_stockhistorial_inventario1_idx` (`idInventario`);

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
  MODIFY `idCaja` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;
--
-- AUTO_INCREMENT de la tabla `catalogousuario`
--
ALTER TABLE `catalogousuario`
  MODIFY `idCatalogoUsuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;
--
-- AUTO_INCREMENT de la tabla `checkin`
--
ALTER TABLE `checkin`
  MODIFY `idCheckIn` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
--
-- AUTO_INCREMENT de la tabla `checkindetalle`
--
ALTER TABLE `checkindetalle`
  MODIFY `idCheckInDetalle` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=53;
--
-- AUTO_INCREMENT de la tabla `checkout`
--
ALTER TABLE `checkout`
  MODIFY `idCheckOut` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;
--
-- AUTO_INCREMENT de la tabla `checkoutdetalle`
--
ALTER TABLE `checkoutdetalle`
  MODIFY `idCheckOutDetalle` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=42;
--
-- AUTO_INCREMENT de la tabla `cliente`
--
ALTER TABLE `cliente`
  MODIFY `idCliente` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
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
  MODIFY `idGastos` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT de la tabla `gastotipo`
--
ALTER TABLE `gastotipo`
  MODIFY `idGastoTipo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;
--
-- AUTO_INCREMENT de la tabla `inventario`
--
ALTER TABLE `inventario`
  MODIFY `idInventario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT de la tabla `listaprecio`
--
ALTER TABLE `listaprecio`
  MODIFY `idListaPrecio` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT de la tabla `mezcla`
--
ALTER TABLE `mezcla`
  MODIFY `idMezcla` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT de la tabla `precio`
--
ALTER TABLE `precio`
  MODIFY `idPrecio` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=52;
--
-- AUTO_INCREMENT de la tabla `producto`
--
ALTER TABLE `producto`
  MODIFY `idProducto` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=55;
--
-- AUTO_INCREMENT de la tabla `stock`
--
ALTER TABLE `stock`
  MODIFY `idStock` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=52;
--
-- AUTO_INCREMENT de la tabla `stockaperturacaja`
--
ALTER TABLE `stockaperturacaja`
  MODIFY `idStockAperturaCaja` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=505;
--
-- AUTO_INCREMENT de la tabla `stockhistorial`
--
ALTER TABLE `stockhistorial`
  MODIFY `idStockHistorial` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=52;
--
-- AUTO_INCREMENT de la tabla `sucursal`
--
ALTER TABLE `sucursal`
  MODIFY `idSucursal` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;
--
-- AUTO_INCREMENT de la tabla `tipocheckin`
--
ALTER TABLE `tipocheckin`
  MODIFY `idTipoCheckIn` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;
--
-- AUTO_INCREMENT de la tabla `tipocheckout`
--
ALTER TABLE `tipocheckout`
  MODIFY `idTipoCheckOut` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;
--
-- AUTO_INCREMENT de la tabla `traspaso`
--
ALTER TABLE `traspaso`
  MODIFY `idTraspaso` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
--
-- AUTO_INCREMENT de la tabla `traspasocheckin`
--
ALTER TABLE `traspasocheckin`
  MODIFY `idTraspasoCheckIn` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT de la tabla `traspasocheckout`
--
ALTER TABLE `traspasocheckout`
  MODIFY `idTraspasoCheckOut` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT de la tabla `traspasodetalle`
--
ALTER TABLE `traspasodetalle`
  MODIFY `idTraspasoDetalle` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT de la tabla `usuario`
--
ALTER TABLE `usuario`
  MODIFY `idUsuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
--
-- AUTO_INCREMENT de la tabla `venta`
--
ALTER TABLE `venta`
  MODIFY `idVenta` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;
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
  ADD CONSTRAINT `fk_cajadetalle_caja1` FOREIGN KEY (`idCaja`) REFERENCES `caja` (`idCaja`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_gastos_gastostipo1` FOREIGN KEY (`idGastoTipo`) REFERENCES `gastotipo` (`idGastoTipo`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `inventario`
--
ALTER TABLE `inventario`
  ADD CONSTRAINT `fk_inventario_empresa1` FOREIGN KEY (`idEmpresa`) REFERENCES `empresa` (`idEmpresa`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_inventario_sucursal1` FOREIGN KEY (`idSucursal`) REFERENCES `sucursal` (`idSucursal`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_inventario_usuario1` FOREIGN KEY (`idUsuario`) REFERENCES `usuario` (`idUsuario`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `listaprecio`
--
ALTER TABLE `listaprecio`
  ADD CONSTRAINT `fk_listaprecio_empresa1` FOREIGN KEY (`idEmpresa`) REFERENCES `empresa` (`idEmpresa`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `mezcla`
--
ALTER TABLE `mezcla`
  ADD CONSTRAINT `fk_mezcla_checkin1` FOREIGN KEY (`idCheckIn`) REFERENCES `checkin` (`idCheckIn`) ON DELETE NO ACTION ON UPDATE NO ACTION,
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
  ADD CONSTRAINT `fk_stockhistorial_inventario1` FOREIGN KEY (`idInventario`) REFERENCES `inventario` (`idInventario`) ON DELETE NO ACTION ON UPDATE NO ACTION,
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
