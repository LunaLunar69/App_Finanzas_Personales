import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CxcPage extends StatelessWidget {
  const CxcPage({super.key});
  void _editarRegistro(String id, Map<String, dynamic> data, BuildContext context) {
    TextEditingController fechaController = TextEditingController(text: data['fecha'] ?? '');
    TextEditingController nombreController = TextEditingController(text: data['nombre'] ?? '');
    TextEditingController facturaController = TextEditingController(text: data['No.factura'] ?? '');
    TextEditingController importeController = TextEditingController(text: data['importe_total']?.toString() ?? '0.0');
    TextEditingController saldoPagadoController = TextEditingController(text: data['saldo_pagado']?.toString() ?? '0.0');
    TextEditingController saldoActualController = TextEditingController(text: data['saldo_actual']?.toString() ?? '0.0');
    TextEditingController categoriaController = TextEditingController(text: data['categoria'] ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Registro'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: fechaController, decoration: const InputDecoration(labelText: 'Fecha')),
                TextField(controller: nombreController, decoration: const InputDecoration(labelText: 'Nombre')),
                TextField(controller: facturaController, decoration: const InputDecoration(labelText: 'No. Factura')),
                TextField(controller: importeController, decoration: const InputDecoration(labelText: 'Importe Total')),
                TextField(controller: saldoPagadoController, decoration: const InputDecoration(labelText: 'Saldo Pagado')),
                TextField(controller: saldoActualController, decoration: const InputDecoration(labelText: 'Saldo Actual')),
                TextField(controller: categoriaController, decoration: const InputDecoration(labelText: 'Categoría')),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                FirebaseFirestore.instance.collection('cxc').doc(id).update({
                  'fecha': fechaController.text,
                  'nombre': nombreController.text,
                  'No.factura': facturaController.text,
                  'importe_total': double.tryParse(importeController.text) ?? 0.0,
                  'saldo_pagado': double.tryParse(saldoPagadoController.text) ?? 0.0,
                  'saldo_actual': double.tryParse(saldoActualController.text) ?? 0.0,
                  'categoria': categoriaController.text,
                });
                Navigator.pop(context);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _eliminarRegistro(String id, BuildContext context) {
    FirebaseFirestore.instance.collection('cxc').doc(id).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Registro eliminado')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('cxc').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay datos disponibles.'));
          }
          
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 12,
              columns: const[
                DataColumn(label: Text('Acciones')),
                DataColumn(label: Text('Fecha')),
                DataColumn(label: Text('Nombre')),
                DataColumn(label: Text('No. Factura')),
                DataColumn(label: Text('Importe Total')),
                DataColumn(label: Text('Saldo Pagado')),
                DataColumn(label: Text('Saldo Actual')),
                DataColumn(label: Text('Categoría')),
              ],
              rows: snapshot.data!.docs.map((doc) {
                Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                return DataRow(cells: [
                  DataCell(Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editarRegistro(doc.id, data, context),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _eliminarRegistro(doc.id, context),
                      ),
                    ],
                  )),
                  DataCell(Text(data['fecha'] ?? 'N/A')),
                  DataCell(Text(data['nombre'] ?? 'N/A')),
                  DataCell(Text(data['No.factura'] ?? '')),
                  DataCell(Text(data['importe_total']?.toString() ?? '0.0')),
                  DataCell(Text(data['saldo_pagado']?.toString() ?? '0.0')),
                  DataCell(Text(data['saldo_actual']?.toString() ?? '0.0')),
                  DataCell(Text(data['categoria'] ?? 'N/A')),
                ]);
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
