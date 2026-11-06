import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vsm_app/services/api_service.dart';
import 'package:vsm_app/provider/admin_dashboard_provider.dart';
import 'package:vsm_app/widgets/cash_balance_card.dart';
import 'package:vsm_app/widgets/collected_contributions_card.dart';

// Import des sous-widgets modulaires
import 'collected_today_card.dart';
import 'up_to_date_members_card.dart';
import 'transactions_history_widget.dart';

class CotisationsManagementWidget extends StatefulWidget {
  const CotisationsManagementWidget({super.key});

  @override
  State<CotisationsManagementWidget> createState() =>
      _CotisationsManagementWidgetState();
}

class _CotisationsManagementWidgetState
    extends State<CotisationsManagementWidget> {
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  List<dynamic> _membersList = [];
  List<dynamic> _transactionsList = [];

  double _totalCollectedContributions = 0.0;
  double _totalCollectedToday = 0.0;
  int _upToDateCount = 0;

  static const Color greenPrimary = Color(0xFF1E5235);
  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color bordeauxRed = Color(0xFF6B1D2F);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      try {
        context.read<AdminDashboardProvider>();
      } catch (e) {
        debugPrint("Provider non trouvé ou non initialisé : $e");
      }
    });
    _fetchCotisationsData();
  }

  Future<void> _fetchCotisationsData() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');

      if (token == null) {
        setState(() => _isLoading = false);
        return;
      }

      try {
        final membersRes = await _apiService.get('/users', token: token);
        if (membersRes != null && membersRes['data'] != null) {
          _membersList = membersRes['data'];
        } else if (membersRes is List) {
          _membersList = membersRes;
        }
      } catch (e) {
        debugPrint("Erreur récupération membres : $e");
      }

      final contributionsRes = await _apiService.fetchContributions(token);

      if (contributionsRes != null && contributionsRes['status'] == 'success') {
        final responseData = contributionsRes['data'];

        if (responseData != null) {
          final totalAmt = responseData['total_amount'] ?? 0;
          _totalCollectedContributions = (totalAmt is num)
              ? totalAmt.toDouble()
              : double.tryParse(totalAmt.toString()) ?? 0.0;

          final records = responseData['records'] ?? [];

          setState(() {
            _transactionsList = records.map((item) {
              return {
                'id': item['id'],
                'userId': item['user_id'] ?? 1,
                'memberName': item['user_name'] ?? 'Membre VSM',
                'amount': (item['amount'] as num).toDouble(),
                'type': item['type'] ?? 'standard',
                'status': item['status'] ?? 'paid',
                'date': item['paid_at'] != null
                    ? item['paid_at'].toString().substring(0, 10)
                    : (item['created_at'] != null
                          ? item['created_at'].toString().substring(0, 10)
                          : DateTime.now().toString().substring(0, 10)),
              };
            }).toList();
          });
        }
      }

      _calculateStats();
    } catch (e) {
      debugPrint(">>> Erreur chargement cotisations : $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _calculateStats() {
    double todayTotal = 0;
    int count = 0;
    final String todayStr = DateTime.now().toString().substring(0, 10);
    final Set<int> paidUserIds = {};

    for (var tx in _transactionsList) {
      if (tx['date'] == todayStr) {
        todayTotal += (tx['amount'] ?? 0);
      }
      if (tx['status'] == 'paid' && tx['userId'] != null) {
        paidUserIds.add(tx['userId']);
      }
    }

    count = paidUserIds.length;

    setState(() {
      _totalCollectedToday = todayTotal;
      _upToDateCount = count;
    });
  }

  void _showAddContributionModal() {
    int? selectedUserId = (_membersList.isNotEmpty)
        ? _membersList[0]['id']
        : null;
    final TextEditingController amountController = TextEditingController(
      text: "5000",
    );
    String selectedType = "standard";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
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
                      "Enregistrer un paiement de cotisation",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: greenPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(height: 10),
                const SizedBox(height: 10),

                DropdownButtonFormField<int>(
                  value: selectedUserId,
                  decoration: const InputDecoration(
                    labelText: "Membre / Joueur",
                    border: OutlineInputBorder(),
                  ),
                  items: _membersList.map<DropdownMenuItem<int>>((member) {
                    return DropdownMenuItem<int>(
                      value: member['id'],
                      child: Text(member['name'] ?? 'Membre #${member['id']}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    selectedUserId = value;
                  },
                ),
                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    labelText: "Type de cotisation",
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: "standard",
                      child: Text("Cotisation Standard / Mensuelle"),
                    ),
                    DropdownMenuItem(
                      value: "match",
                      child: Text("Cotisation Spéciale Match"),
                    ),
                    DropdownMenuItem(
                      value: "fine",
                      child: Text("Sanction / Amende"),
                    ),
                    DropdownMenuItem(
                      value: "donation",
                      child: Text("Don / Contribution Libre"),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) selectedType = value;
                  },
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
                      backgroundColor: greenPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () async {
                      final double amount =
                          double.tryParse(amountController.text) ?? 0;
                      if (amount >= 500 && selectedUserId != null) {
                        final prefs = await SharedPreferences.getInstance();
                        final String? token = prefs.getString('auth_token');

                        if (token != null) {
                          try {
                            final res = await _apiService.addContribution(
                              token,
                              userId: selectedUserId!,
                              amount: amount,
                              type: selectedType,
                              status: 'paid',
                              paidAt: DateTime.now().toString().substring(
                                0,
                                19,
                              ),
                            );

                            if (mounted) {
                              Navigator.pop(context);
                              if (res != null && res['status'] == 'success') {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Cotisation enregistrée en base de données !",
                                    ),
                                    backgroundColor: greenPrimary,
                                  ),
                                );
                                _fetchCotisationsData();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      res['message'] ??
                                          "Erreur d'enregistrement.",
                                    ),
                                    backgroundColor: bordeauxRed,
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                            debugPrint("Erreur ajout API : $e");
                          }
                        }
                      }
                    },
                    child: const Text(
                      "Valider l'encaissement",
                      style: TextStyle(
                        color: goldAccent,
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

  void _showEditContributionModal(Map<String, dynamic> item) {
    final TextEditingController amountController = TextEditingController(
      text: item['amount'].toString(),
    );
    String selectedType = item['type'] ?? 'standard';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 15,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Modifier la cotisation (${item['memberName']})",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: greenPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 10),

              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(
                  labelText: "Type de cotisation",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: "standard", child: Text("Standard")),
                  DropdownMenuItem(value: "match", child: Text("Match")),
                  DropdownMenuItem(value: "fine", child: Text("Amende")),
                  DropdownMenuItem(value: "donation", child: Text("Don")),
                ],
                onChanged: (val) {
                  if (val != null) selectedType = val;
                },
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
                    backgroundColor: greenPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () async {
                    final double amount =
                        double.tryParse(amountController.text) ?? 0;
                    if (amount >= 500) {
                      final prefs = await SharedPreferences.getInstance();
                      final String? token = prefs.getString('auth_token');

                      if (token != null) {
                        try {
                          final res = await _apiService.updateContribution(
                            token,
                            id: item['id'],
                            amount: amount,
                            type: selectedType,
                          );

                          if (mounted) {
                            Navigator.pop(context);
                            if (res != null && res['status'] == 'success') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Cotisation mise à jour avec succès !",
                                  ),
                                  backgroundColor: greenPrimary,
                                ),
                              );
                              _fetchCotisationsData();
                            }
                          }
                        } catch (e) {
                          debugPrint("Erreur update API : $e");
                        }
                      }
                    }
                  },
                  child: const Text(
                    "Mettre à jour",
                    style: TextStyle(
                      color: goldAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _confirmDeleteContribution(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Supprimer la cotisation"),
        content: const Text(
          "Êtes-vous sûr de vouloir supprimer cette transaction en base de données ?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: bordeauxRed),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              final String? token = prefs.getString('auth_token');

              if (token != null) {
                try {
                  final res = await _apiService.removeContribution(token, id);
                  if (mounted) {
                    Navigator.pop(context);
                    if (res != null && res['status'] == 'success') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Cotisation supprimée de la BD !"),
                        ),
                      );
                      _fetchCotisationsData();
                    }
                  }
                } catch (e) {
                  debugPrint("Erreur delete API : $e");
                }
              }
            },
            child: const Text(
              "Supprimer",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailsModal(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Détails de la contribution"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Membre : ${item['memberName']}"),
            const SizedBox(height: 8),
            Text("Montant : ${item['amount']} XAF"),
            const SizedBox(height: 8),
            Text("Type : ${item['type']}"),
            const SizedBox(height: 8),
            Text("Statut : ${item['status']}"),
            const SizedBox(height: 8),
            Text("Date : ${item['date']}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Fermer"),
          ),
        ],
      ),
    );
  }

  // --- MÉTHODE QUI APPELLE L'API ET AFFICHE LES DÉTAILS DE LA LISTE ---
  Future<void> _showCollectedContributionsDetailsModal() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          const Center(child: CircularProgressIndicator(color: goldAccent)),
    );

    List<dynamic> freshApiList = [];
    double freshTotal = _totalCollectedContributions;

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');

      if (token != null) {
        final contributionsRes = await _apiService.fetchContributions(token);

        if (contributionsRes != null &&
            contributionsRes['status'] == 'success') {
          final responseData = contributionsRes['data'];
          if (responseData != null) {
            final totalAmt = responseData['total_amount'] ?? 0;
            freshTotal = (totalAmt is num)
                ? totalAmt.toDouble()
                : double.tryParse(totalAmt.toString()) ?? 0.0;

            final records = responseData['records'] ?? [];
            freshApiList = records.map((item) {
              return {
                'id': item['id'],
                'memberName': item['user_name'] ?? 'Membre VSM',
                'amount': (item['amount'] as num?)?.toDouble() ?? 0.0,
                'type': item['type'] ?? 'standard',
                'status': item['status'] ?? 'paid',
                'date': item['paid_at'] != null
                    ? item['paid_at'].toString().substring(0, 10)
                    : (item['created_at'] != null
                          ? item['created_at'].toString().substring(0, 10)
                          : 'N/A'),
              };
            }).toList();
          }
        }
      }
    } catch (e) {
      debugPrint("Erreur lors de l'appel API des détails : $e");
    }

    if (mounted) Navigator.pop(context); // Fermer le loader

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Détails - Cotisations Perçues"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Total Global : ${freshTotal.toStringAsFixed(0)} XAF",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: greenPrimary,
                  ),
                ),
                const Divider(height: 20),
                Text(
                  "Transactions enregistrées (${freshApiList.length}) :",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),

                SizedBox(
                  width: double.maxFinite,
                  height: 300,
                  child: freshApiList.isEmpty
                      ? const Center(child: Text("Aucune transaction trouvée."))
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: freshApiList.length,
                          itemBuilder: (context, index) {
                            final tx = freshApiList[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                dense: true,
                                leading: const Icon(
                                  Icons.monetization_on,
                                  color: greenPrimary,
                                ),
                                title: Text(
                                  tx['memberName'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  "Type: ${tx['type']} • ${tx['date']}",
                                ),
                                trailing: Text(
                                  "${tx['amount']} XAF",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: greenPrimary,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Fermer"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: goldAccent)),
      );
    }

    final int membersCount = _membersList.length;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _fetchCotisationsData,
        color: goldAccent,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(12.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Row(
                    children: const [
                      Icon(
                        Icons.account_balance_wallet,
                        color: greenPrimary,
                        size: 22,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Gestion des Cotisations & Entrées",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: greenPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        const SizedBox(width: 165, child: CashBalanceCard()),
                        const SizedBox(width: 10),

                        SizedBox(
                          width: 165,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: _showCollectedContributionsDetailsModal,
                            child: const CollectedContributionsCard(),
                          ),
                        ),
                        const SizedBox(width: 10),

                        SizedBox(
                          width: 165,
                          child: CollectedTodayCard(
                            totalCollected: _totalCollectedToday,
                          ),
                        ),
                        const SizedBox(width: 10),

                        SizedBox(
                          width: 165,
                          child: UpToDateMembersCard(
                            upToDateCount: _upToDateCount,
                            membersCount: membersCount,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Historique récent des encaissements",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: greenPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.refresh,
                          size: 20,
                          color: greenPrimary,
                        ),
                        onPressed: _fetchCotisationsData,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                ]),
              ),
            ),

            TransactionsHistoryWidget(
              transactionsList: _transactionsList,
              onEdit: (item) => _showEditContributionModal(item),
              onDelete: (id) => _confirmDeleteContribution(id),
              onTap: (item) => _showDetailsModal(item),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddContributionModal,
        backgroundColor: goldAccent,
        foregroundColor: greenPrimary,
        elevation: 2,
        child: const Icon(Icons.add, size: 24),
      ),
    );
  }
}
