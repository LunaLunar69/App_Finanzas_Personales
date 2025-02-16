import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:minimallogin/querys/firestore.dart';

class AssetsPage extends StatefulWidget {
  const AssetsPage({super.key});

  @override
  _AssetsPageState createState() => _AssetsPageState();
}

class _AssetsPageState extends State<AssetsPage> {
  final FirestoreService firestoreService = FirestoreService();
  final String userId = "sampleUser";

  Future<void> _showAddAssetDialog() async {
    final TextEditingController assetController = TextEditingController();
    final TextEditingController assetDescriptionController =
        TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar activo'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: assetController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: assetDescriptionController,
                decoration: const InputDecoration(labelText: 'Descripcion'),
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
              if (assetController.text.isNotEmpty) {
                await firestoreService.addAsset(
                  userId,
                  assetController.text,
                  assetDescriptionController.text,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _showEditAssetDialog(String assetId, Map<String, dynamic> assetData) {
    final TextEditingController assetController =
        TextEditingController(text: assetData['nombre']);
    final TextEditingController assetDescriptionController =
        TextEditingController(text: assetData['descripcion']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar activo'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: assetController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: assetDescriptionController,
                decoration: const InputDecoration(labelText: 'Descripcion'),
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
              await firestoreService.updateAsset(
                userId,
                assetId,
                assetController.text,
                assetDescriptionController.text,
              );
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog( String assetId , Map<String, dynamic> asset) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('¿Está seguro de que desea eliminar este activo?'),
                Text('Concepto: ${asset['nombre']}'),
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
                await firestoreService.deleteAsset( 'sampleUser', assetId);
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
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddAssetDialog,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getAssets(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No hay activos"));
          }

          final assets = snapshot.data!.docs;
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Acciones')),
                DataColumn(label: Text('Nombre')),
                DataColumn(label: Text('Descripción')),
              ],
              rows: assets.map((asset) {
                final assetData = asset.data() as Map<String, dynamic>;
                return DataRow(
                  cells: [
                    DataCell(Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () =>
                              _showEditAssetDialog(asset.id, assetData),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () =>
                              _showDeleteConfirmationDialog(asset.id , assetData),
                        ),
                      ],
                    )),
                    DataCell(Text(assetData['nombre'] ?? '')),
                    DataCell(Text(assetData['descripcion'] ?? '')),
                  ],
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
