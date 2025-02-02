import 'package:minimallogin/querys/firestore.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TransfersPage extends StatefulWidget {
  const TransfersPage({super.key});

  @override
  _TransfersPageState createState() => _TransfersPageState();
}

class _TransfersPageState extends State<TransfersPage> {
  final FirestoreService firestoreService = FirestoreService();
  List<Map<String, dynamic>> transfers = [];
  List<Map<String, dynamic>> filteredTransfers = [];
  List<String> cardHolders = [];

  final TextEditingController _searchController = TextEditingController();
  String _searchBy = 'amount'; // Campo de búsqueda por defecto

  @override
  void initState() {
    super.initState();
    _loadTransfers();
    _loadCardHolders();
  }

  Future<void> _loadTransfers() async {
    final loadedTransfers = await firestoreService.getTransfers();
    setState(() {
      transfers = loadedTransfers;
      filteredTransfers = loadedTransfers;
    });
  }

  Future<void> _loadCardHolders() async {
    final QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('tarjetas').get();

    setState(() {
      cardHolders = querySnapshot.docs
          .map((doc) => doc['cardHolderName'] as String)
          .toList();
    });
  }

  void _filterTransfers(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredTransfers = transfers;
      } else {
        filteredTransfers = transfers.where((transfer) {
          switch (_searchBy) {
            case 'amount':
              // Convertir monto a cadena para comparación
              return transfer['amount'].toString().contains(query);
            case 'date':
              // Convertir fecha a cadena formateada para comparación
              String formattedDate = DateFormat('yyyy-MM-dd')
                  .format((transfer['date'] as Timestamp).toDate());
              return formattedDate.contains(query);
            default:
              return false;
          }
        }).toList();
      }
    });
  }

  Future<void> _showEditTransferDialog(Map<String, dynamic> transfer) async {
    final TextEditingController amountController =
        TextEditingController(text: transfer['amount']?.toString() ?? '0');

    String? selectedOriginCount = transfer['originCount'];
    String? selectedDestinyCount = transfer['destinyCount'];
    DateTime selectedDate = (transfer['date'] as Timestamp).toDate();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Transferencia'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Cuenta de Origen',
                  border: OutlineInputBorder(),
                ),
                value: selectedOriginCount,
                items: cardHolders.map((String number) {
                  return DropdownMenuItem<String>(
                    value: number,
                    child: Text(number),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedOriginCount = newValue;
                  });
                },
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Cuenta de Destino',
                  border: OutlineInputBorder(),
                ),
                value: selectedDestinyCount,
                items: cardHolders.map((String number) {
                  return DropdownMenuItem<String>(
                    value: number,
                    child: Text(number),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedDestinyCount = newValue;
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
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              if (selectedOriginCount == null ||
                  selectedDestinyCount == null ||
                  amountController.text.isEmpty) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Alerta'),
                    content: const Text('Por favor, complete todos los campos'),
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

              await firestoreService.updateTransfer(
                docId: transfer['id'],
                date: selectedDate,
                amount: double.tryParse(amountController.text) ?? 0,
                originCount: selectedOriginCount!,
                destinyCount: selectedDestinyCount!,
              );

              _loadTransfers();
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddTransferDialog() async {
    final TextEditingController amountController = TextEditingController();

    String? selectedOriginCount;
    String? selectedDestinyCount;
    DateTime selectedDate = DateTime.now();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Transferencia'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration( 
                  labelText: 'Cuenta de Origen',
                  border: OutlineInputBorder(),
                ),
                items: cardHolders.map((String number) {
                  return DropdownMenuItem<String>(
                    value: number,
                    child: Text(number),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedOriginCount = newValue;
                  });
                },
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Cuenta de Destino',
                  border: OutlineInputBorder(),
                ),
                items: cardHolders.map((String number) {
                  return DropdownMenuItem<String>(
                    value: number,
                    child: Text(number),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedDestinyCount = newValue;
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
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              if (selectedOriginCount == null ||
                  selectedDestinyCount == null ||
                  amountController.text.isEmpty) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Alerta'),
                    content: const Text('Por favor complete todos los campos'),
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

              await firestoreService.addTransfer(
                date: selectedDate,
                amount: double.tryParse(amountController.text) ?? 0,
                originCount: selectedOriginCount!,
                destinyCount: selectedDestinyCount!,
              );

              _loadTransfers();
              Navigator.pop(context);
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(
      Map<String, dynamic> transfer) async {
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
                    '¿Está seguro de que desea eliminar esta transferencia?'),
                Text('Monto: ${transfer['amount']}'),
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
                await firestoreService.deleteTransfer(transfer['id']);
                _loadTransfers();
                Navigator.of(context).pop();
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
        title: const Text('Transpasos'),
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight * 2),
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: _showAddTransferDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar transaccion'),
                ),
              ],
            ),
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
                      onChanged: _filterTransfers,
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
      body: Column(children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Acciones')),
                  DataColumn(label: Text('Fecha')),
                  DataColumn(label: Text('Cuenta de Origen')),
                  DataColumn(label: Text('Cuenta de Destino')),
                  DataColumn(label: Text('Monto')),
                ],
                
                rows: (filteredTransfers.isNotEmpty ? filteredTransfers : transfers).map((transfer) {
                  return DataRow(
                    cells: [
                      DataCell(Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showEditTransferDialog(transfer),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () =>
                                _showDeleteConfirmationDialog(transfer),
                          ),
                        ],
                      )),
                      DataCell(Text(DateFormat('yyyy-MM-dd')
                          .format((transfer['date'] as Timestamp).toDate()))),
                      DataCell(Text(transfer['originCount'].toString())),
                      DataCell(Text(transfer['destinyCount'].toString())),
                      DataCell(Text(transfer['amount'].toString())),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
