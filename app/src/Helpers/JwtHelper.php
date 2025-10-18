<?php

// src/Helpers/JwtHelper.php
namespace App\Helpers;
use Dotenv\Dotenv;
use Firebase\JWT\JWT;
use Firebase\JWT\Key;


   require_once __DIR__ . '/../../vendor/autoload.php';
//require __DIR__ . '/app/vendor/autoload.php';


  
    



class JwtHelper {
    public static function generarToken(array $data): string {
      

          $dotenv = Dotenv::createImmutable(__DIR__ . '/../../');
        $dotenv->load();
        
        $key = $_ENV['JWT_SECRET'];
        $exp = time() + intval($_ENV['JWT_EXPIRATION']);

        $payload = [
            "iat" => time(),
            "exp" => $exp,
            "data" => $data
        ];

        return JWT::encode($payload, $key, 'HS256');
    }

   /* public static function verificarToken(string $token): array {
        
         $key = $_ENV['JWT_SECRET'];
        return (array) JWT::decode($token, new Key($key, 'HS256'));
    }*/
    
    // JwtHelper.php

    public static function verificarToken(string $token): array {
        $key = $_ENV['JWT_SECRET'];
        return json_decode(json_encode(JWT::decode($token, new Key($key, 'HS256'))), true);
    }
    
}
