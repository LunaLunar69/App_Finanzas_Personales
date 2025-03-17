import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  CollectionReference getCardsCollection(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('tarjetas');
  }

  CollectionReference getTransactionsCollection(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('transactions');
  }

  CollectionReference getCategoriesCollection(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('categories');
  }

  CollectionReference getIngresosCollection(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('ingresos');
  }

  CollectionReference getTransfersCollection(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('transfers');
  }

  DocumentReference getSaldoDoc(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('saldos')
        .doc('saldo');
  }

  DocumentReference getCategoriesDoc(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('categorias')
        .doc('sample');
  }

  CollectionReference getAssetsCollection(String userId) {
    return FirebaseFirestore.instance
        .collection('activos')
        .doc(userId)
        .collection('items');
  }

  Future<void> addCard({
    required String userId,
    required String bank,
    required String cardHolderName,
    required String cardNumber,
    required String cardType,
    required String expiryDate,
    required double initialBalance,
  }) async {
    try {
      final cards = getCardsCollection(userId);
      await cards.add({
        'bank': bank,
        'cardHolderName': cardHolderName,
        'cardNumber': cardNumber,
        'cardType': cardType,
        'expiryDate': expiryDate,
        'timestamp': FieldValue.serverTimestamp(),
        'balance': initialBalance,
      });
    } catch (e) {
      throw Exception('Error adding card: $e');
    }
  }

  Future<bool> isDuplicateCard(String userId, String cardNumber) async {
    try {
      final cards = getCardsCollection(userId);
      final querySnapshot =
          await cards.where('cardNumber', isEqualTo: cardNumber).get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Error checking for duplicate card: $e');
    }
  }

  Stream<QuerySnapshot> getCards(String userId) {
    final cards = getCardsCollection(userId);
    return cards.orderBy('timestamp', descending: true).snapshots();
  }

  Future<void> updateCard({
    required String userId,
    required String docId,
    required String bank,
    required String cardHolderName,
    required String cardNumber,
    required String cardType,
    required String expiryDate,
    required double balance,
  }) async {
    try {
      final cards = getCardsCollection(userId);
      await cards.doc(docId).update({
        'bank': bank,
        'cardHolderName': cardHolderName,
        'cardNumber': cardNumber,
        'cardType': cardType,
        'expiryDate': expiryDate,
        'balance': balance,
      });
    } catch (e) {
      throw Exception('Error updating card: $e');
    }
  }

  Future<void> deleteCard(String userId, String docId) async {
    try {
      final cards = getCardsCollection(userId);
      await cards.doc(docId).delete();
    } catch (e) {
      throw Exception('Error deleting card: $e');
    }
  }

  //saldo operations
  Future<void> setSaldoInicial(String userId, double cantidad) async {
    try {
      final _saldoDoc = getSaldoDoc(userId);
      await _saldoDoc.set({
        'cantidad': cantidad,
      });
    } catch (e) {
      throw Exception('Error setting initial balance: $e');
    }
  }

  Future<double?> getSaldoActual(String userId) async {
    try {
      final _saldoDoc = getSaldoDoc(userId);
      final docSnapshot = await _saldoDoc.get();
      if (docSnapshot.exists) {
        return docSnapshot.get('cantidad') as double;
      }
      return null;
    } catch (e) {
      throw Exception('Error getting current balance: $e');
    }
  }

  Future<bool> checkSaldoExists(String userId) async {
    try {
      final _saldoDoc = getSaldoDoc(userId);
      final docSnapshot = await _saldoDoc.get();
      return docSnapshot.exists;
    } catch (e) {
      throw Exception('Error checking balance existence: $e');
    }
  }

  Future<void> updateSaldo(String userId, double newAmount) async {
    try {
      final _saldoDoc = getSaldoDoc(userId);
      await _saldoDoc.update({
        'cantidad': newAmount,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error updating balance: $e');
    }
  }

  //transactions
  Future<List<Map<String, dynamic>>> getTransactions(String userId) async {
    try {
      final transactions = getTransactionsCollection(userId);
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
    required String userId,
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
      final transactions = getTransactionsCollection(userId);
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
    required String userId,
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
      final transactions = getTransactionsCollection(userId);
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

  Future<void> deleteTransaction(String userId, String docId) async {
    try {
      final transactions = getTransactionsCollection(userId);
      await transactions.doc(docId).delete();
    } catch (e) {
      throw Exception('Error deleting transaction: $e');
    }
  }

  //transfers
  Future<List<Map<String, dynamic>>> getTransfers(String userId) async {
    try {
      final transfers = getTransfersCollection(userId);
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
    required String userId,
    required DateTime date,
    required double amount,
    required String idOriginCount,
    required String idDestinyCount,
    required String originCount,
    required String destinyCount,
  }) async {
    try {
      final cardsCollection = getCardsCollection(userId);
      final transfersCollection = getTransfersCollection(userId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final originDocRef = cardsCollection.doc(idOriginCount);
        final originDocSnapshot = await transaction.get(originDocRef);

        if (!originDocSnapshot.exists) {
          throw Exception('La cuenta de origen no existe');
        }

        final double currentBalance =
            originDocSnapshot.get('balance') as double;

        //verify theres enough money lol
        if (currentBalance < amount) {
          throw Exception(
              'Fondos insuficientes en la cuenta de origen. Balance: $currentBalance, Monto a transferir: $amount');
        }

        final destinyDocRef = cardsCollection.doc(idDestinyCount);
        final destinyDocSnapshot = await transaction.get(destinyDocRef);

        if (!destinyDocSnapshot.exists) {
          throw Exception('La cuenta de destino no existe');
        }

        final double destinyBalance =
            destinyDocSnapshot.get('balance') as double;

        //upate the balance field in both account cards
        transaction.update(originDocRef, {
          'balance': currentBalance - amount,
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        transaction.update(destinyDocRef, {
          'balance': destinyBalance + amount,
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        transaction.set(transfersCollection.doc(), {
          'date': date,
          'amount': amount,
          'idOriginCount': idOriginCount,
          'idDestinyCount': idDestinyCount,
          'originCount': originCount,
          'destinyCount': destinyCount,
          'timestamp': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      // Capturar y relanzar la excepción con un mensaje descriptivo
      throw Exception('Error en la transferencia: $e');
    }
  }

  Future<void> updateTransfer({
    required String userId,
    required String docId,
    required DateTime date,
    required double amount,
    required String idOriginCount,
    required String idDestinyCount,
    required String originCount,
    required String destinyCount,
  }) async {
    try {
      final cardsCollection = getCardsCollection(userId);
      final transfersCollection = getTransfersCollection(userId);
      final transferDocRef = transfersCollection.doc(docId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final transferSnapshot = await transaction.get(transferDocRef);

        if (!transferSnapshot.exists) {
          throw Exception('La transferencia no existe');
        }

        final previousData = transferSnapshot.data() as Map<String, dynamic>;
        final double previousAmount = previousData['amount'] as double;
        final String previousOriginId = previousData['idOriginCount'] as String;
        final String previousDestinyId =
            previousData['idDestinyCount'] as String;

        final bool accountsChanged = previousOriginId != idOriginCount ||
            previousDestinyId != idDestinyCount;

        final originDocRef = cardsCollection.doc(idOriginCount);
        final destinyDocRef = cardsCollection.doc(idDestinyCount);

        final originSnapshot = await transaction.get(originDocRef);
        final destinySnapshot = await transaction.get(destinyDocRef);

        if (!originSnapshot.exists || !destinySnapshot.exists) {
          throw Exception('Una o ambas cuentas no existen');
        }

        DocumentReference? previousOriginDocRef;
        DocumentReference? previousDestinyDocRef;
        DocumentSnapshot? previousOriginSnapshot;
        DocumentSnapshot? previousDestinySnapshot;

        if (accountsChanged) {
          previousOriginDocRef = cardsCollection.doc(previousOriginId);
          previousDestinyDocRef = cardsCollection.doc(previousDestinyId);

          previousOriginSnapshot = await transaction.get(previousOriginDocRef);
          previousDestinySnapshot =
              await transaction.get(previousDestinyDocRef);

          if (!previousOriginSnapshot.exists ||
              !previousDestinySnapshot.exists) {
            throw Exception('Una o ambas cuentas anteriores no existen');
          }
        }

        double originBalance = originSnapshot.get('balance') as double;
        double destinyBalance = destinySnapshot.get('balance') as double;

        //if the accounts have changed, revert the changes
        if (accountsChanged) {
          double previousOriginBalance =
              previousOriginSnapshot!.get('balance') as double;
          double previousDestinyBalance =
              previousDestinySnapshot!.get('balance') as double;

          transaction.update(previousOriginDocRef!, {
            'balance': previousOriginBalance + previousAmount,
            'lastUpdated': FieldValue.serverTimestamp(),
          });

          transaction.update(previousDestinyDocRef!, {
            'balance': previousDestinyBalance - previousAmount,
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        } else {
          double amountDifference = amount - previousAmount;

          //verify if theres enough money XD
          if (amountDifference > 0 && originBalance < amountDifference) {
            throw Exception(
                'Fondos insuficientes para aumentar el monto de la transferencia');
          }
          originBalance -= amountDifference;
          destinyBalance += amountDifference;

          transaction.update(originDocRef, {
            'balance': originBalance,
            'lastUpdated': FieldValue.serverTimestamp(),
          });

          transaction.update(destinyDocRef, {
            'balance': destinyBalance,
            'lastUpdated': FieldValue.serverTimestamp(),
          });

          transaction.update(transferDocRef, {
            'date': date,
            'amount': amount,
            'originCount': originCount,
            'destinyCount': destinyCount,
          });

          return;
        }

        if (originBalance < amount) {
          throw Exception('Fondos insuficientes en la cuenta de origen');
        }

        //update the balance in the correspondant card account
        transaction.update(originDocRef, {
          'balance': originBalance - amount,
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        transaction.update(destinyDocRef, {
          'balance': destinyBalance + amount,
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        transaction.update(transferDocRef, {
          'date': date,
          'amount': amount,
          'idOriginCount': idOriginCount,
          'idDestinyCount': idDestinyCount,
          'originCount': originCount,
          'destinyCount': destinyCount,
        });
      });
    } catch (e) {
      throw Exception('Error al actualizar la transferencia: $e');
    }
  }

  Future<void> deleteTransfer({
    required String userId,
    required String docId,
  }) async {
    try {
      final cardsCollection = getCardsCollection(userId);
      final transfersCollection = getTransfersCollection(userId);
      final transferDocRef = transfersCollection.doc(docId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final transferSnapshot = await transaction.get(transferDocRef);

        if (!transferSnapshot.exists) {
          throw Exception('La transferencia no existe');
        }

        final transferData = transferSnapshot.data() as Map<String, dynamic>;
        final double amount = transferData['amount'] as double;
        final String idOriginCount = transferData['idOriginCount'] as String;
        final String idDestinyCount = transferData['idDestinyCount'] as String;

        final originDocRef = cardsCollection.doc(idOriginCount);
        final destinyDocRef = cardsCollection.doc(idDestinyCount);

        final originSnapshot = await transaction.get(originDocRef);
        final destinySnapshot = await transaction.get(destinyDocRef);

        if (!originSnapshot.exists || !destinySnapshot.exists) {
          throw Exception('Una o ambas cuentas no existen');
        }

        //get balance data from both accounts
        double originBalance = originSnapshot.get('balance') as double;
        double destinyBalance = destinySnapshot.get('balance') as double;

        //revert the transfer
        transaction.update(originDocRef, {
          'balance': originBalance + amount,
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        transaction.update(destinyDocRef, {
          'balance': destinyBalance - amount,
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        transaction.delete(transferDocRef);
      });
    } catch (e) {
      throw Exception('Error al eliminar la transferencia: $e');
    }
  }

  //categories
  Future<void> addCategory(String name, String userId) async {
    try {
      final categories = getCategoriesCollection(userId);
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
    final categories = getCategoriesCollection(userId);
    return categories.doc(userId).snapshots();
  }

  //arath's part lol
  Future<void> guardarIngreso(
      String userId, Map<String, dynamic> ingresoData) async {
    try {
      final _ingresosCollection = getIngresosCollection(userId);
      await _ingresosCollection.add(ingresoData);
      print('Ingreso guardado correctamente.');
    } catch (e) {
      print('Error al guardar el ingreso: $e');
      rethrow;
    }
  }

  //activos
  Future<void> addAsset(
      String userId, String nombre, String descripcion) async {
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
    return getAssetsCollection(userId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> updateAsset(
      String userId, String assetId, String nombre, String descripcion) async {
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
