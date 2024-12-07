// ignore_for_file: deprecated_member_use, non_constant_identifier_names, file_names, use_build_context_synchronously
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sms_registration_with_websocket/Bloc/AuthBloc.dart';
import 'package:sms_registration_with_websocket/Bloc/PhoneBalanceBloc.dart';
import 'package:sms_registration_with_websocket/Bloc/SocketBloc.dart';
import 'package:sms_registration_with_websocket/Helpers/dbHelper.dart';
import 'package:sms_registration_with_websocket/Models/tbl_dk_user.dart';
import 'package:sms_registration_with_websocket/Pages/HomePage.dart';
import 'package:sms_registration_with_websocket/Services/Services.dart';

import 'LogInPage.dart';

class SplashScreen extends StatefulWidget {
  final Services srv;

  const SplashScreen(this.srv, {super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  bool isLoaded = false;
  int tryLoadCount = 0;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1));

    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller);

    LoadingData()
        .then((value) {
      if (value) {
        isLoaded = value;
        sleep(const Duration(seconds: 1));
        checkAgain:
        if (BlocProvider.of<AuthBloc>(context).state is AuthSuccess &&
            (BlocProvider.of<AuthBloc>(context).state as AuthSuccess).getTokenExpDate.isAfter(DateTime.now().add(const Duration(minutes: 1)))) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => HomePage(),
          ));
        } else if (BlocProvider.of<AuthBloc>(context).state is AuthInProgress) {
          sleep(const Duration(seconds: 1));
          break checkAgain;
        } else {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => LoginPage(),
          ));
        }
      }
    });
  }

  Future<bool> LoadingData() async {
    bool returnValue = false;
    await DbHelper.init();
    try {
      if (BlocProvider.of<AuthBloc>(context).state is! AuthSuccess) {
        int userCount = await DbHelper.rowCount('tbl_dk_user') ?? 0;
        debugPrint('DkPrint userCount=$userCount');
        if (userCount > 0) {
          debugPrint('DkPrint try to read User from db');
          var user = await DbHelper.queryFirstRow('tbl_dk_user');
          TblDkUser dkUser = TblDkUser.fromMap(user);
          debugPrint('DkPrint User read from db. Try to login');
          BlocProvider.of<AuthBloc>(context).add(AuthLogInEvent(dkUser.UName, dkUser.UPass));
          debugPrint('DkPrint LoggedIn');
        }
      }

      BlocProvider.of<PhoneBalanceBloc>(context).add(GetBalanceEvent());

      returnValue = true;
    } catch (_) {
      debugPrint("DkPrint Error on loading Data process. ErrorCount = $tryLoadCount");
      debugPrint(_.toString());
      returnValue = false;
      tryLoadCount = tryLoadCount + 1;
      await Future.delayed(const Duration(seconds: 4));
    }

    return returnValue;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _controller.forward();
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          BlocProvider.of<SocketBloc>(context).add(ConnectToSocketEvent((BlocProvider.of<AuthBloc>(context).state as AuthSuccess).getToken));
          debugPrint('AuthSuccess on splashScreen');
        }
      },
      child: Scaffold(
        body: Center(
          child: FadeTransition(
              opacity: _animation,
              child: (tryLoadCount <= 5)
                  ? SizedBox(
                      width: MediaQuery.of(context).size.width / 1.5,
                      height: MediaQuery.of(context).size.width / 1.5,
                      child: GestureDetector(
                        onTap: () {
                          if (isLoaded) {
                            Navigator.of(context).pushReplacement(MaterialPageRoute(
                              builder: (context) => HomePage(),
                            ));
                          }
                        },
                        child: Shimmer.fromColors(
                          baseColor: Colors.black,
                          highlightColor: Colors.yellow,
                          child: SvgPicture.asset('images/SapCozgut.svg'),
                        ),
                      ))
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                            width: MediaQuery.of(context).size.width / 1.5,
                            height: MediaQuery.of(context).size.width / 1.5,
                            child: GestureDetector(
                              onTap: () {
                                if (isLoaded) {
                                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                                    builder: (context) => HomePage(),
                                  ));
                                }
                              },
                              child: Shimmer.fromColors(
                                baseColor: Colors.black,
                                highlightColor: Colors.yellow,
                                child: SvgPicture.asset('images/SapCozgut.svg'),
                              ),
                            )),
                        Shimmer.fromColors(
                            baseColor: Colors.red,
                            highlightColor: Colors.orange,
                            child: const Text(
                              "Maglumat bazasyna baglanmady! Internet toruna baglandyňyzmy?",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.yellow),
                              textAlign: TextAlign.center,
                            ))
                      ],
                    )),
        ),
      ),
    );
  }
}
