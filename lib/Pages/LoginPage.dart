// ignore_for_file: file_names, use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sms_registration_with_websocket/Bloc/AuthBloc.dart';
import 'package:sms_registration_with_websocket/modules/qrScanModule.dart';

import 'HomePage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool connected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.1,
        backgroundColor: const Color(0xFF4F51C0),
        title: const Text("Içeri gir", style: TextStyle(color: Colors.white)),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            // BlocProvider.of<SocketBloc>(context).add(ConnectToSocketEvent((BlocProvider.of<AuthBloc>(context).state as AuthSuccess).getToken));
            debugPrint('authsucceess on login');
          }
        },
        child: Stack(
          children: <Widget>[
            //////////////////////// Background ////////////////////////
            Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Flexible(
                  flex: 1,
                  child: Container(
                    color: const Color(0xFF4F51C0),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Container(
                    color: Colors.white,
                  ),
                )
              ],
            ),
            BlocListener<AuthBloc, AuthState>(listener: (context, state) {
              if (state is AuthFailure) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(state.errorStatus),
                  backgroundColor: Colors.red,
                ));
              }
              if (state is AuthSuccess) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(),
                    ));
              }
            }, child: BlocBuilder<AuthBloc, AuthState>(
              builder: (contex, state) {
                if (state is AuthInProgress) {
                  return Center(
                    child: Stack(
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(25)),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey,
                                    offset: Offset(0, 0),
                                    blurRadius: 2,
                                    spreadRadius: 1),
                              ]),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 100, 20, 50),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                TextField(
                                  decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Ulanyjy ady'),
                                  controller: _usernameController,
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                TextField(
                                  decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Açar söz'),
                                  controller: _passwordController,
                                  obscureText: true,
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    //////////////////////// QRCode Login button //////////////
                                    Stack(
                                      children: <Widget>[
                                        Container(
                                          height: 55,
                                          width: 55,
                                          decoration: BoxDecoration(
                                              color: Colors.green[300],
                                              borderRadius:
                                                  const BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(15),
                                                      bottomLeft:
                                                          Radius.circular(15)),
                                              boxShadow: const [
                                                BoxShadow(
                                                    color: Colors.grey,
                                                    spreadRadius: 0,
                                                    blurRadius: 2,
                                                    offset: Offset(0, 0))
                                              ]),
                                          child: const Icon(Icons.qr_code),
                                        ),
                                        ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(15),
                                              bottomLeft: Radius.circular(15)),
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              onTap: () async {
                                                String cameraScanResult = '';
                                                try {
                                                  if (await Permission.camera
                                                      .request()
                                                      .isGranted) {
                                                    debugPrint(
                                                        'DkPrint Before scan');
                                                    cameraScanResult =
                                                        await Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              const QrViewWidget()),
                                                    );

                                                    debugPrint(
                                                        "DkPrint Qr: $cameraScanResult");
                                                    if (cameraScanResult
                                                        .isNotEmpty) {
                                                      dynamic decoded =
                                                          jsonDecode(
                                                              cameraScanResult);
                                                      _usernameController.text =
                                                          decoded["uName"];
                                                      _passwordController.text =
                                                          decoded["password"];
                                                      BlocProvider.of<AuthBloc>(
                                                              context)
                                                          .add(AuthLogInEvent(
                                                              _usernameController
                                                                  .text,
                                                              _passwordController
                                                                  .text));
                                                    }
                                                  }
                                                } catch (e) {
                                                  cameraScanResult =
                                                      'DkPrintError: $e';
                                                }
                                              },
                                              child: const SizedBox(
                                                width: 55,
                                                height: 55,
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),

                                    //////////////////////// button Ulgama gir ///////////////
                                    Stack(
                                      children: <Widget>[
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.4,
                                          height: 55,
                                          decoration: const BoxDecoration(
                                              color: Colors.blue,
                                              borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(15),
                                                  bottomRight:
                                                      Radius.circular(15)),
                                              boxShadow: [
                                                BoxShadow(
                                                    color: Colors.grey,
                                                    spreadRadius: 0,
                                                    blurRadius: 2,
                                                    offset: Offset(0, 0))
                                              ]),
                                          child: const Center(
                                              child: Text(
                                            'Ulgama gir',
                                            style: TextStyle(fontSize: 16),
                                          )),
                                        ),
                                        ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                              topRight: Radius.circular(15),
                                              bottomRight: Radius.circular(15)),
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              onTap: () {
                                                BlocProvider.of<AuthBloc>(
                                                        context)
                                                    .add(AuthLogInEvent(
                                                        _usernameController
                                                            .text,
                                                        _passwordController
                                                            .text));
                                              },
                                              child: SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.4,
                                                height: 55,
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                        const Positioned.fill(
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Text(
                              'Giriş',
                              style: TextStyle(
                                  fontSize: 44,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4F51C0)),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.grey.shade700.withOpacity(0.5),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(25))),
                            width: MediaQuery.of(context).size.width * 0.8,
                          ),
                        ),
                        const Positioned.fill(
                            child: Center(child: CircularProgressIndicator())),
                      ],
                    ),
                  );
                } else {
                  return Center(
                    child: Stack(
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(25)),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey,
                                    offset: Offset(0, 0),
                                    blurRadius: 2,
                                    spreadRadius: 1),
                              ]),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 100, 20, 50),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                TextField(
                                  decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Ulanyjy ady'),
                                  controller: _usernameController,
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                TextField(
                                  decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Açar söz'),
                                  controller: _passwordController,
                                  obscureText: true,
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    //////////////////////// QRCode Login button //////////////
                                    Stack(
                                      children: <Widget>[
                                        Container(
                                          height: 55,
                                          width: 55,
                                          decoration: BoxDecoration(
                                              color: Colors.green[300],
                                              borderRadius:
                                                  const BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(15),
                                                      bottomLeft:
                                                          Radius.circular(15)),
                                              boxShadow: const [
                                                BoxShadow(
                                                    color: Colors.grey,
                                                    spreadRadius: 0,
                                                    blurRadius: 2,
                                                    offset: Offset(0, 0))
                                              ]),
                                          child: const Icon(Icons.qr_code),
                                        ),
                                        ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(15),
                                              bottomLeft: Radius.circular(15)),
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              onTap: () async {
                                                String cameraScanResult = '';
                                                try {
                                                  if (await Permission.camera
                                                      .request()
                                                      .isGranted) {
                                                    debugPrint(
                                                        'Merdan=>> Before scan');
                                                    cameraScanResult =
                                                        await Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              const QrViewWidget()),
                                                    );

                                                    debugPrint(
                                                        "Merdan=>> barcode: $cameraScanResult");
                                                    if (cameraScanResult
                                                        .isNotEmpty) {
                                                      dynamic decoded =
                                                          jsonDecode(
                                                              cameraScanResult);
                                                      _usernameController.text =
                                                          decoded["uName"];
                                                      _passwordController.text =
                                                          decoded["password"];
                                                      BlocProvider.of<AuthBloc>(
                                                              context)
                                                          .add(AuthLogInEvent(
                                                              _usernameController
                                                                  .text,
                                                              _passwordController
                                                                  .text));
                                                    }
                                                  }
                                                } catch (e) {
                                                  cameraScanResult =
                                                      '*Näbelli ýalňyşlyk: $e';
                                                }
                                              },
                                              child: const SizedBox(
                                                width: 55,
                                                height: 55,
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),

                                    //////////////////////// button Ulgama gir ///////////////
                                    Stack(
                                      children: <Widget>[
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.4,
                                          height: 55,
                                          decoration: const BoxDecoration(
                                              color: Colors.blue,
                                              borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(15),
                                                  bottomRight:
                                                      Radius.circular(15)),
                                              boxShadow: [
                                                BoxShadow(
                                                    color: Colors.grey,
                                                    spreadRadius: 0,
                                                    blurRadius: 2,
                                                    offset: Offset(0, 0))
                                              ]),
                                          child: const Center(
                                              child: Text(
                                            'Ulgama gir',
                                            style: TextStyle(fontSize: 16),
                                          )),
                                        ),
                                        ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                              topRight: Radius.circular(15),
                                              bottomRight: Radius.circular(15)),
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              onTap: () {
                                                BlocProvider.of<AuthBloc>(
                                                        context)
                                                    .add(AuthLogInEvent(
                                                        _usernameController
                                                            .text,
                                                        _passwordController
                                                            .text));
                                              },
                                              child: SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.4,
                                                height: 55,
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Positioned.fill(
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Text(
                              'Giriş',
                              style: TextStyle(
                                  fontSize: 44,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4F51C0)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            )),
          ],
        ),
      ),
    );
  }
}
