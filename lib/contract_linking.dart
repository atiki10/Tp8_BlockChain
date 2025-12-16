import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart'; 
import 'package:web_socket_channel/io.dart';

class ContractLinking extends ChangeNotifier { 
  final String _rpcUrl = "HTTP://127.0.0.1:7545"; 
  final String _wsUrl = "ws://10.0.2.2:7545/";
  final String _privateKey = "0xd832fdc114ff01784fdd34b0b03e26d305ef400931e8a3ed28a2c75949cbfb1d";

  late Web3Client _client;
  bool isLoading = true;

  late String _abiCode;
  late EthereumAddress _contractAddress;
  late Credentials _credentials;
  late DeployedContract _contract;
  late ContractFunction _yourName;
  late ContractFunction _setName;
  late String deployedName;

  ContractLinking() {
    initialSetup();
  }

  Future<void> initialSetup() async {
    _client = Web3Client(
      _rpcUrl,
      Client(),
      socketConnector: () {
        return IOWebSocketChannel.connect(_wsUrl).cast<String>();
      },
    );

    await getAbi();
    await getCredentials();
    await getDeployedContract();
  }


  Future<void> getAbi() async {
    String abiFile =
        await rootBundle.loadString("src/artifacts/HelloWorld.json");

    final jsonAbi = jsonDecode(abiFile);

    _abiCode = jsonEncode(jsonAbi["abi"]);

    final networks = jsonAbi["networks"] as Map<String, dynamic>;

    // Ganache network id = 5777 (dans 99% des cas)
    if (networks.containsKey("5777")) {
      _contractAddress =
          EthereumAddress.fromHex(networks["5777"]["address"]);
    } else {
      final first = networks.entries.first;
      _contractAddress = EthereumAddress.fromHex(first.value["address"]);
    }
  }


  Future<void> getCredentials() async {
    _credentials = EthPrivateKey.fromHex(_privateKey);
  }


  Future<void> getDeployedContract() async {
    _contract = DeployedContract(
      ContractAbi.fromJson(_abiCode, "HelloWorld"),
      _contractAddress,
    );

    _yourName = _contract.function("yourName");
    _setName = _contract.function("setName");

    await getName();
  }


  Future<void> getName() async {
    try {
      final response = await _client.call(
        contract: _contract,
        function: _yourName,
        params: [],
      );

      deployedName = response[0] as String;
    } catch (e) {
      deployedName = "Erreur";
      print("Erreur getName(): $e");
    }

    isLoading = false;
    notifyListeners();
  }


  Future<String?> setName(String nameToSet) async {
    isLoading = true;
    notifyListeners();

    try {
      // Envoi de la transaction qui appelle setName
      final txHash = await _client.sendTransaction(
        _credentials,
        Transaction.callContract(
          contract: _contract,
          function: _setName,
          parameters: [nameToSet],
          // gasPrice / maxGas peuvent etre ajoutés si nécessaire :
          // maxGas: 100000,
        ),
        chainId: 1337, // laisser null pour Ganache local
        fetchChainIdFromNetworkId: false,
      );

      // Optionnel : attendre la confirmation (poll) -> on relira ensuite la valeur
      await getName();
      return txHash;
    } catch (e) {
      print("setName error: $e");
      isLoading = false;
      notifyListeners();
      return null;
    }
  }


}