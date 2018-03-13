<?php
class Producto
{
	var $Return_Type;
	var $conn;

	var $idEmpresa;
	var $idProducto;
	var $idSucursal;

	var $pro_sku;
	var $pro_nombre;
	var $pro_descripcion;
	var $pro_unidad;

	public function __construct( $Class_Properties = array() ) {
		$this->Assign_Properties_Values($Class_Properties);
		$this->conn = new Connection();
		$this->Return_Type = 'json';
	}

	public function muestra(){
		$_response['success'] = false;
		if( empty( $this->idEmpresa )){
			$_response['msg']     	= 'No se ha proporcionado el id de la empresa.';
		}
		else{
			$params = array('empresa' => array( 'value' => $this->idEmpresa, 'type' => 'INT' ) );
			$_result = $this->conn->Query( "PRODUCTOMUESTRA_SP", $params );
			
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

	public function precioventa(){
		$_response['success'] = false;
		if( empty( $this->idSucursal )){
			$_response['msg']     	= 'No se ha proporcionado el id de la Sucursal.';
		}
		else{
			$params = array('idSucursal' => array( 'value' => $this->idSucursal, 'type' => 'INT' ) );
			$_result = $this->conn->Query( "PRODUCTOPRECIOVENTA_SP", $params );
			
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

	public function nuevo(){
		$_response['success'] = false;
		if( empty( $this->idEmpresa )){
			$_response['msg']     	= 'No se ha proporcionado el id de la empresa.';
		}
		else if( empty( $this->pro_nombre ) ){
			$_response['msg']     	= 'Proporciona el nombre del producto.';
		}
		else if( empty( $this->pro_descripcion ) ){
			$_response['msg']     	= 'Proporciona una descripción del producto.';
		}
		else if( empty( $this->pro_unidad ) ){
			$_response['msg']     	= 'Proporciona la unidad de medida del producto.';
		}
		else{
			$params = array(
					'sku' 			=> array( 'value' => $this->pro_sku, 		 'type' => 'STRING' ),
					'nombre' 		=> array( 'value' => $this->pro_nombre, 	 'type' => 'STRING' ),
					'descripcion' 	=> array( 'value' => $this->pro_descripcion, 'type' => 'STRING' ),
					'unidad' 		=> array( 'value' => $this->pro_unidad, 	 'type' => 'STRING' ),
					'empresa' 		=> array( 'value' => $this->idEmpresa, 	 'type' => 'INT' )
				);

			$_result = $this->conn->Query( "PRODUCTONUEVO_SP", $params );
			
			if( !empty( $_result ) ){
				$_response['success'] 	= true;
				$_response['msg']     	= 'Se ha registrado un nuevo producto.';
			}
			else{
				$_response['msg']     	= 'Ha ocurrido un error no controlado.';	
			}			
		}
		
		return $this->Request( $_response );
	}

	public function editar(){
		$_response['success'] = false;
		if( empty( $this->idProducto )){
			$_response['msg']     	= 'No se ha proporcionado el id del producto.';
		}
		else if( empty( $this->pro_nombre ) ){
			$_response['msg']     	= 'Proporciona el nombre del producto.';
		}
		else if( empty( $this->pro_descripcion ) ){
			$_response['msg']     	= 'Proporciona una descripción del producto.';
		}
		else if( empty( $this->pro_unidad ) ){
			$_response['msg']     	= 'Proporciona la unidad de medida del producto.';
		}
		else{
			$params = array(
					'sku' 			=> array( 'value' => $this->pro_sku, 		 'type' => 'STRING' ),
					'nombre' 		=> array( 'value' => $this->pro_nombre, 	 'type' => 'STRING' ),
					'descripcion' 	=> array( 'value' => $this->pro_descripcion, 'type' => 'STRING' ),
					'unidad' 		=> array( 'value' => $this->pro_unidad, 	 'type' => 'STRING' ),
					'productoID' 	=> array( 'value' => $this->idProducto,  	 'type' => 'INT' )
				);

			$_result = $this->conn->Query( "PRODUCTOEDITAR_SP", $params );
			
			if( !empty( $_result ) ){
				$_response['success'] 	= true;
				$_response['msg']     	= 'Se ha editado un producto con exito.';
			}
			else{
				$_response['msg']     	= 'Ha ocurrido un error no controlado.';	
			}			
		}
		
		return $this->Request( $_response );
	}

	public function eliminar(){
		$_response['success'] = false;
		if( empty( $this->idProducto )){
			$_response['msg']     	= 'No se ha proporcionado el id del producto.';
		}
		else{
			$params = array('producto' => array( 'value' => $this->idProducto, 'type' => 'INT' ) );

			$_result = $this->conn->Query( "PRODUCTOELIMINAR_SP", $params );
			
			if( !empty( $_result ) ){
				$_response['success'] 	= true;
				$_response['msg']     	= 'Se ha eliminado un producto de forma correcta.';
			}
			else{
				$_response['msg']     	= 'Ha ocurrido un error no controlado.';	
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