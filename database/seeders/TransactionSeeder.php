<?php
namespace Database\Seeders;

use App\Models\Transaction;
use App\Models\User;
use Illuminate\Database\Seeder;

class TransactionSeeder extends Seeder
{
    public function run(): void
    {
        $players = User::where('role', 'player')->where('is_active', true)->get();

        // Cotisations reçues
        foreach ($players as $player) {
            Transaction::create([
                'user_id' => $player->id,
                'type' => 'income',
                'category' => 'Cotisation mensuelle',
                'amount' => 5000,
                'description' => 'Cotisation mois en cours',
                'transaction_date' => now(),
            ]);
        }

        // Dépense du club
        Transaction::create([
            'user_id' => null,
            'type' => 'expense',
            'category' => 'Équipement',
            'amount' => 15000,
            'description' => 'Achat de 2 nouveaux ballons de match',
            'transaction_date' => now()->subDays(2),
        ]);
    }
}