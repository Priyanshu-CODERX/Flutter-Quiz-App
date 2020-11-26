import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:quizApp/jsonData.dart';

class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  quizJson quiz;
  List<Results> results;

  Future<void> fetchQuestions() async {
    var url = "https://opentdb.com/api.php?amount=20";
    var res = await http.get(url);
    var decodeRes = jsonDecode(res.body);
    print(decodeRes);
    quiz = quizJson.fromJson(decodeRes);
    results = quiz.results;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("QuizzyFy")),
        elevation: 0.0,
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.home),
        onPressed: () {},
      ),
      body: RefreshIndicator(
        onRefresh: fetchQuestions,
        child: FutureBuilder(
          future: fetchQuestions(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return Text("Press button to start");
              case ConnectionState.active:
              case ConnectionState.waiting:
                return Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.white,
                  ),
                );
              case ConnectionState.done:
                if (snapshot.hasError) {
                  return error();
                } else {
                  return questionList();
                }
                return null;
            }
          },
        ),
      ),
    );
  }

  Padding error() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Try Again after connecting to the internet"),
          SizedBox(height: 30.0),
          RaisedButton(
            onPressed: () {
              fetchQuestions();
              setState(() {});
            },
            child: Text("Try Again!"),
          )
        ],
      ),
    );
  }

  ListView questionList() {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) => Card(
        color: Colors.black45,
        elevation: 1.0,
        child: ExpansionTile(
          title: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                results[index].question,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              FittedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FilterChip(
                      backgroundColor: Colors.black87,
                      label: Text(results[index].category),
                      onSelected: (b) {},
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    FilterChip(
                      backgroundColor: Colors.black87,
                      label: Text(results[index].difficulty),
                      onSelected: (b) {},
                    ),
                  ],
                ),
              ),
            ],
          ),
          leading: CircleAvatar(
            backgroundColor: Colors.white,
            child: Text(
              "Q",
              style: TextStyle(
                fontSize: 10.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          children: results[index].allAnswers.map((ans) {
            return AnswerWidget(results, index, ans);
          }).toList(),
        ),
      ),
    );
  }
}

class AnswerWidget extends StatefulWidget {
  final List<Results> results;
  final int index;
  final String ans;

  AnswerWidget(this.results, this.index, this.ans);

  @override
  _AnswerWidgetState createState() => _AnswerWidgetState();
}

class _AnswerWidgetState extends State<AnswerWidget> {
  Color ans = Colors.white;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        setState(() {
          if (widget.ans == widget.results[widget.index].correctAnswer) {
            ans = Colors.green;
          } else {
            ans = Colors.red;
          }
        });
      },
      title: Text(
        widget.ans,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: ans,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
