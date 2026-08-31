import 'package:flutter/material.dart';

import 'api_client.dart';
import 'models.dart';
import 'order_detail_screen.dart';
import 'task_detail_screen.dart';
import 'more_screen.dart';

class HomeScreen extends StatefulWidget {
  final ApiClient api;
  final Future<void> Function() onLogout;

  const HomeScreen({
    super.key,
    required this.api,
    required this.onLogout,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      DayTaskPage(api: widget.api),
      TaskListPage(api: widget.api, scope: 'open', title: 'Open taken'),
      OrderListPage(api: widget.api),
      MoreScreen(api: widget.api),
    ];

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            Image.asset('assets/logo.png', height: 34, fit: BoxFit.contain),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('DV Gravures'),
                Text(
                  'Mobile v0.3.4',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Afmelden',
            onPressed: widget.onLogout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.today), label: 'Vandaag'),
          NavigationDestination(icon: Icon(Icons.checklist), label: 'Taken'),
          NavigationDestination(icon: Icon(Icons.folder_copy), label: 'Opdrachten'),
          NavigationDestination(icon: Icon(Icons.more_horiz), label: 'Meer'),
        ],
      ),
    );
  }
}

class DayTaskPage extends StatefulWidget {
  final ApiClient api;

  const DayTaskPage({super.key, required this.api});

  @override
  State<DayTaskPage> createState() => _DayTaskPageState();
}

class _DayTaskPageState extends State<DayTaskPage> {
  late DateTime _selectedDate;
  late Future<List<WorkTask>> _future;
  String _groupBy = 'cemetery';

  static const _weekdays = [
    'maandag', 'dinsdag', 'woensdag', 'donderdag', 'vrijdag', 'zaterdag', 'zondag'
  ];
  static const _months = [
    'januari', 'februari', 'maart', 'april', 'mei', 'juni',
    'juli', 'augustus', 'september', 'oktober', 'november', 'december'
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _future = _loadFor(_selectedDate);
  }

  String _dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _dateLabel(DateTime d) =>
      '${_weekdays[d.weekday - 1]} ${d.day} ${_months[d.month - 1]}';

  bool get _isToday {
    final n = DateTime.now();
    return n.year == _selectedDate.year &&
        n.month == _selectedDate.month &&
        n.day == _selectedDate.day;
  }

  Future<List<WorkTask>> _loadFor(DateTime date) =>
      widget.api.tasks(scope: 'date', date: _dateKey(date));

  Future<void> _refresh() async {
    setState(() => _future = _loadFor(_selectedDate));
    await _future;
  }

  void _moveDay(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
      _future = _loadFor(_selectedDate);
    });
  }

  void _goToday() {
    final n = DateTime.now();
    setState(() {
      _selectedDate = DateTime(n.year, n.month, n.day);
      _future = _loadFor(_selectedDate);
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(DateTime.now().year + 3, 12, 31),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _selectedDate = DateTime(picked.year, picked.month, picked.day);
      _future = _loadFor(_selectedDate);
    });
  }

  List<WorkTask> _mobileTasks(List<WorkTask> source) => source.where((task) {
        final title = task.title.trim().toLowerCase();
        return task.adminCode != 'INVOICE' &&
            task.workflowStepCode != 'INVOICE' &&
            task.workflowStepCode != 'ORDERING' &&
            title != 'factureren' &&
            title != 'facturatie' &&
            title != 'bestellingen uitvoeren';
      }).toList();

  String _groupKey(WorkTask task) {
    if (_groupBy == 'date') {
      return task.plannedDate?.trim().isNotEmpty == true
          ? task.plannedDate!
          : (task.dueDate?.trim().isNotEmpty == true ? task.dueDate! : 'Geen datum');
    }
    if (_groupBy == 'cemetery') {
      return task.cemeteryName?.trim().isNotEmpty == true
          ? task.cemeteryName!.trim()
          : 'Zonder begraafplaats';
    }
    return '';
  }

  String _groupIdentity(WorkTask task) {
    if (_groupBy == 'cemetery') {
      return task.cemeteryId != null ? 'cemetery-${task.cemeteryId}' : 'without-cemetery';
    }
    return _groupKey(task);
  }

  String _visualState(WorkTask task) {
    if (task.isClosed) return 'DONE';
    final workflow = task.workflowState?.toUpperCase() ?? '';
    if (workflow == 'BLOCKED') return 'BLOCKED';
    if (workflow == 'FUTURE') return 'FUTURE';
    if (workflow == 'DONE') return 'DONE';
    final status = task.statusName.toLowerCase();
    if (status.contains('geblokkeerd')) return 'BLOCKED';
    if (status.contains('afgewerkt') || status.contains('voltooid')) return 'DONE';
    if (status.contains('toekomst')) return 'FUTURE';
    return 'ACTIVE';
  }

  Color _statusBackground(WorkTask task) => switch (_visualState(task)) {
        'DONE' => const Color(0xFFDCEFDC),
        'FUTURE' => const Color(0xFFDCECFF),
        'BLOCKED' => const Color(0xFFDFE3E8),
        _ => const Color(0xFFFFF0AD),
      };

  Color _statusForeground(WorkTask task) => switch (_visualState(task)) {
        'DONE' => const Color(0xFF25612C),
        'FUTURE' => const Color(0xFF205C9C),
        'BLOCKED' => const Color(0xFF4C5966),
        _ => const Color(0xFF765900),
      };

  Widget _taskCard(WorkTask task) => Padding(
        padding: const EdgeInsets.only(bottom: 9),
        child: Card(
          color: _statusBackground(task),
          child: ListTile(
            contentPadding: const EdgeInsets.all(14),
            leading: CircleAvatar(
              backgroundColor: Colors.white.withValues(alpha: 0.72),
              foregroundColor: _statusForeground(task),
              child: Text(
                task.orderNumber?.split('-').last ?? '•',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ),
            title: Text(
              task.title,
              style: TextStyle(
                color: _statusForeground(task),
                fontWeight: FontWeight.w700,
              ),
            ),
            subtitle: Text(
              [
                if (task.orderNumber?.isNotEmpty == true)
                  '${task.orderNumber} · ${task.subject}',
                if (task.cemeteryName?.isNotEmpty == true) task.cemeteryName!,
                if (task.graveLocation?.isNotEmpty == true) task.graveLocation!,
              ].join('\n'),
              style: TextStyle(
                color: _statusForeground(task).withValues(alpha: 0.82),
              ),
            ),
            trailing: Icon(Icons.chevron_right, color: _statusForeground(task)),
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TaskDetailScreen(api: widget.api, task: task),
                ),
              );
              _refresh();
            },
          ),
        ),
      );

  List<Widget> _buildGrouped(List<WorkTask> tasks) {
    if (_groupBy == 'none') return tasks.map(_taskCard).toList();
    final groups = <String, List<WorkTask>>{};
    final labels = <String, String>{};
    for (final task in tasks) {
      final key = _groupIdentity(task);
      groups.putIfAbsent(key, () => <WorkTask>[]).add(task);
      labels.putIfAbsent(key, () => _groupKey(task));
    }
    final widgets = <Widget>[];
    for (final entry in groups.entries) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(2, 10, 2, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  labels[entry.key] ?? entry.key,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              Text('${entry.value.length}'),
            ],
          ),
        ),
      );
      widgets.addAll(entry.value.map(_taskCard));
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<WorkTask>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done && !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _ErrorState(message: snapshot.error.toString(), onRetry: _refresh);
        }
        final tasks = _mobileTasks(snapshot.data ?? const <WorkTask>[]);
        final cemeteryCount = tasks
            .map((t) => t.cemeteryName?.trim())
            .where((v) => v != null && v!.isNotEmpty)
            .toSet()
            .length;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragEnd: (details) {
            final v = details.primaryVelocity ?? 0;
            if (v < -250) _moveDay(1);
            if (v > 250) _moveDay(-1);
          },
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                    child: Row(
                      children: [
                        IconButton(
                          tooltip: 'Vorige dag',
                          onPressed: () => _moveDay(-1),
                          icon: const Icon(Icons.chevron_left),
                        ),
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: _pickDate,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 7),
                              child: Column(
                                children: [
                                  Text(
                                    _isToday ? 'Vandaag' : _dateLabel(_selectedDate),
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w800,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                  if (!_isToday)
                                    Text(
                                      _dateKey(_selectedDate),
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Volgende dag',
                          onPressed: () => _moveDay(1),
                          icon: const Icon(Icons.chevron_right),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (!_isToday)
                      TextButton.icon(
                        onPressed: _goToday,
                        icon: const Icon(Icons.today, size: 18),
                        label: const Text('Vandaag'),
                      ),
                    const Spacer(),
                    PopupMenuButton<String>(
                      tooltip: 'Groeperen',
                      initialValue: _groupBy,
                      onSelected: (value) => setState(() => _groupBy = value),
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'cemetery', child: Text('Per begraafplaats')),
                        PopupMenuItem(value: 'date', child: Text('Per datum')),
                        PopupMenuItem(value: 'none', child: Text('Geen groepering')),
                      ],
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.view_list, size: 18),
                            SizedBox(width: 5),
                            Text('Groeperen'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  '${tasks.length} taken · $cemeteryCount begraafplaatsen',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                if (tasks.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(18),
                      child: Text('Geen taken gepland voor deze dag.'),
                    ),
                  )
                else
                  ..._buildGrouped(tasks),
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    'Tip: swipe links/rechts om van dag te wisselen.',
                    style: TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class TaskListPage extends StatefulWidget {
  final ApiClient api;
  final String scope;
  final String title;

  const TaskListPage({
    super.key,
    required this.api,
    required this.scope,
    required this.title,
  });

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  late Future<List<WorkTask>> _future;
  String _groupBy = 'cemetery';

  @override
  void initState() {
    super.initState();
    _future = widget.api.tasks(scope: widget.scope);
  }

  Future<void> _refresh() async {
    setState(() => _future = widget.api.tasks(scope: widget.scope));
    await _future;
  }

  String _visualState(WorkTask task) {
    if (task.isClosed) return 'DONE';
    final workflow = task.workflowState?.toUpperCase() ?? '';
    if (workflow == 'BLOCKED') return 'BLOCKED';
    if (workflow == 'FUTURE') return 'FUTURE';
    if (workflow == 'DONE') return 'DONE';
    final status = task.statusName.toLowerCase();
    if (status.contains('geblokkeerd')) return 'BLOCKED';
    if (status.contains('afgewerkt') || status.contains('voltooid')) return 'DONE';
    if (status.contains('toekomst')) return 'FUTURE';
    return 'ACTIVE';
  }

  Color _statusBackground(WorkTask task) => switch (_visualState(task)) {
        'DONE' => const Color(0xFFDCEFDC),
        'FUTURE' => const Color(0xFFDCECFF),
        'BLOCKED' => const Color(0xFFDFE3E8),
        _ => const Color(0xFFFFF0AD),
      };

  Color _statusForeground(WorkTask task) => switch (_visualState(task)) {
        'DONE' => const Color(0xFF25612C),
        'FUTURE' => const Color(0xFF205C9C),
        'BLOCKED' => const Color(0xFF4C5966),
        _ => const Color(0xFF765900),
      };

  List<WorkTask> _mobileTasks(List<WorkTask> source) => source.where((task) {
        final title = task.title.trim().toLowerCase();
        return task.adminCode != 'INVOICE' &&
            task.workflowStepCode != 'INVOICE' &&
            task.workflowStepCode != 'ORDERING' &&
            title != 'factureren' &&
            title != 'facturatie' &&
            title != 'bestellingen uitvoeren';
      }).toList();

  String _groupKey(WorkTask task) {
    if (_groupBy == 'taskType') {
      return task.title.trim().isNotEmpty ? task.title.trim() : 'Andere taak';
    }
    if (_groupBy == 'date') {
      return task.plannedDate?.trim().isNotEmpty == true
          ? task.plannedDate!
          : (task.dueDate?.trim().isNotEmpty == true ? task.dueDate! : 'Geen datum');
    }
    if (_groupBy == 'cemetery') {
      return task.cemeteryName?.trim().isNotEmpty == true
          ? task.cemeteryName!.trim()
          : 'Zonder begraafplaats';
    }
    return '';
  }

  Widget _taskCard(WorkTask task) => Padding(
        padding: const EdgeInsets.only(bottom: 9),
        child: Card(
          color: _statusBackground(task),
          child: ListTile(
            contentPadding: const EdgeInsets.all(14),
            leading: CircleAvatar(
              backgroundColor: Colors.white.withValues(alpha: 0.72),
              foregroundColor: _statusForeground(task),
              child: Text(
                task.orderNumber?.split('-').last ?? '•',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ),
            title: Text(
              task.title,
              style: TextStyle(
                color: _statusForeground(task),
                fontWeight: FontWeight.w700,
              ),
            ),
            subtitle: Text(
              [
                if (task.orderNumber?.isNotEmpty == true)
                  '${task.orderNumber} · ${task.subject}',
                if (task.cemeteryName?.isNotEmpty == true) task.cemeteryName!,
                if (task.graveLocation?.isNotEmpty == true) task.graveLocation!,
              ].join('\n'),
              style: TextStyle(
                color: _statusForeground(task).withValues(alpha: 0.82),
              ),
            ),
            trailing: Icon(Icons.chevron_right, color: _statusForeground(task)),
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TaskDetailScreen(api: widget.api, task: task),
                ),
              );
              _refresh();
            },
          ),
        ),
      );

  List<Widget> _grouped(List<WorkTask> tasks) {
    if (_groupBy == 'none') return tasks.map(_taskCard).toList();
    final groups = <String, List<WorkTask>>{};
    for (final task in tasks) {
      groups.putIfAbsent(_groupKey(task), () => <WorkTask>[]).add(task);
    }
    final out = <Widget>[];
    for (final entry in groups.entries) {
      out.add(Padding(
        padding: const EdgeInsets.fromLTRB(2, 10, 2, 8),
        child: Row(children: [
          Expanded(child: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w800))),
          Text('${entry.value.length}'),
        ]),
      ));
      out.addAll(entry.value.map(_taskCard));
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<WorkTask>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _ErrorState(message: snapshot.error.toString(), onRetry: _refresh);
        }
        final tasks = _mobileTasks(snapshot.data ?? const <WorkTask>[]);
        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${widget.title} · ${tasks.length}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  PopupMenuButton<String>(
                    tooltip: 'Groeperen',
                    initialValue: _groupBy,
                    onSelected: (value) => setState(() => _groupBy = value),
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'cemetery', child: Text('Per begraafplaats')),
                      PopupMenuItem(value: 'date', child: Text('Per datum')),
                      PopupMenuItem(value: 'taskType', child: Text('Per taaktype')),
                      PopupMenuItem(value: 'none', child: Text('Geen groepering')),
                    ],
                    icon: const Icon(Icons.view_list),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (tasks.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: Text('Geen taken gevonden.'),
                  ),
                )
              else
                ..._grouped(tasks),
            ],
          ),
        );
      },
    );
  }
}

class OrderListPage extends StatefulWidget {
  final ApiClient api;

  const OrderListPage({super.key, required this.api});

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  final _search = TextEditingController();
  late Future<List<WorkOrderSummary>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.api.orders();
  }

  Future<void> _load([String query = '']) async {
    setState(() => _future = widget.api.orders(query: query));
    await _future;
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<WorkOrderSummary>>(
      future: _future,
      builder: (context, snapshot) {
        final orders = snapshot.data ?? const [];
        return RefreshIndicator(
          onRefresh: () => _load(_search.text),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(
                controller: _search,
                decoration: InputDecoration(
                  labelText: 'Zoek opdracht',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: () => _load(_search.text),
                  ),
                ),
                textInputAction: TextInputAction.search,
                onSubmitted: _load,
              ),
              const SizedBox(height: 14),
              if (snapshot.connectionState != ConnectionState.done)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (snapshot.hasError)
                _ErrorState(
                  message: snapshot.error.toString(),
                  onRetry: () => _load(_search.text),
                )
              else if (orders.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: Text('Geen opdrachten gevonden.'),
                  ),
                )
              else
                ...orders.map(
                  (order) => Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(14),
                        title: Text('${order.orderNumber} · ${order.subject}'),
                        subtitle: Text(
                          [
                            if (order.companyName?.isNotEmpty == true) order.companyName!,
                            if (order.currentStep?.isNotEmpty == true) 'Stap: ${order.currentStep}',
                            if (order.cemeteryName?.isNotEmpty == true) order.cemeteryName!,
                          ].join('\n'),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => OrderDetailScreen(api: widget.api, orderId: order.id),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 34),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onRetry, child: const Text('Opnieuw proberen')),
          ],
        ),
      ),
    );
  }
}
