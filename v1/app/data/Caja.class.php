<?php
class Caja
{
	var $Return_Type;
	var $conn;

	var $idEmpresa;
	var $idProducto;
	var $idSucursal;
	var $idUsuario;
	var $caja_monto;
	var $idCaja;
	var $tipo;

	public function __construct( $Class_Properties = array() ) {
		$this->Assign_Properties_Values($Class_Properties);
		$this->conn = new Connection();
		$this->Return_Type = 'json';
	}

	public function apertura(){
		$_response['success'] = false;
		if( empty( $this->idEmpresa )){
			$_response['msg']     	= 'No se ha proporcionado el id de la empresa.';
		}
		else if( empty( $this->idSucursal ) ){
			$_response['msg']     	= 'No se ha proporcionado el id de la sucursal.';
		}
		else if( empty( $this->idUsuario ) ){
			$_response['msg']     	= 'No se ha proporcionado el id del usuario.';
		}
		else if( !is_numeric( $this->caja_monto ) ){
			$_response['msg']     	= 'Asegurate de propocionar un monto correcto';
		}
		else if( $this->caja_monto < 0 ){
			$_response['msg']     	= 'Asegurate de propocionar un monto correcto';
		}
		else{
			$params = array(
					'idEmpresa' 	=> array( 'value' => $this->idEmpresa, 	'type' => 'INT' ),
					'idSucursal' 	=> array( 'value' => $this->idSucursal, 'type' => 'INT' ),
					'idUsuario' 	=> array( 'value' => $this->idUsuario, 	'type' => 'INT' ),
					'caja_monto' 	=> array( 'value' => $this->caja_monto, 'type' => 'INT' )
				);

			$_result = $this->conn->Query( "CAJAAPERTURA_SP", $params );
			
			if( !empty( $_result ) ){
				$_response['success'] 	= true;
				$_response['msg']     	= $_result[0]['msg'];
				$_response['LastId']   	= $_result[0]['LastId'];
			}
			else{
				$_response['msg']     	= 'Ha ocurrido un error no controlado.';	
			}			
		}
		
		return $this->Request( $_response );
	}

	public function resumen(){
		$_response['success'] = false;
		if( empty( $this->idCaja )){
			$_response['msg']     	= 'No se ha proporcionado el id de la caja.';
		}
		else{
			$params = array('idCaja' 	=> array( 'value' => $this->idCaja, 	'type' => 'INT' ) );

			$_result = $this->conn->Query( "CAJARESUMEN_SP", $params );
			
			if( !empty( $_result ) ){
				$_response['success'] 	= true;
				$_response['msg']     	= "Resumen de la caja";
				$_response['data']   	= $_result;
			}
			else{
				$_response['msg']     	= 'Ha ocurrido un error no controlado.';	
			}			
		}
		
		return $this->Request( $_response );
	}

	public function productosvendidos(){
		$_response['success'] = false;
		if( empty( $this->idCaja )){
			$_response['msg']     	= 'No se ha proporcionado el id de la caja.';
		}
		else{
			$params = array('idCaja' 	=> array( 'value' => $this->idCaja, 	'type' => 'INT' ) );

			$_result = $this->conn->Query( "PRODUCTOSVENDIDOS_SP", $params );
			
			if( !empty( $_result ) ){
				$_response['success'] 	= true;
				$_response['msg']     	= "Productos vendidos";
				$_response['data']   	= $_result;
			}
			else{
				$_response['msg']     	= 'Ha ocurrido un error no controlado.';	
			}			
		}
		
		return $this->Request( $_response );
	}

	public function cierre(){
		$_response['success'] = false;
		if( empty( $this->idCaja )){
			$_response['msg']     	= 'No se ha proporcionado el id de la caja.';
		}
		else if( empty( $this->tipo )){
			$_response['msg']     	= 'No se ha proporcionado el tipo de dato a obtener.';
		}
		else{
			$params = array(
				'idCaja'  => array( 'value' => $this->idCaja, 	'type' => 'INT' ),
				'tipo' 	  => array( 'value' => $this->tipo, 	'type' => 'INT' )
			);

			$_result = $this->conn->Query( "CAJACIERRE_SP", $params );
			
			if( !empty( $_result ) ){
				$_response['success'] 	= true;
				$_response['msg']     	= "Resumen de la caja";
				$_response['data']   	= $_result;
			}
			else{
				$_response['msg']     	= 'Ha ocurrido un error no controlado.';	
			}			
		}
		
		return $this->Request( $_response );
	}

	public function setfechacierre(){
		$_response['success'] = false;
		if( empty( $this->idCaja )){
			$_response['msg']     	= 'No se ha proporcionado el id de la caja.';
		}
		else{
			$params = array('idCaja'  => array( 'value' => $this->idCaja, 	'type' => 'INT' ) );

			$_result = $this->conn->Query( "CAJASETFECHA_SP", $params );
			
			if( !empty( $_result ) ){
				$_response['success'] 	= true;
				$_response['msg']     	= "Resumen de la caja";
				$_response['data']   	= $_result;
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