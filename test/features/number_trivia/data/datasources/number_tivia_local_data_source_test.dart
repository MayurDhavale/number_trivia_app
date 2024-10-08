import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:number_trivia_app/core/error/exceptions.dart';
import 'package:number_trivia_app/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:number_trivia_app/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../fixtures/fixture_reader.dart';
import 'number_tivia_local_data_source_test.mocks.dart';

@GenerateMocks([SharedPreferences])
void main() {
  late NumberTriviaLocalDataSourceImpl dataSourceImpl;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    dataSourceImpl = NumberTriviaLocalDataSourceImpl(
        sharedPreferences: mockSharedPreferences);
  });

  group('getLastNumberTrivia', () {
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia_cached.json')));
    final cacheKey = "CACHED_NUMBER_TRIVIA";
    test(
      "should return numberTrivia from SharedPreferences when there is one in the cache ",
      () async {
        //arrange
        when(mockSharedPreferences.getString(any))
            .thenReturn(fixture('trivia_cached.json'));

        //act
        final result = await dataSourceImpl.getLastNumberTrivia();

        //assert
        verify(mockSharedPreferences.getString(cacheKey));
        expect(result, tNumberTriviaModel);
        expect(cacheKey, CACHED_NUMBER_TRIVIA);
      },
    );

    test(
      "should throw a CacheException when there is a not a cached value",
      () async {
        //arrange
        when(mockSharedPreferences.getString(any)).thenReturn(null);

        //act
        final call = dataSourceImpl.getLastNumberTrivia;

        //assert
        expect(() => call(), throwsA(TypeMatcher<CacheException>()));
      },
    );
  });

  group('cacheNumberTrivia', () {
    final tNumberTriviaModel =
        NumberTriviaModel(number: 1, text: 'test trivia');

    test(
      "should call SharedPrefrences to cache the data",
      () async {
        //arrange
        when(mockSharedPreferences.setString(any, any))
            .thenAnswer((_) async => true);

        //act
        dataSourceImpl.cacheNumberTrivia(tNumberTriviaModel);

        //assert
        final expectedJsonString = json.encode(tNumberTriviaModel.toJson());
        verify(mockSharedPreferences.setString(
            CACHED_NUMBER_TRIVIA, expectedJsonString));
      },
    );
  });
}
