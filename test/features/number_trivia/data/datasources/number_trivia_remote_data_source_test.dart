import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
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

  group('getConcreteNumberTrivia', () {
    const tNumber = 1;
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));

    test(
      '''should perform a GET request on a URL with 
      number being the endpoint and with application/json header''',
      () async {
        //arrange
        when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
            (_) async => http.Response(fixture('trivia.json'), 200));

        //act
        remoteDataSourceImpl.getConcreteNumberTrivia(tNumber);
        //assert
        verify(mockClient.get(
          Uri.parse('http://numbersapi.com/$tNumber'),
          headers: {
            'Content-Type': 'application/json',
          },
        ));
      },
    );

    test(
      "should return NumberTrivia when response code is 200 is sucess ",
      () async {
        //arrange
        when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
            (_) async => http.Response(fixture('trivia.json'), 200));

        //act
        final result =
            await remoteDataSourceImpl.getConcreteNumberTrivia(tNumber);

        //assert
        expect(result, tNumberTriviaModel);
      },
    );
  });
}
