import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ResumenOrdenScreen extends StatelessWidget {
  final String orderId;

  ResumenOrdenScreen({required this.orderId});

  Future<Map<String, dynamic>> _fetchOrderDetails() async {
    final orderDoc = await FirebaseFirestore.instance.collection('Compras').doc(orderId).get();
    if (!orderDoc.exists) {
      throw Exception('El pedido no existe.');
    }

    final orderData = orderDoc.data()!;
    final subCollections = ['producto1', 'producto2', 'producto3', 'producto4', 'producto5', 'producto6'];
    final products = <Map<String, dynamic>>[];

    for (var subCollection in subCollections) {
      final subCollectionSnapshot = await FirebaseFirestore.instance
          .collection('Compras')
          .doc(orderId)
          .collection(subCollection)
          .get();

      for (var doc in subCollectionSnapshot.docs) {
        products.add(doc.data());
      }
    }

    return {
      'order': orderData,
      'products': products,
    };
  }

  Future<void> _finalizarPedido(BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('Compras').doc(orderId).update({'Status': 'Completa'});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pedido marcado como Listo.')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al completar el pedido: $e')),
      );
    }
  }
    Future<void> _Cancelar(BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('Compras').doc(orderId).update({'Status': 'Cancelado'});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pedido marcado como cancelado.')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al completar el pedido: $e')),
      );
    }
  }

  Future<void> _confirmCancel(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Cancelacion'),
          content: const Text('¿Estás seguro de que deseas Cancelar este Pedido?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
             onPressed: () => _Cancelar(context),

              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
              
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Orden Cancelada')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumen de la orden'),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchOrderDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar los detalles de la orden'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Detalles no disponibles'));
          }

          final data = snapshot.data!;
          final order = data['order'];
          final products = data['products'] as List<dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Productos',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final product = products[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(product['Nombre'] ?? 'N/A'),
                                    Text('${product['Cantidad'] ?? 'N/A'} kg'),
                                    Text('\$${product['Precio'] ?? 'N/A'}'),
                                  ],
                                ),
                              );
                            },
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total:',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                '\$${order['totalPedido'] ?? '0.00'}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          const SizedBox(height: 20),
                          Text('Pedido para: ${order['Entrega'] ?? 'No especificado'}'),
                          Text('Cliente: ${order['NombreClientes'] ?? 'No especificado'}'),
                          if (order.containsKey('Direccion'))
                            Text('Dirección: ${order['Direccion']}'),
                          if (order.containsKey('Notas'))
                            Text('Notas: ${order['Notas']}'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => _confirmCancel(context),
                          child: const Text('Cancelar', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => _finalizarPedido(context),
                          child: const Text('¡Pedido Listo!', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
