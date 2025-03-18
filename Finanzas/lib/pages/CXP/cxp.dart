import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CxpPage extends StatelessWidget {
  const CxpPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtener el usuario autenticado
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('No has iniciado sesión')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _nuevoRegistro(user.uid, context), // Pasar el UID
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('cxp')
            .where('uid', isEqualTo: user.uid) // Filtrar por UID del usuario
            .snapshots(),
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
              columns: const [
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

  void _nuevoRegistro(String uid, BuildContext context) {
    TextEditingController fechaController = TextEditingController();
    TextEditingController nombreController = TextEditingController();
    TextEditingController facturaController = TextEditingController();
    TextEditingController importeController = TextEditingController();
    TextEditingController saldoPagadoController = TextEditingController();
    TextEditingController saldoActualController = TextEditingController();
    TextEditingController categoriaController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar nuevo Registro'),
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
                FirebaseFirestore.instance.collection('cxp').add({
                  'uid': uid, // Guardar el UID del usuario
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
                FirebaseFirestore.instance.collection('cxp').doc(id).update({
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
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de que deseas eliminar este registro?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Cerrar el cuadro sin eliminar
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              FirebaseFirestore.instance.collection('cxc').doc(id).delete();
              Navigator.pop(context); // Cerrar el cuadro de diálogo
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Registro eliminado')),
              );
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );
}

}
