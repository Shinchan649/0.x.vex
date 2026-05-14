import 'package:web3dart/web3dart.dart';
import 'package:web3dart/crypto.dart';
import 'package:http/http.dart';
import 'dart:math';
import 'dart:convert';
import 'dart:typed_data';
import 'package:logger/logger.dart';
import 'swap_service.dart';

class CollectorService {
  final logger = Logger();
  final Map<String, List<Map<String, String>>> _commonTokens = {
    'Ethereum': [{'symbol': 'USDC', 'address': '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48'}],
    'Polygon': [{'symbol': 'USDC', 'address': '0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174'}],
    'BSC': [{'symbol': 'USDT', 'address': '0x55d398326f99059fF775485246999027B3197955'}],
  };
  Future<List<Map<String, dynamic>>> collectDust({
    required String rpcUrl,
    required List<String> privateKeys,
    required String destinationAddress,
    String? chainName,
    bool swapToStable = false,
    String? oneInchApiKey,
  }) async {
    final httpClient = Client();
    final ethClient = Web3Client(rpcUrl, httpClient);
    final results = <Map<String, dynamic>>[];

    for (final pk in privateKeys) {
      try {
        final creds = EthPrivateKey.fromHex(pk.trim());

        final tokens = _commonTokens[chainName] ?? [];
        final swapService = SwapService(apiKey: oneInchApiKey);

        for (final t in tokens) {
          if (swapToStable && oneInchApiKey != null) {
            try {
              // Get balance first
              final contract = DeployedContract(ContractAbi.fromJson('[{"constant":true,"inputs":[{"name":"_owner","type":"address"}],"name":"balanceOf","outputs":[{"name":"balance","type":"uint256"}],"type":"function"}]', 'ERC20'), EthereumAddress.fromHex(t['address']!));
              final bRes = await ethClient.call(contract: contract, function: contract.function('balanceOf'), params: [creds.address]);
              final balance = bRes.first as BigInt;

              if (balance > BigInt.zero) {
                // Target stable (e.g. USDC on Polygon)
                final targetToken = _commonTokens[chainName]?.first['address'] ?? t['address']!;
                if (targetToken != t['address']) {
                  final chainId = chainName == 'Polygon' ? 137 : (chainName == 'BSC' ? 56 : 1);

                  // Check allowance
                  final approveData = await swapService.getApproveTransaction(chainId: chainId, tokenAddress: t['address']!, amount: balance.toString());
                  if (approveData != null) {
                    final approveHash = await ethClient.sendTransaction(
                      creds,
                      Transaction(
                        to: EthereumAddress.fromHex(approveData['to']),
                        data: hexToBytes(approveData['data']),
                        value: EtherAmount.zero(),
                      ),
                      fetchChainIdFromNetworkId: true,
                    );
                    results.add({'address': creds.address.hex, 'type': 'Approve (${t['symbol']})', 'status': 'success', 'txHash': approveHash});
                  }

                  final swapData = await swapService.getSwapData(
                    chainId: chainId,
                    fromToken: t['address']!,
                    toToken: targetToken,
                    amount: balance.toString(),
                    fromAddress: creds.address.hex,
                  );
                  if (swapData != null) {
                    try {
                      final txData = swapData['tx'];
                      final txHash = await ethClient.sendTransaction(
                        creds,
                        Transaction(
                          to: EthereumAddress.fromHex(txData['to']),
                          value: EtherAmount.fromUnitAndValue(EtherUnit.wei, BigInt.parse(txData['value'])),
                          data: hexToBytes(txData['data']),
                          gasPrice: EtherAmount.fromUnitAndValue(EtherUnit.wei, BigInt.parse(txData['gasPrice'])),
                          maxGas: int.parse(txData['gas'].toString()),
                        ),
                        fetchChainIdFromNetworkId: true,
                      );
                      results.add({'address': creds.address.hex, 'type': 'Swap (${t['symbol']})', 'status': 'success', 'amount': balance.toString(), 'txHash': txHash});
                    } catch (e) {
                      logger.e("Swap execution error: $e");
                      results.add({'address': creds.address.hex, 'type': 'Swap (${t['symbol']})', 'status': 'failed', 'amount': balance.toString()});
                    }
                  }
                }
              }
            } catch (e) { logger.e("Swap error: $e"); }
          }
          await _sweepToken(ethClient, creds, t['address']!, destinationAddress, results, t['symbol']!);
        }

        await _sweepNative(ethClient, creds, destinationAddress, results);
      } catch (e) { logger.e(e); }
    }
    await ethClient.dispose(); httpClient.close(); return results;
  }
  Future<void> _sweepNative(Web3Client client, EthPrivateKey creds, String dest, List<Map<String, dynamic>> res) async {
    final b = await client.getBalance(creds.address); final gp = await client.getGasPrice();
    if (b.getInWei > (gp.getInWei * BigInt.from(42000))) {
      final amt = b.getInWei - (gp.getInWei * BigInt.from(21000));
      final tx = await client.sendTransaction(creds, Transaction(to: EthereumAddress.fromHex(dest), value: EtherAmount.fromUnitAndValue(EtherUnit.wei, amt), gasPrice: gp, maxGas: 21000), fetchChainIdFromNetworkId: true);
      res.add({'address': creds.address.hex, 'type': 'Native', 'status': 'success', 'amount': (amt.toDouble()/1e18).toStringAsFixed(6), 'txHash': tx});
    }
  }
  Future<void> _sweepToken(Web3Client client, EthPrivateKey creds, String token, String dest, List<Map<String, dynamic>> res, String sym) async {
    final contract = DeployedContract(ContractAbi.fromJson('[{"constant":true,"inputs":[{"name":"_owner","type":"address"}],"name":"balanceOf","outputs":[{"name":"balance","type":"uint256"}],"type":"function"},{"constant":false,"inputs":[{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transfer","outputs":[{"name":"success","type":"bool"}],"type":"function"}]', 'ERC20'), EthereumAddress.fromHex(token));
    final bRes = await client.call(contract: contract, function: contract.function('balanceOf'), params: [creds.address]);
    if (bRes.first > BigInt.zero) {
      final tx = await client.sendTransaction(creds, Transaction.callContract(contract: contract, function: contract.function('transfer'), parameters: [EthereumAddress.fromHex(dest), bRes.first]), fetchChainIdFromNetworkId: true);
      res.add({'address': creds.address.hex, 'type': 'Token ($sym)', 'status': 'success', 'amount': bRes.first.toString(), 'txHash': tx});
    }
  }
}
