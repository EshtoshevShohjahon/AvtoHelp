import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../../core/theme/app_theme.dart';
import '../../core/network/api_client.dart';
import '../../widgets/app_widgets.dart';

class AddListingScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? existing; // non-null → edit mode
  const AddListingScreen({super.key, this.existing});

  @override
  ConsumerState<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends ConsumerState<AddListingScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();

  String _listingType = 'service';
  String _vehicleCat = 'both';
  String _priceType = 'fixed';

  List<File> _newImages = [];
  List<String> _existingImages = [];
  List<String> _toRemove = [];

  bool _loading = false;
  final _picker = ImagePicker();

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final e = widget.existing!;
      _titleCtrl.text = e['title'] ?? '';
      _descCtrl.text = e['description'] ?? '';
      _priceCtrl.text = e['price']?.toString() ?? '';
      _categoryCtrl.text = e['category'] ?? '';
      _listingType = e['listing_type'] ?? 'service';
      _vehicleCat = e['vehicle_category'] ?? 'both';
      _priceType = e['price_type'] ?? 'fixed';
      _existingImages = List<String>.from(e['images'] ?? []);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _categoryCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 80);
    if (picked.isEmpty) return;
    final total = _newImages.length + _existingImages.length - _toRemove.length;
    final canAdd = 5 - total;
    if (canAdd <= 0) return;
    setState(() {
      _newImages.addAll(
          picked.take(canAdd).map((x) => File(x.path)));
    });
  }

  Future<void> _submit() async {
    if (_titleCtrl.text.trim().isEmpty || _priceCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations(context).fillRequired),
            backgroundColor: AppColors.danger),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final api = ref.read(apiClientProvider);

      final imageFiles = await Future.wait(_newImages.map((f) async =>
          MultipartFile.fromFile(f.path, filename: f.path.split('/').last)));

      final formData = FormData.fromMap({
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'price': _priceCtrl.text.isEmpty ? '0' : _priceCtrl.text.trim(),
        'price_type': _priceType,
        'listing_type': _listingType,
        'category': _categoryCtrl.text.trim(),
        'vehicle_category': _vehicleCat,
        if (_toRemove.isNotEmpty) 'remove_images': _toRemove.join(','),
        if (imageFiles.isNotEmpty) 'images': imageFiles,
      });

      if (_isEdit) {
        await api.dio.put('/marketplace/${widget.existing!['id']}',
            data: formData,
            options: Options(headers: {
              'Content-Type': 'multipart/form-data',
            }));
      } else {
        await api.dio.post('/marketplace',
            data: formData,
            options: Options(headers: {
              'Content-Type': 'multipart/form-data',
            }));
      }

      if (!mounted) return;
      context.pop(true);
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()),
              backgroundColor: AppColors.danger),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? l.editListing : l.addListing),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_loading)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.amber),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _submit,
              child: Text(l.save,
                  style: const TextStyle(
                      color: AppColors.amber, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Images
          _SectionLabel(l.photos),
          const SizedBox(height: 10),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                // Existing images
                ..._existingImages.where((img) => !_toRemove.contains(img.split('/').last)).map((img) {
                  final fn = img.split('/').last;
                  return _ImageThumb(
                    child: Image.network(img, fit: BoxFit.cover),
                    onRemove: () => setState(() => _toRemove.add(fn)),
                  );
                }),
                // New images
                ..._newImages.map((f) => _ImageThumb(
                  child: Image.file(f, fit: BoxFit.cover),
                  onRemove: () => setState(() => _newImages.remove(f)),
                )),
                // Add button
                if (_newImages.length + _existingImages.length - _toRemove.length < 5)
                  GestureDetector(
                    onTap: _pickImages,
                    child: Container(
                      width: 100,
                      height: 100,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: AppColors.charcoal,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.steelLine, style: BorderStyle.solid),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined,
                              color: AppColors.steelLight, size: 30),
                          SizedBox(height: 4),
                          Text('Rasm',
                              style: TextStyle(
                                  color: AppColors.steelLight, fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Title
          _SectionLabel(l.listingTitle),
          const SizedBox(height: 8),
          TextField(
            controller: _titleCtrl,
            style: const TextStyle(color: AppColors.bone),
            decoration: InputDecoration(hintText: l.listingTitleHint),
          ),
          const SizedBox(height: 16),

          // Type
          _SectionLabel(l.listingType),
          const SizedBox(height: 8),
          _ChipGroup(
            options: const ['service', 'part', 'oil', 'tire', 'other'],
            labels: [l.marketplaceServices, l.marketplaceParts,
                     l.marketplaceOil, l.marketplaceTire, l.other],
            selected: _listingType,
            onSelected: (v) => setState(() => _listingType = v),
          ),
          const SizedBox(height: 16),

          // Vehicle category
          _SectionLabel(l.vehicleCategory),
          const SizedBox(height: 8),
          _ChipGroup(
            options: const ['light', 'truck', 'both'],
            labels: [l.lightCar, l.truckSection, l.all],
            selected: _vehicleCat,
            onSelected: (v) => setState(() => _vehicleCat = v),
          ),
          const SizedBox(height: 16),

          // Category
          _SectionLabel(l.category),
          const SizedBox(height: 8),
          TextField(
            controller: _categoryCtrl,
            style: const TextStyle(color: AppColors.bone),
            decoration: InputDecoration(hintText: l.categoryHint),
          ),
          const SizedBox(height: 16),

          // Price
          _SectionLabel(l.price),
          const SizedBox(height: 8),
          _ChipGroup(
            options: const ['fixed', 'from', 'negotiable'],
            labels: [l.priceFixed, l.priceFrom, l.negotiable],
            selected: _priceType,
            onSelected: (v) => setState(() => _priceType = v),
          ),
          const SizedBox(height: 8),
          if (_priceType != 'negotiable')
            TextField(
              controller: _priceCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.bone),
              decoration: InputDecoration(
                hintText: '0',
                suffixText: 'so\'m',
                suffixStyle: const TextStyle(color: AppColors.steelLight),
              ),
            )
          else
            const SizedBox.shrink(),
          const SizedBox(height: 16),

          // Description
          _SectionLabel(l.description),
          const SizedBox(height: 8),
          TextField(
            controller: _descCtrl,
            style: const TextStyle(color: AppColors.bone),
            maxLines: 4,
            decoration: InputDecoration(hintText: l.descriptionHint),
          ),
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.asphalt))
                  : Text(_isEdit ? l.saveChanges : l.publish),
            ),
          ),
        ]),
      ),
    );
  }
}

class _ImageThumb extends StatelessWidget {
  final Widget child;
  final VoidCallback onRemove;
  const _ImageThumb({required this.child, required this.onRemove});

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Container(
        width: 100,
        height: 100,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.steelLine),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: child,
        ),
      ),
      Positioned(
        top: 4,
        right: 12,
        child: GestureDetector(
          onTap: onRemove,
          child: Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: AppColors.danger,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close, color: Colors.white, size: 14),
          ),
        ),
      ),
    ],
  );
}

class _ChipGroup extends StatelessWidget {
  final List<String> options;
  final List<String> labels;
  final String selected;
  final ValueChanged<String> onSelected;
  const _ChipGroup({
    required this.options,
    required this.labels,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: List.generate(options.length, (i) {
      final sel = options[i] == selected;
      return GestureDetector(
        onTap: () => onSelected(options[i]),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: sel ? AppColors.amber : AppColors.charcoal,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
                color: sel ? AppColors.amber : AppColors.steelLine),
          ),
          child: Text(labels[i],
              style: TextStyle(
                  fontSize: 12,
                  color: sel ? const Color(0xFF1A1100) : AppColors.boneDim,
                  fontWeight: sel ? FontWeight.w600 : FontWeight.normal)),
        ),
      );
    }),
  );
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          color: AppColors.steelLight, fontSize: 11, letterSpacing: 0.5));
}
