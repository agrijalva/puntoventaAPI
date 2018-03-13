<?php
class Inventario
{
	var $Return_Type;
	var $conn;

	var $inv_nombre;
	var $inv_descripcion;

	var $cantidad;
	var $descripcion;

	var $idEmpresa;
	var $idSucursal;
	var $idProducto;
	var $idUsuario;
	var $idInventario;

	public function __construct( $Class_Properties = array() ) {
		$this->Assign_Properties_Values($Class_Properties);
		$this->conn = new Connection();
		$this->Return_Type = 'json';
	}

	public function detalle(){
		$_response['success'] = false;
		if( empty( $this->idInventario )){
			$_response['msg']     	= 'No se ha proporcionado el id del inventario.';
		}
		else{
			$params = array('idInventario' => array( 'value' => $this->idInventario, 'type' => 'INT' ) );
			$_result = $this->conn->Query( "INVENTARIODETALLE_SP", $params );
			
			if( !empty( $_result ) ){
				$_response['success'] 	= true;
				$_response['msg']     	= 'Registros encontrados: ' . count( $_result );
				$_response['data'] 		= $_result;
			}
			else{
				$_response['msg']     	= 'No se encontraron registros.';	
			}			
		}
		
		return $this->Request( $_response );
	}

	public function mostrar(){
		$_response['success'] = false;
		if( empty( $this->idEmpresa )){
			$_response['msg']     	= 'No se ha proporcionado el id de la empresa.';
		}
		else{
			$params = array('idEmpresa' => array( 'value' => $this->idEmpresa, 'type' => 'INT' ) );
			$_result = $this->conn->Query( "INVENTARIOMUESTRA_SP", $params );
			
			if( !empty( $_result ) ){
				$_response['success'] 	= true;
				$_response['msg']     	= 'Registros encontrados: ' . count( $_result );
				$_response['data'] 		= $_result;
			}
			else{
				$_response['msg']     	= 'No se encontraron registros.';	
			}			
		}
		
		return $this->Request( $_response );
	}

	public function stockInventario(){
		$_response['success'] = false;
		if( empty( $this->idEmpresa )){
			$_response['msg']     	= 'No se ha proporcionado el id de la empresa.';
		}
		else{
			$params = array(
				'idEmpresa'  => array( 'value' => $this->idEmpresa, 'type' => 'INT' ),
				'idSucursal' => array( 'value' => $this->idSucursal, 'type' => 'INT' )
			 );
			$_result = $this->conn->Query( "PRODUCTOINVENTARIOINIT_SP", $params );
			
			if( !empty( $_result ) ){
				$_response['success'] 	= true;
				$_response['msg']     	= 'Registros encontrados: ' . count( $_result );
				$_response['data'] 		= $_result;
			}
			else{
				$_response['msg']     	= 'No se encontraron registros.';	
			}			
		}
		
		return $this->Request( $_response );
	}

	public function  aperturar(){
		$_response['success'] = false;
		if( empty($this->inv_nombre)){
			$_response['msg'] = 'No se ha proporcionado el titulo del inventario.';
		}
		else if( empty($this->inv_descripcion)){
			$_response['msg'] = 'Se necesita una descripción para el inventario.';
		}
		else if( empty($this->idSucursal)){
			$_response['msg'] = 'No se ha proporcionado el id de la sucursal.';
		}
		else if( empty($this->idEmpresa)){
			$_response['msg'] = 'No se ha proporcionado el id de la empresa.';
		}
		else if( empty($this->idUsuario)){
			$_response['msg'] = 'No se ha proporcionado el id del usuario.';
		}
		else {
			$params = array(
				'inv_nombre' 		=> array( 'value' => $this->inv_nombre, 		'type' => 'STRING' ),
				'inv_descripcion' 	=> array( 'value' => $this->inv_descripcion, 	'type' => 'STRING' ),
				'idSucursal' 		=> array( 'value' => $this->idSucursal, 		'type' => 'INT' ),
				'idEmpresa' 		=> array( 'value' => $this->idEmpresa, 			'type' => 'INT' ),
				'idUsuario' 		=> array( 'value' => $this->idUsuario, 			'type' => 'INT' )
			);
			$_result = $this->conn->Query( "INVENTARIONUEVO_SP", $params );
			
			if( !empty( $_result ) ){
				$_response['success'] 	= true;
				$_response['msg']     	= 'Se ha abierto un inventario nuevo.';
				$_response['LastId'] 	= $_result[0]['LastId'];
			}
			else{
				$_response['msg']     	= 'No se encontraron registros.';	
			}
		}
		
		return $this->Request( $_response );
	}

	public function  modificar(){
		$_response['success'] = false;
		if( empty($this->inv_nombre)){
			$_response['msg'] = 'No se ha proporcionado el titulo del inventario.';
		}
		else if( empty($this->inv_descripcion)){
			$_response['msg'] = 'Se necesita una descripción para el inventario.';
		}
		else if( empty($this->idInventario)){
			$_response['msg'] = 'No se ha proporcionado el id del inventario.';
		}
		else {
			$params = array(
				'idInventario' 		=> array( 'value' => $this->idInventario, 		'type' => 'INT' ),
				'inv_nombre' 		=> array( 'value' => $this->inv_nombre, 		'type' => 'STRING' ),
				'inv_descripcion' 	=> array( 'value' => $this->inv_descripcion, 	'type' => 'STRING' )
			);
			$_result = $this->conn->Query( "INVENTARIOEDITAR_SP", $params );
			
			if( !empty( $_result ) ){
				$_response['success'] 	= true;
				$_response['msg']     	= 'Se ha actualizado la información del inventario.';
			}
			else{
				$_response['msg']     	= 'No se encontraron registros.';	
			}
		}
		
		return $this->Request( $_response );
	}

	public function  eliminar(){
		$_response['success'] = false;
		if( empty($this->idInventario)){
			$_response['msg'] = 'No se ha proporcionado el id del inventario.';
		}
		else {
			$params = array(
				'idInventario' 		=> array( 'value' => $this->idInventario, 		'type' => 'INT' )
			);
			$_result = $this->conn->Query( "INVENTARIOELIMINAR_SP", $params );
			
			if( !empty( $_result ) ){
				$_response['success'] 	= true;
				$_response['msg']     	= $_result[0]['msg'];
			}
			else{
				$_response['msg']     	= 'Ocurrio un error al cerrar el inventario.';	
			}
		}
		
		return $this->Request( $_response );
	}

	public function  cerrar(){
		$_response['success'] = false;
		if( empty($this->idInventario)){
			$_response['msg'] = 'No se ha proporcionado el id del inventario.';
		}
		else {
			$params = array(
				'idInventario' 		=> array( 'value' => $this->idInventario, 		'type' => 'INT' )
			);
			$_result = $this->conn->Query( "INVENTARIOCIERRE_SP", $params );
			
			if( !empty( $_result ) ){
				$_response['success'] 	= true;
				$_response['msg']     	= $_result[0]['msg'];
			}
			else{
				$_response['msg']     	= 'Ocurrio un error al cerrar el inventario.';	
			}
		}
		
		return $this->Request( $_response );
	}

	public function registrarInventario(){
		$_response['success'] = false;
		if( empty($this->idInventario)){
			$_response['msg'] = 'No se ha proporcionado el id del inventario.';
		}
		else if( empty($this->descripcion)){
			$_response['msg'] = 'Se necesita una descripción para el inventario.';
		}
		else if( $this->cantidad == '' ){
			$_response['msg'] = 'Proporcione una cantidad para este producto.';
		}
		else if( empty($this->idProducto)){
			$_response['msg'] = 'Proporcione el id del prodcuto.';
		}
		else {
			$params = array(
				'inventario' 	=> array( 'value' => $this->idInventario, 	'type' => 'INT' ),
				'producto' 		=> array( 'value' => $this->idProducto, 	'type' => 'INT' ),
				'cantidad' 		=> array( 'value' => $this->cantidad, 		'type' => 'INT' ),
				'descripcion' 	=> array( 'value' => $this->descripcion, 	'type' => 'STRING' )
			);
			$_result = $this->conn->Query( "INVENTARIOREGISTRAR_SP", $params );
			
			if( !empty( $_result ) ){
				$_response['success'] 	= (int)$_result[0]['success'];
				$_response['msg']     	= ( (int)$_result[0]['success'] == 1 ) ? 'Cantidad registrada' : $_result[0]['msg'];
			}
			else{
				$_response['msg']     	= 'Ocurrio un error';	
			}
		}
		
		return $this->Request( $_response );
	}

	private function Assign_Properties_Values($Properties_Array){
		if (is_array($Properties_Array)) {
			foreach($Properties_Array as $Property_Name => $Property_Value)  {
				$this->{$Property_Name} = trim(htmlentities($Property_Value, ENT_QUOTES, 'UTF-8'));
			}
		}
	}

	private function Request( $_array ){
		if( empty( $this->Return_Type ) ){
			return $_array;			
		}
		else if( $this->Return_Type == 'json'  || $this->Return_Type == 'JSON' ){
			print_r( json_encode( $_array ) );
		}
	}
}
?>