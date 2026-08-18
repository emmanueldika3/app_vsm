<?php

namespace App\Http\Controllers;

/**
 * @OA\Info(
 *      title="VSM_API",
 *      version="1.0.0",
 *      description="Documentation interactive de l'API mobile Vétérans Santé Mahèn"
 * )
 * 
 * @OA\Server(
 *      url="http://127.0.0.1:8000/api",
 *      description="Serveur Local"
 * )
 * 
 * @OA\SecurityScheme(
 *      type="http",
 *      scheme="bearer",
 *      bearerFormat="JWT",
 *      securityScheme="bearerAuth",
 *      description="Saisissez votre token Sanctum"
 * )
 */
abstract class Controller
{
    //
}