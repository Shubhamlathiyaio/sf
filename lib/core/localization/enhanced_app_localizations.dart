import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  // Common Terms
  String get appTitle =>
      _localizedValues[locale.languageCode]?['app_title'] ?? 'Billing App';
  String get dashboard =>
      _localizedValues[locale.languageCode]?['dashboard'] ?? 'Dashboard';
  String get invoices =>
      _localizedValues[locale.languageCode]?['invoices'] ?? 'Invoices';
  String get customers =>
      _localizedValues[locale.languageCode]?['customers'] ?? 'Customers';
  String get reports =>
      _localizedValues[locale.languageCode]?['reports'] ?? 'Reports';
  String get settings =>
      _localizedValues[locale.languageCode]?['settings'] ?? 'Settings';

  // Invoice Terms
  String get invoice =>
      _localizedValues[locale.languageCode]?['invoice'] ?? 'Invoice';
  String get invoiceNumber =>
      _localizedValues[locale.languageCode]?['invoice_number'] ??
      'Invoice Number';
  String get billTo =>
      _localizedValues[locale.languageCode]?['bill_to'] ?? 'Bill To';
  String get shipTo =>
      _localizedValues[locale.languageCode]?['ship_to'] ?? 'Ship To';
  String get date => _localizedValues[locale.languageCode]?['date'] ?? 'Date';
  String get dueDate =>
      _localizedValues[locale.languageCode]?['due_date'] ?? 'Due Date';
  String get dueDays =>
      _localizedValues[locale.languageCode]?['due_days'] ?? 'Due Days';

  // Table Headers
  String get srNo => _localizedValues[locale.languageCode]?['sr_no'] ?? 'Sr No';
  String get chalanNo =>
      _localizedValues[locale.languageCode]?['chalan_no'] ?? 'Chalan No';
  String get description =>
      _localizedValues[locale.languageCode]?['description'] ?? 'Description';
  String get taka => _localizedValues[locale.languageCode]?['taka'] ?? 'Taka';
  String get hsn => _localizedValues[locale.languageCode]?['hsn'] ?? 'HSN';
  String get meter =>
      _localizedValues[locale.languageCode]?['meter'] ?? 'Meter';
  String get rate => _localizedValues[locale.languageCode]?['rate'] ?? 'Rate';
  String get amount =>
      _localizedValues[locale.languageCode]?['amount'] ?? 'Amount';

  // Calculations
  String get subtotal =>
      _localizedValues[locale.languageCode]?['subtotal'] ?? 'Subtotal';
  String get discount =>
      _localizedValues[locale.languageCode]?['discount'] ?? 'Discount';
  String get otherDeductions =>
      _localizedValues[locale.languageCode]?['other_deductions'] ??
      'Other Deductions';
  String get freight =>
      _localizedValues[locale.languageCode]?['freight'] ?? 'Freight';
  String get taxableValue =>
      _localizedValues[locale.languageCode]?['taxable_value'] ??
      'Taxable Value';
  String get igst => _localizedValues[locale.languageCode]?['igst'] ?? 'IGST';
  String get sgst => _localizedValues[locale.languageCode]?['sgst'] ?? 'SGST';
  String get cgst => _localizedValues[locale.languageCode]?['cgst'] ?? 'CGST';
  String get netAmount =>
      _localizedValues[locale.languageCode]?['net_amount'] ?? 'Net Amount';
  String get broker =>
      _localizedValues[locale.languageCode]?['broker'] ?? 'Broker';

  // Customer Information
  String get firmName =>
      _localizedValues[locale.languageCode]?['firm_name'] ?? 'Firm Name';
  String get contactPerson =>
      _localizedValues[locale.languageCode]?['contact_person'] ??
      'Contact Person';
  String get mobileNumber =>
      _localizedValues[locale.languageCode]?['mobile_number'] ??
      'Mobile Number';
  String get email =>
      _localizedValues[locale.languageCode]?['email'] ?? 'Email';
  String get firmAddress =>
      _localizedValues[locale.languageCode]?['firm_address'] ?? 'Firm Address';
  String get deliveryAddress =>
      _localizedValues[locale.languageCode]?['delivery_address'] ??
      'Delivery Address';
  String get gstNumber =>
      _localizedValues[locale.languageCode]?['gst_number'] ?? 'GST Number';
  String get stateCode =>
      _localizedValues[locale.languageCode]?['state_code'] ?? 'State Code';

  // Actions
  String get create =>
      _localizedValues[locale.languageCode]?['create'] ?? 'Create';
  String get edit => _localizedValues[locale.languageCode]?['edit'] ?? 'Edit';
  String get delete =>
      _localizedValues[locale.languageCode]?['delete'] ?? 'Delete';
  String get save => _localizedValues[locale.languageCode]?['save'] ?? 'Save';
  String get cancel =>
      _localizedValues[locale.languageCode]?['cancel'] ?? 'Cancel';
  String get share =>
      _localizedValues[locale.languageCode]?['share'] ?? 'Share';
  String get print =>
      _localizedValues[locale.languageCode]?['print'] ?? 'Print';
  String get download =>
      _localizedValues[locale.languageCode]?['download'] ?? 'Download';
  String get generatePDF =>
      _localizedValues[locale.languageCode]?['generate_pdf'] ?? 'Generate PDF';

  // Status
  String get draft =>
      _localizedValues[locale.languageCode]?['draft'] ?? 'Draft';
  String get sent => _localizedValues[locale.languageCode]?['sent'] ?? 'Sent';
  String get paid => _localizedValues[locale.languageCode]?['paid'] ?? 'Paid';
  String get overdue =>
      _localizedValues[locale.languageCode]?['overdue'] ?? 'Overdue';
  String get cancelled =>
      _localizedValues[locale.languageCode]?['cancelled'] ?? 'Cancelled';
  String get partiallyPaid =>
      _localizedValues[locale.languageCode]?['partially_paid'] ??
      'Partially Paid';

  // Messages
  String get amountInWords =>
      _localizedValues[locale.languageCode]?['amount_in_words'] ??
      'Amount in Words';
  String get termsConditions =>
      _localizedValues[locale.languageCode]?['terms_conditions'] ??
      'Terms & Conditions';
  String get authorizedSignatory =>
      _localizedValues[locale.languageCode]?['authorized_signatory'] ??
      'Authorized Signatory';
  String get companyDetails =>
      _localizedValues[locale.languageCode]?['company_details'] ??
      'Company Details';

  // Currency
  String get rupees =>
      _localizedValues[locale.languageCode]?['rupees'] ?? 'Rupees';
  String get paise =>
      _localizedValues[locale.languageCode]?['paise'] ?? 'Paise';
  String get only => _localizedValues[locale.languageCode]?['only'] ?? 'Only';
  String get and => _localizedValues[locale.languageCode]?['and'] ?? 'and';

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_title': 'Billing App',
      'dashboard': 'Dashboard',
      'invoices': 'Invoices',
      'customers': 'Customers',
      'reports': 'Reports',
      'settings': 'Settings',
      'invoice': 'Invoice',
      'invoice_number': 'Invoice Number',
      'bill_to': 'Bill To',
      'ship_to': 'Ship To',
      'date': 'Date',
      'due_date': 'Due Date',
      'due_days': 'Due Days',
      'sr_no': 'Sr No',
      'chalan_no': 'Chalan No',
      'description': 'Description',
      'taka': 'Taka',
      'hsn': 'HSN',
      'meter': 'Meter',
      'rate': 'Rate',
      'amount': 'Amount',
      'subtotal': 'Subtotal',
      'discount': 'Discount',
      'other_deductions': 'Other Deductions',
      'freight': 'Freight',
      'taxable_value': 'Taxable Value',
      'igst': 'IGST',
      'sgst': 'SGST',
      'cgst': 'CGST',
      'net_amount': 'Net Amount',
      'broker': 'Broker',
      'firm_name': 'Firm Name',
      'contact_person': 'Contact Person',
      'mobile_number': 'Mobile Number',
      'email': 'Email',
      'firm_address': 'Firm Address',
      'delivery_address': 'Delivery Address',
      'gst_number': 'GST Number',
      'state_code': 'State Code',
      'create': 'Create',
      'edit': 'Edit',
      'delete': 'Delete',
      'save': 'Save',
      'cancel': 'Cancel',
      'share': 'Share',
      'print': 'Print',
      'download': 'Download',
      'generate_pdf': 'Generate PDF',
      'draft': 'Draft',
      'sent': 'Sent',
      'paid': 'Paid',
      'overdue': 'Overdue',
      'cancelled': 'Cancelled',
      'partially_paid': 'Partially Paid',
      'amount_in_words': 'Amount in Words',
      'terms_conditions': 'Terms & Conditions',
      'authorized_signatory': 'Authorized Signatory',
      'company_details': 'Company Details',
      'rupees': 'Rupees',
      'paise': 'Paise',
      'only': 'Only',
      'and': 'and',
    },
    'hi': {
      'app_title': 'बिलिंग एप्प',
      'dashboard': 'डैशबोर्ड',
      'invoices': 'इनवॉइस',
      'customers': 'ग्राहक',
      'reports': 'रिपोर्ट',
      'settings': 'सेटिंग्स',
      'invoice': 'इनवॉइस',
      'invoice_number': 'इनवॉइस नंबर',
      'bill_to': 'बिल भेजें',
      'ship_to': 'शिप करें',
      'date': 'दिनांक',
      'due_date': 'देय तिथि',
      'due_days': 'देय दिन',
      'sr_no': 'क्र.सं.',
      'chalan_no': 'चालान नं.',
      'description': 'विवरण',
      'taka': 'तका',
      'hsn': 'एचएसएन',
      'meter': 'मीटर',
      'rate': 'दर',
      'amount': 'राशि',
      'subtotal': 'उप-योग',
      'discount': 'छूट',
      'other_deductions': 'अन्य कटौती',
      'freight': 'भाड़ा',
      'taxable_value': 'कर योग्य मूल्य',
      'igst': 'आईजीएसटी',
      'sgst': 'एसजीएसटी',
      'cgst': 'सीजीएसटी',
      'net_amount': 'कुल राशि',
      'broker': 'दलाल',
      'firm_name': 'फर्म का नाम',
      'contact_person': 'संपर्क व्यक्ति',
      'mobile_number': 'मोबाइल नंबर',
      'email': 'ईमेल',
      'firm_address': 'फर्म का पता',
      'delivery_address': 'डिलीवरी पता',
      'gst_number': 'जीएसटी नंबर',
      'state_code': 'राज्य कोड',
      'create': 'बनाएं',
      'edit': 'संपादित करें',
      'delete': 'हटाएं',
      'save': 'सेव करें',
      'cancel': 'रद्द करें',
      'share': 'साझा करें',
      'print': 'प्रिंट करें',
      'download': 'डाउनलोड करें',
      'generate_pdf': 'पीडीएफ बनाएं',
      'draft': 'मसौदा',
      'sent': 'भेजा गया',
      'paid': 'भुगतान किया गया',
      'overdue': 'देय',
      'cancelled': 'रद्द',
      'partially_paid': 'आंशिक भुगतान',
      'amount_in_words': 'शब्दों में राशि',
      'terms_conditions': 'नियम और शर्तें',
      'authorized_signatory': 'अधिकृत हस्ताक्षरकर्ता',
      'company_details': 'कंपनी विवरण',
      'rupees': 'रुपये',
      'paise': 'पैसे',
      'only': 'केवल',
      'and': 'और',
    },
    'gu': {
      'app_title': 'બિલિંગ એપ્લિકેશન',
      'dashboard': 'ડેશબોર્ડ',
      'invoices': 'ઇન્વૉઇસ',
      'customers': 'ગ્રાહકો',
      'reports': 'રિપોર્ટ્સ',
      'settings': 'સેટિંગ્સ',
      'invoice': 'ઇન્વૉઇસ',
      'invoice_number': 'ઇન્વૉઇસ નંબર',
      'bill_to': 'બિલ મોકલવું',
      'ship_to': 'શિપ કરવું',
      'date': 'તારીખ',
      'due_date': 'બાકી તારીખ',
      'due_days': 'બાકી દિવસો',
      'sr_no': 'ક્રમ નં.',
      'chalan_no': 'ચલાન નં.',
      'description': 'વર્ણન',
      'taka': 'તાકા',
      'hsn': 'એચએસએન',
      'meter': 'મીટર',
      'rate': 'દર',
      'amount': 'રકમ',
      'subtotal': 'પેટા-કુલ',
      'discount': 'છૂટ',
      'other_deductions': 'અન્ય કાપ',
      'freight': 'ભાડું',
      'taxable_value': 'કરપાત્ર મૂલ્ય',
      'igst': 'આઇજીએસટી',
      'sgst': 'એસજીએસટી',
      'cgst': 'સીજીએસટી',
      'net_amount': 'કુલ રકમ',
      'broker': 'દલાલ',
      'firm_name': 'ફર્મનું નામ',
      'contact_person': 'સંપર્ક વ્યક્તિ',
      'mobile_number': 'મોબાઇલ નંબર',
      'email': 'ઇમેઇલ',
      'firm_address': 'ફર્મનું સરનામું',
      'delivery_address': 'ડિલિવરી સરનામું',
      'gst_number': 'જીએસટી નંબર',
      'state_code': 'રાજ્ય કોડ',
      'create': 'બનાવો',
      'edit': 'સંપાદન કરો',
      'delete': 'કાઢી નાખો',
      'save': 'સેવ કરો',
      'cancel': 'રદ કરો',
      'share': 'શેર કરો',
      'print': 'પ્રિન્ટ કરો',
      'download': 'ડાઉનલોડ કરો',
      'generate_pdf': 'પીડીએફ બનાવો',
      'draft': 'ડ્રાફ્ટ',
      'sent': 'મોકલાયેલ',
      'paid': 'ચૂકવાયેલ',
      'overdue': 'બાકી',
      'cancelled': 'રદ',
      'partially_paid': 'આંશિક ચૂકવણી',
      'amount_in_words': 'શબ્દોમાં રકમ',
      'terms_conditions': 'નિયમો અને શરતો',
      'authorized_signatory': 'અધિકૃત હસ્તાક્ષરકર્તા',
      'company_details': 'કંપની વિગતો',
      'rupees': 'રૂપિયા',
      'paise': 'પૈસા',
      'only': 'માત્ર',
      'and': 'અને',
    },
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'hi', 'gu'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
