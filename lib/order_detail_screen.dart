import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'api_client.dart';
import 'models.dart';

class OrderDetailScreen extends StatefulWidget {
  final ApiClient api;
  final int orderId;

  const OrderDetailScreen({
    super.key,
    required this.api,
    required this.orderId,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  Map<String, dynamic>? _order;
  List<WorkTask> _tasks = const [];
  List<OrderPhoto> _photos = const [];
  bool _loading = true;
  bool _uploading = false;
  String? _error;
  final Map<int, Future<Uint8List>> _photoCache = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await widget.api.order(widget.orderId);
      final order = Map<String, dynamic>.from(data['order'] as Map? ?? const {});
      final tasks = (data['tasks'] as List? ?? const [])
          .whereType<Map>()
          .map((e) => WorkTask.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      final photos = (data['photos'] as List? ?? const [])
          .whereType<Map>()
          .map((e) {
            final photo = OrderPhoto.fromJson(Map<String, dynamic>.from(e));
            return OrderPhoto(
              id: photo.id,
              photoType: photo.photoType,
              originalFilename: photo.originalFilename,
              caption: photo.caption,
              takenAt: photo.takenAt,
              url: widget.api.absoluteUrl(photo.url),
            );
          })
          .toList();
      if (!mounted) return;
      setState(() {
        _order = order;
        _tasks = tasks;
        _photos = photos;
      });
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _takePhoto(ImageSource source) async {
    if (_uploading) return;

    try {
      final picker = ImagePicker();
      // iOS: laat eerst de bottom sheet volledig sluiten voordat
      // UIImagePickerController / PHPicker wordt gepresenteerd.
      await Future<void>.delayed(const Duration(milliseconds: 450));

      final picked = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 2400,
        requestFullMetadata: false,
        preferredCameraDevice: CameraDevice.rear,
      );
      if (picked == null) return;

      if (!mounted) return;
      setState(() => _uploading = true);

      await widget.api.uploadPhoto(
        orderId: widget.orderId,
        file: File(picked.path),
        caption: 'Mobiele foto',
      );

      _photoCache.clear();
      await _load();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto toegevoegd aan het dossier.')),
      );
    } on PlatformException catch (e) {
      if (!mounted) return;
      final message = switch (e.code) {
        'camera_access_denied' =>
          'Geen toegang tot de camera. Geef DV Gravures cameratoegang in de iPhone-instellingen.',
        'photo_access_denied' =>
          'Geen toegang tot de fotobibliotheek. Geef DV Gravures toegang tot Foto’s in de iPhone-instellingen.',
        _ => 'Foto selecteren kon niet worden gestart (${e.code}).',
      };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Foto toevoegen is mislukt. De app blijft actief; probeer opnieuw of controleer de iPhone-toestemmingen.',
          ),
        ),
      );
    } finally {
      if (mounted && _uploading) {
        setState(() => _uploading = false);
      }
    }
  }

  Future<Uint8List> _photoBytes(OrderPhoto photo) {
    return _photoCache.putIfAbsent(
      photo.id,
      () => widget.api.photoBytes(photo.id),
    );
  }

  String _value(String key) => _order?[key]?.toString() ?? '';

  Widget _kv(String label, String value) {
    if (value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 125,
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _order == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final subject = _value('order_mode') == 'MANUAL'
        ? (_value('order_title').isEmpty ? 'Andere opdracht' : _value('order_title'))
        : (_value('deceased_name').isEmpty ? 'Opdracht' : _value('deceased_name'));

    return Scaffold(
      appBar: AppBar(
        title: Text('${_value('order_number')} · $subject'),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _uploading
            ? null
            : () => showModalBottomSheet<void>(
                  context: context,
                  builder: (context) => SafeArea(
                    child: Wrap(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.photo_camera),
                          title: const Text('Foto maken'),
                          onTap: () {
                            Navigator.pop(context);
                            _takePhoto(ImageSource.camera);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.photo_library),
                          title: const Text('Uit fotobibliotheek'),
                          onTap: () {
                            Navigator.pop(context);
                            _takePhoto(ImageSource.gallery);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
        icon: _uploading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.add_a_photo),
        label: Text(_uploading ? 'Uploaden…' : 'Foto'),
      ),
      body: _error != null
          ? Center(child: Text(_error!))
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Opdracht',
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 14),
                          _kv('Klant', _value('company_name')),
                          _kv('Overledene', _value('deceased_name')),
                          _kv('Begraafplaats', _value('cemetery_name')),
                          _kv('Ligging', _value('grave_location')),
                          _kv('Huidige stap', _value('current_step')),
                          _kv('Status', _value('main_status')),
                          if (_value('waiting_reason').isNotEmpty)
                            _kv('Wacht op', _value('waiting_reason')),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Taken', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  if (_tasks.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Geen taken gevonden.'),
                      ),
                    )
                  else
                    ..._tasks.map(
                      (task) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Card(
                          child: ListTile(
                            leading: Icon(
                              task.isClosed
                                  ? Icons.check_circle
                                  : Icons.radio_button_checked,
                            ),
                            title: Text(task.title),
                            subtitle: Text(task.statusName),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text('Foto’s', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  if (_photos.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Nog geen foto’s in dit dossier.'),
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _photos.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1.05,
                      ),
                      itemBuilder: (context, i) {
                        final photo = _photos[i];
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              FutureBuilder<Uint8List>(
                                future: _photoBytes(photo),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState != ConnectionState.done) {
                                    return const ColoredBox(
                                      color: Color(0xFFE6EBEF),
                                      child: Center(
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                    );
                                  }
                                  if (snapshot.hasError || snapshot.data == null) {
                                    return ColoredBox(
                                      color: const Color(0xFFE6EBEF),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.broken_image_outlined),
                                            const SizedBox(height: 6),
                                            const Text(
                                              'Foto kon niet laden',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(fontSize: 12),
                                            ),
                                            const SizedBox(height: 4),
                                            TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  _photoCache.remove(photo.id);
                                                });
                                              },
                                              child: const Text('Opnieuw'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                                  return Image.memory(
                                    snapshot.data!,
                                    fit: BoxFit.cover,
                                    gaplessPlayback: true,
                                  );
                                },
                              ),
                              if (photo.caption?.trim().isNotEmpty == true)
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(7),
                                    color: Colors.black54,
                                    child: Text(
                                      photo.caption!,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
    );
  }
}
