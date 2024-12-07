// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:another_telephony/telephony.dart';
import 'package:sms_registration_with_websocket/Helpers/dbHelper.dart';
import 'package:sms_registration_with_websocket/Models/RespDkReceivedCode.dart';
import 'package:sms_registration_with_websocket/Models/socketProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sms_registration_with_websocket/Bloc/AuthBloc.dart';
import 'package:sms_registration_with_websocket/Bloc/PhoneBalanceBloc.dart';
import 'package:sms_registration_with_websocket/Bloc/SmsSenderBloc.dart';
import 'package:sms_registration_with_websocket/Bloc/SocketBloc.dart';
import 'package:sms_registration_with_websocket/Models/providerModel.dart';
import 'package:sms_registration_with_websocket/Models/tbl_dk_customer.dart';

class HomePage extends StatefulWidget {
  final SocketProvider _socketProvider = SocketProvider();

  HomePage({super.key});

  @override
  State<HomePage> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  String _balance = '';
  String _message = "";
  final telephony = Telephony.instance;

  onMessage(SmsMessage message) async {
    debugPrint("Gotten message: $_message");
    setState(() {
      _message = message.body ?? "Error reading message body.";
    });
  }

  static onBackgroundMessage(SmsMessage message) async {
     String message0 = message.body ?? "Error reading message body on background.";
  }

  Future<void> initPlatformState() async {
    final bool? result = await telephony.requestPhoneAndSmsPermissions;
    if (result != null && result) {
      telephony.listenIncomingSms(
          onNewMessage: onMessage, onBackgroundMessage: onBackgroundMessage);
    }
    if (!mounted) return;
  }
  static const platform = MethodChannel('SignInHelperService');
  bool connected = false;

  Future<void> _startService() async {
    try {
      final result = await platform.invokeMethod('startSignInHelperService');
      debugPrint(result);
      setState(() {
      });
    } on PlatformException catch (e) {
      debugPrint("Failed to invoke method: '${e.message}'.");
    }
  }

  Future<void> _stopService() async {
    try {
      final result = await platform.invokeMethod('stopSignInHelperService');
      debugPrint(result);
      setState(() {
      });
    } on PlatformException catch (e) {
      debugPrint("Failed to invoke method: '${e.message}'.");
    }
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.errorStatus),
            backgroundColor: Colors.red,
          ));
        }
      },
      child: BlocListener<SmsSenderBloc, SmsSenderState>(
        listener: (context, state) {
          if (state is SendingSmsState) {
            Provider.of<ProviderModel>(context, listen: false).getCustomers.insert(0, state.getCustomer);
          } else if (state is SmsSentState) {
            Provider.of<ProviderModel>(context, listen: false).getCustomers[Provider.of<ProviderModel>(context, listen: false)
                .getCustomers
                .indexWhere((element) => element.Key == state.getCustomer.Key)] = state.getCustomer;
          } else if (state is SmsDeliveredState) {
            Provider.of<ProviderModel>(context, listen: false).getCustomers[Provider.of<ProviderModel>(context, listen: false)
                .getCustomers
                .indexWhere((element) => element.Key == state.getCustomer.Key)] = state.getCustomer;
          } else if (state is ErrorSendingSmsState) {
            Provider.of<ProviderModel>(context, listen: false).getCustomers[Provider.of<ProviderModel>(context, listen: false)
                .getCustomers
                .indexWhere((element) => element.Key == state.getCustomer.Key)] = state.getCustomer;
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthSuccess) {
                  debugPrint('LoggedIn on HomePage');
                }
              },
              builder: (context, state) {
                if (state is AuthSuccess) {
                  return Text(state.getUName);
                } else if (state is AuthInProgress) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                  return const SizedBox.shrink();
              },
            ),
            actions: [
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is AuthSuccess) {
                    return StreamBuilder(
                      stream: widget._socketProvider.websocket,
                      builder: (context, snapshot) {
                        debugPrint("DkPrint connection state ${snapshot.connectionState}");
                        debugPrint("DkPrint data ${snapshot.data.toString()}");
                        debugPrint("DkPrint error ${snapshot.error.toString()}");
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          widget._socketProvider.openSocket(state.getToken);
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          );
                        } else if (snapshot.connectionState == ConnectionState.active && !snapshot.hasData) {
                          return Container(
                            decoration: BoxDecoration(color: Colors.green, border: Border.all(color: Colors.black26, width: 10)),
                          );
                        } else if (snapshot.connectionState == ConnectionState.active && snapshot.hasData) {
                          try {
                            RespDkReceivedCode receivedCode = RespDkReceivedCode.fromJson(jsonDecode(snapshot.data.toString()));
                            BlocProvider.of<SmsSenderBloc>(context)
                                .add(SendSmsEvent(UniqueKey().toString(), receivedCode.phone_number, receivedCode.verify_code));
                          } catch (e) {
                            debugPrint(e.toString());
                          }
                          return Container(
                            decoration: BoxDecoration(color: Colors.yellow, border: Border.all(color: Colors.black26, width: 10)),
                          );
                        } else if (snapshot.connectionState == ConnectionState.done) {
                          widget._socketProvider.closeSocket();
                          widget._socketProvider.openSocket(state.getToken);
                          return Container(
                            decoration: BoxDecoration(color: Colors.black, border: Border.all(color: Colors.black26, width: 10)),
                          );
                        } else if (snapshot.hasError) {
                          debugPrint(snapshot.error.toString());
                          return const SizedBox.shrink();
                        }
                          return const SizedBox.shrink();
                      },
                    );
                  } else {
                    return Container();
                  }
                },
              ),
              BlocBuilder<SocketBloc, SocketState>(
                builder: (context, state) {
                  if (state is SocketInitState) {
                    return Container(
                      decoration: BoxDecoration(border: Border.all(color: Colors.black26, width: 5)),
                    );
                  } else if (state is ConnectingToSocketState) {
                    return Container(
                      decoration: BoxDecoration(color: Colors.amber, border: Border.all(color: Colors.black26, width: 5)),
                    );
                  } else if (state is ConnectionErrorState) {
                    return Container(
                      decoration: BoxDecoration(color: Colors.red, border: Border.all(color: Colors.black26, width: 5)),
                    );
                  } else if (state is ConnectedState) {
                    return Container(
                      decoration: BoxDecoration(color: Colors.green, border: Border.all(color: Colors.black26, width: 5)),
                    );
                  } else if (state is DataReceived) {
                    return Container(
                      decoration: BoxDecoration(color: Colors.lightGreenAccent, border: Border.all(color: Colors.black26, width: 5)),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              ElevatedButton(
                  child: const Text('Start'),
                  onPressed: () {
                    _startService();
                  }),
              ElevatedButton(child: const Text('Stop'), onPressed: () => _stopService())
            ],
          ),
          body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.grey.shade200,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  BlocBuilder<PhoneBalanceBloc, PhoneBalanceState>(
                    builder: (context, state) {
                      if (state is PhoneBalanceInitState) {
                        return InkWell(
                          onTap: () async {
                            BlocProvider.of<PhoneBalanceBloc>(context).add(GetBalanceEvent());
                          },
                          child: Stack(
                            children: [
                              Card(
                                color: Colors.white,
                                shadowColor: Colors.grey,
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: Column(
                                      children: [
                                        const Text('Balans'),
                                        Text(
                                          _balance.isNotEmpty ? _balance : '',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      } else if (state is GettingBalanceState) {
                        return InkWell(
                          onTap: () {},
                          child: Stack(
                            children: [
                              Card(
                                color: Colors.white,
                                shadowColor: Colors.grey,
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: Column(
                                      children: [
                                        const Text('Balans'),
                                        Text(
                                          _balance.isNotEmpty ? _balance : '',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.all(10.0),
                                child: Align(
                                  alignment: Alignment.topRight,
                                  child: SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      } else if (state is BalanceGotState) {
                        _balance = state.getBalance;
                        return InkWell(
                          onTap: () async {
                            BlocProvider.of<PhoneBalanceBloc>(context).add(GetBalanceEvent());
                          },
                          child: Stack(
                            children: [
                              Card(
                                color: Colors.white,
                                shadowColor: Colors.grey,
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: Column(
                                      children: [
                                        const Text('Balans'),
                                        Text(
                                          _balance.isNotEmpty ? _balance : '',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                      child: Card(
                        color: Colors.white,
                        shadowColor: Colors.grey,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                          child: RefreshIndicator(
                            onRefresh: () async {
                              List<TblDkCustomer> list =
                                  (await DbHelper.queryAllRows('tbl_dk_customer')).map((e) => TblDkCustomer.fromMap(e)).toList();
                              Provider.of<ProviderModel>(context, listen: false).setCustomers = list;
                            },
                            child: ListView.builder(
                              itemCount: context.watch<ProviderModel>().getCustomers.length,
                              itemBuilder: (context, index) => PaymentsHistoryItem(context.watch<ProviderModel>().getCustomers[index]),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {},
                      child: SizedBox(
                          height: 100,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(
                                  Icons.history,
                                  size: 55,
                                  color: Theme.of(context).primaryColor,
                                ),
                                Text('Taryh', style: TextStyle(color: Theme.of(context).primaryColor)),
                              ],
                            ),
                          )),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PaymentsHistoryItem extends StatelessWidget {
  final TblDkCustomer _customer;
  final DateFormat _dateFormat = DateFormat('dd.MM.yyyy HH:mm:ss');

  PaymentsHistoryItem(this._customer, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width / 5,
              child: Center(
                child: (_customer.SmsStatus == 1)
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : (_customer.SmsStatus == 2)
                        ? const Icon(
                            Icons.send,
                            color: Colors.orange,
                          )
                        : (_customer.SmsStatus == 3)
                            ? const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              )
                            : const Icon(
                                Icons.cancel,
                                color: Colors.red,
                              ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.local_phone,
                        color: Colors.black54,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(2, 2, 4, 2),
                          child: Text(
                            _customer.CustomerPhoneNo,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.lock,
                        color: Colors.black54,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(2, 2, 4, 2),
                          child: Text(_customer.VerifyCode),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: Colors.black54,
                      ),
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Text(_dateFormat.format(_customer.Date).toString()),
                      )),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        (_customer.Desc.isNotEmpty)
            ? Expanded(
                child: Container(
                  color: Colors.red,
                  child: Text(
                    _customer.Desc,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 3,
                  ),
                ),
              )
            : Container(
                width: 0,
              )
      ],
    );
  }
}
