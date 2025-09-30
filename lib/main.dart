import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sf/bloc/app_bloc.dart';
import 'package:sf/bloc/base_bloc_state.dart';
import 'package:sf/bloc/bill_bloc.dart';
import 'package:sf/bloc/company_bloc.dart';
import 'package:sf/bloc/create_invoice_bloc.dart';
import 'package:sf/bloc/customer_bloc.dart';
import 'package:sf/bloc/invoice_bloc.dart';
import 'package:sf/bloc/navigation_bloc.dart';
import 'package:sf/bloc/ui_bloc.dart';
import 'package:sf/services/hive_service.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/main_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Hive database
    await HiveService.init();
  } catch (e) {
    // Log the error but don't prevent app from starting
    debugPrint('Error initializing Hive: $e');
    // Try to initialize Hive again when needed
  }

  runApp(const BillingApp());
}

class BillingApp extends StatelessWidget {
  const BillingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AppBloc()..add(const InitializeAppEvent()),
        ),
        BlocProvider(create: (context) => NavigationBloc()),
        BlocProvider(
          create: (context) => BillBloc()..add(const LoadBillsEvent()),
        ),
        BlocProvider(
          create: (context) {
            final bloc = CustomerBloc()..add(const LoadCustomersEvent());
            // Add a listener to handle initialization errors
            bloc.stream.listen((state) {
              if (state is ErrorState && 
                  (state.message.contains('not initialized') || 
                   state.message.contains('Failed to get customers'))) {
                // Try to reinitialize Hive if there's an initialization error
                Future.microtask(() async {
                  try {
                    await HiveService.init();
                    bloc.add(const LoadCustomersEvent());
                  } catch (e) {
                    debugPrint('Failed to reinitialize Hive: $e');
                  }
                });
              }
            });
            return bloc;
          },
        ),
        BlocProvider(
          create: (context) => CompanyBloc()..add(const LoadCompaniesEvent()),
        ),
        BlocProvider(
          create: (context) => InvoiceBloc()..add(const LoadInvoicesEvent()),
        ),
        BlocProvider(create: (context) => UIBloc()),
        BlocProvider(
          create: (context) => CreateInvoiceBloc()..generateBillNumber(),
        ),
      ],
      child: BlocBuilder<AppBloc, BaseBlocState>(
        builder: (context, state) {
          final isDarkMode = state is AppLoadedState ? state.isDarkMode : false;

          return ScreenUtilInit(
            designSize: const Size(375, 812), // iPhone 12 Pro design size
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) {
              return MaterialApp(
                title: 'Billing App',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
                home: const MainWrapper(),
              );
            },
          );
        },
      ),
    );
  }
}