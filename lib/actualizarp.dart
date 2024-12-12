import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UpdateProductForm extends StatefulWidget {
  final String productId;

  const UpdateProductForm({super.key, required this.productId});

  @override
  _UpdateProductFormState createState() => _UpdateProductFormState();
}

class _UpdateProductFormState extends State<UpdateProductForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  String _category = 'Pollo';
  bool _availability = true;
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();
  String? _currentImageUrl;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _priceController = TextEditingController();
    _descriptionController = TextEditingController();
    _loadProductData();
  }

  Future<void> _loadProductData() async {
    final doc = await FirebaseFirestore.instance.collection('Productos').doc(widget.productId).get();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        _nameController.text = data['nombre'];
        _priceController.text = data['precio'].toString();
        _descriptionController.text = data['descripcion'];
        _availability = data['disponibilidad'];
        _category = data['categoria'];
        _currentImageUrl = data['imagenUrl'];
      });
    }
  }

  Future<void> _selectImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  Future<void> _updateProduct() async {
    try {
      String? imageUrl = _currentImageUrl;

      // Si hay una nueva imagen seleccionada, eliminar la anterior de Storage y subir la nueva
      if (_imageFile != null) {
        // Eliminar imagen actual si existe
        if (_currentImageUrl != null) {
          final oldImageRef = FirebaseStorage.instance.refFromURL(_currentImageUrl!);
          await oldImageRef.delete();
        }

        // Subir la nueva imagen a Firebase Storage
        final storageRef = FirebaseStorage.instance.ref().child('productos/${_imageFile!.name}');
        await storageRef.putFile(File(_imageFile!.path));
        imageUrl = await storageRef.getDownloadURL();
      }

      // Actualizar el documento en Firestore
      await FirebaseFirestore.instance.collection('Productos').doc(widget.productId).update({
        'nombre': _nameController.text,
        'precio': double.tryParse(_priceController.text) ?? 0.0,
        'descripcion': _descriptionController.text,
        'disponibilidad': _availability,
        'categoria': _category,
        'imagenUrl': imageUrl,
        'fecha_actualizacion': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto actualizado con éxito')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar el producto: $e')),
      );
    }
  }

  Future<void> _deleteProduct() async {
    try {
      // Eliminar imagen de Storage si existe
      if (_currentImageUrl != null) {
        final imageRef = FirebaseStorage.instance.refFromURL(_currentImageUrl!);
        await imageRef.delete();
      }

      // Eliminar el producto de Firestore
      await FirebaseFirestore.instance.collection('Productos').doc(widget.productId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto eliminado con éxito')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar el producto: $e')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Actualizar Producto'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _selectImage,
              child: Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey, width: 2.0),
                ),
                child: _imageFile == null
                    ? (_currentImageUrl != null
                        ? ClipOval(
                            child: Image.network(
                              _currentImageUrl!,
                              fit: BoxFit.cover,
                              width: 150,
                              height: 150,
                            ),
                          )
                        : const Center(
                            child: Icon(
                              Icons.image,
                              size: 80,
                              color: Colors.grey,
                            ),
                          ))
                    : ClipOval(
                        child: Image.file(
                          File(_imageFile!.path),
                          fit: BoxFit.cover,
                          width: 150,
                          height: 150,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'imagen +',
              style: TextStyle(color: Color.fromRGBO(30, 66, 230, 1)),
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10.0,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                      validator: (value) {
                        return value!.isEmpty ? 'Este campo es obligatorio' : null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'Precio'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        return value!.isEmpty ? 'Este campo es obligatorio' : null;
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _category,
                      decoration: const InputDecoration(labelText: 'Categoría'),
                      items: <String>['Pollo', 'Res', 'Cerdo', 'Embutidos'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _category = newValue!;
                        });
                      },
                      validator: (value) {
                        return value == null ? 'Este campo es obligatorio' : null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Descripcion',
                        hintText: 'Breve descripcion del producto',
                      ),
                      maxLines: 2,
                      validator: (value) {
                        return value!.isEmpty ? 'Este campo es obligatorio' : null;
                      },
                    ),
                    const SizedBox(height: 10),
                    SwitchListTile(
                      title: const Text('Disponibilidad'),
                      value: _availability,
                      onChanged: (value) {
                        setState(() {
                          _availability = value;
                        });
                      },
                      activeColor: Colors.green,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 120, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _updateProduct();
                        }
                      },
                      child: const Text(
                        'Actualizar',
                        style: TextStyle(fontSize: 18.0, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
