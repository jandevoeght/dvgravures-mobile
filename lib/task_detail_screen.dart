import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'api_client.dart';
import 'models.dart';
import 'order_detail_screen.dart';

class TaskDetailScreen extends StatefulWidget {
  final ApiClient api;
  final WorkTask task;

  const TaskDetailScreen({
    super.key,
    required this.api,
    required this.task,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  bool _busy = false;
  bool _done = false;
  String? _note;

  @override
  void initState() {
    super.initState();
    _note = widget.task.planningNotes;
  }

  Future<void> _openMaps() async {
    final address = widget.task.address;
    if (address.isEmpty) return;
    final uri = Uri.parse(
      'https://maps.apple.com/?q=${Uri.encodeComponent(address)}',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _complete() async {
    setState(() => _busy = true);
    try {
      await widget.api.completeManualTask(widget.task.id);
      if (!mounted) return;
      setState(() => _done = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Taak afgewerkt.')),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _editNote() async {
    final controller = TextEditingController(text: _note ?? '');
    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Notitie bij taak'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 5,
          maxLength: 1000,
          decoration: const InputDecoration(
            hintText: 'Typ of dicteer een korte notitie…',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuleren'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Opslaan'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value == null) return;
    try {
      await widget.api.updateTaskNote(widget.task.id, value);
      if (!mounted) return;
      setState(() => _note = value);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notitie opgeslagen.')),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
  }

  Widget _row(String label, String? value) {
    if (value == null || value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 118,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    return Scaffold(
      appBar: AppBar(title: Text(task.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (task.orderNumber != null)
                    Text(
                      '${task.orderNumber} · ${task.subject}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 118,
                          child: Text(
                            'Status',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: (_done || task.isClosed)
                                ? const Color(0xFFDCEFDC)
                                : (task.statusName.toLowerCase().contains('geblokkeerd')
                                    ? const Color(0xFFDFE3E8)
                                    : (task.statusCode.toUpperCase() == 'FUTURE'
                                        ? const Color(0xFFDCEcff)
                                        : const Color(0xFFFFF0AD))),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            _done ? 'Afgewerkt' : task.statusName,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                              color: (_done || task.isClosed)
                                  ? const Color(0xFF25612C)
                                  : (task.statusName.toLowerCase().contains('geblokkeerd')
                                      ? const Color(0xFF4C5966)
                                      : (task.statusCode.toUpperCase() == 'FUTURE'
                                          ? const Color(0xFF205C9C)
                                          : const Color(0xFF765900))),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _row('Klant', task.companyName),
                  _row('Overledene', task.deceasedName),
                  _row('Workflowstap', task.workflowStepName),
                  _row('Begraafplaats', task.cemeteryName),
                  _row('Ligging', task.graveLocation),
                  _row('Gepland', task.plannedDate),
                  _row('Vervaldatum', task.dueDate),
                  _row('Start', task.scheduledStart),
                  _row('Prioriteit', task.priority),
                  _row('Omschrijving', task.description),
                  _row('Notitie', _note),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _editNote,
            icon: const Icon(Icons.note_add_outlined),
            label: Text((_note?.trim().isNotEmpty == true)
                ? 'Notitie aanpassen'
                : 'Notitie toevoegen'),
          ),
          const SizedBox(height: 10),
          if (task.workOrderId != null)
            FilledButton.tonalIcon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => OrderDetailScreen(
                    api: widget.api,
                    orderId: task.workOrderId!,
                  ),
                ),
              ),
              icon: const Icon(Icons.folder_open),
              label: const Text('Open opdrachtdossier'),
            ),
          if (task.address.isNotEmpty) ...[
            const SizedBox(height: 10),
            FilledButton.tonalIcon(
              onPressed: _openMaps,
              icon: const Icon(Icons.navigation),
              label: const Text('Navigeren naar begraafplaats'),
            ),
          ],
          if (!task.isClosed && !_done) ...[
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: _busy ? null : _complete,
              icon: const Icon(Icons.check_circle),
              label: Text(_busy ? 'Bezig…' : 'Taak afwerken'),
            ),
            const SizedBox(height: 8),
            const Text(
              'In deze eerste mobiele versie kunnen alleen handmatige taken rechtstreeks worden afgewerkt. Workflowtaken blijven door de bestaande workflow gestuurd.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}
