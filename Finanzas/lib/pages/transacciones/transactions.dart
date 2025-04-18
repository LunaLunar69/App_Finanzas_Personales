import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:minimallogin/querys/firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  TransactionsPageState createState() => TransactionsPageState();
}

class TransactionsPageState extends State<TransactionsPage> {
  final FirestoreService firestoreService = FirestoreService();
  final categoriesStreamController = StreamController<List<String>>();
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  List<Map<String, dynamic>> transactions = [];
  List<Map<String, dynamic>> filteredTransactions = [];

  final TextEditingController _searchController = TextEditingController();
  String _searchBy = 'amount'; // Default search field

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  //positive number validation input formatter
  final _positiveNumberFormatter = FilteringTextInputFormatter.allow(
    RegExp(r'^[1-9]\d*(\.\d+)?$'),
  );

  Future<void> _loadTransactions() async {
    final loadedTransactions = await firestoreService.getTransactions(userId);
    setState(() {
      transactions = loadedTransactions;
      filteredTransactions = loadedTransactions;
    });
  }

  late StreamSubscription? categoriesSubscription;
  List<String> allCategories = [];
  final List<String> defaultCategories = [
    'Pasajes',
    'Hobbies',
    'Escuela',
    'Salud',
    'Comida'
  ];

  //get categories from Firebase
  void initializeCategories(String userId) {
    categoriesSubscription =
        firestoreService.getCategories(userId).listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        final List<String> firebaseCategories =
            List<String>.from(data['categorias'] ?? [])
                .where((category) => !defaultCategories.contains(category))
                .toList();

        setState(() {
          allCategories = [...defaultCategories, ...firebaseCategories];
        });
      }
    });
  }

  Future<void> _showAddTransactionDialog() async {
    final categoriesStreamController = StreamController<List<String>>.broadcast();
    
    final TextEditingController conceptController = TextEditingController();
    final TextEditingController invoiceNumberController = TextEditingController();
    final TextEditingController importController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController currentBalanceController = TextEditingController();
    final TextEditingController amountController = TextEditingController();

    String method = 'Crédito';
    final List<String> methods = ['Efectivo', 'Crédito'];

    String? selectedCategory;
    List<String> dialogCategories = List.from(defaultCategories);

    DateTime selectedDate = DateTime.now();
    DateTime paymentDate = DateTime.now();

    firestoreService.getCategories(userId).listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        final List<String> firebaseCategories = 
            List<String>.from(data['categorias'] ?? [])
                .where((category) => !defaultCategories.contains(category))
                .toList();
        
        //to add the default categories and the categories from firebase
        final combinedCategories = [...defaultCategories, ...firebaseCategories];
        categoriesStreamController.add(combinedCategories);
      } else {
        categoriesStreamController.add(defaultCategories);
      }
    });

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Agregar transacción'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: conceptController,
                  decoration: const InputDecoration(labelText: 'Concepto'),
                ),
                TextField(
                  controller: invoiceNumberController,
                  decoration: const InputDecoration(labelText: 'Número de factura'),
                ),
                TextField(
                  controller: importController,
                  decoration: const InputDecoration(labelText: 'Importe'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                  maxLines: 3,
                ),
                TextField(
                  controller: currentBalanceController,
                  decoration: const InputDecoration(labelText: 'Saldo actual'),
                  keyboardType: TextInputType.number,
                ),
                StreamBuilder<List<String>>(
                  stream: categoriesStreamController.stream,
                  initialData: dialogCategories,
                  builder: (context, snapshot) {
                    final categories = snapshot.data ?? dialogCategories;
                    
                    return DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Categoría',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedCategory,
                      items: categories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCategory = newValue;
                        });
                      },
                    );
                  },
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Método',
                    border: OutlineInputBorder(),
                  ),
                  value: method,
                  items: methods.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      method = newValue!;
                    });
                  },
                ),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(labelText: 'Monto'),
                  keyboardType: TextInputType.number,
                ),
                ListTile(
                  title: const Text('Fecha'),
                  subtitle: Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                ),
                ListTile(
                  title: const Text('Fecha de pago'),
                  subtitle: Text(DateFormat('yyyy-MM-dd').format(paymentDate)),
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: paymentDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        paymentDate = picked;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                categoriesStreamController.close();
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                if (conceptController.text.isEmpty ||
                    invoiceNumberController.text.isEmpty ||
                    importController.text.isEmpty ||
                    descriptionController.text.isEmpty ||
                    amountController.text.isEmpty ||
                    selectedCategory == null) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Alerta'),
                      content: const Text('Por favor complete todos los campos obligatorios'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Aceptar'),
                        ),
                      ],
                    ),
                  );
                  return;
                }

                await firestoreService.addTransaction(
                  userId: userId,
                  date: selectedDate,
                  concept: conceptController.text,
                  invoiceNumber: invoiceNumberController.text,
                  import: double.tryParse(importController.text) ?? 0,
                  description: descriptionController.text,
                  currentBalance: double.tryParse(currentBalanceController.text) ?? 0,
                  category: selectedCategory!,
                  method: method,
                  amount: double.tryParse(amountController.text) ?? 0,
                  paymentDate: paymentDate,
                  balance: 0,
                );
                
                categoriesStreamController.close();
                _loadTransactions();
                Navigator.pop(context);
              },
              child: const Text('Agregar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditTransactionDialog(Map<String, dynamic> transaction) async {
    final TextEditingController conceptController =
        TextEditingController(text: transaction['concept'] ?? '');
    final TextEditingController invoiceNumberController =
        TextEditingController(text: transaction['invoiceNumber'] ?? '');
    final TextEditingController importController =
        TextEditingController(text: transaction['import']?.toString() ?? '0');
    final TextEditingController descriptionController =
        TextEditingController(text: transaction['description'] ?? '');
    final TextEditingController currentBalanceController =
        TextEditingController(text: transaction['currentBalance']?.toString() ?? '0');
    final TextEditingController amountController =
        TextEditingController(text: transaction['amount']?.toString() ?? '0');

    String method = transaction['method'] ?? 'Crédito';
    final List<String> methods = ['Efectivo', 'Crédito'];

    final categoriesStreamController = StreamController<List<String>>();

    firestoreService.getCategories('sampleUser').listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        final List<String> firebaseCategories = 
            List<String>.from(data['categorias'] ?? [])
                .where((category) => !defaultCategories.contains(category))
                .toList();
        
        final combinedCategories = [...defaultCategories, ...firebaseCategories];
        categoriesStreamController.add(combinedCategories);
      } else {
        categoriesStreamController.add(defaultCategories);
      }
    });

    DateTime selectedDate = (transaction['date'] as Timestamp).toDate();
    DateTime paymentDate = (transaction['paymentDate'] as Timestamp).toDate();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Editar transacción'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: conceptController,
                  decoration: const InputDecoration(labelText: 'Concepto'),
                ),
                TextField(
                  controller: invoiceNumberController,
                  decoration: const InputDecoration(labelText: 'Numero de factura'),
                ),
                TextField(
                  controller: importController,
                  decoration: const InputDecoration(labelText: 'Importe'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Descripcion'),
                  maxLines: 3,
                ),
                TextField(
                  controller: currentBalanceController,
                  decoration: const InputDecoration(labelText: 'Saldo actual'),
                  keyboardType: TextInputType.number,
                ),
                StreamBuilder<List<String>>(
                  stream: categoriesStreamController.stream,
                  initialData: defaultCategories,
                  builder: (context, snapshot) {
                    final categories = snapshot.data ?? defaultCategories;
                    
                    return DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Categoría',
                        border: OutlineInputBorder(),
                      ),
                      value: transaction['category'],
                      items: categories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          transaction['category'] = newValue!;
                        });
                      },
                    );
                  },
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Metodo',
                    border: OutlineInputBorder(),
                  ),
                  value: method,
                  items: methods.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      method = newValue!;
                    });
                  },
                ),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(labelText: 'Monto'),
                  keyboardType: TextInputType.number,
                ),
                ListTile(
                  title: const Text('Fecha'),
                  subtitle: Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                ),
                ListTile(
                  title: const Text('Fecha de pago'),
                  subtitle: Text(DateFormat('yyyy-MM-dd').format(paymentDate)),
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: paymentDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        paymentDate = picked;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                categoriesStreamController.close();
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                if (conceptController.text.isEmpty ||
                    invoiceNumberController.text.isEmpty ||
                    importController.text.isEmpty ||
                    descriptionController.text.isEmpty ||
                    amountController.text.isEmpty ||
                    transaction['category'] == null) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Alerta'),
                      content: const Text('Por favor complete todos los campos obligatorios'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Aceptar'),
                        ),
                      ],
                    ),
                  );
                  return;
                }

                await firestoreService.updateTransaction(
                  userId: userId,
                  docId: transaction['id'],
                  date: selectedDate,
                  concept: conceptController.text,
                  invoiceNumber: invoiceNumberController.text,
                  import: double.tryParse(importController.text) ?? 0,
                  description: descriptionController.text,
                  currentBalance: double.tryParse(currentBalanceController.text) ?? 0,
                  category: transaction['category'],
                  method: method,
                  amount: double.tryParse(amountController.text) ?? 0,
                  paymentDate: paymentDate,
                  balance: transaction['balance'] ?? 0,
                );
                categoriesStreamController.close();
                _loadTransactions();
                Navigator.pop(context);
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );

    categoriesStreamController.close();
  }
  Future<void> _showAddCategoryDialog() async {
    final TextEditingController categoryController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar categoria'),
        content: TextField(
          controller: categoryController,
          decoration: const InputDecoration(labelText: 'Nombre'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              if (categoryController.text.isNotEmpty) {
                await firestoreService.addCategory(
                    categoryController.text, 'sampleUser');
                Navigator.pop(context);
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(
      Map<String, dynamic> transaction) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text(
                    '¿Está seguro de que desea eliminar esta transacción?'),
                Text('Concepto: ${transaction['concept']}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Eliminar'),
              onPressed: () async {
                await firestoreService.deleteTransaction(userId, transaction['id']);
                _loadTransactions();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  TextField _buildPositiveNumberField(
      {required TextEditingController controller, required String labelText}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: labelText),
      keyboardType: TextInputType.number,
      inputFormatters: [
        _positiveNumberFormatter,
      ],
    );
  }

  void _filterTransactions(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredTransactions = transactions;
      } else {
        filteredTransactions = transactions.where((transaction) {
          switch (_searchBy) {
            case 'amount':
              return transaction['amount'].toString().contains(query);
            case 'date':
              String formattedDate = DateFormat('yyyy-MM-dd')
                  .format((transaction['date'] as Timestamp).toDate());
              return formattedDate.contains(query);
            default:
              return false;
          }
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transacciones'),
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight * 2),
          child: Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                ElevatedButton.icon(
                  onPressed: _showAddTransactionDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Transacción'),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _showAddCategoryDialog,
                  icon: const Icon(Icons.category),
                  label: const Text('Categoria'),
                ),
              ]),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    // Search field dropdown
                    DropdownButton<String>(
                      value: _searchBy,
                      items: const [
                        DropdownMenuItem(
                          value: 'amount',
                          child: Text('Monto'),
                        ),
                        DropdownMenuItem(
                          value: 'date',
                          child: Text('Fecha'),
                        ),
                      ],
                      onChanged: (String? newValue) {
                        setState(() {
                          _searchBy = newValue!;
                        });
                      },
                    ),
                    const SizedBox(width: 10),
                    // Expanded search text field
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText:
                              'Buscar por ${_searchBy == 'amount' ? 'monto' : 'fecha'}',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onChanged: _filterTransactions,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Acciones')),
                    DataColumn(label: Text('Fecha')),
                    DataColumn(label: Text('Concepto')),
                    DataColumn(label: Text('Numero de factura')),
                    DataColumn(label: Text('Importe')),
                    DataColumn(label: Text('Descripcion')),
                    DataColumn(label: Text('Saldo actual')),
                    DataColumn(label: Text('Categoria')),
                    DataColumn(label: Text('Metodo')),
                    DataColumn(label: Text('Monto')),
                    DataColumn(label: Text('Fecha de pago')),
                    DataColumn(label: Text('Saldo')),
                  ],
                  rows: (filteredTransactions.isNotEmpty
                          ? filteredTransactions
                          : transactions)
                      .map((transaction) {
                    return DataRow(
                      cells: [
                        DataCell(Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () =>
                                  _showEditTransactionDialog(transaction),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () =>
                                  _showDeleteConfirmationDialog(transaction),
                            ),
                          ],
                        )),
                        DataCell(Text(DateFormat('yyyy-MM-dd').format(
                            (transaction['date'] as Timestamp).toDate()))),
                        DataCell(Text(transaction['concept'] ?? '')),
                        DataCell(Text(transaction['invoiceNumber'] ?? '')),
                        DataCell(Text(transaction['import'].toString())),
                        DataCell(Text(transaction['description'] ?? '')),
                        DataCell(
                            Text(transaction['currentBalance'].toString())),
                        DataCell(Text(transaction['category'] ?? '')),
                        DataCell(Text(transaction['method'] ?? '')),
                        DataCell(Text(transaction['amount'].toString())),
                        DataCell(Text(DateFormat('yyyy-MM-dd').format(
                            (transaction['paymentDate'] as Timestamp)
                                .toDate()))),
                        DataCell(Text(transaction['balance'].toString())),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
