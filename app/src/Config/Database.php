<?php
// config/Database.php

namespace App\Config;


require_once __DIR__ . '/../../vendor/autoload.php';
//require __DIR__ . '/app/vendor/autoload.php';

use Dotenv\Dotenv;
use PDO;
use PDOException;
use Exception;
use App\DTO\ApiResponseDTO;

class Database
{
    private static $instance = null;
    private $conn;

    private function __construct()
    {
        try {
            $dotenv = Dotenv::createImmutable(__DIR__ . '/../../');
            $dotenv->load();

            // Verifica si las variables de entorno están definidas
            if (!isset($_ENV['DB_HOST'], $_ENV['DB_NAME'], $_ENV['DB_USER'], $_ENV['DB_PASS'])) {
                throw new Exception('Faltan variables de entorno. Asegúrate de que el archivo .env esté configurado correctamente.');
            }

            $host = $_ENV['DB_HOST'];
            $db_name = $_ENV['DB_NAME'];
            $username = $_ENV['DB_USER'];
            $password = $_ENV['DB_PASS'];


            $this->conn = new PDO("mysql:host=$host;dbname=$db_name", $username, $password, [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
            ]);
        } catch (PDOException $e) {
            die("Error de conexión a la base de datos: " . $e->getMessage());
        }
    }

    // Retorna la instancia de la conexión
    public static function getInstance()
    {
        if (self::$instance === null) {
            self::$instance = new Database();
        }

        return self::$instance;
    }

    // Obtiene el objeto PDO
    public function getConnection()
    {
        return $this->conn;
    }

    // Cierra la conexión
    public function closeConnection()
    {
        $this->conn = null;
        self::$instance = null;
    }


    // Función auxiliar para ejecutar procedimientos almacenados
    public function executeProcedure(string $query, array $data): ApiResponseDTO
    {
        try {
            $v_data = json_encode($data);

            // Preparar y ejecutar la consulta
            $stmt = $this->conn->prepare($query);
            
            // Solo vincular si el parámetro :v_data existe en la consulta
            if (strpos($query, ':v_data') !== false) {
                $stmt->bindParam(':v_data', $v_data, PDO::PARAM_STR);
            }
            
            $stmt->execute();

            // Obtener el valor de la salida
            $result = $this->conn->query("SELECT @v_salida AS v_salida")->fetch(PDO::FETCH_ASSOC);

            if ($result['v_salida'] === null) {
                return new ApiResponseDTO('ERROR', "No se recibió salida del procedimiento.", null);
            }

            // Decodificar la respuesta JSON de la salida
            $decodedResult = json_decode($result['v_salida'], true);

            // Verificar si la decodificación fue exitosa
            if (json_last_error() !== JSON_ERROR_NONE) {
                return new ApiResponseDTO('ERROR', "Error al procesar la salida JSON.", null);
            }

            // Retornar la respuesta estructurada
            if (isset($decodedResult['status'])) {
                $status = $decodedResult['status'];
                $message = $decodedResult['message'] ?? 'Operación finalizada';
                $data = $decodedResult['data'] ?? null;
                return new ApiResponseDTO($status, $message, $data);
            } else {
                return new ApiResponseDTO('ERROR', "Estructura inesperada en la respuesta del procedimiento.", null);
            }

        } catch (PDOException $e) {
            return new ApiResponseDTO('ERROR', "Error en la base de datos: " . $e->getMessage(), null);
        } catch (Exception $e) {
            return new ApiResponseDTO('ERROR', "Error general: " . $e->getMessage(), null);
        } finally {
            // Cerrar la conexión
            $this->closeConnection();
        }
    }
}
