<?php
class Gasto
{
	var $Return_Type;
	var $conn;

	var $idUsuario;
	var $idEmpresa;
	var $idSucursal;
	var $idCaja;

	var $monto; 
	var $caja;
	var $descripcion;
	var $gastoTipo;

	public function __construct( $Class_Properties = array() ) {
		$this->Assign_Properties_Values($Class_Properties);
		$this->conn = new Connection();
		$this->Return_Type = 'json';
	}

	public function tipo(){
		$params = array();

		$_result = $this->conn->Query( "GASTOTIPO_SP", $params );
		
		if( !empty( $_result ) ){
			$_response['success'] 	= true;
			$_response['msg']     	= "Se encontraron " . count($_result) . " resultados.";
			$_response['data']     	= $_result;
		}
		else{
			$_response['msg']     	= 'Ha ocurrido un error no controlado.';	
		}	
		
		return $this->Request( $_response );
	}

	public function registro(){
		$_response['success'] = false;
		if( empty( $this->monto )){
			$_response['msg']     	= 'Proporciona el monto del gasto.';
		}
		else if( empty( $this->caja ) ){
			$_response['msg']     	= 'Proporciona el id de la caja.';
		}
		else if( empty( $this->descripcion ) ){
			$_response['msg']     	= 'Proporciona el motivo del gasto';
		}
		else if( empty( $this->gastoTipo ) ){
			$_response['msg']     	= 'Proporciona el tipo de gasto.';
		}
		else{
			$params = array(
					'monto' 		=> array( 'value' => $this->monto, 			'type' => 'STRING' ),
					'caja' 			=> array( 'value' => $this->caja, 	 		'type' => 'STRING' ),
					'descripcion' 	=> array( 'value' => $this->descripcion, 	'type' => 'STRING' ),
					'gastoTipo' 	=> array( 'value' => $this->gastoTipo, 	 	'type' => 'STRING' )
				);

			$_result = $this->conn->Query( "GASTOREGISTRO_SP", $params );
			
			if( !empty( $_result ) ){
				$_response['success'] 	= true;
				$_response['msg']     	= $_result[0]['msg'];
				$_response['LastId']    = $_result[0]['LastId'];
			}
			else{
				$_response['msg']     	= 'Ha ocurrido un error no controlado.';	
			}			
		}
		
		return $this->Request( $_response );
	}

	// public function ventadetalle(){
	// 	$_response['success'] = false;
	// 	if( empty( $this->idCheckOut )){
	// 		$_response['msg']     	= 'Proporciona la descripción.';
	// 	}
	// 	else if( empty( $this->idProducto ) ){
	// 		$_response['msg']     	= 'Proporciona el idUsuario.';
	// 	}
	// 	else if( empty( $this->cod_cantidad ) ){
	// 		$_response['msg']     	= 'Proporciona la empresa';
	// 	}
	// 	else if( empty( $this->cod_precio ) ){
	// 		$_response['msg']     	= 'Proporciona la sucursal.';
	// 	}
	// 	else{
	// 		$params = array(
	// 				'idCheckOut' 		=> array( 'value' => $this->idCheckOut, 		'type' => 'INT' ),
	// 				'idProducto' 		=> array( 'value' => $this->idProducto, 	 	'type' => 'INT' ),
	// 				'cod_cantidad' 		=> array( 'value' => $this->cod_cantidad, 		'type' => 'INT' ),
	// 				'cod_precio' 		=> array( 'value' => $this->cod_precio, 	 	'type' => 'INT' ),
	// 				'cod_observaciones'	=> array( 'value' => $this->cod_observaciones, 	'type' => 'STRING' )
	// 			);

	// 		$_result = $this->conn->Query( "VENTADETALLE_SP", $params );
			
	// 		if( !empty( $_result ) ){
	// 			$_response['success'] 	= true;
	// 			$_response['msg']     	= $_result[0]['msg'];
	// 		}
	// 		else{
	// 			$_response['msg']     	= 'Ha ocurrido un error no controlado.';	
	// 		}			
	// 	}
		
	// 	return $this->Request( $_response );
	// }

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