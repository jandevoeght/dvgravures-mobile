import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'api_client.dart';

String _value(Map<String,dynamic> data,String key)=>data[key]?.toString().trim()??'';
String _address(Map<String,dynamic> data){
  final street=[_value(data,'street'),_value(data,'house_number')].where((x)=>x.isNotEmpty).join(' ');
  final city=[_value(data,'postal_code_raw'),_value(data,'city_raw')].where((x)=>x.isNotEmpty).join(' ');
  return [street,city].where((x)=>x.isNotEmpty).join(', ');
}
String _plain(String value)=>value.replaceAll(RegExp(r'<br\s*/?>',caseSensitive:false),'\n').replaceAll(RegExp(r'</p>',caseSensitive:false),'\n').replaceAll(RegExp(r'<[^>]+>'),'').replaceAll('&nbsp;',' ').replaceAll('&amp;','&').trim();
Future<void> _open(String prefix,String value)async{final raw=prefix.isEmpty?(value.startsWith('http')?value:'https://$value'):'$prefix${Uri.encodeComponent(value)}';await launchUrl(Uri.parse(raw),mode:LaunchMode.externalApplication);}
Future<void> _navigate(BuildContext context,String address)async{
 final choice=await showModalBottomSheet<String>(context:context,builder:(c)=>SafeArea(child:Wrap(children:[
  ListTile(leading:const Icon(Icons.map_outlined),title:const Text('Apple Kaarten'),onTap:()=>Navigator.pop(c,'apple')),
  ListTile(leading:const Icon(Icons.map),title:const Text('Google Maps'),onTap:()=>Navigator.pop(c,'google')),
 ])));
 if(choice=='apple')await _open('https://maps.apple.com/?q=',address);
 if(choice=='google')await _open('https://www.google.com/maps/search/?api=1&query=',address);
}
Widget _line(String label,String value,{VoidCallback? onTap}){
 if(value.isEmpty)return const SizedBox.shrink();
 return ListTile(contentPadding:EdgeInsets.zero,title:Text(label,style:const TextStyle(fontSize:12,fontWeight:FontWeight.w600)),subtitle:Text(value,style:const TextStyle(fontSize:16)),trailing:onTap==null?null:const Icon(Icons.chevron_right),onTap:onTap);
}

class CemeteryDetailScreen extends StatelessWidget{
 final ApiClient api;final int id;const CemeteryDetailScreen({super.key,required this.api,required this.id});
 @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Begraafplaats')),body:FutureBuilder<Map<String,dynamic>>(future:api.cemeteryDetails(id),builder:(context,s){
  if(!s.hasData)return s.hasError?Center(child:Text('${s.error}')):const Center(child:CircularProgressIndicator());
  final x=s.data!,address=_address(x),phone=_value(x,'phone'),email=_value(x,'email'),website=_value(x,'website');
  final notes=_plain(_value(x,'notes_html').isNotEmpty?_value(x,'notes_html'):_value(x,'notes'));
  return ListView(padding:const EdgeInsets.all(16),children:[
   Text(_value(x,'name'),style:Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight:FontWeight.w800)),const SizedBox(height:12),
   Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(children:[
    _line('Adres',address,onTap:address.isEmpty?null:()=>_navigate(context,address)),
    _line('Verantwoordelijke',_value(x,'responsible_name')),
    _line('Telefoon',phone,onTap:phone.isEmpty?null:()=>_open('tel:',phone)),
    _line('E-mail',email,onTap:email.isEmpty?null:()=>_open('mailto:',email)),
    _line('Website',website,onTap:website.isEmpty?null:()=>_open('',website)),
    _line('Extra informatie',notes),
   ]))),
   if(address.isNotEmpty)...[const SizedBox(height:12),FilledButton.icon(onPressed:()=>_navigate(context,address),icon:const Icon(Icons.navigation),label:const Text('Navigatie starten'))]
  ]);
 }));
}

class CustomerDetailScreen extends StatelessWidget{
 final ApiClient api;final int id;const CustomerDetailScreen({super.key,required this.api,required this.id});
 @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Klant')),body:FutureBuilder<Map<String,dynamic>>(future:api.customerDetails(id),builder:(context,s){
  if(!s.hasData)return s.hasError?Center(child:Text('${s.error}')):const Center(child:CircularProgressIndicator());
  final response=s.data!,x=Map<String,dynamic>.from(response['customer'] as Map? ?? const {}),contacts=(response['contacts'] as List? ?? const []).whereType<Map>().toList();
  final address=_address(x),phone=_value(x,'phone'),email=_value(x,'email'),website=_value(x,'website');
  final notes=_plain(_value(x,'notes'));
  return ListView(padding:const EdgeInsets.all(16),children:[
   Text(_value(x,'name'),style:Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight:FontWeight.w800)),const SizedBox(height:12),
   Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(children:[
    _line('Adres',address,onTap:address.isEmpty?null:()=>_navigate(context,address)),
    _line('Telefoon',phone,onTap:phone.isEmpty?null:()=>_open('tel:',phone)),_line('E-mail',email,onTap:email.isEmpty?null:()=>_open('mailto:',email)),
    _line('Website',website,onTap:website.isEmpty?null:()=>_open('',website)),_line('BTW-nummer',_value(x,'vat_number')),
    _line('Provincie',_value(x,'province_raw')),_line('Land',_value(x,'country_code')),_line('Opmerkingen',notes),
   ]))),
   if(contacts.isNotEmpty)...[const SizedBox(height:16),Text('Contactpersonen',style:Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight:FontWeight.w800)),const SizedBox(height:8),
    ...contacts.map((raw){final c=Map<String,dynamic>.from(raw),name=[_value(c,'first_name'),_value(c,'last_name')].where((x)=>x.isNotEmpty).join(' '),mobile=_value(c,'mobile'),contactPhone=mobile.isNotEmpty?mobile:_value(c,'phone'),contactEmail=_value(c,'email'),role=[_value(c,'department'),_value(c,'job_title')].where((x)=>x.isNotEmpty).join(' · ');return Card(child:Padding(padding:const EdgeInsets.all(14),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(name,style:const TextStyle(fontWeight:FontWeight.w800,fontSize:16)),if(role.isNotEmpty)Text(role),_line('Telefoon',contactPhone,onTap:contactPhone.isEmpty?null:()=>_open('tel:',contactPhone)),_line('E-mail',contactEmail,onTap:contactEmail.isEmpty?null:()=>_open('mailto:',contactEmail))])));})],
   if(address.isNotEmpty)...[const SizedBox(height:12),FilledButton.icon(onPressed:()=>_navigate(context,address),icon:const Icon(Icons.navigation),label:const Text('Navigatie starten'))]
  ]);
 }));
}
