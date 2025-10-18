<?php
namespace App\DTO;

class ApiResponseDTO {
    public string $status;
    public string $message;
    public mixed $data;

    public function __construct(string $status, string $message, mixed $data = null) {
        $this->status = $status;
        $this->message = $message;
        $this->data = $data;
    }
}
