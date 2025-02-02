import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:minimallogin/pages/targetas/add_cards.dart';
import 'package:minimallogin/pages/targetas/update_card.dart';
import 'package:minimallogin/querys/firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';


class CardListPage extends StatelessWidget {
  final FirestoreService firestoreService = FirestoreService();

  CardListPage({super.key});

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
              firestoreService.deleteCard(docId);
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
                MaterialPageRoute(builder: (context) => CreditCardScreen()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getCards(),
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
              final cardData = cards[index].data() as Map<String, dynamic>;
              final cardId = cards[index].id;

              return Padding(
                padding: const EdgeInsets.all(5.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: CreditCardWidget(
                        cardNumber:
                            cardData['cardNumber'] ?? '**** **** **** ****',
                        expiryDate: cardData['expiryDate'] ?? 'N/A',
                        cardHolderName: cardData['cardHolderName'] ?? 'N/A',
                        isHolderNameVisible: true,
                        cvvCode: cardData['cvvCode'] ?? '***',
                        showBackView: false,
                        onCreditCardWidgetChange: (CreditCardBrand brand) {},
                      ),
                    ),
                    Column(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
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
                          icon: const Icon(Icons.delete, color: Colors.red),
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
    );
  }
}
 