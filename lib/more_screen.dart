import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'api_client.dart';
import 'models.dart';
import 'directory_detail_screens.dart';

Future<void> _launch(String prefix, String value) async {
  final uri = Uri.parse('$prefix${Uri.encodeComponent(value)}');
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    throw const ApiException('Kan de gekozen app niet openen.');
  }
}

Future<void> _navigate(BuildContext context, String address) async {
  final choice = await showModalBottomSheet<String>(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: Wrap(children: [
        ListTile(leading: const Icon(Icons.map_outlined), title: const Text('Apple Kaarten'), onTap: () => Navigator.pop(sheetContext, 'apple')),
        ListTile(leading: const Icon(Icons.map), title: const Text('Google Maps'), onTap: () => Navigator.pop(sheetContext, 'google')),
      ]),
    ),
  );
  if (choice == 'apple') await _launch('https://maps.apple.com/?q=', address);
  if (choice == 'google') await _launch('https://www.google.com/maps/search/?api=1&query=', address);
}

class MoreScreen extends StatelessWidget {
  final ApiClient api;
  const MoreScreen({super.key, required this.api});

  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
    _tile(context, Icons.location_city, 'Begraafplaatsen', 'Zoeken en navigatie', CemeterySearchScreen(api: api)),
    _tile(context, Icons.people_alt_outlined, 'Klanten', 'Adres en contactgegevens', CustomerSearchScreen(api: api)),
    _tile(context, Icons.shopping_cart_outlined, 'Aankooplijst', 'Gedeelde praktische lijst', ShoppingListScreen(api: api)),
  ]);

  Widget _tile(BuildContext context, IconData icon, String title, String subtitle, Widget page) => Card(
    child: ListTile(
      contentPadding: const EdgeInsets.all(16), leading: CircleAvatar(child: Icon(icon)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)), subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
    ),
  );
}

class CemeterySearchScreen extends StatefulWidget {
  final ApiClient api;
  const CemeterySearchScreen({super.key, required this.api});
  @override State<CemeterySearchScreen> createState() => _CemeterySearchState();
}

class _CemeterySearchState extends State<CemeterySearchScreen> {
  late Future<List<Cemetery>> _future;
  Timer? _timer;
  @override void initState() { super.initState(); _future = widget.api.cemeteries(); }
  @override void dispose() { _timer?.cancel(); super.dispose(); }
  void _search(String query) {
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 300), () => setState(() => _future = widget.api.cemeteries(query: query)));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Begraafplaatsen')),
    body: Column(children: [
      Padding(padding: const EdgeInsets.all(16), child: TextField(onChanged: _search, decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Naam, gemeente of postcode'))),
      Expanded(child: FutureBuilder<List<Cemetery>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return snapshot.hasError ? Center(child: Text('${snapshot.error}')) : const Center(child: CircularProgressIndicator());
          final rows = snapshot.data!;
          if (rows.isEmpty) return const Center(child: Text('Geen begraafplaatsen gevonden.'));
          return ListView.builder(itemCount: rows.length, itemBuilder: (context, index) {
            final cemetery = rows[index];
            return ListTile(
              title: Text(cemetery.name, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(cemetery.address.isEmpty ? 'Adres ontbreekt' : cemetery.address),
              trailing: cemetery.address.isEmpty ? null : IconButton(tooltip: 'Navigatie starten', icon: const Icon(Icons.navigation), onPressed: () => _navigate(context, cemetery.address)),
              onTap: () => Navigator.push(context,MaterialPageRoute(builder:(_)=>CemeteryDetailScreen(api:widget.api,id:cemetery.id))),
            );
          });
        },
      )),
    ]),
  );
}

class CustomerSearchScreen extends StatefulWidget {
  final ApiClient api;
  const CustomerSearchScreen({super.key, required this.api});
  @override State<CustomerSearchScreen> createState() => _CustomerSearchState();
}

class _CustomerSearchState extends State<CustomerSearchScreen> {
  late Future<List<Customer>> _future;
  Timer? _timer;
  @override void initState() { super.initState(); _future = widget.api.customers(); }
  @override void dispose() { _timer?.cancel(); super.dispose(); }
  void _search(String query) {
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 300), () => setState(() => _future = widget.api.customers(query: query)));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Klanten')),
    body: Column(children: [
      Padding(padding: const EdgeInsets.all(16), child: TextField(onChanged: _search, decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Naam, contact, gemeente…'))),
      Expanded(child: FutureBuilder<List<Customer>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return snapshot.hasError ? Center(child: Text('${snapshot.error}')) : const Center(child: CircularProgressIndicator());
          final rows = snapshot.data!;
          if (rows.isEmpty) return const Center(child: Text('Geen klanten gevonden.'));
          return ListView.builder(itemCount: rows.length, itemBuilder: (context, index) {
            final customer = rows[index];
            return Card(
              margin: const EdgeInsets.fromLTRB(12, 4, 12, 4),
              child: ListTile(title: Text(customer.name, style: const TextStyle(fontWeight: FontWeight.w700)),subtitle: Text(customer.address),trailing:const Icon(Icons.chevron_right),onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>CustomerDetailScreen(api:widget.api,id:customer.id)))),
            );
          });
        },
      )),
    ]),
  );
}

class ShoppingListScreen extends StatefulWidget {
  final ApiClient api;
  const ShoppingListScreen({super.key, required this.api});
  @override State<ShoppingListScreen> createState() => _ShoppingListState();
}

class _ShoppingListState extends State<ShoppingListScreen> {
  late Future<List<ShoppingItem>> _future;
  List<String> _knownCategories=[];
  Future<List<ShoppingItem>> _load()async{final rows=await widget.api.shoppingItems();_knownCategories=rows.map((x)=>x.category.trim()).where((x)=>x.isNotEmpty).toSet().toList()..sort();return rows;}
  @override void initState() { super.initState(); _future = _load(); }
  Future<void> _reload() async { setState(() => _future = _load()); await _future; }

  Future<void> _add() async {
    final description = TextEditingController();
    final category = TextEditingController();
    final quantity = TextEditingController();
    final note = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Artikel toevoegen'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: description, autofocus: true, decoration: const InputDecoration(labelText: 'Wat aankopen?')),
          TextField(controller: category, decoration: const InputDecoration(labelText: 'Categorie (optioneel)')),
          if(_knownCategories.isNotEmpty)Padding(padding:const EdgeInsets.only(top:8),child:Wrap(spacing:6,children:_knownCategories.map((x)=>ActionChip(label:Text(x),onPressed:()=>category.text=x)).toList())),
          TextField(controller: quantity, decoration: const InputDecoration(labelText: 'Aantal (optioneel)')),
          TextField(controller: note, maxLines: 2, decoration: const InputDecoration(labelText: 'Opmerking (optioneel)')),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Annuleren')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Toevoegen')),
        ],
      ),
    );
    if (confirmed == true && description.text.trim().isNotEmpty) {
      await widget.api.addShoppingItem(description.text.trim(), category:category.text.trim(), quantity: quantity.text.trim(), note: note.text.trim());
      await _reload();
    }
    description.dispose(); category.dispose(); quantity.dispose(); note.dispose();
  }

  Future<void> _editCategory(ShoppingItem item)async{
   final controller=TextEditingController(text:item.category);
   final save=await showDialog<bool>(context:context,builder:(c)=>AlertDialog(title:const Text('Categorie aanpassen'),content:Column(mainAxisSize:MainAxisSize.min,children:[TextField(controller:controller,autofocus:true,decoration:const InputDecoration(labelText:'Categorie')),if(_knownCategories.isNotEmpty)Padding(padding:const EdgeInsets.only(top:8),child:Wrap(spacing:6,children:_knownCategories.map((x)=>ActionChip(label:Text(x),onPressed:()=>controller.text=x)).toList()))]),actions:[TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('Annuleren')),FilledButton(onPressed:()=>Navigator.pop(c,true),child:const Text('Opslaan'))]));
   if(save==true){await widget.api.updateShoppingCategory(item.id,controller.text.trim());await _reload();}controller.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Aankooplijst')),
    floatingActionButton: FloatingActionButton.extended(onPressed: _add, icon: const Icon(Icons.add), label: const Text('Toevoegen')),
    body: RefreshIndicator(
      onRefresh: _reload,
      child: FutureBuilder<List<ShoppingItem>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            if (snapshot.hasError) return ListView(children: [Padding(padding: const EdgeInsets.all(24), child: Text('${snapshot.error}'))]);
            return const Center(child: CircularProgressIndicator());
          }
          final rows = snapshot.data!;
          if (rows.isEmpty) return ListView(children: const [Padding(padding: EdgeInsets.all(40), child: Center(child: Text('De aankooplijst is leeg.')))]);
          final widgets=<Widget>[];String? lastGroup;
          for(final item in rows){
              final category=item.category.trim().isEmpty?'Zonder categorie':item.category.trim();
              final group='${item.purchased?'Aangekocht':'Nog aan te kopen'}|$category';
              if(group!=lastGroup){widgets.add(Padding(padding:const EdgeInsets.fromLTRB(16,18,16,6),child:Text('${item.purchased?'Aangekocht':'Nog aan te kopen'} · $category',style:const TextStyle(fontWeight:FontWeight.w800))));lastGroup=group;}
              final title = item.quantity.isEmpty ? item.description : '${item.description} · ${item.quantity}';
              widgets.add(Dismissible(
                key: ValueKey(item.id), direction: DismissDirection.endToStart,
                background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.all(20), child: const Icon(Icons.delete, color: Colors.white)),
                onDismissed: (_) => widget.api.deleteShoppingItem(item.id),
                child: CheckboxListTile(
                  value: item.purchased,
                  onChanged: (value) async { await widget.api.toggleShoppingItem(item.id, value ?? false); await _reload(); },
                  title: Text(title, style: TextStyle(decoration: item.purchased ? TextDecoration.lineThrough : null)),
                  subtitle: Text([if (item.note.isNotEmpty) item.note, if (item.createdByName.isNotEmpty) 'Toegevoegd door ${item.createdByName}'].join('\n')),
                  secondary: IconButton(tooltip:'Categorie aanpassen',icon:const Icon(Icons.category_outlined),onPressed:()=>_editCategory(item)),
                ),
              ));
          }
          return ListView(padding:const EdgeInsets.only(bottom:90),children:widgets);
        },
      ),
    ),
  );
}
