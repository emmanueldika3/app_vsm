<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use OpenApi\Annotations as OA;

/**
 * @OA\Tag(
 *     name="Administration",
 *     description="Endpoints réservés aux administrateurs"
 * )
 */
class AdminDashboardController extends Controller
{
    /**
     * @OA\Get(
     *     path="/api/admin/dashboard",
     *     summary="Consulter le tableau de bord administration",
     *     tags={"Administration"},
     *     security={{"bearerAuth": {}}},
     *     @OA\Response(
     *         response=200,
     *         description="Statistiques d'administration récupérées avec succès",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="Dashboard admin OK")
     *         )
     *     ),
     *     @OA\Response(response=401, description="Non autorisé"),
     *     @OA\Response(response=403, description="Accès interdit")
     * )
     */
    public function index(): JsonResponse
    {
        return response()->json(['message' => 'Dashboard admin OK']);
    }
}