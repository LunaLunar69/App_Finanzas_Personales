import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:minimallogin/querys/firestore.dart';


class CreditCardScreen extends StatefulWidget {
  const CreditCardScreen({super.key});

  @override
  _CreditCardScreenState createState() => _CreditCardScreenState();
}
 
class _CreditCardScreenState extends State<CreditCardScreen> {
  
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  String cardType = 'Crédito';
  String? selectedBank;
  final TextEditingController initialBalanceController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final List<String> cardTypes = ['Crédito', 'Débito'];
  final List<String> bankOptions = [
    'BBVA',
    'Banorte',
    'Santander',
    'Citibanamex',
    'Banco Azteca'
  ];

  final FirestoreService firestoreService =
      FirestoreService(); // Usa FirestoreService
  final String userId = FirebaseAuth.instance.currentUser!.uid;


  Future<void> saveCardToFirebase() async {
    if (formKey.currentState!.validate() && selectedBank != null) {

      bool isDuplicate = await firestoreService.isDuplicateCard(userId, cardNumber);

      if (isDuplicate) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('El número de tarjeta ya existe.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      double initialBalance = 0.0;
      if (initialBalanceController.text.isNotEmpty) {
        initialBalance = double.tryParse(initialBalanceController.text) ?? 0.0;
      }

      try {
        await firestoreService.addCard(
          userId: userId,
          bank: selectedBank!,
          cardHolderName: cardHolderName,
          cardNumber: cardNumber,
          cardType: cardType,
          expiryDate: expiryDate,
          initialBalance: initialBalance
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tarjeta guardada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );

        await Future.delayed(const Duration(milliseconds: 500));
        
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar la tarjeta: $e'),
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
        title: const Text('Crear tarjeta'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              CreditCardWidget(
                cardNumber: cardNumber,
                expiryDate: expiryDate,
                cardHolderName: cardHolderName.isEmpty ? '' : cardHolderName,
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
                formKey: formKey,
                onCreditCardModelChange: (CreditCardModel data) {
                  setState(() {
                    cardNumber = data.cardNumber;
                    expiryDate = data.expiryDate;
                    cardHolderName = data.cardHolderName;
                    isCvvFocused = data.isCvvFocused;
                  });
                }, cvvCode: '',
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
                  controller: initialBalanceController,
                  decoration: const InputDecoration(labelText: 'Saldo inicial'),
                  keyboardType: TextInputType.number,
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: saveCardToFirebase,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: const Text('Guardar Tarjeta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
