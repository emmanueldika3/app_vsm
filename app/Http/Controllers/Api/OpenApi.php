<?php

namespace App\Http\Controllers\Api;

use OpenApi\Attributes as OA;

#[OA\Info(
    version: "1.0.0",
    title: "VSM_API",
    description: "Documentation interactive de l'API mobile Vétérans Santé Mahèn"
)]
#[OA\Server(
    url: "http://127.0.0.1:8000/api",
    description: "Serveur Local"
)]
#[OA\SecurityScheme(
    securityScheme: "bearerAuth",
    type: "http",
    name: "Authorization",
    in: "header",
    scheme: "bearer",
    bearerFormat: "JWT",
    description: "Saisissez votre token Sanctum"
)]
class OpenApi
{
    // Ce fichier sert uniquement de support aux annotations globales OpenAPI
}