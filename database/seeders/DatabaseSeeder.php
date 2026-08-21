<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // Exécution ordonnée des seeders
        $this->call([
            UserSeeder::class,
            TransactionSeeder::class,
            AnnouncementSeeder::class,
        ]);
    }
}