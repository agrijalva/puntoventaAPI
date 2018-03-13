<?php
class Checkout
{
	var $Return_Type;
	var $conn;

	var $cho_descripcion;
	var $idUsuario;
	var $idEmpresa;
	var $idSucursal;
	var $idCaja;
	var $idCliente;
	var $ven_monto;
	var $idProducto;
	var $idCheckOut;

	public function __construct( $Class_Properties = array() ) {
		$this->Assign_Properties_Values($Class_Properties);
		$this->conn = new Connection();
		$this->Return_Type = 'json';
	}

	public function ventacabecera(){
		$_response['success'] = false;
		if( empty( $this->cho_descripcion )){
			$_response['msg']     	= 'Proporciona la descripción.';
		}
		else if( empty( $this->idUsuario ) ){
			$_response['msg']     	= 'Proporciona el idUsuario.';
		}
		else if( empty( $this->idEmpresa ) ){
			$_response['msg']     	= 'Proporciona la empresa';
		}
		else if( empty( $this->idSucursal ) ){
			$_response['msg']     	= 'Proporciona la sucursal.';
		}
		else if( empty( $this->idCaja ) ){
			$_response['msg']     	= 'Proporciona el identificador de la caja.';
		}
		else if( empty( $this->idCliente ) ){
			$_response['msg']     	= 'Proporciona el cliente.';
		}
		else if( empty( $this->ven_monto ) ){
			$_response['msg']     	= 'Proporciona el monto de la veta.';
		}
		else{
			$params = array(
					'cho_descripcion' 	=> array( 'value' => $this->cho_descripcion, 	'type' => 'STRING' ),
					'idUsuario' 		=> array( 'value' => $this->idUsuario, 	 		'type' => 'STRING' ),
					'idEmpresa' 		=> array( 'value' => $this->idEmpresa, 			'type' => 'STRING' ),
					'idSucursal' 		=> array( 'value' => $this->idSucursal, 	 	'type' => 'STRING' ),
					'idCaja' 			=> array( 'value' => $this->idCaja, 	 		'type' => 'STRING' ),
					'idCliente' 		=> array( 'value' => $this->idCliente, 			'type' => 'STRING' ),
					'ven_monto' 		=> array( 'value' => $this->ven_monto, 	 		'type' => 'STRING' )
				);

			$_result = $this->conn->Query( "VENTACABECERA_SP", $params );
			
			if( !empty( $_result ) ){
				$_response['success'] 	= true;
				$_response['msg']     	= 'Se ha registrado un nuevo producto.';
				$_response['LastId']    = $_result[0]['LastId'];
				$_response['folio']     = $_result[0]['folio'];
			}
			else{
				$_response['msg']     	= 'Ha ocurrido un error no controlado.';	
			}			
		}
		
		return $this->Request( $_response );
	}

	public function ventadetalle(){
		$_response['success'] = false;
		if( empty( $this->idCheckOut )){
			$_response['msg']     	= 'Proporciona la descripción.';
		}
		else if( empty( $this->idProducto ) ){
			$_response['msg']     	= 'Proporciona el idUsuario.';
		}
		else if( empty( $this->cod_cantidad ) ){
			$_response['msg']     	= 'Proporciona la empresa';
		}
		else if( empty( $this->cod_precio ) ){
			$_response['msg']     	= 'Proporciona la sucursal.';
		}
		else{
			$params = array(
					'idCheckOut' 		=> array( 'value' => $this->idCheckOut, 		'type' => 'INT' ),
					'idProducto' 		=> array( 'value' => $this->idProducto, 	 	'type' => 'INT' ),
					'cod_cantidad' 		=> array( 'value' => $this->cod_cantidad, 		'type' => 'INT' ),
					'cod_precio' 		=> array( 'value' => $this->cod_precio, 	 	'type' => 'INT' ),
					'cod_observaciones'	=> array( 'value' => $this->cod_observaciones, 	'type' => 'STRING' )
				);

			$_result = $this->conn->Query( "VENTADETALLE_SP", $params );
			
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