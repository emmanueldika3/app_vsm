<?php
namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Admin / Président
        User::create([
            'name' => 'Emmanuel Dika',
            'phone' => '690000000',
            'email' => 'admin@vsm.com',
            'password' => Hash::make('1234'),
            'role' => 'admin',
            'position' => 'Président',
            'is_active' => true,
        ]);
        // 2. joueur
        User::create([
            'name' => 'Yvan Moussongo',
            'phone' => '690000001',
            'email' => 'player@vsm.com',
            'password' => Hash::make('1234'),
            'role' => 'player',
            'position' => 'milieu',
            'is_active' => true,
        ]);

        // 3. Trésorier
        User::create([
            'name' => 'Jean-Paul Nsoga',
            'phone' => '690000002',
            'email' => 'tresorier@vsm.com',
            'password' => Hash::make('1234'),
            'role' => 'treasurer',
            'position' => 'Trésorier',
            'is_active' => true,
        ]);
        // 4. Coach
        User::create([
            'name' => 'Nog Guy',
            'phone' => '690000003',
            'email' => 'coach@vsm.com',
            'password' => Hash::make('1234'),
            'role' => 'coach',
            'position' => 'Encadreur',
            'is_active' => true,
        ]);

        // 5. Membres Actifs (Validation OK)
        $players = [
            ['name' => 'Samuel Eto’o', 'position' => 'Attaquant', 'phone' => '690000004'],
            ['name' => 'Rigobert Song', 'position' => 'Défenseur', 'phone' => '690000005'],
            ['name' => 'Geremi Njitap', 'position' => 'Milieu', 'phone' => '690000006'],
            ['name' => 'Carlos Kameni', 'position' => 'Gardien', 'phone' => '690000007'],
        ];

        foreach ($players as $player) {
            User::create([
                'name' => $player['name'],
                'phone' => $player['phone'],
                'email' => strtolower(str_replace(' ', '', $player['name'])) . '@vsm.com',
                'password' => Hash::make('1234'),
                'role' => 'player',
                'position' => $player['position'],
                'is_active' => true,
            ]);
        }

        // 6. Demandes d'adhésion en attente
        $pending = [
            ['name' => 'Patrick Mboma', 'position' => 'Attaquant', 'phone' => '690000008'],
            ['name' => 'Stephane Mbia', 'position' => 'Milieu', 'phone' => '690000009'],
        ];

        foreach ($pending as $p) {
            User::create([
                'name' => $p['name'],
                'phone' => $p['phone'],
                'email' => strtolower(str_replace(' ', '', $p['name'])) . '@vsm.com',
                'password' => Hash::make('1234'),
                'role' => 'player',
                'position' => $p['position'],
                'is_active' => false, // 👈 En attente de validation
            ]);
        }
    }
}