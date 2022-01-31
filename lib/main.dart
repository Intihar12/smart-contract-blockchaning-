import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:pk_coin/slider_widget.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:web3dart/web3dart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  late Client httpClient;
   late Web3Client ethClient;
  bool data=false;
  late  int myAmount=0;
  final myAddress = "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4";
var myData;
 String txHash="";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    httpClient= Client();
    ethClient = Web3Client("https://rinkeby.infura.io/v3/582af40427d54962b83343a6fb204a18", httpClient);
    getBalance(myAddress);
  }

  Future<DeployedContract> loadContract() async{
    String abi = await rootBundle.loadString("assets/abi.json");
    String contractAddress = "0xd9145CCE52D386f254917e481eB44e9943F39138";
    final contract = DeployedContract(ContractAbi.fromJson(abi, "PKCoin"),EthereumAddress.fromHex(contractAddress));

    return contract;
  }

  Future<List<dynamic>> query(String functionName, List <dynamic>args) async{

    final contract = await loadContract();
    final ethFunction = contract.function(functionName);
    final result = await ethClient.call(contract: contract, function: ethFunction, params: args);
    return result;
  }



  Future <void> getBalance(String targetAddress)async{
    //EthereumAddress address = EthereumAddress.fromHex(targetAddress);
    List<dynamic> result = await query("getBalance", []);
    myData =result[0];
    data=true;

    setState(() {} );
  }
Future <String>submit(String functionName, List<dynamic>args)async{
    EthPrivateKey credentials =EthPrivateKey.fromHex("0x20832B529EFF565c3b6E92baE383d0a52B32dB53");
    DeployedContract contract = await loadContract();
    final ethfunction = contract.function(functionName);
    final result =await ethClient.sendTransaction(credentials, Transaction.callContract(
        contract: contract, function: ethfunction, parameters: args), fetchChainIdFromNetworkId: true);
    return result;
}

  Future <String> SendCoin() async{
    var bigAmount =BigInt.from(myAmount);
    var responce= await submit("depositBablance", [bigAmount]);
    print("Deposit");
txHash= responce;
setState(() {

});
    return responce;

  }
  Future <String> withdrawCoin() async{
    var bigAmount =BigInt.from(myAmount);
    var responce= await submit("withdrawBalance", [bigAmount]);
    print("withdran");
    txHash=responce;
    setState(() {

    });
    return responce;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Vx.gray300,
      body:  ZStack([
        VxBox().teal600.size(context.screenWidth, context.percentHeight * 30).make(),

        VStack([
          (context.percentHeight * 10).heightBox,
          "\$PKCOIN".text.xl4.white.bold.center.makeCentered().p16(),
         // (context.percentHeight * 5).heightBox,

          VxBox(child: VStack([
            "Balance".text.gray700.xl2.semiBold.makeCentered(),
            10.heightBox,
            data? "\$$myData" .text.bold.xl6.makeCentered().shimmer():CircularProgressIndicator().centered()
          ])).p16.white.size(context.screenWidth,context.percentHeight * 18).rounded.shadowXl.make().p16(),
          30.heightBox,
          SliderWidget(min: 0,max: 100,
          finalVal:(value){
         myAmount = (value * 100).round();
         print(myAmount);
          }).centered(),
          HStack([
            TextButton.icon(onPressed:() => getBalance(myAddress),


            style: ButtonStyle(backgroundColor:  MaterialStateProperty.all<Color>(Colors.teal,

            )),

            icon:Icon(Icons.refresh,color: Colors.white,),label: "Refresh".text.white.make().h(30),
            ),



            TextButton.icon(onPressed: () => SendCoin(),

              style: ButtonStyle(backgroundColor:  MaterialStateProperty.all<Color>(Colors.lightGreen,

              )),

              icon:Icon(Icons.call_made_outlined,color: Colors.white,),
              label: "Deposit".text.white.make().h(30),),


            TextButton.icon(onPressed: ()=> withdrawCoin(),

              style: ButtonStyle(backgroundColor:  MaterialStateProperty.all<Color>(Colors.red,

              )),

              icon:Icon(Icons.call_received_outlined,color: Colors.white,),label: "WithDraw".text.white.make().h(30),)



          ], alignment: MainAxisAlignment.spaceAround,
          axisSize: MainAxisSize.max,).p1(),
          if(txHash != null)txHash.text.black.makeCentered().p16()

        ])
     ] ),
    );
  }
}

