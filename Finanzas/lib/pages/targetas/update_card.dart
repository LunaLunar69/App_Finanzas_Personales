

import 'package:firebase_auth/firebase_auth.dart';
import 'package:minimallogin/querys/firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';

class UpdateCardScreen extends StatefulWidget {
  final String cardId;
  final Map<String, dynamic> cardData;

  const UpdateCardScreen({super.key, required this.cardId, required this.cardData});

  @override
  _UpdateCardScreenState createState() => _UpdateCardScreenState();
}

class _UpdateCardScreenState extends State<UpdateCardScreen> {
  late String cardNumber;
  late String expiryDate;
  late String cardHolderName;
  late String cvvCode;
  bool isCvvFocused = false;
  late String cardType;
  String? selectedBank;
  final TextEditingController balanceController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final List<String> cardTypes = ['Crédito', 'Débito'];
  final List<String> bankOptions = [
    'BBVA',
    'Banorte',
    'Santander',
    'Citibanamex',
    'Banco Azteca'
  ];

  final FirestoreService firestoreService = FirestoreService();
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    cardNumber = widget.cardData['cardNumber'] ?? '';
    expiryDate = widget.cardData['expiryDate'] ?? '';
    cardHolderName = widget.cardData['cardHolderName'] ?? '';
    cvvCode = widget.cardData['cvvCode'] ?? '';
    cardType = widget.cardData['cardType'] ?? 'Crédito';
    selectedBank = widget.cardData['bank'];
    balanceController.text = widget.cardData['balance'].toString();
  }

  Future<void> updateCardInFirebase() async {
    if (formKey.currentState!.validate() && selectedBank != null) {

      double balance = 0.0;
      if (balanceController.text.isNotEmpty) {
        balance = double.tryParse(balanceController.text) ?? 0.0;
      }

      try {
        await firestoreService.updateCard(
          userId: userId,
          docId: widget.cardId,
          bank: selectedBank!,
          cardHolderName: cardHolderName,
          cardNumber: cardNumber,
          cardType: cardType,
          expiryDate: expiryDate,
          balance: balance,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tarjeta actualizada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        
        await Future.delayed(const Duration(milliseconds: 500));

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar la tarjeta: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Actualizar tarjeta'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              CreditCardWidget(
                cardNumber: cardNumber,
                expiryDate: expiryDate,
                cardHolderName:cardHolderName.isEmpty ? '' : cardHolderName,
                isHolderNameVisible: true,
                cvvCode: '000',
                showBackView: isCvvFocused,
                onCreditCardWidgetChange: (CreditCardBrand cardBrand) {},
              ), 
              CreditCardForm(
                cardNumber: cardNumber,
                expiryDate: expiryDate,
                cardHolderName: cardHolderName,
                isHolderNameVisible: true,
                enableCvv: false,
                cvvCode: '',
                formKey: formKey,
                onCreditCardModelChange: (CreditCardModel data) {
                  setState(() {
                    cardNumber = data.cardNumber;
                    expiryDate = data.expiryDate;
                    cardHolderName = data.cardHolderName;
                    cvvCode = data.cvvCode;
                    isCvvFocused = data.isCvvFocused;
                  });
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Tipo de tarjeta',
                  border: OutlineInputBorder(),
                ),
                value: cardType,
                items: cardTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    cardType = newValue!;
                  });
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Banco',
                  border: OutlineInputBorder(),
                ),
                value: selectedBank,
                items: bankOptions.map((String bank) {
                  return DropdownMenuItem<String>(
                    value: bank,
                    child: Text(bank),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedBank = newValue;
                  });
                },
              ),
              TextField(
                  controller: balanceController,
                  decoration: const InputDecoration(labelText: 'Saldo'),
                  keyboardType: TextInputType.number,
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: updateCardInFirebase,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: const Text('Actualizar Tarjeta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
