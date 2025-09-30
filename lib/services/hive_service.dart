import 'dart:io';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/bill.dart';
import '../models/organization.dart';
import '../models/customer.dart';
import '../models/company.dart';

class HiveService {
  static const String billsBoxName = 'bills';
  static const String organizationsBoxName = 'organizations';
  static const String customersBoxName = 'customers';
  static const String companiesBoxName = 'companies';
  static const String settingsBoxName = 'settings';

  static Box<Bill>? _billsBox;
  static Box<Organization>? _organizationsBox;
  static Box<Customer>? _customersBox;
  static Box<Company>? _companiesBox;
  static Box<dynamic>? _settingsBox;

  /// Initialize Hive database
  static Future<void> init() async {
    try {
      // For web platform, we don't need to set a specific directory
      if (!kIsWeb) {
        // Get the application documents directory
        final appDocDir = await getApplicationDocumentsDirectory();
        final appDocPath = appDocDir.path;

        developer.log('Application documents directory: $appDocPath');

        // Ensure the directory exists
        final directory = Directory(appDocPath);
        if (!await directory.exists()) {
          developer.log('Creating directory: $appDocPath');
          await directory.create(recursive: true);
        } else {
          developer.log('Directory already exists: $appDocPath');
        }

        developer.log('Initializing Hive with path: $appDocPath');

        // Initialize Hive with the application documents directory
        Hive.init(appDocPath);
      } else {
        developer.log('Initializing Hive for web platform');
        // For web, Hive.init() is not needed as it uses IndexedDB
      }

      // Register all type adapters
      _registerAdapters();

      // Open boxes
      await _openBoxes();
    } catch (e, stackTrace) {
      developer.log('Error initializing Hive: $e');
      developer.log('Stack trace: $stackTrace');
      // Re-throw the exception so the caller knows initialization failed
      throw Exception('Failed to initialize Hive: $e');
    }
  }

  /// Register all Hive type adapters
  static void _registerAdapters() {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(BillAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(BillItemAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(BillStatusAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(OrganizationAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(CustomerAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(CompanyAdapter());
    }
  }

  /// Open all Hive boxes
  static Future<void> _openBoxes() async {
    try {
      print('Opening bills box');
      _billsBox = await Hive.openBox<Bill>(billsBoxName);
      print('Opening organizations box');
      _organizationsBox = await Hive.openBox<Organization>(
        organizationsBoxName,
      );
      print('Opening customers box');
      _customersBox = await Hive.openBox<Customer>(customersBoxName);
      print('Opening companies box');
      _companiesBox = await Hive.openBox<Company>(companiesBoxName);
      print('Opening settings box');
      _settingsBox = await Hive.openBox(settingsBoxName);
      print('All boxes opened successfully');
    } catch (e, stackTrace) {
      print('Error opening boxes: $e');
      print('Stack trace: $stackTrace');
      // Try to reopen individual boxes if some failed
      await _recoverBoxes();
      throw Exception('Failed to open Hive boxes: $e');
    }
  }

  /// Attempt to recover individual boxes if opening all at once fails
  static Future<void> _recoverBoxes() async {
    try {
      print('Attempting to recover boxes individually');

      if (_billsBox == null || !_billsBox!.isOpen) {
        print('Recovering bills box');
        _billsBox = await Hive.openBox<Bill>(billsBoxName);
      }

      if (_organizationsBox == null || !_organizationsBox!.isOpen) {
        print('Recovering organizations box');
        _organizationsBox = await Hive.openBox<Organization>(
          organizationsBoxName,
        );
      }

      if (_customersBox == null || !_customersBox!.isOpen) {
        print('Recovering customers box');
        _customersBox = await Hive.openBox<Customer>(customersBoxName);
      }

      if (_companiesBox == null || !_companiesBox!.isOpen) {
        print('Recovering companies box');
        _companiesBox = await Hive.openBox<Company>(companiesBoxName);
      }

      if (_settingsBox == null || !_settingsBox!.isOpen) {
        print('Recovering settings box');
        _settingsBox = await Hive.openBox(settingsBoxName);
      }

      print('Box recovery completed');
    } catch (recoveryError) {
      print('Error during box recovery: $recoveryError');
      // If recovery fails, we'll let the original error propagate
    }
  }

  /// Get bills box
  static Box<Bill> get billsBox {
    if (_billsBox == null) {
      throw Exception(
        'Bills box is not initialized. Call HiveService.init() first.',
      );
    }
    // Additional check to ensure box is still open
    if (!_billsBox!.isOpen) {
      throw Exception(
        'Bills box is closed. Please re-initialize Hive service.',
      );
    }
    return _billsBox!;
  }

  /// Get organizations box
  static Box<Organization> get organizationsBox {
    if (_organizationsBox == null) {
      throw Exception(
        'Organizations box is not initialized. Call HiveService.init() first.',
      );
    }
    // Additional check to ensure box is still open
    if (!_organizationsBox!.isOpen) {
      throw Exception(
        'Organizations box is closed. Please re-initialize Hive service.',
      );
    }
    return _organizationsBox!;
  }

  /// Get customers box
  static Box<Customer> get customersBox {
    if (_customersBox == null) {
      throw Exception(
        'Customers box is not initialized. Call HiveService.init() first.',
      );
    }
    // Additional check to ensure box is still open
    if (!_customersBox!.isOpen) {
      throw Exception(
        'Customers box is closed. Please re-initialize Hive service.',
      );
    }
    return _customersBox!;
  }

  /// Get companies box
  static Box<Company> get companiesBox {
    if (_companiesBox == null) {
      throw Exception(
        'Companies box is not initialized. Call HiveService.init() first.',
      );
    }
    // Additional check to ensure box is still open
    if (!_companiesBox!.isOpen) {
      throw Exception(
        'Companies box is closed. Please re-initialize Hive service.',
      );
    }
    return _companiesBox!;
  }

  /// Get settings box
  static Box<dynamic> get settingsBox {
    if (_settingsBox == null) {
      throw Exception(
        'Settings box is not initialized. Call HiveService.init() first.',
      );
    }
    // Additional check to ensure box is still open
    if (!_settingsBox!.isOpen) {
      throw Exception(
        'Settings box is closed. Please re-initialize Hive service.',
      );
    }
    return _settingsBox!;
  }

  /// Bills CRUD operations
  static Future<List<Bill>> getAllBills() async {
    try {
      if (_billsBox == null || !_billsBox!.isOpen) {
        if (_billsBox == null) {
          // Try to initialize the box if it's null
          print('Bills box is null, attempting to initialize');
          try {
            _billsBox = await Hive.openBox<Bill>(billsBoxName);
          } catch (initError) {
            print('Failed to initialize bills box: $initError');
            throw Exception('Bills box is not initialized: $initError');
          }
        }

        // Additional check to ensure box is still open
        if (!_billsBox!.isOpen) {
          print('Bills box is closed, attempting to reopen');
          try {
            await _billsBox!.close(); // Close if it was improperly closed
          } catch (e) {
            print('Error closing bills box: $e');
          }
          _billsBox = await Hive.openBox<Bill>(billsBoxName);
        }
      }
      return _billsBox!.values.toList();
    } catch (e) {
      throw Exception('Failed to get bills: $e');
    }
  }

  static Future<Bill?> getBill(String id) async {
    try {
      if (_billsBox == null) {
        throw Exception('Bills box is not initialized');
      }
      return _billsBox!.values.firstWhere(
        (bill) => bill.id == id,
        orElse: () => throw StateError('Bill not found'),
      );
    } catch (e) {
      return null;
    }
  }

  static Future<void> saveBill(Bill bill) async {
    try {
      if (_billsBox == null) {
        throw Exception('Bills box is not initialized');
      }
      await _billsBox!.put(bill.id, bill);
    } catch (e) {
      throw Exception('Failed to save bill: $e');
    }
  }

  static Future<void> deleteBill(String id) async {
    try {
      if (_billsBox == null) {
        throw Exception('Bills box is not initialized');
      }
      await _billsBox!.delete(id);
    } catch (e) {
      throw Exception('Failed to delete bill: $e');
    }
  }

  static Future<void> updateBill(Bill bill) async {
    try {
      if (_billsBox == null) {
        throw Exception('Bills box is not initialized');
      }
      await _billsBox!.put(bill.id, bill);
    } catch (e) {
      throw Exception('Failed to update bill: $e');
    }
  }

  /// Organizations CRUD operations
  static Future<List<Organization>> getAllOrganizations() async {
    try {
      if (_organizationsBox == null || !_organizationsBox!.isOpen) {
        if (_organizationsBox == null) {
          // Try to initialize the box if it's null
          print('Organizations box is null, attempting to initialize');
          try {
            _organizationsBox = await Hive.openBox<Organization>(
              organizationsBoxName,
            );
          } catch (initError) {
            print('Failed to initialize organizations box: $initError');
            throw Exception('Organizations box is not initialized: $initError');
          }
        }

        // Additional check to ensure box is still open
        if (!_organizationsBox!.isOpen) {
          print('Organizations box is closed, attempting to reopen');
          try {
            await _organizationsBox!
                .close(); // Close if it was improperly closed
          } catch (e) {
            print('Error closing organizations box: $e');
          }
          _organizationsBox = await Hive.openBox<Organization>(
            organizationsBoxName,
          );
        }
      }
      return _organizationsBox!.values.toList();
    } catch (e) {
      throw Exception('Failed to get organizations: $e');
    }
  }

  static Future<Organization?> getOrganization(String id) async {
    try {
      if (_organizationsBox == null) {
        throw Exception('Organizations box is not initialized');
      }
      return _organizationsBox!.values.firstWhere(
        (org) => org.id == id,
        orElse: () => throw StateError('Organization not found'),
      );
    } catch (e) {
      return null;
    }
  }

  static Future<void> saveOrganization(Organization organization) async {
    try {
      if (_organizationsBox == null) {
        throw Exception('Organizations box is not initialized');
      }
      await _organizationsBox!.put(organization.id, organization);
    } catch (e) {
      throw Exception('Failed to save organization: $e');
    }
  }

  static Future<void> deleteOrganization(String id) async {
    try {
      if (_organizationsBox == null) {
        throw Exception('Organizations box is not initialized');
      }
      await _organizationsBox!.delete(id);
    } catch (e) {
      throw Exception('Failed to delete organization: $e');
    }
  }

  /// Customers CRUD operations
  static Future<List<Customer>> getAllCustomers() async {
    try {
      if (_customersBox == null) {
        // Try to initialize the box if it's null
        print('Customers box is null, attempting to initialize');
        try {
          _customersBox = await Hive.openBox<Customer>(customersBoxName);
        } catch (initError) {
          print('Failed to initialize customers box: $initError');
          throw Exception('Customers box is not initialized: $initError');
        }
      }

      // Additional check to ensure box is still open
      if (!_customersBox!.isOpen) {
        print('Customers box is closed, attempting to reopen');
        try {
          await _customersBox!.close(); // Close if it was improperly closed
        } catch (e) {
          print('Error closing customers box: $e');
        }
        _customersBox = await Hive.openBox<Customer>(customersBoxName);
      }

      return _customersBox!.values.toList();
    } catch (e) {
      print('Error getting all customers: $e');
      throw Exception('Failed to get customers: $e');
    }
  }

  static Future<Customer?> getCustomer(String id) async {
    try {
      if (_customersBox == null) {
        throw Exception('Customers box is not initialized');
      }
      return _customersBox!.values.firstWhere(
        (customer) => customer.id == id,
        orElse: () => throw StateError('Customer not found'),
      );
    } catch (e) {
      return null;
    }
  }

  static Future<void> saveCustomer(Customer customer) async {
    try {
      if (_customersBox == null) {
        // Try to initialize the box if it's null
        print('Customers box is null, attempting to initialize');
        try {
          _customersBox = await Hive.openBox<Customer>(customersBoxName);
        } catch (initError) {
          print('Failed to initialize customers box: $initError');
          throw Exception('Customers box is not initialized: $initError');
        }
      }

      // Additional check to ensure box is still open
      if (!_customersBox!.isOpen) {
        print('Customers box is closed, attempting to reopen');
        try {
          await _customersBox!.close(); // Close if it was improperly closed
        } catch (e) {
          print('Error closing customers box: $e');
        }
        _customersBox = await Hive.openBox<Customer>(customersBoxName);
      }

      await _customersBox!.put(customer.id, customer);
      print('Customer saved successfully: ${customer.id}');
    } catch (e) {
      print('Error saving customer: $e');
      throw Exception('Failed to save customer: ${e.toString()}');
    }
  }

  static Future<void> deleteCustomer(String id) async {
    try {
      if (_customersBox == null) {
        throw Exception('Customers box is not initialized');
      }
      await _customersBox!.delete(id);
    } catch (e) {
      throw Exception('Failed to delete customer: $e');
    }
  }

  static Future<void> updateCustomer(Customer customer) async {
    try {
      if (_customersBox == null) {
        throw Exception('Customers box is not initialized');
      }
      await _customersBox!.put(customer.id, customer);
    } catch (e) {
      throw Exception('Failed to update customer: $e');
    }
  }

  /// Companies CRUD operations
  static Future<List<Company>> getAllCompanies() async {
    try {
      if (_companiesBox == null || !_companiesBox!.isOpen) {
        if (_companiesBox == null) {
          // Try to initialize the box if it's null
          print('Companies box is null, attempting to initialize');
          try {
            _companiesBox = await Hive.openBox<Company>(companiesBoxName);
          } catch (initError) {
            print('Failed to initialize companies box: $initError');
            throw Exception('Companies box is not initialized: $initError');
          }
        }

        // Additional check to ensure box is still open
        if (!_companiesBox!.isOpen) {
          print('Companies box is closed, attempting to reopen');
          try {
            await _companiesBox!.close(); // Close if it was improperly closed
          } catch (e) {
            print('Error closing companies box: $e');
          }
          _companiesBox = await Hive.openBox<Company>(companiesBoxName);
        }
      }
      return _companiesBox!.values.toList();
    } catch (e) {
      throw Exception('Failed to get companies: $e');
    }
  }

  static Future<Company?> getCompany(String id) async {
    try {
      if (_companiesBox == null) {
        throw Exception('Companies box is not initialized');
      }
      return _companiesBox!.values.firstWhere(
        (company) => company.id == id,
        orElse: () => throw StateError('Company not found'),
      );
    } catch (e) {
      return null;
    }
  }

  static Future<Company?> getDefaultCompany() async {
    try {
      if (_companiesBox == null) {
        throw Exception('Companies box is not initialized');
      }
      final companies = await getAllCompanies();
      return companies.isNotEmpty ? companies.first : null;
    } catch (e) {
      return null;
    }
  }

  static Future<void> saveCompany(Company company) async {
    try {
      if (_companiesBox == null) {
        throw Exception('Companies box is not initialized');
      }
      await _companiesBox!.put(company.id, company);
    } catch (e) {
      throw Exception('Failed to save company: $e');
    }
  }

  static Future<void> deleteCompany(String id) async {
    try {
      if (_companiesBox == null) {
        throw Exception('Companies box is not initialized');
      }
      await _companiesBox!.delete(id);
    } catch (e) {
      throw Exception('Failed to delete company: $e');
    }
  }

  static Future<void> updateCompany(Company company) async {
    try {
      if (_companiesBox == null) {
        throw Exception('Companies box is not initialized');
      }
      await _companiesBox!.put(company.id, company);
    } catch (e) {
      throw Exception('Failed to update company: $e');
    }
  }

  /// Settings operations
  static Future<T?> getSetting<T>(String key) async {
    try {
      if (_settingsBox == null || !_settingsBox!.isOpen) {
        if (_settingsBox == null) {
          // Try to initialize the box if it's null
          print('Settings box is null, attempting to initialize');
          try {
            _settingsBox = await Hive.openBox(settingsBoxName);
          } catch (initError) {
            print('Failed to initialize settings box: $initError');
            throw Exception('Settings box is not initialized: $initError');
          }
        }

        // Additional check to ensure box is still open
        if (!_settingsBox!.isOpen) {
          print('Settings box is closed, attempting to reopen');
          try {
            await _settingsBox!.close(); // Close if it was improperly closed
          } catch (e) {
            print('Error closing settings box: $e');
          }
          _settingsBox = await Hive.openBox(settingsBoxName);
        }
      }
      return _settingsBox!.get(key) as T?;
    } catch (e) {
      return null;
    }
  }

  static Future<void> setSetting<T>(String key, T value) async {
    try {
      if (_settingsBox == null || !_settingsBox!.isOpen) {
        if (_settingsBox == null) {
          // Try to initialize the box if it's null
          print('Settings box is null, attempting to initialize');
          try {
            _settingsBox = await Hive.openBox(settingsBoxName);
          } catch (initError) {
            print('Failed to initialize settings box: $initError');
            throw Exception('Settings box is not initialized: $initError');
          }
        }

        // Additional check to ensure box is still open
        if (!_settingsBox!.isOpen) {
          print('Settings box is closed, attempting to reopen');
          try {
            await _settingsBox!.close(); // Close if it was improperly closed
          } catch (e) {
            print('Error closing settings box: $e');
          }
          _settingsBox = await Hive.openBox(settingsBoxName);
        }
      }
      await _settingsBox!.put(key, value);
    } catch (e) {
      throw Exception('Failed to save setting: $e');
    }
  }

  static Future<void> deleteSetting(String key) async {
    try {
      if (_settingsBox == null || !_settingsBox!.isOpen) {
        if (_settingsBox == null) {
          // Try to initialize the box if it's null
          print('Settings box is null, attempting to initialize');
          try {
            _settingsBox = await Hive.openBox(settingsBoxName);
          } catch (initError) {
            print('Failed to initialize settings box: $initError');
            throw Exception('Settings box is not initialized: $initError');
          }
        }

        // Additional check to ensure box is still open
        if (!_settingsBox!.isOpen) {
          print('Settings box is closed, attempting to reopen');
          try {
            await _settingsBox!.close(); // Close if it was improperly closed
          } catch (e) {
            print('Error closing settings box: $e');
          }
          _settingsBox = await Hive.openBox(settingsBoxName);
        }
      }
      await _settingsBox!.delete(key);
    } catch (e) {
      throw Exception('Failed to delete setting: $e');
    }
  }

  /// Search operations
  static Future<List<Customer>> searchCustomers(String query) async {
    try {
      if (_customersBox == null) {
        throw Exception('Customers box is not initialized');
      }
      final allCustomers = await getAllCustomers();
      if (query.isEmpty) return allCustomers;

      return allCustomers.where((customer) {
        return customer.firmName.toLowerCase().contains(query.toLowerCase()) ||
            customer.contactPersonName.toLowerCase().contains(
              query.toLowerCase(),
            ) ||
            customer.mobileNumber.contains(query) ||
            customer.gstNumber.toLowerCase().contains(query.toLowerCase()) ||
            customer.firmAddress.toLowerCase().contains(query.toLowerCase());
      }).toList();
    } catch (e) {
      throw Exception('Failed to search customers: $e');
    }
  }

  static Future<List<Bill>> searchBills(String query) async {
    try {
      if (_billsBox == null) {
        throw Exception('Bills box is not initialized');
      }
      final allBills = await getAllBills();
      if (query.isEmpty) return allBills;

      return allBills.where((bill) {
        return bill.customerName.toLowerCase().contains(query.toLowerCase()) ||
            bill.billNumber.toLowerCase().contains(query.toLowerCase()) ||
            bill.notes.toLowerCase().contains(query.toLowerCase());
      }).toList();
    } catch (e) {
      throw Exception('Failed to search bills: $e');
    }
  }

  /// Get bills by status
  static Future<List<Bill>> getBillsByStatus(BillStatus status) async {
    try {
      if (_billsBox == null) {
        throw Exception('Bills box is not initialized');
      }
      final allBills = await getAllBills();
      return allBills.where((bill) => bill.status == status).toList();
    } catch (e) {
      throw Exception('Failed to get bills by status: $e');
    }
  }

  /// Get bills by date range
  static Future<List<Bill>> getBillsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      if (_billsBox == null) {
        throw Exception('Bills box is not initialized');
      }
      final allBills = await getAllBills();
      return allBills.where((bill) {
        return bill.billDate.isAfter(
              startDate.subtract(const Duration(days: 1)),
            ) &&
            bill.billDate.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();
    } catch (e) {
      throw Exception('Failed to get bills by date range: $e');
    }
  }

  /// Clear all data (for testing or reset)
  static Future<void> clearAllData() async {
    try {
      if (_billsBox == null ||
          _organizationsBox == null ||
          _customersBox == null ||
          _companiesBox == null ||
          _settingsBox == null) {
        throw Exception('One or more boxes are not initialized');
      }
      await _billsBox!.clear();
      await _organizationsBox!.clear();
      await _customersBox!.clear();
      await _companiesBox!.clear();
      await _settingsBox!.clear();
    } catch (e) {
      throw Exception('Failed to clear all data: $e');
    }
  }

  /// Close all boxes
  static Future<void> closeBoxes() async {
    try {
      if (_billsBox == null ||
          _organizationsBox == null ||
          _customersBox == null ||
          _companiesBox == null ||
          _settingsBox == null) {
        throw Exception('One or more boxes are not initialized');
      }
      await _billsBox!.close();
      await _organizationsBox!.close();
      await _customersBox!.close();
      await _companiesBox!.close();
      await _settingsBox!.close();
    } catch (e) {
      throw Exception('Failed to close boxes: $e');
    }
  }

  /// Get database size info
  static Future<Map<String, dynamic>> getDatabaseInfo() async {
    try {
      if (_billsBox == null ||
          _organizationsBox == null ||
          _customersBox == null ||
          _companiesBox == null ||
          _settingsBox == null) {
        throw Exception('One or more boxes are not initialized');
      }
      return {
        'billsCount': _billsBox!.length,
        'organizationsCount': _organizationsBox!.length,
        'customersCount': _customersBox!.length,
        'companiesCount': _companiesBox!.length,
        'settingsCount': _settingsBox!.length,
        'totalEntries':
            _billsBox!.length +
            _organizationsBox!.length +
            _customersBox!.length +
            _companiesBox!.length +
            _settingsBox!.length,
      };
    } catch (e) {
      throw Exception('Failed to get database info: $e');
    }
  }
}
