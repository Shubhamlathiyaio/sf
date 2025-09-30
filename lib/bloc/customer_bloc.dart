import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../models/customer.dart';
import '../services/hive_service.dart';
import 'base_bloc_state.dart';

// Events
abstract class CustomerEvent extends Equatable {
  const CustomerEvent();

  @override
  List<Object> get props => [];
}

class LoadCustomersEvent extends CustomerEvent {
  const LoadCustomersEvent();
}

class CreateCustomerEvent extends CustomerEvent {
  final Customer customer;

  const CreateCustomerEvent(this.customer);

  @override
  List<Object> get props => [customer];
}

class UpdateCustomerEvent extends CustomerEvent {
  final Customer customer;

  const UpdateCustomerEvent(this.customer);

  @override
  List<Object> get props => [customer];
}

class DeleteCustomerEvent extends CustomerEvent {
  final String customerId;

  const DeleteCustomerEvent(this.customerId);

  @override
  List<Object> get props => [customerId];
}

class SearchCustomersEvent extends CustomerEvent {
  final String query;

  const SearchCustomersEvent(this.query);

  @override
  List<Object> get props => [query];
}

// States
class CustomerLoadedState extends BaseBlocState {
  final List<Customer> customers;
  final List<Customer> filteredCustomers;
  final String searchQuery;

  const CustomerLoadedState({
    required this.customers,
    List<Customer>? filteredCustomers,
    this.searchQuery = '',
  }) : filteredCustomers = filteredCustomers ?? customers;

  @override
  List<Object> get props => [customers, filteredCustomers, searchQuery];

  CustomerLoadedState copyWith({
    List<Customer>? customers,
    List<Customer>? filteredCustomers,
    String? searchQuery,
  }) {
    return CustomerLoadedState(
      customers: customers ?? this.customers,
      filteredCustomers: filteredCustomers ?? this.filteredCustomers,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

// BLoC
class CustomerBloc extends Bloc<CustomerEvent, BaseBlocState> {
  CustomerBloc() : super(const LoadingState()) {
    on<LoadCustomersEvent>(_onLoadCustomers);
    on<CreateCustomerEvent>(_onCreateCustomer);
    on<UpdateCustomerEvent>(_onUpdateCustomer);
    on<DeleteCustomerEvent>(_onDeleteCustomer);
    on<SearchCustomersEvent>(_onSearchCustomers);
  }

  Future<void> _onLoadCustomers(
    LoadCustomersEvent event,
    Emitter<BaseBlocState> emit,
  ) async {
    try {
      emit(const LoadingState());
      final customers = await HiveService.getAllCustomers();
      emit(CustomerLoadedState(customers: customers));
    } catch (e) {
      // If we get an initialization error, try to reinitialize Hive
      if (e.toString().contains('not initialized') ||
          e.toString().contains('Failed to get customers')) {
        try {
          // Try to reinitialize Hive service
          await HiveService.init();
          // Try again to get customers
          final customers = await HiveService.getAllCustomers();
          emit(CustomerLoadedState(customers: customers));
        } catch (reinitError) {
          emit(ErrorState(message: 'Failed to load customers: $reinitError'));
        }
      } else {
        emit(ErrorState(message: 'Failed to load customers: $e'));
      }
    }
  }

  Future<void> _onCreateCustomer(
    CreateCustomerEvent event,
    Emitter<BaseBlocState> emit,
  ) async {
    try {
      if (state is CustomerLoadedState) {
        final currentState = state as CustomerLoadedState;

        // Check if customer with same mobile or GST already exists
        final existingCustomer = currentState.customers.any(
          (customer) =>
              customer.mobileNumber == event.customer.mobileNumber ||
              (customer.gstNumber.isNotEmpty &&
                  event.customer.gstNumber.isNotEmpty &&
                  customer.gstNumber == event.customer.gstNumber),
        );

        if (existingCustomer) {
          emit(
            const ErrorState(
              message: 'Customer with same mobile number or GST already exists',
            ),
          );
          return;
        }

        await HiveService.saveCustomer(event.customer);
        final updatedCustomers = [...currentState.customers, event.customer];

        emit(currentState.copyWith(customers: updatedCustomers));
      } else {
        // If not in loaded state, emit an error
        emit(
          const ErrorState(
            message: 'Customer list not loaded properly. Please try again.',
          ),
        );
      }
    } catch (e) {
      emit(ErrorState(message: 'Failed to create customer: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateCustomer(
    UpdateCustomerEvent event,
    Emitter<BaseBlocState> emit,
  ) async {
    try {
      if (state is CustomerLoadedState) {
        final currentState = state as CustomerLoadedState;

        await HiveService.saveCustomer(event.customer);

        final updatedCustomers = currentState.customers.map((customer) {
          return customer.id == event.customer.id ? event.customer : customer;
        }).toList();

        emit(currentState.copyWith(customers: updatedCustomers));
      }
    } catch (e) {
      emit(ErrorState(message: 'Failed to update customer: $e'));
    }
  }

  Future<void> _onDeleteCustomer(
    DeleteCustomerEvent event,
    Emitter<BaseBlocState> emit,
  ) async {
    try {
      if (state is CustomerLoadedState) {
        final currentState = state as CustomerLoadedState;

        await HiveService.deleteCustomer(event.customerId);

        final updatedCustomers = currentState.customers
            .where((customer) => customer.id != event.customerId)
            .toList();

        emit(currentState.copyWith(customers: updatedCustomers));
      }
    } catch (e) {
      emit(ErrorState(message: 'Failed to delete customer: $e'));
    }
  }

  Future<void> _onSearchCustomers(
    SearchCustomersEvent event,
    Emitter<BaseBlocState> emit,
  ) async {
    if (state is CustomerLoadedState) {
      final currentState = state as CustomerLoadedState;

      if (event.query.isEmpty) {
        emit(
          currentState.copyWith(
            filteredCustomers: currentState.customers,
            searchQuery: event.query,
          ),
        );
        return;
      }

      final filteredCustomers = currentState.customers.where((customer) {
        final query = event.query.toLowerCase();
        return customer.firmName.toLowerCase().contains(query) ||
            customer.contactPersonName.toLowerCase().contains(query) ||
            customer.mobileNumber.contains(query) ||
            customer.gstNumber.toLowerCase().contains(query) ||
            customer.firmAddress.toLowerCase().contains(query);
      }).toList();

      emit(
        currentState.copyWith(
          filteredCustomers: filteredCustomers,
          searchQuery: event.query,
        ),
      );
    }
  }
}
