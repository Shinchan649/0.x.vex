import 'package:bip39/bip39.dart' as bip39;
import 'package:bip32/bip32.dart' as bip32;
import 'package:web3dart/web3dart.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:typed_data';

class WalletService {
  final _storage = const FlutterSecureStorage();
  static const String _walletKey = 'wallets_v3';
  Future<String> createNewMnemonic() async => bip39.generateMnemonic();
  Future<String> derivePrivateKey(String mnemonic, {int index = 0}) async {
    final seed = bip39.mnemonicToSeed(mnemonic);
    final root = bip32.BIP32.fromSeed(seed);
    final child = root.derivePath("m/44'/60'/0'/0/$index");
    return EthPrivateKey.fromHex(Uint8List.fromList(child.privateKey!).map((e) => e.toRadixString(16).padLeft(2, '0')).join()).privateKeyInt.toRadixString(16);
  }
  Future<void> saveWallet(String name, String pk, {String? mnemonic}) async {
    final prefs = await SharedPreferences.getInstance();
    final wallets = jsonDecode(prefs.getString(_walletKey) ?? '[]');
    final addr = EthPrivateKey.fromHex(pk).address.hex;
    wallets.add({'name': name, 'address': addr, 'hasMnemonic': mnemonic != null});
    await prefs.setString(_walletKey, jsonEncode(wallets));
    await _storage.write(key: 'pk_$addr', value: pk);
    if (mnemonic != null) await _storage.write(key: 'mn_$addr', value: mnemonic);
  }
  Future<List<Map<String, dynamic>>> getWallets() async {
    final prefs = await SharedPreferences.getInstance();
    return List<Map<String, dynamic>>.from(jsonDecode(prefs.getString(_walletKey) ?? '[]'));
  }
  Future<String?> getPrivateKey(String addr) async => await _storage.read(key: 'pk_$addr');
}
