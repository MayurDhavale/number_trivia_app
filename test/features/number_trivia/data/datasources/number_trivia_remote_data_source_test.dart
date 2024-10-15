import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:number_trivia_app/core/error/exceptions.dart';
import 'package:number_trivia_app/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:number_trivia_app/features/number_trivia/data/models/number_trivia_model.dart';

import '../../../../fixtures/fixture_reader.dart';
import 'number_trivia_remote_data_source_test.mocks.dart';

  @GenerateMocks([http.Client])

void main() {
  late NumberTriviaRemoteDataSourceImpl remoteDataSourceImpl;
  late MockClient mockClient;

  setUp(() {
    mockClient = MockClient();
    remoteDataSourceImpl = NumberTriviaRemoteDataSourceImpl(client: mockClient);
  });

  void setUpMockHttpClientSuccess200() {
     when(mockClient.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response(fixture('trivia.json'), 200));
  }

  void setUpMockHttpClientSuccess404() {
    when(mockClient.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response('something wrong', 404),);
  }

  group('getConcreteNumberTrivia', () {
    final tNumber = 1;
    final tNumberTriviaModel = NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));
    test(
      '''should perform a GET request on URL with number 
      being the endpoint and with application/json header''',
      () async {
        //arrange    
        setUpMockHttpClientSuccess200();
        //act
        remoteDataSourceImpl.getConcreteNumberTrivia(tNumber);
        //assert

        verify(mockClient.get(
        Uri.parse('http://numbersapi.com/$tNumber'),
        headers: {
          'Content-Type' : 'application/json'
        },
        ));
    
      },
    );
    test(
      "should return NumberTrivia when the response code is 200 (success)",
      () async {
        //arrange    
        setUpMockHttpClientSuccess200();
        //act
        final result = await remoteDataSourceImpl.getConcreteNumberTrivia(tNumber);
        //assert
        expect(result, tNumberTriviaModel);
      },
    );

    test(
      "should throw a ServerException when the response code is 404 or other",
      () async {
        //arrange    
        setUpMockHttpClientSuccess404();
        //act
        final call = remoteDataSourceImpl.getConcreteNumberTrivia(tNumber);
        //assert

        expect(call, throwsA(const TypeMatcher<ServerException>()));
    
      },
    );
  });

  group('getRandomNumberTrivia', () {
    final tNumberTriviaModel = NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));

    test(
      '''should perform a GET request on URL with *random* 
      being the endpoint and with application/json header''',
      () async {
        //arrange    
        setUpMockHttpClientSuccess200();
        //act
        remoteDataSourceImpl.getRandomNumberTrivia();
        //assert
        verify(mockClient.get(
        Uri.parse('http://numbersapi.com/random'),
        headers: {
          'Content-Type' : 'application/json'
        },
        ));
    
      },
    );
    test(
      "should return NumberTrivia when the response code is 200 (success)",
      () async {
        //arrange    
        setUpMockHttpClientSuccess200();
        //act
        final result = await remoteDataSourceImpl.getRandomNumberTrivia();
        //assert
        expect(result, tNumberTriviaModel);
      },
    );
    test(
      "should throw a ServerException when the response code is 404 or other",
      () async {
        //arrange    
        setUpMockHttpClientSuccess404();
        //act
        final call = remoteDataSourceImpl.getRandomNumberTrivia;
        //assert

        expect(call, throwsA(const TypeMatcher<ServerException>()));
    
      },
    );
  });
}