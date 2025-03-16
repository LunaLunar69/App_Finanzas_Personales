import 'package:firebase_auth/firebase_auth.dart';
import 'package:minimallogin/querys/firestore.dart';
import 'package:flutter/material.dart';

class IngresoForm extends StatefulWidget {
  const IngresoForm({super.key});

  @override
  _IngresoFormState createState() => _IngresoFormState();
}

class _IngresoFormState extends State<IngresoForm> {
  final _dateController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? selectedCategory;
  String? selectedFormaCobro;
  String? selectedMetodoPago;

  List<String> categories = ['Sueldo', 'Venta', 'Otros', 'Agregar nuevo'];
  List<String> formasCobro = ['Crédito', 'Débito', 'Transferencia', 'Agregar nuevo'];
  List<String> metodosPago = ['Contado', 'Tarjeta', 'Cheque', 'Agregar nuevo'];

  final FirestoreService _firestoreService = FirestoreService();
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  Future<void> guardarIngreso() async {
    if (_dateController.text.isEmpty ||
        _amountController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        selectedCategory == null ||
        selectedFormaCobro == null ||
        selectedMetodoPago == null) {
      mostrarAlerta('Por favor, completa todos los campos antes de guardar.');
      return;
    }

    try {
      await _firestoreService.guardarIngreso(userId, {
        'fecha': _dateController.text,
        'importe': _amountController.text,
        'descripcion': _descriptionController.text,
        'categoria': selectedCategory,
        'formaCobro': selectedFormaCobro,
        'metodoPago': selectedMetodoPago,
      });

      mostrarAlerta('Ingreso guardado correctamente.');

      setState(() {
        _dateController.clear();
        _amountController.clear();
        _descriptionController.clear();
        selectedCategory = null;
        selectedFormaCobro = null;
        selectedMetodoPago = null;
      });
    } catch (error) {
      mostrarAlerta('Hubo un error al guardar el ingreso.');
    }
  }

  void mostrarAlerta(String mensaje) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Aviso'),
          content: Text(mensaje),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  void _showAddOptionDialog(String title, List<String> list, Function(String) onSelected) {
    final newOptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Agregar $title'),
          content: TextField(
            controller: newOptionController,
            decoration: const InputDecoration(hintText: 'Escribe una nueva opción'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                String newOption = newOptionController.text.trim();
                if (newOption.isNotEmpty) {
                  setState(() {
                    list.insert(list.length - 1, newOption);
                    onSelected(newOption);
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Agregar'),
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
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _dateController,
                    decoration: const InputDecoration(
                      labelText: 'Fecha',
                      icon: Icon(Icons.calendar_today),
                    ),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _dateController.text = "${pickedDate.toLocal()}".split(' ')[0];
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Importe',
                      icon: Icon(Icons.attach_money),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Categoría',
              ),
              value: selectedCategory,
              items: categories.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue == 'Agregar nuevo') {
                  _showAddOptionDialog('Categoría', categories, (newOption) {
                    setState(() {
                      selectedCategory = newOption;
                    });
                  });
                } else {
                  setState(() {
                    selectedCategory = newValue;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Forma de cobro',
              ),
              value: selectedFormaCobro,
              items: formasCobro.map((String forma) {
                return DropdownMenuItem<String>(
                  value: forma,
                  child: Text(forma),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue == 'Agregar nuevo') {
                  _showAddOptionDialog('Forma de cobro', formasCobro, (newOption) {
                    setState(() {
                      selectedFormaCobro = newOption;
                    });
                  });
                } else {
                  setState(() {
                    selectedFormaCobro = newValue;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Método de pago',
              ),
              value: selectedMetodoPago,
              items: metodosPago.map((String metodo) {
                return DropdownMenuItem<String>(
                  value: metodo,
                  child: Text(metodo),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue == 'Agregar nuevo') {
                  _showAddOptionDialog('Método de pago', metodosPago, (newOption) {
                    setState(() {
                      selectedMetodoPago = newOption;
                    });
                  });
                } else {
                  setState(() {
                    selectedMetodoPago = newValue;
                  });
                }
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: guardarIngreso,
                child: const Text('GUARDAR INGRESO'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}