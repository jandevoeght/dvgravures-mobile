import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'api_client.dart';
import 'models.dart';

Future<void> _launch(String scheme,String value) async {
  final uri=Uri.parse('$scheme${Uri.encodeComponent(value)}');
  if(!await launchUrl(uri,mode:LaunchMode.externalApplication)) throw const ApiException('Kan de gekozen app niet openen.');
}

Future<void> _navigate(BuildContext context,String address) async {
  final choice=await showModalBottomSheet<String>(context:context,builder:(c)=>SafeArea(child:Wrap(children:[
    ListTile(leading:const Icon(Icons.map_outlined),title:const Text('Apple Kaarten'),onTap:()=>Navigator.pop(c,'apple')),
    ListTile(leading:const Icon(Icons.map),title:const Text('Google Maps'),onTap:()=>Navigator.pop(c,'google')),
  ])));
  if(choice=='apple')await _launch('https://maps.apple.com/?q=',address);
  if(choice=='google')await _launch('https://www.google.com/maps/search/?api=1&query=',address);
}

class MoreScreen extends StatelessWidget {
  final ApiClient api; const MoreScreen({super.key,required this.api});
  @override Widget build(BuildContext context)=>ListView(padding:const EdgeInsets.all(16),children:[
    _tile(context,Icons.location_city,'Begraafplaatsen','Zoeken en navigatie',CemeterySearchScreen(api:api)),
    _tile(context,Icons.people_alt_outlined,'Klanten','Adres en contactgegevens',CustomerSearchScreen(api:api)),
    _tile(context,Icons.shopping_cart_outlined,'Aankooplijst','Gedeelde praktische lijst',ShoppingListScreen(api:api)),
  ]);
  Widget _tile(BuildContext c,IconData i,String title,String sub,Widget page)=>Card(child:ListTile(contentPadding:const EdgeInsets.all(16),leading:CircleAvatar(child:Icon(i)),title:Text(title,style:const TextStyle(fontWeight:FontWeight.w700)),subtitle:Text(sub),trailing:const Icon(Icons.chevron_right),onTap:()=>Navigator.push(c,MaterialPageRoute(builder:(_)=>page))));
}

class CemeterySearchScreen extends StatefulWidget {final ApiClient api;const CemeterySearchScreen({super.key,required this.api});@override State<CemeterySearchScreen> createState()=>_CemeterySearchState();}
class _CemeterySearchState extends State<CemeterySearchScreen>{late Future<List<Cemetery>> _future;Timer? _timer;@override void initState(){super.initState();_future=widget.api.cemeteries();}@override void dispose(){_timer?.cancel();super.dispose();}
 void _search(String q){_timer?.cancel();_timer=Timer(const Duration(milliseconds:300),()=>setState(()=>_future=widget.api.cemeteries(query:q)));}
 @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Begraafplaatsen')),body:Column(children:[Padding(padding:const EdgeInsets.all(16),child:TextField(onChanged:_search,decoration:const InputDecoration(prefixIcon:Icon(Icons.search),hintText:'Naam, gemeente of postcode'))),Expanded(child:FutureBuilder<List<Cemetery>>(future:_future,builder:(c,s){if(!s.hasData)return s.hasError?Center(child:Text('${s.error}')):const Center(child:CircularProgressIndicator());final rows=s.data!;if(rows.isEmpty)return const Center(child:Text('Geen begraafplaatsen gevonden.'));return ListView.builder(itemCount:rows.length,itemBuilder:(c,i){final x=rows[i];return ListTile(title:Text(x.name,style:const TextStyle(fontWeight:FontWeight.w700)),subtitle:Text(x.address.isEmpty?'Adres ontbreekt':x.address),trailing:x.address.isEmpty?null:IconButton(tooltip:'Navigatie starten',icon:const Icon(Icons.navigation),onPressed:()=>_navigate(context,x.address)));});}))]));}

class CustomerSearchScreen extends StatefulWidget {final ApiClient api;const CustomerSearchScreen({super.key,required this.api});@override State<CustomerSearchScreen> createState()=>_CustomerSearchState();}
class _CustomerSearchState extends State<CustomerSearchScreen>{late Future<List<Customer>> _future;Timer? _timer;@override void initState(){super.initState();_future=widget.api.customers();}@override void dispose(){_timer?.cancel();super.dispose();}
 void _search(String q){_timer?.cancel();_timer=Timer(const Duration(milliseconds:300),()=>setState(()=>_future=widget.api.customers(query:q)));}
 @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Klanten')),body:Column(children:[Padding(padding:const EdgeInsets.all(16),child:TextField(onChanged:_search,decoration:const InputDecoration(prefixIcon:Icon(Icons.search),hintText:'Naam, contact, gemeente…'))),Expanded(child:FutureBuilder<List<Customer>>(future:_future,builder:(c,s){if(!s.hasData)return s.hasError?Center(child:Text('${s.error}')):const Center(child:CircularProgressIndicator());return ListView.builder(itemCount:s.data!.length,itemBuilder:(c,i){final x=s.data![i];return Card(margin:const EdgeInsets.fromLTRB(12,4,12,4),child:ExpansionTile(title:Text(x.name,style:const TextStyle(fontWeight:FontWeight.w700)),subtitle:Text(x.address),children:[if(x.contactName.isNotEmpty)ListTile(leading:const Icon(Icons.person_outline),title:Text(x.contactName)),if((x.contactPhone.isNotEmpty?x.contactPhone:x.phone).isNotEmpty)ListTile(leading:const Icon(Icons.phone),title:Text(x.contactPhone.isNotEmpty?x.contactPhone:x.phone),onTap:()=>_launch('tel:',x.contactPhone.isNotEmpty?x.contactPhone:x.phone)),if((x.contactEmail.isNotEmpty?x.contactEmail:x.email).isNotEmpty)ListTile(leading:const Icon(Icons.email_outlined),title:Text(x.contactEmail.isNotEmpty?x.contactEmail:x.email),onTap:()=>_launch('mailto:',x.contactEmail.isNotEmpty?x.contactEmail:x.email)),if(x.address.isNotEmpty)ListTile(leading:const Icon(Icons.navigation),title:const Text('Navigatie starten'),onTap:()=>_navigate(context,x.address))]));});}))]));}

class ShoppingListScreen extends StatefulWidget {final ApiClient api;const ShoppingListScreen({super.key,required this.api});@override State<ShoppingListScreen> createState()=>_ShoppingListState();}
class _ShoppingListState extends State<ShoppingListScreen>{late Future<List<ShoppingItem>> _future;@override void initState(){super.initState();_future=widget.api.shoppingItems();}Future<void> _reload()async{setState(()=>_future=widget.api.shoppingItems());await _future;}
 Future<void> _add()async{final d=TextEditingController(),q=TextEditingController(),n=TextEditingController();final ok=await showDialog<bool>(context:context,builder:(c)=>AlertDialog(title:const Text('Artikel toevoegen'),content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[TextField(controller:d,autofocus:true,decoration:const InputDecoration(labelText:'Wat aankopen?')),TextField(controller:q,decoration:const InputDecoration(labelText:'Aantal (optioneel)')),TextField(controller:n,maxLines:2,decoration:const InputDecoration(labelText:'Opmerking (optioneel)'))])),actions:[TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('Annuleren')),FilledButton(onPressed:()=>Navigator.pop(c,true),child:const Text('Toevoegen'))]));if(ok==true&&d.text.trim().isNotEmpty){await widget.api.addShoppingItem(d.text.trim(),quantity:q.text.trim(),note:n.text.trim());await _reload();}d.dispose();q.dispose();n.dispose();}
 @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Aankooplijst')),floatingActionButton:FloatingActionButton.extended(onPressed:_add,icon:const Icon(Icons.add),label:const Text('Toevoegen')),body:RefreshIndicator(onRefresh:_reload,child:FutureBuilder<List<ShoppingItem>>(future:_future,builder:(c,s){if(!s.hasData)return s.hasError?ListView(children:[Padding(padding:const EdgeInsets.all(24),child:Text('${s.error}'))]):const Center(child:CircularProgressIndicator());final rows=s.data!;if(rows.isEmpty)return ListView(children:const [Padding(padding:EdgeInsets.all(40),child:Center(child:Text('De aankooplijst is leeg.')))]);return ListView.builder(padding:const EdgeInsets.only(bottom:90),itemCount:rows.length,itemBuilder:(c,i){final x=rows[i];return Dismissible(key:ValueKey(x.id),direction:DismissDirection.endToStart,background:Container(color:Colors.red,alignment:Alignment.centerRight,padding:const EdgeInsets.all(20),child:const Icon(Icons.delete,color:Colors.white)),onDismissed:(_)=>widget.api.deleteShoppingItem(x.id),child:CheckboxListTile(value:x.purchased,onChanged:(v)async{await widget.api.toggleShoppingItem(x.id,v??false);_reload();},title:Text('${x.description}${x.quantity.isEmpty?'':' · ${x.quantity}'}',style:TextStyle(decoration:x.purchased?TextDecoration.lineThrough:null)),subtitle:Text([if(x.note.isNotEmpty)x.note,if(x.createdByName.isNotEmpty)'Toegevoegd door ${x.createdByName}'].join('\n'))));});}))));}
