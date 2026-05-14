import 'package:web3dart/web3dart.dart';
import 'package:logger/logger.dart';

class SecurityService {
  final logger = Logger();

  Future<void> revokeAllowance({
    required Web3Client client,
    required EthPrivateKey credentials,
    required String tokenAddress,
    required String spenderAddress,
  }) async {
    final contract = DeployedContract(
      ContractAbi.fromJson('[{"constant":false,"inputs":[{"name":"_spender","type":"address"},{"name":"_value","type":"uint256"}],"name":"approve","outputs":[{"name":"success","type":"bool"}],"type":"function"}]', 'ERC20'),
      EthereumAddress.fromHex(tokenAddress),
    );

    try {
      await client.sendTransaction(
        credentials,
        Transaction.callContract(
          contract: contract,
          function: contract.function('approve'),
          parameters: [EthereumAddress.fromHex(spenderAddress), BigInt.zero],
        ),
        fetchChainIdFromNetworkId: true,
      );
    } catch (e) {
      logger.e("Error revoking allowance: $e");
    }
  }

  Future<void> sweepNFT({
    required Web3Client client,
    required EthPrivateKey credentials,
    required String nftAddress,
    required BigInt tokenId,
    required String destination,
  }) async {
    final contract = DeployedContract(
      ContractAbi.fromJson('[{"constant":false,"inputs":[{"name":"from","type":"address"},{"name":"to","type":"address"},{"name":"tokenId","type":"uint256"}],"name":"safeTransferFrom","outputs":[],"type":"function"}]', 'ERC721'),
      EthereumAddress.fromHex(nftAddress),
    );

    try {
      await client.sendTransaction(
        credentials,
        Transaction.callContract(
          contract: contract,
          function: contract.function('safeTransferFrom'),
          parameters: [credentials.address, EthereumAddress.fromHex(destination), tokenId],
        ),
        fetchChainIdFromNetworkId: true,
      );
    } catch (e) {
      logger.e("Error sweeping NFT: $e");
    }
  }
}
