import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:number_trivia_app/core/error/exceptions.dart';

import '../models/number_trivia_model.dart';

abstract class NumberTriviaRemoteDataSource {
  Future<NumberTriviaModel> getConcreteNumberTrivia(int number);
  Future<NumberTriviaModel> getRandomNumberTrivia();
}

class NumberTriviaRemoteDataSourceImpl implements NumberTriviaRemoteDataSource {
  final http.Client client;

  NumberTriviaRemoteDataSourceImpl({required this.client});

  @override
  Future<NumberTriviaModel> getConcreteNumberTrivia(int number) async {
    // TODO: implement getConcreteNumberTrivia
    final response = await client.get(
        Uri.parse('http://numbersapi.com/$number'),
        headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      return NumberTriviaModel.fromJson(json.decode(response
          .body)); //Future.value(NumberTriviaModel(number: 1, text: 'text'));
    } else {
      throw ServerException();
    }
  }

  @override
  Future<NumberTriviaModel> getRandomNumberTrivia() async {
    final response = await client.get(Uri.parse('http://numbersapi.com/random'),
        headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      return NumberTriviaModel.fromJson(json.decode(response
          .body)); //Future.value(NumberTriviaModel(number: 1, text: 'text'));
    } else {
      throw ServerException();
    }
  }

  Future<NumberTriviaModel> _getTriviaFromUrl(String url) async {
    final response = await client.get(Uri.parse('http://numbersapi.com/random'),
        headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      return NumberTriviaModel.fromJson(json.decode(response
          .body)); //Future.value(NumberTriviaModel(number: 1, text: 'text'));
    } else {
      throw ServerException();
    }
  }
}
