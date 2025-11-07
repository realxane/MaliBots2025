import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:malibots_challenge_eni/constants/app_text_styles.dart';
import 'package:uuid/uuid.dart';
import 'produit.dart';

const Color bogolan = Color(0xFF7B3F00);

class AddEditProductScreen extends StatefulWidget {
  final Product? product; // null => add, else edit

  const AddEditProductScreen({Key? key, this.product}) : super(key: key);

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nameC;
  late TextEditingController _descC;
  late TextEditingController _priceC;
  late TextEditingController _stockC;
  String _region = 'Bamako';
  String _category = 'Tenue';
  String _color = 'Bogolan';
  List<String> _images = [];

  final List<String> _regions = [
    'Bamako',
    'Sikasso',
    'Ségou',
    'Kayes',
    'Tombouctou',
  ];
  final List<String> _categories = [
    'Tenue',
    'Accessoire',
    'Chapeau',
    'Robe',
    'Bijoux',
  ];
  final List<String> _colors = ['Bogolan', 'Rouge', 'Bleu', 'Vert', 'Marron'];

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameC = TextEditingController(text: p?.name ?? '');
    _descC = TextEditingController(text: p?.description ?? '');
    _priceC = TextEditingController(
      text: p != null ? p!.price.toStringAsFixed(0) : '',
    );
    _stockC = TextEditingController(
      text: p != null ? p!.stock.toString() : '1',
    );
    _region = p?.region ?? _region;
    _category = p?.category ?? _category;
    _color = p?.color ?? _color;
    _images = p?.images.toList() ?? [];
  }

  @override
  void dispose() {
    _nameC.dispose();
    _descC.dispose();
    _priceC.dispose();
    _stockC.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile>? picked = await _picker.pickMultiImage();
      if (picked != null && picked.isNotEmpty) {
        setState(() {
          _images.addAll(picked.map((x) => x.path));
        });
      }
    } catch (e) {
      // ignore or show snack
    }
  }

  void _removeImage(String path) {
    setState(() => _images.remove(path));
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ajoutez au moins une image')),
      );
      return;
    }

    final id = widget.product?.id ?? const Uuid().v4();

    final product = Product(
      id: id,
      name: _nameC.text.trim(),
      description: _descC.text.trim(),
      price: double.tryParse(_priceC.text.trim()) ?? 0,
      stock: int.tryParse(_stockC.text.trim()) ?? 0,
      images: _images,
      region: _region,
      category: _category,
      color: _color,
    );

    Navigator.of(context).pop(product);
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ajouter les images',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              const SizedBox(width: 6),
              ..._images.map(
                (p) => Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 10),
                      width: 140,
                      height: 110,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: FileImage(File(p)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: GestureDetector(
                        onTap: () => _removeImage(p),
                        child: const CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.black54,
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _pickImages,
                child: Container(
                  width: 140,
                  height: 110,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: bogolan.withOpacity(0.12),
                    border: Border.all(color: bogolan.withOpacity(0.2)),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.add_a_photo_outlined,
                      color: bogolan,
                      size: 36,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: bogolan, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: bogolan),
        title: Text(
          isEdit ? 'Modifier le produit' : 'Ajouter des produits',
          style: const TextStyle(color: bogolan),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            _buildImagePicker(),
            const SizedBox(height: 14),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameC,
                    decoration: _inputDecoration('Nom du produit'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Requis' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _descC,
                    decoration: _inputDecoration('Description du produit'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _priceC,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration('Prix du produit'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Requis' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _stockC,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration('Quantité en stock'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Requis' : null,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _region,
                          decoration: _inputDecoration('Région'),
                          items: _regions
                              .map(
                                (r) =>
                                    DropdownMenuItem(value: r, child: Text(r)),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _region = v ?? _region),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _category,
                          decoration: _inputDecoration('Catégorie'),
                          items: _categories
                              .map(
                                (c) =>
                                    DropdownMenuItem(value: c, child: Text(c)),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _category = v ?? _category),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _color,
                    decoration: _inputDecoration('Couleur'),
                    items: _colors
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _color = v ?? _color),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: bogolan,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _submit,
                      child: Text(
                        isEdit ? 'Mettre à jour' : 'Publier',
                        style: AppTextStyles.button,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
