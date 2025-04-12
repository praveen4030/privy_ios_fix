import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:privy_flutter/privy_flutter.dart';
import 'package:privy_ios_fix/utils/privy_utils.dart';

class PrivyLoginUtils {
  bool isSendingOtp = false;
  bool isVerifyingOtp = false;
  TextEditingController emailController = TextEditingController();
  String emailVal = "";
  String otpVal = "";
  bool canResendOtp = false;
  bool isResendingOtp = false;
  Timer? timerToResendOtp;
  int timeLeftToResendOtp = 30;

  Privy get privy => PrivyUtils.sharedInstance.privy!;

  Future<void> loginWithEmail() async {
    isSendingOtp = true;
    if (privy.user != null) {
      await privy.logout();
    }
    final Result<void> result = await PrivyUtils.sharedInstance.privy!.email
        .sendCode(emailVal);

    result.fold(
      onSuccess: (_) async {
        // OTP was sent successfully
        await Future.delayed(const Duration(milliseconds: 100), () {});
        //unfocus
        Fluttertoast.showToast(msg: "OTP sent successfully!");
      },
      onFailure: (error) {
        // Handle error sending OTP
        Fluttertoast.showToast(msg: "OTP sent failed!");
      },
    );
  }

  Future<void> verifyOtp() async {
    isVerifyingOtp = true;
    final Result<void> result = await PrivyUtils.sharedInstance.privy!.email
        .loginWithCode(code: otpVal, email: emailVal);

    result.fold(
      onSuccess: (_) async {
        PrivyUtils.sharedInstance.isAuthenticated = true;
        Fluttertoast.showToast(msg: "Logged in successfully!");
        isVerifyingOtp = false;
      },
      onFailure: (error) {
        debugPrint("Unable to create wallets: ${error.message}");
        isVerifyingOtp = false;
        if (error.message.contains("PrivySDK.LoginWithEmailError")) {
          Fluttertoast.showToast(msg: "Invalid OTP");
          return;
        }
        Fluttertoast.showToast(msg: error.message);
      },
    );
  }

  Future<void> resendOtp() async {
    isResendingOtp = true;
    final Result<void> result = await PrivyUtils.sharedInstance.privy!.email
        .sendCode(emailVal);
    resendOtpTimer();
    isResendingOtp = false;
    result.fold(
      onSuccess: (_) async {
        // OTP was sent successfully
        Fluttertoast.showToast(msg: "OTP sent successfully!");
      },
      onFailure: (error) {
        // Handle error sending OTP
        Fluttertoast.showToast(msg: error.message);
      },
    );
  }

  void resendOtpTimer() {
    if (timerToResendOtp != null) {
      timerToResendOtp!.cancel();
    }
    timeLeftToResendOtp = 30;
    canResendOtp = false;
    timerToResendOtp = Timer.periodic(const Duration(seconds: 1), (timer) {
      timeLeftToResendOtp--;
      if (timeLeftToResendOtp <= 0) {
        canResendOtp = true;
        timerToResendOtp!.cancel();
      }
    });
  }
}
