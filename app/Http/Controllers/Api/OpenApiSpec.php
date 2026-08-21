<?php

namespace App\Http\Controllers\Api;

use OpenApi\Attributes as OA;

#[OA\Info(
    version: "1.0.0",
    title: "API VSM Mobile",
    description: "Documentation API VSM PK11"
)]
#[OA\Server(
    url: "http://127.0.0.1:8000",
    description: "Serveur Local"
)]
#[OA\Schema(
    schema: "UserModel",
    title: "Modèle Utilisateur / Membre VSM",
    description: "Représentation JSON d'un utilisateur renvoyée à Flutter",
    required: ["id", "name", "phone", "role"],
    properties: [
        new OA\Property(property: "id", type: "integer", example: 1),
        new OA\Property(property: "name", type: "string", example: "Emmanuel Dika"),
        new OA\Property(property: "phone", type: "string", example: "+237690000000"),
        new OA\Property(property: "email", type: "string", format: "email", nullable: true, example: "user@vsm.cm"),
        new OA\Property(property: "photo_url", type: "string", nullable: true, example: "http://127.0.0.1:8000/storage/avatars/user_1.jpg"),
        new OA\Property(
            property: "role",
            type: "string",
            enum: ["admin", "player", "treasurer", "president", "coach"],
            example: "player"
        )
    ]
)]
class OpenApiSpec
{
    //
}