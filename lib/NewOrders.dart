import 'package:apptienda/ResumenOrden.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrdenesNuevasScreen extends StatelessWidget {
  const OrdenesNuevasScreen({Key? key}) : super(key: key);

  Future<List<Map<String, dynamic>>> _fetchPendingOrders() async {
    final List<Map<String, dynamic>> orders = [];

    final querySnapshot = await FirebaseFirestore.instance
        .collection('Compras')
        .where('Status', isEqualTo: 'Pendiente')
        .get();

    for (final doc in querySnapshot.docs) {
      final data = doc.data();
      final orderId = doc.id;

      // Obtener el primer producto de la subcolección 'producto1'
      final subCollectionSnapshot = await FirebaseFirestore.instance
          .collection('Compras')
          .doc(orderId)
          .collection('producto1')
          .get();

      if (subCollectionSnapshot.docs.isNotEmpty) {
        final firstProduct = subCollectionSnapshot.docs.first.data();
        orders.add({
          'orderId': orderId,
          'Entrega': data['Entrega'],
          'Imagen': firstProduct['imagenUrl'] ?? '',
          'Nombre': firstProduct['Nombre'] ?? 'Producto sin nombre',
        });
      }
    }

    return orders;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Órdenes Nuevas'),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchPendingOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar las órdenes'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay órdenes pendientes'));
          }

          final orders = snapshot.data!;
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 3,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      order['Imagen'],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.error, color: Colors.red),
                    ),
                  ),
                  title: Text(
                    order['Nombre'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Entrega: ${order['Entrega']}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navegar a la pantalla de resumen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ResumenOrdenScreen(orderId: order['orderId']),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
