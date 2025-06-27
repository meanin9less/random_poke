import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:loginjwt/dice.dart';
import 'package:loginjwt/token.dart';
import 'package:loginjwt/userinfo.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

void main() {
  runApp(
      MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context)=> Token(),
        )
      ],
        child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(),
      home: MyPage(),
    );
  }
}

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? username;
  String? password;


  bool tryValidation (){
    if(_formKey.currentState!.validate()){
      _formKey.currentState!.save();
      return true;
    }
    return false;
  }

  Future<bool> loginRequest() async {
    Token provider = context.read<Token>(); //Provider.of<Token>(context, listen: false)
    // watch > build가 가능한 환경에서 써야함, 여기서 쓰기의 의미는 build를 다시하는것, set 가능,
    // widget build와는 관계없이 provider를 사용하겠다 > read
    // build안에서 provider를 가져올 때 watch 써야함
    final url = Uri.parse("http://10.0.2.2:8080/login");
    UserInfo user = UserInfo(username: username!, password: password!);
    // final headers = {"Content-Type":"application/json"}; //
    // final headers = {"Content-Type":"application/x-www-form-urlencoded"}; // 이거 넣어도됨, 인코드x
    final body = user.toJson();// > header 설정 안하고 json.encode안하고 맵으로 전달하면 쿼리파라미터로 전달됨
    // encode = 직렬화, map을 직렬화하면 json문자열객체로, 안하면 쿼리 파라미터 문으로 봄
    try{
      final response = await http.post(url, body: body);

      if(response.statusCode == 200){
        final token = response.headers['authorization'];
        final refresh = response.headers['set-cookie'];
        provider.accessToken = token!;
        provider.refreshToken = refresh!;
        return true;
      }else if(response.statusCode == 401){
        final msg = json.decode(utf8.decode(response.bodyBytes))['error'];
        showSnackBar(context, msg);
      }else{
        showSnackBar(context, "fuck you idiot ${response.statusCode}");
      }
    }catch(e){
      print("Error : $e");
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("凸 android studio 凸"),
        backgroundColor: Colors.redAccent,
        centerTitle: true,
      ),
      body: Builder(
          builder: (context){
            return GestureDetector(
              onTap: (){
                FocusScope.of(context).unfocus();
              },
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height,
                        padding: EdgeInsets.all(30),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                key: ValueKey(1),
                                validator: (value){
                                  if(value!.isEmpty){
                                    return "input username";
                                  }
                                  return null;
                                },
                                onSaved: (value){
                                  username = value!;
                                },
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.account_circle, color: Colors.grey,),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.blue),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  hintText: "username",
                                  contentPadding: EdgeInsets.all(10),
                                ),
                              ),
                              SizedBox(height: 10,),
                              TextFormField(
                                key: ValueKey(2),
                                validator: (value){
                                  if(value!.isEmpty){
                                    return "input password";
                                  }
                                  return null;
                                },
                                onSaved: (value){
                                  password = value!;
                                },
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.lock, color: Colors.grey,),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.blue),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  hintText: "password",
                                  contentPadding: EdgeInsets.all(10),
                                ),
                                obscureText: true,
                              ),
                              SizedBox(height: 10,),
                              ElevatedButton(
                                onPressed: () {
                                  if(tryValidation()){
                                    loginRequest().then((data){
                                      if(data){
                                        Navigator.push(context, MaterialPageRoute(
                                            builder: (context)=> Dice()
                                        ));
                                      }
                                    });
                
                                  }else{
                                    showSnackBar(context, "올바른 계정정보를 입력하세요.");
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red
                                ),
                                child:Icon(Icons.arrow_forward, color: Colors.white,),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          }
      )
    );
  }
}

void showSnackBar (BuildContext context, String message){
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message, textAlign: TextAlign.center,),
      duration: Duration(seconds: 2),
      backgroundColor: Colors.green,
    )
  );
}
