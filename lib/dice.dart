import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:loginjwt/token.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

class Dice extends StatefulWidget {
  const Dice({super.key});

  @override
  State<Dice> createState() => _DiceState();
}

class _DiceState extends State<Dice> {
  late int? leftPoke;
  late int? rightPoke;
  bool isAdmin = false;
  String? errorMessage;

  Future<void> adminRequest() async{
    Token provider = context.read<Token>();
    
    final url = Uri.parse("http://10.0.2.2:8080/admin");
    final headers = {
      'authorization':provider.accessToken,
      'set-token':provider.refreshToken
    };

    try{
      final response = await http.get(url, headers: headers);
      if(response.statusCode==200){
        isAdmin = true;
      }else if (response.statusCode == 403){
        errorMessage = utf8.decode(response.bodyBytes); // json decode > json객체 x 문자열이라 안해도됨;
      }else if(response.statusCode == 456){
        await accessTokenRequest();
        await adminRequest(); // 재귀 호출
      }
    }catch(e){
      print('$e');
    }
  }

  Future<void> accessTokenRequest() async{
    Token provider = context.read<Token>();

    print("reissue");

    final url = Uri.parse("http://10.0.2.2:8080/reissue");
    final headers = {
      'Cookie':provider.refreshToken
    };

    try{
      final response = await http.post(url, headers: headers);
      if(response.statusCode==200){
        final accessToken = response.headers['authorization'];
        provider.accessToken = accessToken!;
      }
    }catch(e){
      print('$e');
    }

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    leftPoke = Random().nextInt(6)+1;
    rightPoke = Random().nextInt(6)+1;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.redAccent,
      appBar: AppBar(
        title: Text("Poke Dice"),
      ),
      body: Builder( // 해당위치(state 클래스 scaffold안에 builder 자리)에 해당하는 새로운 컨텍스트 생성 가능
          builder: (context){
            return GestureDetector(
              onTap: (){
                FocusScope.of(context).unfocus();
              },
              child: SingleChildScrollView( // GestureDetector 의 on tap을 인식 가능
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                              child: Image.asset("images/$leftPoke.webp", width: 300,)
                          ),
                          SizedBox(width: 20,),
                          Expanded(
                              child: Image.asset("images/$rightPoke.webp", width: 300,)
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 60,),
                    ElevatedButton(
                      onPressed: ()async{
                        await adminRequest();
                        if(isAdmin){
                          setState(() {
                            leftPoke = Random().nextInt(6)+1;
                            rightPoke = Random().nextInt(6)+1;
                          });
                          isAdmin = false;
                        }else{
                          showToast(errorMessage!);
                        }
                      },
                      child:Icon(Icons.play_arrow, color: Colors.white, size: 50,),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent
                      ),
                    ),

                  ],
                ),
              ),
            );
          }
      )



    );
  }

  void showToast(String message){
    Fluttertoast.showToast(msg: message, fontSize: 25, backgroundColor: Colors.white, textColor: Colors.orangeAccent, toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.BOTTOM);
  }
}
