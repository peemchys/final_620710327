import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:final_620710327/pages/api/result.dart';

class GamePage extends StatefulWidget {
  const GamePage({Key? key}) : super(key: key);

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late Future<List> _data = _getQuiz();
  var _id = 0;
  var _text = "";
  var _isCorrect = false;
  var _incorrect = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if(_id < 5)
                    FutureBuilder<List>(
                      future: _data,
                      builder: (context, snapshot){
                        if(snapshot.connectionState != ConnectionState.done){
                          return const CircularProgressIndicator();
                        }

                        if(snapshot.hasData) {
                          var data = snapshot.data!;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Image.network(data[_id]['image_url'], height: 350.0,),
                              for(var i=0;i<data[_id]['choice_list'].length;++i)
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton(
                                    onPressed: (){
                                      setState(() {

                                        if(data[_id]['choice_list'][data[_id]['answer']] ){
                                          _text = "GREAT";
                                          _isCorrect = true;
                                          Timer(Duration(seconds: 1), () {
                                            setState(() {
                                              _id++;
                                              _text = "";
                                            });
                                          });

                                        }else{
                                          setState(() {
                                            _text = "WRONG TRYAGAIN";
                                            _isCorrect = false;
                                            _incorrect++;
                                          });
                                        }
                                      });
                                    },
                                    child: Container(
                                        height: 50.0,
                                        color: Colors.blue,
                                        child: Center(child: Text(data[_id]['choice_list'][i], style: TextStyle(fontSize: 20.0),))
                                    ),
                                  ),
                                )
                            ],
                          );
                        }

                        return const SizedBox.shrink();
                      },
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("END GAME" , style: TextStyle(fontSize: 42.0),),
                        Text("WRONG GUESS $_incorrect TIME" , style: TextStyle(fontSize: 28.0),),
                        ElevatedButton(
                          onPressed: (){
                            setState(() {
                              _id = 0;
                              _incorrect = 0;
                              _data = _getQuiz();
                            });
                          },
                          child: Container(
                              height: 50.0,
                              width: 150.0,
                              color: Colors.purpleAccent,
                              child: Text("PLAY AGAIN", textAlign: TextAlign.center, style: TextStyle(fontSize: 18.0),)
                          ),
                        )
                      ],
                    ),
                  if(_isCorrect)
                    Text(_text, style: TextStyle(fontSize: 30.0, color: Colors.lightGreen),)
                  else
                    Text(_text, style: TextStyle(fontSize: 30.0, color: Colors.red),)
                ],
              ),
            )
        ),
      ),
    );
  }

  Future<List> _getQuiz() async{
    final url = Uri.parse('https://cpsu-test-api.herokuapp.com/quizzes');
    var response = await http.get(url, headers: {'id': '620710327'},);

    var json = jsonDecode(response.body);
    var apiResult = ApiResult.fromJson(json);
    List data = apiResult.data;
    print(data);
    return data;
  }
}