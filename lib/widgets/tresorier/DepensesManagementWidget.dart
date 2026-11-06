// lib/widgets/depenses_management_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vsm_app/services/api_service.dart';
import 'package:vsm_app/provider/admin_dashboard_provider.dart';

import 'package:vsm_app/widgets/tresorier/ExpensesMonthCard.dart';
import 'package:vsm_app/widgets/tresorier/ExpensesTodayCard.dart';
import 'package:vsm_app/widgets/executed_disbursements_card.dart';
import 'package:vsm_app/widgets/pending_disbursements_card.dart';

class DepensesManagementWidget extends StatefulWidget {
  const DepensesManagementWidget({super.key});

  @override
  State<DepensesManagementWidget> createState() =>
      _DepensesManagementWidgetState();
}

class _DepensesManagementWidgetState extends State<DepensesManagementWidget> {
  final ApiService _apiService = ApiService();
  static const Color bordeauxRed = Color(0xFF6B1D2F);

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');

      if (token != null && mounted) {
        await context.read<AdminDashboardProvider>().fetchDashboardData(token);
      }
    });
  }

  // --- RAFRAÎCHISSEMENT DES DONNÉES ---
  Future<void> _refreshData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');

    if (token != null && mounted) {
      await context.read<AdminDashboardProvider>().fetchDashboardData(token);
    }
  }

  // --- SOUMISSION D'UNE DEMANDE (CREATE) ---
  Future<void> _submitExpense({
    required BuildContext modalContext,
    required String title,
    required String description,
    required double amount,
  }) async {
    Navigator.pop(modalContext);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Transmission de la demande au président..."),
      ),
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');

      if (token != null) {
        final res = await _apiService.post(
          '/admin/decaissements',
          token: token,
          body: {
            'title': title,
            'description': description,
            'amount': amount,
            'status': 'pending',
          },
        );

        if (res != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Demande transmise au président avec succès !"),
                backgroundColor: bordeauxRed,
              ),
            );
          }
          _refreshData();
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Erreur lors de la soumission de la demande."),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint("Erreur soumission expense via ApiService: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Erreur de connexion au serveur."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // --- MODIFICATION D'UNE DEMANDE PENDING OU REJECTED (UPDATE) ---
  Future<void> _updateExpense({
    required BuildContext modalContext,
    required int expenseId,
    required String title,
    required String description,
    required double amount,
  }) async {
    Navigator.pop(modalContext);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Mise à jour de la demande...")),
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');

      if (token != null) {
        final res = await _apiService.put(
          '/admin/decaissements/$expenseId',
          token: token,
          body: {'title': title, 'description': description, 'amount': amount},
        );

        if (res != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Demande modifiée avec succès !"),
                backgroundColor: bordeauxRed,
              ),
            );
          }
          _refreshData();
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Erreur lors de la modification de la demande."),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint("Erreur mise à jour expense via ApiService: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Erreur de connexion au serveur."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // --- SUPPRESSION D'UNE DEMANDE PENDING OU REJECTED (DELETE) ---
  Future<void> _deleteExpense({
    required BuildContext modalContext,
    required int expenseId,
  }) async {
    Navigator.pop(modalContext);

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');

      if (token != null) {
        final res = await _apiService.delete(
          '/admin/decaissements/$expenseId',
          token: token,
        );

        if (res != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Demande supprimée avec succès."),
                backgroundColor: Colors.grey,
              ),
            );
          }
          _refreshData();
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Impossible de supprimer cette demande."),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint("Erreur suppression expense via ApiService: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Erreur de connexion au serveur."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // --- MODAL DE DEMANDE DE DÉCAISSEMENT ---
  void _showAddExpenseModal() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController amountController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext contextModal) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(contextModal).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 15,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Demande d'exécution de décaissement",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: bordeauxRed,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(contextModal),
                    ),
                  ],
                ),
                const Divider(height: 10),
                const SizedBox(height: 10),

                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: "Libellé / Motif (ex: Achat Ballons)",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: "Description détaillée",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Montant (FCFA)",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: bordeauxRed,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      final double amount =
                          double.tryParse(amountController.text) ?? 0;
                      final String title = titleController.text.trim();
                      final String description = descriptionController.text
                          .trim();

                      if (amount <= 0 || title.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Veuillez remplir le libellé et un montant valide.",
                            ),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }

                      _submitExpense(
                        modalContext: contextModal,
                        title: title,
                        description: description,
                        amount: amount,
                      );
                    },
                    child: const Text(
                      "Soumettre au président",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- MODAL DE MODIFICATION D'UNE DÉPENSE PENDING / REJECTED ---
  void _showEditExpenseModal(dynamic exp) {
    final int expenseId = exp['id'];
    final TextEditingController titleController = TextEditingController(
      text: exp['title'] ?? '',
    );
    final TextEditingController descriptionController = TextEditingController(
      text: exp['description'] ?? '',
    );
    final TextEditingController amountController = TextEditingController(
      text: exp['amount']?.toString() ?? '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext contextModal) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(contextModal).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 15,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Modifier / Corriger la demande",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(contextModal),
                    ),
                  ],
                ),
                const Divider(height: 10),
                const SizedBox(height: 10),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: "Libellé / Motif",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: "Description détaillée",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Montant (FCFA)",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      final double amount =
                          double.tryParse(amountController.text) ?? 0;
                      final String title = titleController.text.trim();
                      final String description = descriptionController.text
                          .trim();

                      if (amount <= 0 || title.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Veuillez remplir des données valides.",
                            ),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }

                      _updateExpense(
                        modalContext: contextModal,
                        expenseId: expenseId,
                        title: title,
                        description: description,
                        amount: amount,
                      );
                    },
                    child: const Text(
                      "Enregistrer et re-soumettre",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- MODAL DES DÉPENSES DU MOIS ---
  void _showMonthExpensesModal(List<dynamic> allExpenses) {
    final String currentMonthStr = DateTime.now().toString().substring(0, 7);
    final monthExpenses = allExpenses.where((exp) {
      final dateStr = exp['date'] ?? exp['created_at'] ?? '';
      return dateStr.startsWith(currentMonthStr);
    }).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 25,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 48),
                  const Text(
                    "Dépenses du mois en cours",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: bordeauxRed,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 10),
              SizedBox(
                height: 250,
                child: monthExpenses.isEmpty
                    ? const Center(
                        child: Text(
                          "Aucune dépense ce mois-ci",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: monthExpenses.length,
                        itemBuilder: (context, index) {
                          final exp = monthExpenses[index];
                          final String status =
                              exp['status']?.toString().toLowerCase() ??
                              'pending';
                          final bool isExecuted = status == 'executed';
                          final bool isRejected = status == 'rejected';

                          Color itemColor = Colors.orange;
                          IconData itemIcon = Icons.hourglass_top;

                          if (isExecuted) {
                            itemColor = bordeauxRed;
                            itemIcon = Icons.arrow_upward;
                          } else if (isRejected) {
                            itemColor = Colors.red;
                            itemIcon = Icons.cancel_outlined;
                          }

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            elevation: 0.5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: Colors.grey.shade200),
                            ),
                            child: ListTile(
                              dense: true,
                              onTap: () {
                                Navigator.pop(context);
                                _showExpenseDetails(exp);
                              },
                              leading: CircleAvatar(
                                backgroundColor: itemColor.withOpacity(0.1),
                                radius: 14,
                                child: Icon(
                                  itemIcon,
                                  color: itemColor,
                                  size: 14,
                                ),
                              ),
                              title: Text(
                                exp['title'] ?? 'Dépense',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              subtitle: Text(
                                "${exp['description'] ?? 'Sans description'} • Statut: $status",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                              trailing: Text(
                                "-${exp['amount'] ?? 0} F",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: itemColor,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  // --- MODAL DÉTAILS D'UNE DÉPENSE ---
  void _showExpenseDetails(dynamic exp) {
    final String status = exp['status']?.toString().toLowerCase() ?? 'pending';
    final bool isExecuted = status == 'executed';
    final bool isRejected = status == 'rejected';
    final bool isPending = status == 'pending';

    // Autorise la modification et suppression si en attente OU rejeté
    final bool canBeModified = isPending || isRejected;

    Color statusColor = Colors.orange;
    String statusText = "En attente de validation (Pending)";
    if (isExecuted) {
      statusColor = bordeauxRed;
      statusText = "Exécuté / Approuvé";
    } else if (isRejected) {
      statusColor = Colors.red;
      statusText = "Rejeté";
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (contextModal) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(contextModal).viewInsets.bottom + 25,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 48),
                  const Text(
                    "Détails du décaissement",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: bordeauxRed,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(contextModal),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 10),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                      Icons.description,
                      "Motif / Libellé",
                      exp['title'] ?? 'N/A',
                    ),
                    const Divider(height: 16),
                    _buildDetailRow(
                      Icons.notes,
                      "Description",
                      exp['description'] ?? 'Aucune description fournie',
                    ),
                    const Divider(height: 16),
                    _buildDetailRow(
                      Icons.payments,
                      "Montant",
                      "-${exp['amount'] ?? 0} FCFA",
                      valueColor: statusColor,
                      isBold: true,
                    ),
                    const Divider(height: 16),
                    _buildDetailRow(
                      Icons.info_outline,
                      "Statut actuel",
                      statusText,
                      valueColor: statusColor,
                    ),
                    if (isRejected && exp['rejection_reason'] != null) ...[
                      const Divider(height: 16),
                      _buildDetailRow(
                        Icons.cancel_outlined,
                        "Motif du rejet",
                        exp['rejection_reason'],
                        valueColor: Colors.red,
                      ),
                    ],
                    const Divider(height: 16),
                    _buildDetailRow(
                      Icons.calendar_today,
                      "Date",
                      exp['date'] ?? exp['created_at'] ?? 'N/A',
                    ),
                  ],
                ),
              ),

              // BOUTONS DE MODIFICATION ET DE SUPPRESSION (VISIBLES SI PENDING OU REJECTED)
              if (canBeModified) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange,
                          side: const BorderSide(color: Colors.orange),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          Navigator.pop(contextModal);
                          _showEditExpenseModal(exp);
                        },
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text("Modifier / Corriger"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text("Confirmer la suppression"),
                              content: const Text(
                                "Voulez-vous vraiment supprimer cette demande ?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text("Annuler"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    _deleteExpense(
                                      modalContext: contextModal,
                                      expenseId: exp['id'],
                                    );
                                  },
                                  child: const Text(
                                    "Supprimer",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.delete, size: 18),
                        label: const Text("Supprimer"),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
    bool isBold = false,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: bordeauxRed.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: bordeauxRed),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                  color: valueColor ?? Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminDashboardProvider>();
    final bool isLoading = provider.isLoading;
    final List<dynamic> expensesList = provider.allExpenses;

    if (isLoading && expensesList.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: bordeauxRed));
    }

    final expensesCount = expensesList.length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExpenseModal,
        backgroundColor: bordeauxRed,
        foregroundColor: Colors.white,
        elevation: 2,
        child: const Icon(Icons.add, size: 24),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: bordeauxRed,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 100,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        children: [
                          const SizedBox(
                            width: 180,
                            child: ExpensesTodayCard(),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 180,
                            child: ExpensesMonthCard(
                              onTap: () =>
                                  _showMonthExpensesModal(expensesList),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const SizedBox(
                            width: 180,
                            child: ExecutedDisbursementsCard(),
                          ),
                          const SizedBox(width: 10),
                          const SizedBox(
                            width: 180,
                            child: PendingDisbursementsCard(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      "Historique récent des décaissements",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: bordeauxRed,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            expensesCount == 0
                ? const SliverFillRemaining(
                    child: Center(
                      child: Text(
                        "Aucune dépense récente",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final exp = expensesList[index];
                        final String status =
                            exp['status']?.toString().toLowerCase() ??
                            'pending';
                        final bool isExecuted = status == 'executed';
                        final bool isRejected = status == 'rejected';

                        Color itemColor = Colors.orange;
                        IconData itemIcon = Icons.hourglass_top;

                        if (isExecuted) {
                          itemColor = bordeauxRed;
                          itemIcon = Icons.arrow_upward;
                        } else if (isRejected) {
                          itemColor = Colors.red;
                          itemIcon = Icons.cancel_outlined;
                        }

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 3),
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListTile(
                            dense: true,
                            onTap: () => _showExpenseDetails(exp),
                            leading: CircleAvatar(
                              backgroundColor: itemColor.withOpacity(0.1),
                              radius: 16,
                              child: Icon(itemIcon, color: itemColor, size: 16),
                            ),
                            title: Text(
                              exp['title'] ?? 'Dépense',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            subtitle: Text(
                              "${exp['description'] ?? 'Sans description'} • Statut: $status",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "-${exp['amount'] ?? 0} F",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: itemColor,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.chevron_right,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        );
                      }, childCount: expensesCount),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
