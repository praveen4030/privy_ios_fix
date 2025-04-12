import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:privy_flutter/privy_flutter.dart';
import 'package:privy_ios_fix/utils/privy_login_utils.dart';

class PrivyUtils {
  static PrivyUtils? _shared;

  PrivyUtils._internal();

  factory PrivyUtils() {
    return _shared ??= PrivyUtils._internal();
  }

  static PrivyUtils get sharedInstance {
    return _shared ??= PrivyUtils._internal();
  }

  bool isReady = false;
  bool isAuthenticated = false;
  Privy? privy;
  PrivyLoginUtils privyLoginUtils = PrivyLoginUtils();
  bool isCreatingWallet = false;
  bool isWalletsCreated = false;
  bool isCreatingSolanaWallet = false;
  bool isCreatingEvmWallet = false;

  final privyConfig = PrivyConfig(
    appId: "clv6fw8s306zb9ubei8siuud9",
    appClientId: "client-WY2kGjAV9PduKgHvw16ZbZqqk8HPSPCBaeLdAyNsj2mNi",
    logLevel: PrivyLogLevel.verbose,
  );

  Future<void> initializePrivy() async {
    privy = Privy.init(config: privyConfig);
    isReady = false;
    await privy!.awaitReady();
    isAuthenticated = privy!.currentAuthState.isAuthenticated;
    isReady = true;
    if (isAuthenticated) {
      getPrivyAddresses();
    }
  }

  Future<void> createWallets() async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      if (privy!.user == null) {
        throw Exception("User not found");
      }
      debugPrint("creating privy wallets");
      isCreatingWallet = true;
      await createSolanaWallet();
      await Future.delayed(const Duration(seconds: 1));
      await createEvmWallet();
      debugPrint("Wallets created successfully");
      getPrivyAddresses();
      isCreatingWallet = false;
    } on PlatformException catch (_) {
      isCreatingWallet = false;
      return;
    } catch (e) {
      isCreatingWallet = false;
      return;
    }
  }

  Future<void> createEvmWallet() async {
    List<EmbeddedEthereumWallet> evmEmbeddedWallets =
        privy!.user!.embeddedEthereumWallets;
    if (evmEmbeddedWallets.isNotEmpty) {
      Fluttertoast.showToast(msg: "Privy EVM Wallets already created");
      return;
    }
    Fluttertoast.showToast(msg: "Creating Privy EVM Wallets");
    isCreatingEvmWallet = true;
    final Result<void> result = await privy!.user!.createEthereumWallet();
    isCreatingEvmWallet = false;
    result.fold(
      onSuccess: (_) {
        Fluttertoast.showToast(msg: "Privy EVM Wallets created successfully");
      },
      onFailure: (error) {
        Fluttertoast.showToast(
          msg: "Privy EVM Wallets creation failed ${error.message}",
        );
        throw Exception(error.message);
      },
    );
  }

  Future<void> createSolanaWallet() async {
    final solanaEmbeddedWallets = privy!.user!.embeddedSolanaWallets;
    if (solanaEmbeddedWallets.isNotEmpty) {
      debugPrint("Privy Solana Wallets already created");
      return;
    }
    Fluttertoast.showToast(msg: "Creating Privy Solana Wallets");
    isCreatingSolanaWallet = true;
    final Result<void> result = await privy!.user!.createSolanaWallet();
    isCreatingSolanaWallet = false;
    result.fold(
      onSuccess: (_) {
        Fluttertoast.showToast(
          msg: "Privy Solana Wallets created successfully",
        );
      },
      onFailure: (error) {
        Fluttertoast.showToast(
          msg: "Privy Solana Wallets creation failed: ${error.message}",
        );
        throw Exception(error.message);
      },
    );
  }

  Future<void> logoutUser() async {
    await privy!.logout();
    isAuthenticated = false;
    Fluttertoast.showToast(msg: "Logged out successfully");
  }

  List<String>? getPrivyAddresses() {
    if (privy?.user == null) {
      isWalletsCreated = false;
      return null;
    }
    List<EmbeddedEthereumWallet> evmEmbeddedWallets =
        privy!.user!.embeddedEthereumWallets;
    final solanaEmbeddedWallets = privy!.user!.embeddedSolanaWallets;
    if (evmEmbeddedWallets.isEmpty || solanaEmbeddedWallets.isEmpty) {
      isWalletsCreated = false;
      return null;
    }
    isWalletsCreated = true;
    return [
      evmEmbeddedWallets.first.address,
      solanaEmbeddedWallets.first.address,
    ];
  }
}
