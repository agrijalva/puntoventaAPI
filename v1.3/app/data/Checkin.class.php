<?php
class Checkin
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
	var $idCheckIn;

	var $Tipo; 
	var $sucOrigen;
	var $sucDestino;

	var $CheckId;
	var $idTraspado;

	var $idCheckOut;
	var $cod_cantidad;
	var $cod_observaciones;

	public function __construct( $Class_Properties = array() ) {
		$this->Assign_Properties_Values($Class_Properties);
		$this->conn = new Connection();
		$this->Return_Type = 'json';
	}

	public function entradacabecera(){
		$_response['success'] = false;
		if( empty( $this->cho_descripcion )){
			$_response['msg']     	= 'Es necesario proporcionar una observación.';
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
		else{
			$params = array(
					'cho_descripcion' 	=> array( 'value' => $this->cho_descripcion, 	'type' => 'STRING' ),
					'idUsuario' 		=> array( 'value' => $this->idUsuario, 	 		'type' => 'STRING' ),
					'idEmpresa' 		=> array( 'value' => $this->idEmpresa, 			'type' => 'STRING' ),
					'idSucursal' 		=> array( 'value' => $this->idSucursal, 	 	'type' => 'STRING' )
				);

			$_result = $this->conn->Query( "ENTRADACABECERA_SP", $params );
			
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

	public function entradadetalle(){
		$_response['success'] = false;
		if( empty( $this->idCheckIn )){
			$_response['msg']     	= 'Proporciona la descripción.';
		}
		else if( empty( $this->idProducto ) ){
			$_response['msg']     	= 'Proporciona el idUsuario.';
		}
		else if( empty( $this->cod_cantidad ) ){
			$_response['msg']     	= 'Proporciona la empresa';
		}
		else{
			$params = array(
					'CheckIn' 		=> array( 'value' => $this->idCheckIn, 			'type' => 'INT' ),
					'Producto' 		=> array( 'value' => $this->idProducto, 	 	'type' => 'INT' ),
					'cantidad' 		=> array( 'value' => $this->cod_cantidad, 		'type' => 'INT' ),
					'observaciones'	=> array( 'value' => $this->cod_observaciones, 	'type' => 'STRING' )
				);

			$_result = $this->conn->Query( "ENTRADADETALLE_SP", $params );
			
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

	public function traspasocabecera(){
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
		else if( $this->Tipo == '' ){
			$_response['msg']     	= 'Proporciona la tipo.';
		}
		else if( empty( $this->sucOrigen ) ){
			$_response['msg']     	= 'Proporciona la origen.';
		}
		else if( empty( $this->sucDestino ) ){
			$_response['msg']     	= 'Proporciona la destino.';
		}
		else{
			$params = array(
					'cho_descripcion' 	=> array( 'value' => $this->cho_descripcion, 	'type' => 'STRING' ),
					'idUsuario' 		=> array( 'value' => $this->idUsuario, 	 		'type' => 'STRING' ),
					'idEmpresa' 		=> array( 'value' => $this->idEmpresa, 			'type' => 'STRING' ),
					'idSucursal' 		=> array( 'value' => $this->idSucursal, 	 	'type' => 'STRING' ),
					'Tipo' 				=> array( 'value' => $this->Tipo, 	 			'type' => 'INT' ),
					'sucOrigen' 		=> array( 'value' => $this->sucOrigen, 			'type' => 'INT' ),
					'sucDestino' 		=> array( 'value' => $this->sucDestino, 	 	'type' => 'INT' )
				);

			$_result = $this->conn->Query( "TRASPASOCABECERA_SP", $params );
			
			if( !empty( $_result ) ){
				$_response['success'] 	= true;
				$_response['msg']     	= 'Se ha registrado un nuevo producto.';
				$_response['LastId']    = $_result[0]['LastId'];
				$_response['folio']     = $_result[0]['folio'];
				$_response['Traspaso']  = $_result[0]['Traspaso'];
			}
			else{
				$_response['msg']     	= 'Ha ocurrido un error no controlado.';	
			}			
		}
		
		return $this->Request( $_response );
	}

	public function traspasodadetalle(){
		$_response['success'] = false;
		if( empty( $this->CheckId )){
			$_response['msg']     	= 'Proporciona la CheckId.';
		}
		else if( empty( $this->idProducto ) ){
			$_response['msg']     	= 'Proporciona el idProducto.';
		}
		else if( empty( $this->cod_cantidad ) ){
			$_response['msg']     	= 'Proporciona la cantidad';
		}
		else{
			$params = array(
					'CheckId' 		=> array( 'value' => $this->CheckId, 			'type' => 'INT' ),
					'Producto' 		=> array( 'value' => $this->idProducto, 	 	'type' => 'INT' ),
					'cantidad' 		=> array( 'value' => $this->cod_cantidad, 		'type' => 'INT' ),
					'observaciones'	=> array( 'value' => $this->cod_observaciones, 	'type' => 'STRING' ),
					'Tipo' 			=> array( 'value' => $this->Tipo, 	 			'type' => 'INT' ),
					'Traspado' 		=> array( 'value' => $this->idTraspado, 		'type' => 'INT' )
				);

			$_result = $this->conn->Query( "TRASPASODETALLE_SP", $params );
			
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

	public function mezclacabecera(){
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
		else{
			$params = array(
					'cho_descripcion' 	=> array( 'value' => $this->cho_descripcion, 	'type' => 'STRING' ),
					'idUsuario' 		=> array( 'value' => $this->idUsuario, 	 		'type' => 'INT' ),
					'idEmpresa' 		=> array( 'value' => $this->idEmpresa, 			'type' => 'INT' ),
					'idSucursal' 		=> array( 'value' => $this->idSucursal, 	 	'type' => 'INT' )
				);

			$_result = $this->conn->Query( "MEZCLACABECERA_SP", $params );
			
			if( !empty( $_result ) ){
				$_response['success'] 	 = true;
				$_response['msg']     	 = 'Se ha registrado un nuevo producto.';
				$_response['folio']      = $_result[0]['folio'];
				$_response['idCheckIn']  = $_result[0]['idCheckIn'];
				$_response['idCheckOut'] = $_result[0]['idCheckOut'];
			}
			else{
				$_response['msg']     	 = 'Ha ocurrido un error no controlado.';	
			}			
		}
		
		return $this->Request( $_response );
	}

	public function mezclaindetalle(){
		$_response['success'] = false;
		if( empty( $this->idCheckIn )){
			$_response['msg']     	= 'Proporciona la descripción.';
		}
		else if( empty( $this->idProducto ) ){
			$_response['msg']     	= 'Proporciona el idProducto.';
		}
		else if( empty( $this->cod_cantidad ) ){
			$_response['msg']     	= 'Proporciona la cantidad';
		}
		else{
			$params = array(
					'CheckIn' 		=> array( 'value' => $this->idCheckIn, 			'type' => 'INT' ),
					'Producto' 		=> array( 'value' => $this->idProducto, 	 	'type' => 'INT' ),
					'cantidad' 		=> array( 'value' => $this->cod_cantidad, 		'type' => 'INT' ),
					'observaciones' => array( 'value' => $this->cod_observaciones, 	'type' => 'STRING' )
				);

			$_result = $this->conn->Query( "MEZCLAINDETALLE_SP", $params );
			
			if( !empty( $_result ) ){
				$_response['success'] 	 = true;
				$_response['msg']     	 = 'Se ha registrado un nuevo producto.';
			}
			else{
				$_response['msg']     	 = 'Ha ocurrido un error no controlado.';	
			}			
		}
		
		return $this->Request( $_response );
	}

	public function mezclaoutdetalle(){
		$_response['success'] = false;
		if( empty( $this->idCheckOut )){
			$_response['msg']     	= 'Proporciona la descripción.';
		}
		else if( empty( $this->idProducto ) ){
			$_response['msg']     	= 'Proporciona el idProducto.';
		}
		else if( empty( $this->cod_cantidad ) ){
			$_response['msg']     	= 'Proporciona la cantidad';
		}
		else{
			$params = array(
					'CheckOut' 		=> array( 'value' => $this->idCheckOut, 		'type' => 'INT' ),
					'Producto' 		=> array( 'value' => $this->idProducto, 	 	'type' => 'INT' ),
					'cantidad' 		=> array( 'value' => $this->cod_cantidad, 		'type' => 'INT' ),
					'observaciones' => array( 'value' => $this->cod_observaciones, 	'type' => 'STRING' )
				);

			$_result = $this->conn->Query( "MEZCLAOUTDETALLE_SP", $params );
			
			if( !empty( $_result ) ){
				$_response['success'] 	 = true;
				$_response['msg']     	 = 'Se ha registrado un nuevo producto.';
			}
			else{
				$_response['msg']     	 = 'Ha ocurrido un error no controlado.';	
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