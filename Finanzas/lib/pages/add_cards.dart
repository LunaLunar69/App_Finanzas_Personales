
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:minimallogin/querys/firestore.dart';

//acuerdate de mi monster we

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
      FirestoreService(); // Use FirestoreService

  Future<void> saveCardToFirebase() async {
    if (formKey.currentState!.validate() && selectedBank != null) {
      bool isDuplicate = await firestoreService.isDuplicateCard(cardNumber);

      if (isDuplicate) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('El número de tarjeta ya existe.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      try {
        await firestoreService.addCard(
          bank: selectedBank!,
          cardHolderName: cardHolderName,
          cardNumber: cardNumber,
          cardType: cardType,
          cvvCode: cvvCode,
          expiryDate: expiryDate,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tarjeta guardada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );

        setState(() {
          cardNumber = '';
          expiryDate = '';
          cardHolderName = '';
          cvvCode = '';
          selectedBank = null;
          cardType = 'Crédito';
        });
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
                cardHolderName:
                    cardHolderName.isEmpty ? 'CARDHOLDER NAME' : cardHolderName,
                cvvCode: cvvCode,
                showBackView: isCvvFocused,
                onCreditCardWidgetChange: (CreditCardBrand cardBrand) {},
              ),
              CreditCardForm(
                cardNumber: cardNumber,
                expiryDate: expiryDate,
                cardHolderName: cardHolderName,
                isHolderNameVisible: true,
                cvvCode: cvvCode,
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
