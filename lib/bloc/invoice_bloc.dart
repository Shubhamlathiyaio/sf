import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/invoice.dart';
import '../models/customer.dart';
import '../models/company.dart';
import '../services/invoice_pdf_service.dart';
import 'base_bloc_event.dart';
import 'base_bloc_state.dart';

// Events
class LoadInvoicesEvent extends BaseBlocEvent {
  const LoadInvoicesEvent();
}

class CreateInvoiceEvent extends BaseBlocEvent {
  final Invoice invoice;

  const CreateInvoiceEvent(this.invoice);

  @override
  List<Object?> get props => [invoice];
}

class UpdateInvoiceEvent extends BaseBlocEvent {
  final Invoice invoice;

  const UpdateInvoiceEvent(this.invoice);

  @override
  List<Object?> get props => [invoice];
}

class DeleteInvoiceEvent extends BaseBlocEvent {
  final String invoiceId;

  const DeleteInvoiceEvent(this.invoiceId);

  @override
  List<Object?> get props => [invoiceId];
}

class GeneratePDFEvent extends BaseBlocEvent {
  final String invoiceId;
  final Customer customer;
  final Company company;

  const GeneratePDFEvent({
    required this.invoiceId,
    required this.customer,
    required this.company,
  });

  @override
  List<Object?> get props => [invoiceId, customer, company];
}

class ShareInvoiceEvent extends BaseBlocEvent {
  final String invoiceId;
  final Customer customer;
  final Company company;

  const ShareInvoiceEvent({
    required this.invoiceId,
    required this.customer,
    required this.company,
  });

  @override
  List<Object?> get props => [invoiceId, customer, company];
}

class PrintInvoiceEvent extends BaseBlocEvent {
  final String invoiceId;
  final Customer customer;
  final Company company;

  const PrintInvoiceEvent({
    required this.invoiceId,
    required this.customer,
    required this.company,
  });

  @override
  List<Object?> get props => [invoiceId, customer, company];
}

class SearchInvoicesEvent extends BaseBlocEvent {
  final String query;

  const SearchInvoicesEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class MarkInvoiceAsPaidEvent extends BaseBlocEvent {
  final String invoiceId;

  const MarkInvoiceAsPaidEvent(this.invoiceId);

  @override
  List<Object?> get props => [invoiceId];
}

class MarkInvoiceAsSentEvent extends BaseBlocEvent {
  final String invoiceId;

  const MarkInvoiceAsSentEvent(this.invoiceId);

  @override
  List<Object?> get props => [invoiceId];
}

// States
class InvoiceInitialState extends BaseBlocState {
  const InvoiceInitialState();
}

class InvoiceLoadedState extends BaseBlocState {
  final List<Invoice> invoices;
  final List<Invoice> filteredInvoices;
  final String searchQuery;

  const InvoiceLoadedState({
    required this.invoices,
    required this.filteredInvoices,
    this.searchQuery = '',
  });

  @override
  List<Object?> get props => [invoices, filteredInvoices, searchQuery];

  InvoiceLoadedState copyWith({
    List<Invoice>? invoices,
    List<Invoice>? filteredInvoices,
    String? searchQuery,
  }) {
    return InvoiceLoadedState(
      invoices: invoices ?? this.invoices,
      filteredInvoices: filteredInvoices ?? this.filteredInvoices,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class PDFGeneratedState extends BaseBlocState {
  final Uint8List pdfBytes;
  final String fileName;

  const PDFGeneratedState({required this.pdfBytes, required this.fileName});

  @override
  List<Object?> get props => [pdfBytes, fileName];
}

// BLoC
class InvoiceBloc extends Bloc<BaseBlocEvent, BaseBlocState> {
  InvoiceBloc() : super(const InvoiceInitialState()) {
    on<LoadInvoicesEvent>(_onLoadInvoices);
    on<CreateInvoiceEvent>(_onCreateInvoice);
    on<UpdateInvoiceEvent>(_onUpdateInvoice);
    on<DeleteInvoiceEvent>(_onDeleteInvoice);
    on<GeneratePDFEvent>(_onGeneratePDF);
    on<ShareInvoiceEvent>(_onShareInvoice);
    on<PrintInvoiceEvent>(_onPrintInvoice);
    on<SearchInvoicesEvent>(_onSearchInvoices);
    on<MarkInvoiceAsPaidEvent>(_onMarkInvoiceAsPaid);
    on<MarkInvoiceAsSentEvent>(_onMarkInvoiceAsSent);
  }

  void _onLoadInvoices(
    LoadInvoicesEvent event,
    Emitter<BaseBlocState> emit,
  ) async {
    emit(const LoadingState());

    try {
      // Create sample invoices for demonstration
      final invoices = _createSampleInvoices();
      emit(InvoiceLoadedState(invoices: invoices, filteredInvoices: invoices));
    } catch (e) {
      emit(ErrorState(message: 'Failed to load invoices: ${e.toString()}'));
    }
  }

  void _onCreateInvoice(
    CreateInvoiceEvent event,
    Emitter<BaseBlocState> emit,
  ) async {
    if (state is InvoiceLoadedState) {
      emit(const LoadingState());

      try {
        final currentState = state as InvoiceLoadedState;
        final updatedInvoices = [...currentState.invoices, event.invoice];

        emit(
          currentState.copyWith(
            invoices: updatedInvoices,
            filteredInvoices: updatedInvoices,
          ),
        );
        emit(const SuccessState(message: 'Invoice created successfully'));
      } catch (e) {
        emit(ErrorState(message: 'Failed to create invoice: ${e.toString()}'));
      }
    }
  }

  void _onUpdateInvoice(
    UpdateInvoiceEvent event,
    Emitter<BaseBlocState> emit,
  ) async {
    if (state is InvoiceLoadedState) {
      emit(const LoadingState());

      try {
        final currentState = state as InvoiceLoadedState;
        final updatedInvoices = currentState.invoices.map((invoice) {
          return invoice.id == event.invoice.id ? event.invoice : invoice;
        }).toList();

        emit(
          currentState.copyWith(
            invoices: updatedInvoices,
            filteredInvoices: updatedInvoices,
          ),
        );
        emit(const SuccessState(message: 'Invoice updated successfully'));
      } catch (e) {
        emit(ErrorState(message: 'Failed to update invoice: ${e.toString()}'));
      }
    }
  }

  void _onDeleteInvoice(
    DeleteInvoiceEvent event,
    Emitter<BaseBlocState> emit,
  ) async {
    if (state is InvoiceLoadedState) {
      emit(const LoadingState());

      try {
        final currentState = state as InvoiceLoadedState;
        final updatedInvoices = currentState.invoices
            .where((invoice) => invoice.id != event.invoiceId)
            .toList();

        emit(
          currentState.copyWith(
            invoices: updatedInvoices,
            filteredInvoices: updatedInvoices,
          ),
        );
        emit(const SuccessState(message: 'Invoice deleted successfully'));
      } catch (e) {
        emit(ErrorState(message: 'Failed to delete invoice: ${e.toString()}'));
      }
    }
  }

  void _onGeneratePDF(
    GeneratePDFEvent event,
    Emitter<BaseBlocState> emit,
  ) async {
    if (state is InvoiceLoadedState) {
      emit(const LoadingState());

      try {
        final currentState = state as InvoiceLoadedState;
        final invoice = currentState.invoices.firstWhere(
          (inv) => inv.id == event.invoiceId,
        );

        final pdfBytes = await InvoicePDFService.generateInvoicePDF(
          invoice: invoice,
          customer: event.customer,
          company: event.company,
        );

        emit(
          PDFGeneratedState(
            pdfBytes: pdfBytes,
            fileName: 'Invoice_${invoice.invoiceNumber}',
          ),
        );

        // Return to loaded state
        emit(currentState);
        emit(const SuccessState(message: 'PDF generated successfully'));
      } catch (e) {
        emit(ErrorState(message: 'Failed to generate PDF: ${e.toString()}'));
      }
    }
  }

  void _onShareInvoice(
    ShareInvoiceEvent event,
    Emitter<BaseBlocState> emit,
  ) async {
    if (state is InvoiceLoadedState) {
      emit(const LoadingState());

      try {
        final currentState = state as InvoiceLoadedState;
        final invoice = currentState.invoices.firstWhere(
          (inv) => inv.id == event.invoiceId,
        );

        final pdfBytes = await InvoicePDFService.generateInvoicePDF(
          invoice: invoice,
          customer: event.customer,
          company: event.company,
        );

        await InvoicePDFService.sharePDF(
          pdfBytes,
          'Invoice_${invoice.invoiceNumber}',
        );

        emit(currentState);
        emit(const SuccessState(message: 'Invoice shared successfully'));
      } catch (e) {
        emit(ErrorState(message: 'Failed to share invoice: ${e.toString()}'));
      }
    }
  }

  void _onPrintInvoice(
    PrintInvoiceEvent event,
    Emitter<BaseBlocState> emit,
  ) async {
    if (state is InvoiceLoadedState) {
      emit(const LoadingState());

      try {
        final currentState = state as InvoiceLoadedState;
        final invoice = currentState.invoices.firstWhere(
          (inv) => inv.id == event.invoiceId,
        );

        final pdfBytes = await InvoicePDFService.generateInvoicePDF(
          invoice: invoice,
          customer: event.customer,
          company: event.company,
        );

        await InvoicePDFService.printPDF(pdfBytes, invoice.invoiceNumber);

        emit(currentState);
        emit(const SuccessState(message: 'Invoice sent to printer'));
      } catch (e) {
        emit(ErrorState(message: 'Failed to print invoice: ${e.toString()}'));
      }
    }
  }

  void _onSearchInvoices(
    SearchInvoicesEvent event,
    Emitter<BaseBlocState> emit,
  ) {
    if (state is InvoiceLoadedState) {
      final currentState = state as InvoiceLoadedState;

      if (event.query.isEmpty) {
        emit(
          currentState.copyWith(
            filteredInvoices: currentState.invoices,
            searchQuery: event.query,
          ),
        );
      } else {
        final filteredInvoices = currentState.invoices.where((invoice) {
          return invoice.invoiceNumber.toLowerCase().contains(
                event.query.toLowerCase(),
              ) ||
              invoice.notes.toLowerCase().contains(event.query.toLowerCase());
        }).toList();

        emit(
          currentState.copyWith(
            filteredInvoices: filteredInvoices,
            searchQuery: event.query,
          ),
        );
      }
    }
  }

  void _onMarkInvoiceAsPaid(
    MarkInvoiceAsPaidEvent event,
    Emitter<BaseBlocState> emit,
  ) async {
    if (state is InvoiceLoadedState) {
      emit(const LoadingState());

      try {
        final currentState = state as InvoiceLoadedState;
        final updatedInvoices = currentState.invoices.map((invoice) {
          if (invoice.id == event.invoiceId) {
            return invoice.copyWith(status: InvoiceStatus.paid);
          }
          return invoice;
        }).toList();

        emit(
          currentState.copyWith(
            invoices: updatedInvoices,
            filteredInvoices: updatedInvoices,
          ),
        );
        emit(const SuccessState(message: 'Invoice marked as paid'));
      } catch (e) {
        emit(
          ErrorState(
            message: 'Failed to mark invoice as paid: ${e.toString()}',
          ),
        );
      }
    }
  }

  void _onMarkInvoiceAsSent(
    MarkInvoiceAsSentEvent event,
    Emitter<BaseBlocState> emit,
  ) async {
    if (state is InvoiceLoadedState) {
      emit(const LoadingState());

      try {
        final currentState = state as InvoiceLoadedState;
        final updatedInvoices = currentState.invoices.map((invoice) {
          if (invoice.id == event.invoiceId) {
            return invoice.copyWith(status: InvoiceStatus.sent);
          }
          return invoice;
        }).toList();

        emit(
          currentState.copyWith(
            invoices: updatedInvoices,
            filteredInvoices: updatedInvoices,
          ),
        );
        emit(const SuccessState(message: 'Invoice marked as sent'));
      } catch (e) {
        emit(
          ErrorState(
            message: 'Failed to mark invoice as sent: ${e.toString()}',
          ),
        );
      }
    }
  }

  List<Invoice> _createSampleInvoices() {
    return [
      Invoice.create(
        customerId: 'customer1',
        companyId: 'company1',
        items: [
          InvoiceItem.create(
            srNo: 1,
            description: 'Cotton Fabric',
            taka: 100,
            meter: 10,
            rate: 50,
            gstRate: 18,
            chalanNo: 'CH001',
            hsnCode: '5208',
          ),
          InvoiceItem.create(
            srNo: 2,
            description: 'Silk Fabric',
            taka: 50,
            meter: 5,
            rate: 100,
            gstRate: 18,
            chalanNo: 'CH002',
            hsnCode: '5007',
          ),
        ],
        discount: 500,
        freight: 200,
        dueDays: 30,
        broker: 'ABC Brokers',
      ).copyWith(status: InvoiceStatus.sent),

      Invoice.create(
        customerId: 'customer2',
        companyId: 'company1',
        items: [
          InvoiceItem.create(
            srNo: 1,
            description: 'Wool Fabric',
            taka: 80,
            meter: 8,
            rate: 75,
            gstRate: 18,
            chalanNo: 'CH003',
            hsnCode: '5111',
          ),
        ],
        discount: 200,
        dueDays: 15,
      ).copyWith(status: InvoiceStatus.paid),
    ];
  }
}
