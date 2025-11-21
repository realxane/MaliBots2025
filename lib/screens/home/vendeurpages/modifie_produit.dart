import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:malibots_challenge_eni/constants/app_text_styles.dart';
import 'package:malibots_challenge_eni/services/produit_service.dart';
import 'package:provider/provider.dart';
import 'package:malibots_challenge_eni/models/product.dart';
// IMPORTANT: on utilise la normalisation centralisée
import 'package:malibots_challenge_eni/utils/image_urls.dart';

const Color bogolan = Color(0xFF7B3F00);

// helpers
bool _isHttp(String s) => s.startsWith('http://') || s.startsWith('https://');

ImageProvider<Object> imageProviderFrom(String raw) {
  final p = normalizeImageRef(raw.trim());
  if (_isHttp(p)) return NetworkImage(p);
  if (p.startsWith('file://')) {
    return FileImage(File(Uri.parse(p).toFilePath()));
  }
  return FileImage(File(p));
}

class AddEditProductScreen extends StatefulWidget {
  final Produit? product; // null => add, else edit

  const AddEditProductScreen({Key? key, this.product}) : super(key: key);

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  final _rng = Random();

  late TextEditingController _nameC;
  late TextEditingController _descC;
  late TextEditingController _priceC;
  late TextEditingController _stockC;

  String _category = 'Habit';
  String _color = 'Bogolan';

  // chemins de fichiers OU URLs http(s)
  List<String> _images = [];

  List<RegionRef> _regions = [];
  RegionRef? _selectedRegion;
  bool _regionsLoading = true;
  String? _regionsError;

  final List<String> _categories = ['Habit', 'Plat', 'Accessoire'];
  final List<String> _colors = ['Bogolan', 'Rouge', 'Bleu', 'Vert', 'Marron'];

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameC = TextEditingController(text: p?.nom ?? '');
    _descC = TextEditingController(text: p?.description ?? '');
    _priceC = TextEditingController(
      text: p?.prix != null ? p!.prix!.toStringAsFixed(0) : '',
    );
    _stockC = TextEditingController(
      text: p?.stock != null ? p!.stock!.toString() : '1',
    );
    _category = p?.categorie ?? _category;

    // normalisation si édition
    _images = (p?.images ?? const []).map(normalizeImageRef).toList();

    _loadRegions(initialRegionLabel: p?.regionName ?? p?.regionId);
  }

  @override
  void dispose() {
    _nameC.dispose();
    _descC.dispose();
    _priceC.dispose();
    _stockC.dispose();
    super.dispose();
  }

  // ----------------- Matérialisation XFile -> chemin fichier
  Future<String> _materializeXFile(XFile xf) async {
    try {
      final p = xf.path;
      if (p.startsWith('/')) return p;
      if (p.startsWith('file://')) return Uri.parse(p).toFilePath();

      final bytes = await xf.readAsBytes();
      final name = xf.name;
      final dot = name.lastIndexOf('.');
      final ext =
          (dot != -1 && dot < name.length - 1) ? name.substring(dot + 1) : 'jpg';
      final fname =
          'picked_${DateTime.now().millisecondsSinceEpoch}_${_rng.nextInt(1 << 32)}.$ext';
      final file = File('${Directory.systemTemp.path}/$fname');
      await file.writeAsBytes(bytes, flush: true);
      return file.path;
    } catch (e) {
      debugPrint('materializeXFile error: $e');
      return xf.path;
    }
  }

  // ----------------- Chargement régions
  Future<void> _loadRegions({String? initialRegionLabel}) async {
    setState(() {
      _regionsLoading = true;
      _regionsError = null;
    });
    try {
      final service = context.read<ProduitService>();
      final list = await service.fetchRegions();

      RegionRef? sel;
      if (initialRegionLabel != null && initialRegionLabel.trim().isNotEmpty) {
        final lower = initialRegionLabel.toLowerCase();
        for (final r in list) {
          if (r.name.toLowerCase() == lower || r.id == initialRegionLabel) {
            sel = r;
            break;
          }
        }
      }
      if (!mounted) return;
      setState(() {
        _regions = list;
        _selectedRegion = sel ?? (list.isNotEmpty ? list.first : null);
        _regionsLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _regionsError = e.toString();
        _regionsLoading = false;
      });
    }
  }

  // ----------------- Sélection images
  Future<void> _pickImages() async {
    try {
      final List<XFile>? picked =
          await _picker.pickMultiImage(imageQuality: 85);
      if (picked == null || picked.isEmpty) return;

      final List<String> newPaths = [];
      for (final xf in picked) {
        final path = await _materializeXFile(xf);
        newPaths.add(path);
      }
      if (!mounted) return;
      setState(() {
        _images = {..._images, ...newPaths}.toList(); // évite doublons
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur pendant la sélection: $e')),
      );
    }
  }

  void _removeImage(String path) {
    setState(() => _images.remove(path));
  }

  // ----------------- Soumission
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedRegion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sélectionnez une région')),
      );
      return;
    }

    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ajoutez au moins une image')),
      );
      return;
    }

    final service = context.read<ProduitService>();
    final token = await service.currentToken();
    if (token == null || token.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Session expirée. Veuillez vous reconnecter.')),
      );
      return;
    }

    final isEdit = widget.product != null;

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final Produit serverProduct = isEdit
          ? await service.updateFromUi(
              id: widget.product!.id,
              nom: _nameC.text.trim(),
              description: _descC.text.trim(),
              prix: double.tryParse(_priceC.text.trim()) ?? 0,
              uiCategorie: _category,
              regionId: _selectedRegion!.id,
              stock: int.tryParse(_stockC.text.trim()) ?? 0,
              imageLocalPathsOrUrls: _images,
              couleur: _color,
            )
          : await service.createFromUi(
              nom: _nameC.text.trim(),
              description: _descC.text.trim(),
              prix: double.tryParse(_priceC.text.trim()) ?? 0,
              uiCategorie: _category,
              regionId: _selectedRegion!.id,
              stock: int.tryParse(_stockC.text.trim()) ?? 0,
              imageLocalPathsOrUrls: _images,
              couleur: _color,
            );

      if (!mounted) return;

      // Normalise toutes les URLs d’images renvoyées par le serveur
      final Produit fixedServerProduct = serverProduct.copyWith(
        images: serverProduct.images.map(normalizeImageRef).toList(),
        firstImageUrl: serverProduct.firstImageUrl != null
            ? normalizeImageRef(serverProduct.firstImageUrl!)
            : serverProduct.firstImageUrl,
      );

      // Si jamais le backend ne renvoie pas encore d’images,
      // on garde les chemins locaux pour l’UI immédiate
      final hasServerImages = fixedServerProduct.images.isNotEmpty ||
          (fixedServerProduct.firstImageUrl != null &&
              fixedServerProduct.firstImageUrl!.isNotEmpty);

      final Produit productForUi =
          hasServerImages ? fixedServerProduct : fixedServerProduct.copyWith(
            images: _images,
          );

      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(isEdit ? 'Produit mis à jour' : 'Produit publié')),
      );

      if (mounted) {
        Navigator.of(context).pop<Produit>(productForUi);
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).maybePop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  // ----------------- UI
  Widget _imageThumb(String raw) {
    final provider = imageProviderFrom(raw);
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(right: 10),
          width: 140,
          height: 110,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(image: provider, fit: BoxFit.cover),
          ),
        ),
        Positioned(
          right: 8,
          top: 8,
          child: GestureDetector(
            onTap: () => _removeImage(raw),
            child: const CircleAvatar(
              radius: 14,
              backgroundColor: Colors.black54,
              child: Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ajouter les images',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              const SizedBox(width: 6),
              ..._images.map(_imageThumb),
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
                  child: const Center(
                    child: Icon(Icons.add_a_photo_outlined,
                        color: bogolan, size: 36),
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
        borderSide: const BorderSide(color: bogolan, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  Widget _buildRegionCategoryRow() {
    final regionField = DropdownButtonFormField<RegionRef>(
      value: _selectedRegion,
      decoration: _inputDecoration('Région'),
      items: _regions
          .map((r) => DropdownMenuItem<RegionRef>(
                value: r,
                child: Text(r.name),
              ))
          .toList(),
      onChanged: _regionsLoading ? null : (v) => setState(() => _selectedRegion = v),
      validator: (_) => _selectedRegion == null ? 'Requis' : null,
    );

    final loadingOverlay = _regionsLoading
        ? Positioned(
            right: 10,
            top: 12,
            child: const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: bogolan),
            ),
          )
        : const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Stack(
                children: [regionField, loadingOverlay],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _category,
                decoration: _inputDecoration('Catégorie'),
                items: _categories
                    .map(
                        (c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v ?? _category),
              ),
            ),
          ],
        ),
        if (_regionsError != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              const Expanded(
                child: Text('Impossible de charger les régions.',
                    style: TextStyle(color: Colors.red)),
              ),
              TextButton(
                onPressed: () => _loadRegions(
                  initialRegionLabel:
                      widget.product?.regionName ?? widget.product?.regionId,
                ),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ],
      ],
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
        title: Text(isEdit ? 'Modifier le produit' : 'Ajouter des produits',
            style: const TextStyle(color: bogolan)),
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
                    decoration:
                        _inputDecoration('Description du produit'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _priceC,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
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
                  _buildRegionCategoryRow(),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _color,
                    decoration: _inputDecoration('Couleur'),
                    items: _colors
                        .map((c) =>
                            DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _color = v ?? _color),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: bogolan,
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _submit,
                      child: Text(isEdit ? 'Mettre à jour' : 'Publier',
                          style: AppTextStyles.button),
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