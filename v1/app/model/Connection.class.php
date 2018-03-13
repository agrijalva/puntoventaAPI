<?php
	class Connection{
		// Datos de conexión de MySQL Server
		var $mysqli;
		var $BaseDatos;
		var $Servidor;
		var $Usuario;
		var $Clave;
			
		var $conf;
		function Connection(){
			$this->Servidor  = DB_HOST;
			$this->Usuario 	 = DB_USERNAME;
			$this->Clave	 = DB_PASSWORD;
			$this->BaseDatos = DB_NAME;
		}

		 function conectar() {
			$mysqli = new mysqli( $this->Servidor, $this->Usuario, $this->Clave, $this->BaseDatos);
			if ( $mysqli->connect_errno ) {
			    echo "Falló la conexión a MySQL: (" . $mysqli->connect_errno . ") " . $mysqli->connect_error;
				$this->mysqli = false;
			    dead();
			}
			else{
				$this->mysqli = $mysqli;
			}

			return true;
		}

		function Query( $sp, $params ){
			if( $this->conectar() ){
				$str_parametros = $this->FormatParams( $params );
				$stored = "CALL " . $sp . "(" . $str_parametros . ");"; // echo $stored;
				$datos = $this->mysqli->query( $stored );

				if (!$datos) {
				    printf("Errormessage: %s\n", $this->mysqli->error);
				    $registros = false;
				}
				else{
					$registros = array();
					while ($fila = $datos->fetch_assoc()) {
						$registros[] = $fila;
					}

					if (empty($registros)){
						$registros = array();
					}
				}

				return $registros;
			}
		}

		private function FormatParams(  $params ){
			$aux = array();
			if( !empty( $params ) ){
				foreach ($params as $key => $item) {
					if( $item['type'] == 'INT' ){
						$aux[] = $item['value'];
					}
					else{
						$aux[] = "'". $item['value'] ."'";	
					}
				}

				return implode(",", $aux);
			}
			else{
				return '';
			}
		}
	}
?>