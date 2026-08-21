<?php

namespace Database\Seeders;

use App\Models\Announcement;
use App\Models\User;
use Illuminate\Database\Seeder;

class AnnouncementSeeder extends Seeder
{
    public function run(): void
    {
        $admin = User::where('role', 'admin')->first();

        if ($admin) {
            Announcement::create([
                'author_id' => $admin->id,
                'title' => 'Entraînement Général - Ce Samedi',
                'content' => 'Rendez-vous à 6h30 au terrain Mahèn PK11. Présence obligatoire de tous les membres.',
                'is_urgent' => true,
            ]);
        }
    }
}
