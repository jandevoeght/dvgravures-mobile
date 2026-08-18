import 'package:flutter/material.dart';

import 'api_client.dart';
import 'models.dart';
import 'order_detail_screen.dart';
import 'task_detail_screen.dart';

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
      TaskListPage(api: widget.api, scope: 'today', title: 'Vandaag'),
      TaskListPage(api: widget.api, scope: 'open', title: 'Open taken'),
      OrderListPage(api: widget.api),
    ];

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            Image.asset('assets/logo.png', height: 34, fit: BoxFit.contain),
            const SizedBox(width: 10),
            const Text('Mobiel'),
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
          NavigationDestination(
            icon: Icon(Icons.today),
            label: 'Vandaag',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist),
            label: 'Taken',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_copy),
            label: 'Opdrachten',
          ),
        ],
      ),
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

  @override
  void initState() {
    super.initState();
    _future = widget.api.tasks(scope: widget.scope);
  }

  Future<void> _refresh() async {
    setState(() => _future = widget.api.tasks(scope: widget.scope));
    await _future;
  }

  Color _statusBackground(WorkTask task) {
    final state = task.isClosed
        ? 'DONE'
        : (task.statusCode.isNotEmpty ? task.statusCode : 'ACTIVE').toUpperCase();

    if (task.statusName.toLowerCase().contains('geblokkeerd') ||
        state == 'BLOCKED') {
      return const Color(0xFFDFE3E8);
    }
    if (state == 'DONE' ||
        task.statusName.toLowerCase().contains('afgewerkt')) {
      return const Color(0xFFDCEFDC);
    }
    if (state == 'FUTURE' ||
        task.statusName.toLowerCase().contains('toekomst')) {
      return const Color(0xFFDCEcff);
    }
    return const Color(0xFFFFF0AD);
  }

  Color _statusForeground(WorkTask task) {
    final bg = _statusBackground(task);
    if (bg == const Color(0xFFDFE3E8)) return const Color(0xFF4C5966);
    if (bg == const Color(0xFFDCEFDC)) return const Color(0xFF25612C);
    if (bg == const Color(0xFFDCEcff)) return const Color(0xFF205C9C);
    return const Color(0xFF765900);
  }

  Widget _statusChip(WorkTask task) {
    final label = task.statusName.trim().isNotEmpty
        ? task.statusName
        : (task.isClosed ? 'Afgewerkt' : 'Actief');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: _statusBackground(task),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: _statusForeground(task),
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
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
          return _ErrorState(
            message: snapshot.error.toString(),
            onRetry: _refresh,
          );
        }
        final tasks = (snapshot.data ?? const <WorkTask>[])
            .where((task) => task.adminCode != 'INVOICE')
            .toList();
        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                '${widget.title} · ${tasks.length}',
                style: Theme.of(context).textTheme.titleLarge,
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
                ...tasks.map(
                  (task) => Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(14),
                        leading: CircleAvatar(
                          child: Text(
                            task.orderNumber?.split('-').last ?? '•',
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                        title: Text(task.title),
                        subtitle: Text(
                          [
                            if (task.orderNumber?.isNotEmpty == true)
                              '${task.orderNumber} · ${task.subject}',
                            if (task.cemeteryName?.isNotEmpty == true)
                              task.cemeteryName!,
                            if (task.graveLocation?.isNotEmpty == true)
                              task.graveLocation!,
                          ].join('\n'),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _statusChip(task),
                            const SizedBox(height: 4),
                            const Icon(Icons.chevron_right, size: 18),
                          ],
                        ),
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  TaskDetailScreen(api: widget.api, task: task),
                            ),
                          );
                          _refresh();
                        },
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
                            if (order.companyName?.isNotEmpty == true)
                              order.companyName!,
                            if (order.currentStep?.isNotEmpty == true)
                              'Stap: ${order.currentStep}',
                            if (order.cemeteryName?.isNotEmpty == true)
                              order.cemeteryName!,
                          ].join('\n'),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => OrderDetailScreen(
                              api: widget.api,
                              orderId: order.id,
                            ),
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
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('Opnieuw proberen'),
            ),
          ],
        ),
      ),
    );
  }
}
