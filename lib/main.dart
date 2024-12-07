import 'dart:io';

import 'package:sms_registration_with_websocket/Bloc/SmsSenderBloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:sms_registration_with_websocket/Bloc/AuthBloc.dart';
import 'package:sms_registration_with_websocket/Bloc/PhoneBalanceBloc.dart';
import 'package:sms_registration_with_websocket/Bloc/SocketBloc.dart';
import 'package:sms_registration_with_websocket/Pages/HomePage.dart';
import 'package:sms_registration_with_websocket/Pages/SplashScreen.dart';
import 'package:sms_registration_with_websocket/Services/Services.dart';
import 'Models/providerModel.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
  };
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  runApp(ChangeNotifierProvider<ProviderModel>(create: (context) => ProviderModel(), child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProviderModel>(
      create: (context) => ProviderModel(),
      child: MultiBlocProvider(
          providers: [
            BlocProvider<PhoneBalanceBloc>(
              create: (context) => PhoneBalanceBloc(),
            ),
            BlocProvider<AuthBloc>(
              create: (context) => AuthBloc(Services()),
            ),
            BlocProvider<SocketBloc>(
              create: (context) => SocketBloc(Services()),
            ),
            BlocProvider<SmsSenderBloc>(
              create: (context) => SmsSenderBloc(),
            )
          ],
          child: MaterialApp(
            title: 'SMSRegistrationApp',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            home: HomePage(),
          )),
    );
  }
}
