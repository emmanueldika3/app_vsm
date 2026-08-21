<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\UserController;
use App\Http\Controllers\Api\DashboardController;
use App\Http\Controllers\Api\ContributionController;
use App\Http\Controllers\Api\EventController;

/*
|--------------------------------------------------------------------------
| Routes Publiques
|--------------------------------------------------------------------------
*/
Route::post('/login', [AuthController::class, 'login']);

/*
|--------------------------------------------------------------------------
| Routes Protégées (Sanctum)
|--------------------------------------------------------------------------
*/
Route::middleware('auth:sanctum')->group(function () {

    // --- AUTHENTIFICATION & PROFIL ---
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me', [AuthController::class, 'me']);
    Route::post('/user/photo', [UserController::class, 'updatePhoto']);

    // --- DASHBOARDS SPÉCIFIQUES SELON LE RÔLE ---
    Route::prefix('dashboard')->group(function () {
        Route::get('/player', [DashboardController::class, 'playerSummary']);
        Route::get('/coach', [DashboardController::class, 'coachSummary']);
        Route::get('/treasurer', [DashboardController::class, 'treasurerSummary']);
        Route::get('/president', [DashboardController::class, 'presidentSummary']);
        Route::get('/admin', [DashboardController::class, 'adminSummary']);
    });

    // --- GESTION DES MEMBRES VSM ---
    Route::get('/users', [UserController::class, 'index']);
    Route::get('/users/{id}', [UserController::class, 'show']);
    Route::put('/users/{id}', [UserController::class, 'update']);

    // --- TRÉSORERIE & COTISATIONS ---
    Route::get('/contributions', [ContributionController::class, 'index']);
    Route::get('/contributions/my-status', [ContributionController::class, 'myStatus']);

    // --- EVENEMENTS, MATCHS & ENTRAÎNEMENTS ---
    Route::get('/events', [EventController::class, 'index']);
    Route::get('/events/{id}', [EventController::class, 'show']);
    Route::post('/events/{id}/presence', [EventController::class, 'updatePresence']);

    // --- ACCÈS RESTREINT : BUREAU & ADMIN VSM ---
    Route::middleware('can:admin-access')->group(function () {
        // Membres
        Route::post('/users', [UserController::class, 'store']);
        Route::delete('/users/{id}', [UserController::class, 'destroy']);

        // Cotisations
        Route::post('/contributions', [ContributionController::class, 'store']);
        Route::put('/contributions/{id}', [ContributionController::class, 'update']);

        // Programme des matchs / convocations
        Route::post('/events', [EventController::class, 'store']);
        Route::put('/events/{id}', [EventController::class, 'update']);
        Route::delete('/events/{id}', [EventController::class, 'destroy']);
    });
});