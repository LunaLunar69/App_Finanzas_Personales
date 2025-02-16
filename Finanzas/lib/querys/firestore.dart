import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference cards = FirebaseFirestore.instance.collection('tarjetas');
  final CollectionReference transactions = FirebaseFirestore.instance.collection('transactions');
  final CollectionReference categories = FirebaseFirestore.instance.collection('categories');
  final CollectionReference _ingresosCollection = FirebaseFirestore.instance.collection('ingresos');
  final CollectionReference transfers = FirebaseFirestore.instance.collection('transfers');
  final DocumentReference _saldoDoc = FirebaseFirestore.instance.collection('saldos').doc('saldo');
  final DocumentReference categoriesDoc = FirebaseFirestore.instance.collection('categorias').doc('sample');
  
  CollectionReference getAssetsCollection(String userId) {
    return FirebaseFirestore.instance.collection('activos').doc(userId).collection('items');
  }

  Future<void> addCard({
    required String bank,
    required String cardHolderName,
    required String cardNumber,
    required String cardType,
    required String cvvCode,
    required String expiryDate,
  }) async {
    try {
      await cards.add({
        'bank': bank,
        'cardHolderName': cardHolderName,
        'cardNumber': cardNumber,
        'cardType': cardType,
        'cvvCode': cvvCode,
        'expiryDate': expiryDate,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error adding card: $e');
    }
  }

  Future<bool> isDuplicateCard(String cardNumber) async {
    try {
      final querySnapshot =
          await cards.where('cardNumber', isEqualTo: cardNumber).get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Error checking for duplicate card: $e');
    }
  }

  Stream<QuerySnapshot> getCards() {
    return cards.orderBy('timestamp', descending: true).snapshots();
  }

  Future<void> updateCard({
    required String docId,
    required String bank,
    required String cardHolderName,
    required String cardNumber,
    required String cardType,
    required String cvvCode,
    required String expiryDate,
  }) async {
    try {
      await cards.doc(docId).update({
        'bank': bank,
        'cardHolderName': cardHolderName,
        'cardNumber': cardNumber,
        'cardType': cardType,
        'cvvCode': cvvCode,
        'expiryDate': expiryDate,
      });
    } catch (e) {
      throw Exception('Error updating card: $e');
    }
  }

  Future<void> deleteCard(String docId) async {
    try {
      await cards.doc(docId).delete();
    } catch (e) {
      throw Exception('Error deleting card: $e');
    }
  }

  //saldo operations
  Future<void> setSaldoInicial(double cantidad) async {
    try {
      await _saldoDoc.set({
        'cantidad': cantidad,
      });
    } catch (e) {
      throw Exception('Error setting initial balance: $e');
    }
  }

  Future<double?> getSaldoActual() async {
    try {
      final docSnapshot = await _saldoDoc.get();
      if (docSnapshot.exists) {
        return docSnapshot.get('cantidad') as double;
      }
      return null;
    } catch (e) {
      throw Exception('Error getting current balance: $e');
    }
  }

  Future<bool> checkSaldoExists() async {
    try {
      final docSnapshot = await _saldoDoc.get();
      return docSnapshot.exists;
    } catch (e) {
      throw Exception('Error checking balance existence: $e');
    }
  }

  Future<void> updateSaldo(double newAmount) async {
    try {
      await _saldoDoc.update({
        'cantidad': newAmount,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error updating balance: $e');
    }
  }

  //transactions
  Future<List<Map<String, dynamic>>> getTransactions() async {
    try {
      final QuerySnapshot snapshot =
          await transactions.orderBy('date', descending: true).get();
      return snapshot.docs
          .map((doc) => {
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              })
          .toList();
    } catch (e) {
      throw Exception('Error loading transactions: $e');
    }
  }

  Future<void> addTransaction({
    required DateTime date,
    required String concept,
    required String invoiceNumber,
    required double import,
    required String description,
    required double currentBalance,
    required String category,
    required String method,
    required double amount,
    required DateTime paymentDate,
    required double balance,
  }) async {
    try {
      await transactions.add({
        'date': date,
        'concept': concept,
        'invoiceNumber': invoiceNumber,
        'import': import,
        'description': description,
        'currentBalance': currentBalance,
        'category': category,
        'method': method,
        'amount': amount,
        'paymentDate': paymentDate,
        'balance': balance,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error adding transaction: $e');
    }
  }

  Future<void> updateTransaction({
    required String docId,
    required DateTime date,
    required String concept,
    required String invoiceNumber,
    required double import,
    required String description,
    required double currentBalance,
    required String category,
    required String method,
    required double amount,
    required DateTime paymentDate,
    required double balance,
  }) async {
    try {
      await transactions.doc(docId).update({
        'date': date,
        'concept': concept,
        'invoiceNumber': invoiceNumber,
        'import': import,
        'description': description,
        'currentBalance': currentBalance,
        'category': category,
        'method': method,
        'amount': amount,
        'paymentDate': paymentDate,
        'balance': balance,
      });
    } catch (e) {
      throw Exception('Error updating transaction: $e');
    }
  }

  Future<void> deleteTransaction(String docId) async {
    try {
      await transactions.doc(docId).delete();
    } catch (e) {
      throw Exception('Error deleting transaction: $e');
    }
  }

  //transfers
  Future<List<Map<String, dynamic>>> getTransfers() async {
    try {
      final QuerySnapshot snapshot =
          await transfers.orderBy('date', descending: true).get();
      return snapshot.docs
          .map((doc) => {
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              })
          .toList();
    } catch (e) {
      throw Exception('Error loading Transfers: $e');
    }
  }

  Future<void> addTransfer({
    required DateTime date,
    required double amount,
    required String originCount,
    required String destinyCount,
  }) async {
    try {
      await transfers.add({
        'date': date,
        'amount': amount,
        'originCount': originCount,
        'destinyCount': destinyCount,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error adding transaction: $e');
    }
  }

  Future<void> updateTransfer({
    required String docId,
    required DateTime date,
    required double amount,
    required String originCount,
    required String destinyCount,
  }) async {
    try {
      await transfers.doc(docId).update({
        'date': date,
        'amount': amount,
        'originCount': originCount,
        'destinyCount': destinyCount,
      });
    } catch (e) {
      throw Exception('Error updating transaction: $e');
    }
  }

  Future<void> deleteTransfer(String docId) async {
    try {
      await transfers.doc(docId).delete();
    } catch (e) {
      throw Exception('Error deleting transaction: $e');
    }
  }

  //categories
  Future<void> addCategory(String name, String userId) async {
    try {
      
      DocumentReference userDoc = categories.doc(userId);
      DocumentSnapshot docSnapshot = await userDoc.get();

      if (docSnapshot.exists) {
        await userDoc.update({
          'categorias': FieldValue.arrayUnion([name])
        });
      } else {
        await userDoc.set({
          'categorias': [name]
        });
      }
    } catch (e) {
      throw Exception('Error adding category: $e');
    }
  }

  Stream<DocumentSnapshot> getCategories(String userId) {
    return categories.doc(userId).snapshots();
  }

  //arath's part lol
  Future<void> guardarIngreso(Map<String, dynamic> ingresoData) async {
    try {
      await _ingresosCollection.add(ingresoData);
      print('Ingreso guardado correctamente.');
    } catch (e) {
      print('Error al guardar el ingreso: $e');
      rethrow;
    }
  }

  //activos
  Future<void> addAsset(String userId, String nombre, String descripcion) async {
    try {
      await getAssetsCollection(userId).add({
        'nombre': nombre,
        'descripcion': descripcion,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error adding asset: $e');
    }
  }

  Stream<QuerySnapshot> getAssets(String userId) {
    return getAssetsCollection(userId).orderBy('timestamp', descending: true).snapshots();
  }

  Future<void> updateAsset(String userId, String assetId, String nombre, String descripcion) async {
    try {
      await getAssetsCollection(userId).doc(assetId).update({
        'nombre': nombre,
        'descripcion': descripcion,
      });
    } catch (e) {
      throw Exception('Error updating asset: $e');
    }
  }

  Future<void> deleteAsset(String userId, String assetId) async {
    try {
      await getAssetsCollection(userId).doc(assetId).delete();
    } catch (e) {
      throw Exception('Error deleting asset: $e');
    }
  }

}
