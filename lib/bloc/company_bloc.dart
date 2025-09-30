import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../models/company.dart';
import '../services/hive_service.dart';
import 'base_bloc_state.dart';

// Events
abstract class CompanyEvent extends Equatable {
  const CompanyEvent();

  @override
  List<Object> get props => [];
}

class LoadCompaniesEvent extends CompanyEvent {
  const LoadCompaniesEvent();
}

class LoadDefaultCompanyEvent extends CompanyEvent {
  const LoadDefaultCompanyEvent();
}

class CreateCompanyEvent extends CompanyEvent {
  final Company company;

  const CreateCompanyEvent(this.company);

  @override
  List<Object> get props => [company];
}

class UpdateCompanyEvent extends CompanyEvent {
  final Company company;

  const UpdateCompanyEvent(this.company);

  @override
  List<Object> get props => [company];
}

class DeleteCompanyEvent extends CompanyEvent {
  final String companyId;

  const DeleteCompanyEvent(this.companyId);

  @override
  List<Object> get props => [companyId];
}

// States
class CompanyLoadedState extends BaseBlocState {
  final List<Company> companies;
  final Company? defaultCompany;

  const CompanyLoadedState({required this.companies, this.defaultCompany});

  @override
  List<Object?> get props => [companies, defaultCompany];

  CompanyLoadedState copyWith({
    List<Company>? companies,
    Company? defaultCompany,
  }) {
    return CompanyLoadedState(
      companies: companies ?? this.companies,
      defaultCompany: defaultCompany ?? this.defaultCompany,
    );
  }
}

class DefaultCompanyLoadedState extends BaseBlocState {
  final Company? defaultCompany;

  const DefaultCompanyLoadedState({this.defaultCompany});

  @override
  List<Object?> get props => [defaultCompany];
}

// BLoC
class CompanyBloc extends Bloc<CompanyEvent, BaseBlocState> {
  CompanyBloc() : super(const LoadingState()) {
    on<LoadCompaniesEvent>(_onLoadCompanies);
    on<LoadDefaultCompanyEvent>(_onLoadDefaultCompany);
    on<CreateCompanyEvent>(_onCreateCompany);
    on<UpdateCompanyEvent>(_onUpdateCompany);
    on<DeleteCompanyEvent>(_onDeleteCompany);
  }

  Future<void> _onLoadCompanies(
    LoadCompaniesEvent event,
    Emitter<BaseBlocState> emit,
  ) async {
    try {
      emit(const LoadingState());
      final companies = await HiveService.getAllCompanies();
      final defaultCompany = companies.isNotEmpty ? companies.first : null;
      emit(
        CompanyLoadedState(
          companies: companies,
          defaultCompany: defaultCompany,
        ),
      );
    } catch (e) {
      emit(ErrorState(message: 'Failed to load companies: $e'));
    }
  }

  Future<void> _onLoadDefaultCompany(
    LoadDefaultCompanyEvent event,
    Emitter<BaseBlocState> emit,
  ) async {
    try {
      emit(const LoadingState());
      final defaultCompany = await HiveService.getDefaultCompany();
      emit(DefaultCompanyLoadedState(defaultCompany: defaultCompany));
    } catch (e) {
      emit(ErrorState(message: 'Failed to load default company: $e'));
    }
  }

  Future<void> _onCreateCompany(
    CreateCompanyEvent event,
    Emitter<BaseBlocState> emit,
  ) async {
    try {
      if (state is CompanyLoadedState) {
        final currentState = state as CompanyLoadedState;

        await HiveService.saveCompany(event.company);
        final updatedCompanies = [...currentState.companies, event.company];

        // If this is the first company, make it the default
        final defaultCompany = currentState.defaultCompany ?? event.company;

        emit(
          currentState.copyWith(
            companies: updatedCompanies,
            defaultCompany: defaultCompany,
          ),
        );
      }
    } catch (e) {
      emit(ErrorState(message: 'Failed to create company: $e'));
    }
  }

  Future<void> _onUpdateCompany(
    UpdateCompanyEvent event,
    Emitter<BaseBlocState> emit,
  ) async {
    try {
      if (state is CompanyLoadedState) {
        final currentState = state as CompanyLoadedState;

        await HiveService.updateCompany(event.company);

        final updatedCompanies = currentState.companies.map((company) {
          return company.id == event.company.id ? event.company : company;
        }).toList();

        // Update default company if it's the one being updated
        final defaultCompany =
            currentState.defaultCompany?.id == event.company.id
            ? event.company
            : currentState.defaultCompany;

        emit(
          currentState.copyWith(
            companies: updatedCompanies,
            defaultCompany: defaultCompany,
          ),
        );
      }
    } catch (e) {
      emit(ErrorState(message: 'Failed to update company: $e'));
    }
  }

  Future<void> _onDeleteCompany(
    DeleteCompanyEvent event,
    Emitter<BaseBlocState> emit,
  ) async {
    try {
      if (state is CompanyLoadedState) {
        final currentState = state as CompanyLoadedState;

        await HiveService.deleteCompany(event.companyId);

        final updatedCompanies = currentState.companies
            .where((company) => company.id != event.companyId)
            .toList();

        // Update default company if it was deleted
        final defaultCompany =
            currentState.defaultCompany?.id == event.companyId
            ? (updatedCompanies.isNotEmpty ? updatedCompanies.first : null)
            : currentState.defaultCompany;

        emit(
          currentState.copyWith(
            companies: updatedCompanies,
            defaultCompany: defaultCompany,
          ),
        );
      }
    } catch (e) {
      emit(ErrorState(message: 'Failed to delete company: $e'));
    }
  }
}
