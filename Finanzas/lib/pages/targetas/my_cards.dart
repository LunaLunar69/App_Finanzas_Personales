import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:minimallogin/pages/targetas/add_cards.dart';
import 'package:minimallogin/pages/targetas/update_card.dart';
import 'package:minimallogin/querys/firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';

class CardListPage extends StatefulWidget {
  const CardListPage({super.key});

  @override
  State<CardListPage> createState() => _CardListPageState();
}

class _CardListPageState extends State<CardListPage> {
  final FirestoreService firestoreService = FirestoreService();
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  final TextEditingController cardBalanceController = TextEditingController();

  final TextEditingController _cashController = TextEditingController();
  double? currentBalance;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
    _loadCurrentBalance();
  }

  Future<void> _loadCurrentBalance() async {
    try {
      final balance = await firestoreService.getSaldoActual(userId);
      setState(() {
        currentBalance = balance;
      });
    } catch (e) {
      print('Error loading balance: $e');
    }
  }

  Future<void> _checkFirstLaunch() async {
    try {
      final saldoExists = await firestoreService.checkSaldoExists(userId);
      if (!saldoExists) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showCashInputDialog();
        });
      }
    } catch (e) {
      print('Error checking first launch: $e');
    }
  }

  Future<void> _saveCashAmount(String cashAmount) async {
    try {
      final double amount = double.parse(cashAmount);
      await firestoreService.setSaldoInicial(userId, amount);
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    }
  }

  Future<void> _showCashInputDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Bienvenido'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Por favor, ingresa tu cantidad de efectivo actual:'),
              TextField(
                controller: _cashController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Cantidad de efectivo',
                  prefixIcon: Icon(Icons.attach_money),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Guardar'),
              onPressed: () {
                if (_cashController.text.isNotEmpty) {
                  _saveCashAmount(_cashController.text);
                }
              },
            ),
          ],
        );
      },
    );
  }

  void showDeleteConfirmation(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: const Text('¿Estás seguro que deseas eliminar esta tarjeta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              firestoreService.deleteCard(userId, docId);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<void> _showUpdateBalanceDialog() async {
    _cashController.text = currentBalance?.toString() ?? '';

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Actualizar Saldo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _cashController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Nuevo saldo',
                  prefixIcon: Icon(Icons.attach_money),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Actualizar'),
              onPressed: () async {
                if (_cashController.text.isNotEmpty) {
                  try {
                    final double amount = double.parse(_cashController.text);
                    await firestoreService.updateSaldo(userId, amount);
                    Navigator.of(context).pop();
                    _loadCurrentBalance();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al actualizar: $e')),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis tarjetas'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CreditCardScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firestoreService.getCards(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No hay tarjetas disponibles.'),
                  );
                }

                final cards = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: cards.length,
                  itemBuilder: (context, index) {
                    final cardData =
                        cards[index].data() as Map<String, dynamic>;
                    final cardId = cards[index].id;

                    return Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: Column(
                                children: [
                                  
                                  CreditCardWidget(
                                    cardNumber: cardData['cardNumber'] ??
                                        '**** **** **** ****',
                                    expiryDate: cardData['expiryDate'] ?? 'N/A',
                                    cardHolderName:
                                        cardData['cardHolderName'] ?? 'N/A',
                                    isHolderNameVisible: true,
                                    cvvCode: '',
                                    showBackView: false,
                                    onCreditCardWidgetChange:
                                        (CreditCardBrand brand) {},
                                  ),
                                  Text(
                                    'Saldo: \$${(cardData['balance'] ?? 0.0).toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                            ],
                          )),
                          Column(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit,
                                    color: Colors.orange),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => UpdateCardScreen(
                                              cardId: cardId,
                                              cardData: cardData,
                                            )),
                                  );
                                },
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  showDeleteConfirmation(context, cardId);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Saldo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\$${currentBalance?.toStringAsFixed(2) ?? '--'}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: _showUpdateBalanceDialog,
                  child: const Text('Actualizar'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cashController.dispose();
    super.dispose();
  }
}
