import 'dart:convert';
import 'package:http/http.dart' as http;
class SwapService {
  final String _baseUrl = 'https://api.1inch.dev/swap/v5.2';
  final String? _apiKey;
  SwapService({String? apiKey}) : _apiKey = apiKey;
  Future<Map<String, dynamic>?> getSwapData({required int chainId, required String fromToken, required String toToken, required String amount, required String fromAddress}) async {
    if (_apiKey == null) return null;
    final url = '$_baseUrl/$chainId/swap?fromTokenAddress=$fromToken&toTokenAddress=$toToken&amount=$amount&fromAddress=$fromAddress&slippage=1';
    try {
      final r = await http.get(Uri.parse(url), headers: {'Authorization': 'Bearer $_apiKey'});
      if (r.statusCode == 200) return jsonDecode(r.body);
    } catch (_) {}
    return null;
  }

  Future<Map<String, dynamic>?> getApproveTransaction({required int chainId, required String tokenAddress, String? amount}) async {
    if (_apiKey == null) return null;
    final url = '$_baseUrl/$chainId/approve/transaction?tokenAddress=$tokenAddress${amount != null ? '&amount=$amount' : ''}';
    try {
      final r = await http.get(Uri.parse(url), headers: {'Authorization': 'Bearer $_apiKey'});
      if (r.statusCode == 200) return jsonDecode(r.body);
    } catch (_) {}
    return null;
  }
}
