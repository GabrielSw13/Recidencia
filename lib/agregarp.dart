import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProductForm extends StatefulWidget {
  const ProductForm({super.key});

  @override
  _ProductFormState createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  double _price = 0.0;
  String _description = '';
  bool _availability = true;
  String _category = 'Pollo';
  XFile? _imageFile;

  final ImagePicker _picker = ImagePicker();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isLoading = false; // Nuevo estado para manejar el indicador de carga

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  Future<void> _uploadProduct() async {
    setState(() {
      _isLoading = true; // Mostrar el indicador de carga
    });

    try {
      if (_imageFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecciona una imagen')),
        );
        setState(() {
          _isLoading = false; // Ocultar el indicador de carga
        });
        return;
      }

      final storageRef = FirebaseStorage.instance.ref();
      final imageRef = storageRef.child('productos/${_imageFile!.name}');
      await imageRef.putFile(File(_imageFile!.path));
      final imageUrl = await imageRef.getDownloadURL();

      await FirebaseFirestore.instance.collection('Productos').add({
        'nombre': _name,
        'precio': _price,
        'descripcion': _description,
        'disponibilidad': _availability,
        'categoria': _category,
        'imagenUrl': imageUrl,
        'fecha_creacion': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto añadido con éxito')),
      );

      _clearForm();
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al añadir producto: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Ocultar el indicador de carga después del proceso
      });
    }
  }

  void _clearForm() {
    _nameController.clear();
    _priceController.clear();
    _descriptionController.clear();
    setState(() {
      _imageFile = null;
      _category = 'Pollo';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Añadir Producto',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          color: Colors.white,
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
                    ? const Center(
                        child: Icon(
                          Icons.image,
                          size: 80,
                          color: Colors.grey,
                        ),
                      )
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
                      onSaved: (value) {
                        _name = value ?? '';
                      },
                      validator: (value) {
                        return value!.isEmpty ? 'Este campo es obligatorio' : null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'Precio'),
                      keyboardType: TextInputType.number,
                      onSaved: (value) {
                        _price = double.tryParse(value ?? '0') ?? 0.0;
                      },
                      validator: (value) {
                        return value!.isEmpty ? 'Este campo es obligatorio' : null;
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _category,
                      decoration: const InputDecoration(labelText: 'Categoría'),
                      items: <String>['Pollo', 'Res', 'Cerdo', 'Embutidos']
                          .map((String value) {
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
                      onSaved: (value) {
                        _description = value ?? '';
                      },
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
                      onPressed: _isLoading
                          ? null // Deshabilitar el botón si está cargando
                          : () {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                _uploadProduct();
                              }
                            },
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              'Añadir',
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
