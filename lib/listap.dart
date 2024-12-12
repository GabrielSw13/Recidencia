import 'package:apptienda/actualizarp.dart';
import 'package:apptienda/agregarp.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String nombre;
  final double precio;
  final String imagenUrl;
  final String descripcion;
  final bool disponibilidad;
  
  Product({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.imagenUrl,
    required this.descripcion,
    required this.disponibilidad,
  });

  // Método para crear un objeto Product a partir de un documento de Firestore
  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      precio: (data['precio'] ?? 0).toDouble(),
      imagenUrl: data['imagenUrl'] ?? '',
      descripcion: data['descripcion'] ?? '',
      disponibilidad: data['disponibilidad'] ?? true,
    );
  }
}

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  // Stream para escuchar cambios en la colección de productos
  Stream<List<Product>> _fetchProducts() {
    return FirebaseFirestore.instance.collection('Productos').snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList(),
    );
  }

  // Función para eliminar un producto de Firestore
Future<void> _confirmDelete(String productId) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: const Text('¿Estás seguro de que deseas eliminar este producto?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  );

  if (confirm == true) {
    _deleteProduct(productId);
  }
}

Future<void> _deleteProduct(String productId) async {
  try {
    await FirebaseFirestore.instance.collection('Productos').doc(productId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Producto eliminado exitosamente')),
    );
  } catch (e) {
    print('Error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error al eliminar el producto')),
    );
  }
}


  // Función para navegar a la pantalla de edición de producto
  void _editProduct(Product product) {
    // Implementa la navegación a la pantalla de edición y envía los datos del producto como argumentos.
               Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UpdateProductForm(productId: product.id),
                  ),
                );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
      ),
      body: StreamBuilder<List<Product>>(
        stream: _fetchProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar los productos'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay productos disponibles'));
          }

          final products = snapshot.data!;
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                elevation: 5,
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      product.imagenUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                    ),
                  ),
                  title: Text(
                    product.nombre,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('\$${product.precio}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Botón de Eliminar
                      TextButton(
                        onPressed: () => _confirmDelete(product.id),
                        child: const Text(
                          'eliminar',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                      // Botón de Editar
                      TextButton(
                        onPressed: () => _editProduct(product),
                        child: const Text(
                          'editar',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProductForm()),
            );
          },
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        child: const Icon(Icons.add),
      ),
    );
  }
}
