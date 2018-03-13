<?php
class Precio
{
	var $Return_Type;
	var $conn;

	var $lpr_nombre;
	var $lpr_descripcion;
	
	var $precioCompra;
	var $precioVenta;

	var $idEmpresa;
	var $idSucursal;
	var $idProducto;
	var $idListaPrecio;

	public function __construct( $Class_Properties = array() ) {
		$this->Assign_Properties_Values($Class_Properties);
		$this->conn = new Connection();
		$this->Return_Type = 'json';
	}

	public function listaspreciodetalle(){
		$_response['success'] = false;
		if( empty( $this->idListaPrecio )){
			$_response['msg']     	= 'No se ha proporcionado el id de la lista de precio.';
		}
		else{
			$params = array('idListaPrecio' => array( 'value' => $this->idListaPrecio, 'type' => 'INT' ) );
			$_result = $this->conn->Query( "LISTAPRECIO_SP", $params );
			
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

	public function listasprecio(){
		$_response['success'] = false;
		if( empty( $this->idEmpresa )){
			$_response['msg']     	= 'No se ha proporcionado el id de la empresa.';
		}
		else{
			$params = array('empresa' => array( 'value' => $this->idEmpresa, 'type' => 'INT' ) );
			$_result = $this->conn->Query( "LISTAPRECIOMUESTRA_SP", $params );
			
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

	public function listaprecionueva(){
		$_response['success'] = false;
		if( empty( $this->idEmpresa )){
			$_response['msg']     	= 'No se ha proporcionado el id de la empresa.';
		}
		else if( empty( $this->idSucursal ) ){
			$_response['msg']     	= 'No se ha proporcionado el id de la sucursal.';
		}
		else if( empty( $this->lpr_nombre ) ){
			$_response['msg']     	= 'Proporciona el nombre de la lista de precios.';
		}
		else if( empty( $this->lpr_descripcion ) ){
			$_response['msg']     	= 'Proporciona la descripción de la lista de precios.';
		}
		else{
			$params = array(
					'nombre' 		=> array( 'value' => $this->lpr_nombre, 	 'type' => 'STRING' ),
					'descripcion' 	=> array( 'value' => $this->lpr_descripcion, 'type' => 'STRING' ),
					'Empresa' 		=> array( 'value' => $this->idEmpresa, 	 	 'type' => 'INT' ),
					'Sucursal' 		=> array( 'value' => $this->idSucursal, 	 'type' => 'INT' )
				);

			$_result = $this->conn->Query( "LISTAPRECIONUEVO_SP", $params );
			
			if( !empty( $_result ) ){
				$_response['success'] 	= true;
				$_response['msg']     	= 'Se ha registrado una nueva lista de precios.';
				$_response['LastId']    = $_result[0]['LastId'];
			}
			else{
				$_response['msg']     	= 'Ha ocurrido un error no controlado.';	
			}			
		}
		
		return $this->Request( $_response );
	}

	public function listaprecioeditar(){
		$_response['success'] = false;
		if( empty( $this->idListaPrecio )){
			$_response['msg']     	= 'No se ha proporcionado el id del producto.';
		}
		else if( empty( $this->lpr_nombre ) ){
			$_response['msg']     	= 'Proporciona el nombre del producto.';
		}
		else if( empty( $this->lpr_descripcion ) ){
			$_response['msg']     	= 'Proporciona una descripción del producto.';
		}
		else{
			$params = array(
					'nombre' 		=> array( 'value' => $this->lpr_nombre, 	 'type' => 'STRING' ),
					'descripcion' 	=> array( 'value' => $this->lpr_descripcion, 'type' => 'STRING' ),
					'listaPrecio' 	=> array( 'value' => $this->idListaPrecio,   'type' => 'INT' )
				);

			$_result = $this->conn->Query( "LISTAPRECIOEDITAR_SP", $params );
			
			if( !empty( $_result ) ){
				$_response['success'] 	= true;
				$_response['msg']     	= 'Se ha editado una lista de precios de forma exitosa.';
			}
			else{
				$_response['msg']     	= 'Ha ocurrido un error no controlado.';	
			}			
		}
		
		return $this->Request( $_response );
	}

	public function listaprecioeliminar(){
		$_response['success'] = false;
		if( empty( $this->idListaPrecio )){
			$_response['msg']     	= 'No se ha proporcionado el id de la lista de precio.';
		}
		else{
			$params = array('listaPrecio' => array( 'value' => $this->idListaPrecio, 'type' => 'INT' ) );

			$_result = $this->conn->Query( "LISTAPRECIOELIMINAR_SP", $params );
			
			if( !empty( $_result ) ){
				$_response['success'] 	= true;
				$_response['msg']     	= 'Se ha eliminado una lista de precio de forma correcta.';
			}
			else{
				$_response['msg']     	= 'Ha ocurrido un error no controlado.';	
			}			
		}
		
		return $this->Request( $_response );
	}

	public function listaprecioregistrar(){
		$_response['success'] = false;
		if( empty( $this->idListaPrecio )){
			$_response['msg']     	= 'No se ha proporcionado el id de la empresa.';
		}
		else if( empty( $this->idProducto ) ){
			$_response['msg']     	= 'No se ha proporcionado el id de la sucursal.';
		}
		else if( $this->precioCompra == '' ){
			$_response['msg']     	= 'El precio de compra no puede esta vacío.';
		}
		else if( $this->precioVenta == '' ){
			$_response['msg']     	= 'El precio de venta no puede esta vacío.';
		}
		else{
			$params = array(
					'idListaPrecio' => array( 'value' => $this->idListaPrecio, 	 'type' => 'INT' ),
					'idProducto' 	=> array( 'value' => $this->idProducto, 	 'type' => 'INT' ),
					'precioCompra' 	=> array( 'value' => $this->precioCompra, 	 'type' => 'INT' ),
					'precioVenta' 	=> array( 'value' => $this->precioVenta, 	 'type' => 'INT' )
				);

			$_result = $this->conn->Query( "LISTAPRECIOREGISTRAR_SP", $params );
			
			if( !empty( $_result ) ){
				$_response['success'] 	= true;
				$_response['msg']     	= $_result[0]['msg'];
			}
			else{
				$_response['msg']     	= 'Ha ocurrido un error no controlado.';	
			}			
		}
		
		return $this->Request( $_response );
	}

	public function productoprecio(){
		$_response['success'] = false;
		if( empty( $this->idEmpresa )){
			$_response['msg']     	= 'No se ha proporcionado el id de la empresa.';
		}
		else{
			$params = array(
					'idListaPrecio' => array( 'value' => $this->idListaPrecio, 	 'type' => 'INT' ),
					'idEmpresa' 	=> array( 'value' => $this->idEmpresa, 	 	 'type' => 'INT' )
				);
			$_result = $this->conn->Query( "PRODUCTOPRECIO_SP", $params );
			
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

	public function activar(){
		$_response['success'] = false;
		if( empty($this->idListaPrecio)){
			$_response['msg'] = 'No se ha proporcionado el id de la lista de precios.';
		}
		else {
			$params = array( 'idListaPrecio' => array( 'value' => $this->idListaPrecio, 'type' => 'INT' ) );
			$_result = $this->conn->Query( "LISTAPRECIOACTIVAR_SP", $params );
			
			if( !empty( $_result ) ){
				$_response['success'] 	= true;
				$_response['msg']     	= $_result[0]['msg'];
			}
			else{
				$_response['msg']     	= 'Ocurrio un error.';	
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