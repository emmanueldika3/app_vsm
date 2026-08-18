<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use OpenApi\Attributes as OA;

class AuthController extends Controller
{
    #[OA\Post(
        path: "/login",
        summary: "Connexion d'un membre VSM via téléphone",
        tags: ["Authentification"],
        requestBody: new OA\RequestBody(
            required: true,
            content: new OA\JsonContent(
                required: ["phone", "password"],
                properties: [
                    new OA\Property(property: "phone", type: "string", example: "690000000"),
                    new OA\Property(property: "password", type: "string", format: "password", example: "secret123")
                ]
            )
        ),
        responses: [
            new OA\Response(
                response: 200, 
                description: "Connexion réussie avec émission de Token Sanctum",
                content: new OA\JsonContent(
                    properties: [
                        new OA\Property(property: "message", type: "string", example: "Connexion réussie"),
                        new OA\Property(
                            property: "user",
                            type: "object",
                            properties: [
                                new OA\Property(property: "id", type: "integer", example: 1),
                                new OA\Property(property: "name", type: "string", example: "Emmanuel Dika"),
                                new OA\Property(property: "phone", type: "string", example: "690000000"),
                                new OA\Property(property: "role", type: "string", example: "player")
                            ]
                        ),
                        new OA\Property(property: "token", type: "string", example: "1|1a2b3c4d5e6f7g8h9i0j")
                    ]
                )
            ),
            new OA\Response(response: 401, description: "Identifiants incorrects"),
            new OA\Response(response: 422, description: "Données de validation manquantes")
        ]
    )]
    public function login(Request $request)
    {
        // 1. Validation de la requête HTTP
        $request->validate([
            'phone' => 'required|string',
            'password' => 'required|string',
        ]);

        // 2. Recherche de l'utilisateur par téléphone
        $user = User::where('phone', $request->phone)->first();

        // 3. Vérification de l'existence et du mot de passe
        if (! $user || ! Hash::check($request->password, $user->password)) {
            return response()->json([
                'message' => 'Identifiants incorrects.'
            ], 401);
        }

        // 4. Génération du Token Sanctum
        $token = $user->createToken('vsm_mobile_token')->plainTextToken;

        // 5. Réponse structurée pour Flutter
        return response()->json([
            'message' => 'Connexion réussie',
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'phone' => $user->phone,
                'role' => $user->role ?? 'player',
            ],
            'token' => $token,
        ], 200);
    }

    #[OA\Get(
        path: "/me",
        summary: "Récupérer le profil du membre connecté",
        tags: ["Authentification"],
        security: [["bearerAuth" => []]],
        responses: [
            new OA\Response(response: 200, description: "Données du membre VSM"),
            new OA\Response(response: 401, description: "Non autorisé")
        ]
    )]
    public function me(Request $request)
    {
        return response()->json([
            'id' => $request->user()->id,
            'name' => $request->user()->name,
            'phone' => $request->user()->phone,
            'role' => $request->user()->role ?? 'player',
        ], 200);
    }
}