class ApiUser {
  final int id;
  final String username;
  final String displayName;
  final String role;

  const ApiUser({
    required this.id,
    required this.username,
    required this.displayName,
    required this.role,
  });

  factory ApiUser.fromJson(Map<String, dynamic> json) => ApiUser(
        id: (json['id'] as num?)?.toInt() ?? 0,
        username: json['username']?.toString() ?? '',
        displayName: json['display_name']?.toString() ?? '',
        role: json['role']?.toString() ?? '',
      );
}

class WorkTask {
  final int id;
  final int? workOrderId;
  final String title;
  final String description;
  final String priority;
  final String statusCode;
  final String statusName;
  final bool isClosed;
  final String? plannedDate;
  final String? planningNotes;
  final String? dueDate;
  final String? scheduledStart;
  final String? completedAt;
  final String? orderNumber;
  final String? deceasedName;
  final String? orderTitle;
  final String? orderMode;
  final String? companyName;
  final int? cemeteryId;
  final String? cemeteryName;
  final String? graveLocation;
  final String? cemeteryStreet;
  final String? cemeteryHouseNumber;
  final String? cemeteryPostalCode;
  final String? cemeteryCity;
  final String? adminCode;
  final String? workflowState;
  final String? workflowStepCode;
  final String? workflowStepName;
  final String? orderDescription;
  final String? engravingColor;
  final String? fontName;
  final String? inscriptionText;
  final int minPhotos;

  const WorkTask({
    required this.id,
    this.workOrderId,
    required this.title,
    required this.description,
    required this.priority,
    required this.statusCode,
    required this.statusName,
    required this.isClosed,
    this.plannedDate,
    this.planningNotes,
    this.dueDate,
    this.scheduledStart,
    this.completedAt,
    this.orderNumber,
    this.deceasedName,
    this.orderTitle,
    this.orderMode,
    this.companyName,
    this.cemeteryId,
    this.cemeteryName,
    this.graveLocation,
    this.cemeteryStreet,
    this.cemeteryHouseNumber,
    this.cemeteryPostalCode,
    this.cemeteryCity,
    this.adminCode,
    this.workflowState,
    this.workflowStepCode,
    this.workflowStepName,
    this.orderDescription,
    this.engravingColor,
    this.fontName,
    this.inscriptionText,
    this.minPhotos = 0,
  });

  String get subject =>
      orderMode == 'MANUAL'
          ? (orderTitle?.trim().isNotEmpty == true ? orderTitle! : 'Andere opdracht')
          : (deceasedName?.trim().isNotEmpty == true ? deceasedName! : 'Opdracht');

  String get address {
    final street = [cemeteryStreet, cemeteryHouseNumber]
        .where((e) => e != null && e!.trim().isNotEmpty)
        .join(' ');
    final city = [cemeteryPostalCode, cemeteryCity]
        .where((e) => e != null && e!.trim().isNotEmpty)
        .join(' ');
    return [street, city].where((e) => e.trim().isNotEmpty).join(', ');
  }

  factory WorkTask.fromJson(Map<String, dynamic> json) => WorkTask(
        id: (json['id'] as num?)?.toInt() ?? 0,
        workOrderId: (json['work_order_id'] as num?)?.toInt(),
        title: json['title']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        priority: json['priority']?.toString() ?? 'NORMAL',
        statusCode: json['status_code']?.toString() ?? '',
        statusName: json['status_name']?.toString() ?? '',
        isClosed: json['is_closed'] == true || json['is_closed'] == 1,
        plannedDate: json['planned_date']?.toString(),
        planningNotes: json['planning_notes']?.toString(),
        dueDate: json['due_date']?.toString(),
        scheduledStart: json['scheduled_start']?.toString(),
        completedAt: json['completed_at']?.toString(),
        orderNumber: json['order_number']?.toString(),
        deceasedName: json['deceased_name']?.toString(),
        orderTitle: json['order_title']?.toString(),
        orderMode: json['order_mode']?.toString(),
        companyName: json['company_name']?.toString(),
        cemeteryId: (json['cemetery_id'] as num?)?.toInt(),
        cemeteryName: json['cemetery_name']?.toString(),
        graveLocation: json['grave_location']?.toString(),
        cemeteryStreet: json['cemetery_street']?.toString(),
        cemeteryHouseNumber: json['cemetery_house_number']?.toString(),
        cemeteryPostalCode: json['cemetery_postal_code']?.toString(),
        cemeteryCity: json['cemetery_city']?.toString(),
        adminCode: json['admin_code']?.toString(),
        workflowState: json['workflow_state']?.toString(),
        workflowStepCode: json['workflow_step_code']?.toString(),
        workflowStepName: json['workflow_step_name']?.toString(),
        orderDescription: json['order_description']?.toString(),
        engravingColor: json['engraving_color']?.toString(),
        fontName: json['font_name']?.toString(),
        inscriptionText: json['inscription_text']?.toString(),
        minPhotos: (json['min_photos'] as num?)?.toInt() ?? 0,
      );
}

class Cemetery {
  final int id; final String name; final String street; final String houseNumber; final String postalCode; final String city;
  const Cemetery({required this.id,required this.name,required this.street,required this.houseNumber,required this.postalCode,required this.city});
  String get address => [[street,houseNumber].where((e)=>e.trim().isNotEmpty).join(' '),[postalCode,city].where((e)=>e.trim().isNotEmpty).join(' ')].where((e)=>e.isNotEmpty).join(', ');
  factory Cemetery.fromJson(Map<String,dynamic> j)=>Cemetery(id:(j['id'] as num?)?.toInt()??0,name:j['name']?.toString()??'',street:j['street']?.toString()??'',houseNumber:j['house_number']?.toString()??'',postalCode:j['postal_code_raw']?.toString()??'',city:j['city_raw']?.toString()??'');
}

class Customer {
  final int id; final String name; final String street; final String houseNumber; final String postalCode; final String city; final String phone; final String email; final String contactName; final String contactPhone; final String contactEmail;
  const Customer({required this.id,required this.name,required this.street,required this.houseNumber,required this.postalCode,required this.city,required this.phone,required this.email,required this.contactName,required this.contactPhone,required this.contactEmail});
  String get address => [[street,houseNumber].where((e)=>e.trim().isNotEmpty).join(' '),[postalCode,city].where((e)=>e.trim().isNotEmpty).join(' ')].where((e)=>e.isNotEmpty).join(', ');
  factory Customer.fromJson(Map<String,dynamic> j)=>Customer(id:(j['id'] as num?)?.toInt()??0,name:j['name']?.toString()??'',street:j['street']?.toString()??'',houseNumber:j['house_number']?.toString()??'',postalCode:j['postal_code_raw']?.toString()??'',city:j['city_raw']?.toString()??'',phone:j['phone']?.toString()??'',email:j['email']?.toString()??'',contactName:j['contact_name']?.toString()??'',contactPhone:j['contact_phone']?.toString()??'',contactEmail:j['contact_email']?.toString()??'');
}

class ShoppingItem {
  final int id; final String description; final String category; final String quantity; final String note; final bool purchased; final String createdByName;
  const ShoppingItem({required this.id,required this.description,required this.category,required this.quantity,required this.note,required this.purchased,required this.createdByName});
  factory ShoppingItem.fromJson(Map<String,dynamic> j)=>ShoppingItem(id:(j['id'] as num?)?.toInt()??0,description:j['description']?.toString()??'',category:j['category']?.toString()??'',quantity:j['quantity']?.toString()??'',note:j['note']?.toString()??'',purchased:j['purchased']==true||j['purchased']==1,createdByName:j['created_by_name']?.toString()??'');
}

class WorkOrderSummary {
  final int id;
  final String orderNumber;
  final String? entryDate;
  final String? deceasedName;
  final String? orderTitle;
  final String? orderMode;
  final String? lifecycleStatus;
  final String? graveLocation;
  final String? companyName;
  final String? cemeteryName;
  final String? mainStatus;
  final String? waitingReason;
  final String? currentStep;

  const WorkOrderSummary({
    required this.id,
    required this.orderNumber,
    this.entryDate,
    this.deceasedName,
    this.orderTitle,
    this.orderMode,
    this.lifecycleStatus,
    this.graveLocation,
    this.companyName,
    this.cemeteryName,
    this.mainStatus,
    this.waitingReason,
    this.currentStep,
  });

  String get subject =>
      orderMode == 'MANUAL'
          ? (orderTitle?.trim().isNotEmpty == true ? orderTitle! : 'Andere opdracht')
          : (deceasedName?.trim().isNotEmpty == true ? deceasedName! : 'Opdracht');

  factory WorkOrderSummary.fromJson(Map<String, dynamic> json) =>
      WorkOrderSummary(
        id: (json['id'] as num?)?.toInt() ?? 0,
        orderNumber: json['order_number']?.toString() ?? '',
        entryDate: json['entry_date']?.toString(),
        deceasedName: json['deceased_name']?.toString(),
        orderTitle: json['order_title']?.toString(),
        orderMode: json['order_mode']?.toString(),
        lifecycleStatus: json['lifecycle_status']?.toString(),
        graveLocation: json['grave_location']?.toString(),
        companyName: json['company_name']?.toString(),
        cemeteryName: json['cemetery_name']?.toString(),
        mainStatus: json['main_status']?.toString(),
        waitingReason: json['waiting_reason']?.toString(),
        currentStep: json['current_step']?.toString(),
      );
}

class OrderPhoto {
  final int id;
  final String? photoType;
  final String? originalFilename;
  final String? caption;
  final String? takenAt;
  final String url;

  const OrderPhoto({
    required this.id,
    this.photoType,
    this.originalFilename,
    this.caption,
    this.takenAt,
    required this.url,
  });

  factory OrderPhoto.fromJson(Map<String, dynamic> json) => OrderPhoto(
        id: (json['id'] as num?)?.toInt() ?? 0,
        photoType: json['photo_type']?.toString(),
        originalFilename: json['original_filename']?.toString(),
        caption: json['caption']?.toString(),
        takenAt: json['taken_at']?.toString(),
        url: json['url']?.toString() ?? '',
      );
}
