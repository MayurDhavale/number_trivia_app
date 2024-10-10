import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:number_trivia_app/core/error/exceptions.dart';
import 'package:number_trivia_app/core/error/failures.dart';
import 'package:number_trivia_app/core/network/network_info.dart';
import 'package:number_trivia_app/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:number_trivia_app/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:number_trivia_app/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:number_trivia_app/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:number_trivia_app/features/number_trivia/domain/entities/number_trivia.dart';

import 'number)_trivia_repository_impl_test.mocks.dart';

@GenerateMocks(
    [NumberTriviaRemoteDataSource, NumberTriviaLocalDataSource, NetworkInfo])
void main() {
  late NumberTriviaRepositoryImpl repositoryImpl;
  late MockNumberTriviaRemoteDataSource mockNumberTriviaRemoteDataSource;
  late MockNumberTriviaLocalDataSource mockNumberTriviaLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockNumberTriviaRemoteDataSource = MockNumberTriviaRemoteDataSource();
    mockNumberTriviaLocalDataSource = MockNumberTriviaLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repositoryImpl = NumberTriviaRepositoryImpl(
        remoteDataSource: mockNumberTriviaRemoteDataSource,
        localDataSource: mockNumberTriviaLocalDataSource,
        networkInfo: mockNetworkInfo);
  });

  void runTestOnline(Function body) {
    group('device is online', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });
      body();
    });
  }

  void runTestOffline(Function body) {
    group('device is offline', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });
      body();
    });
  }

  group('getConcreteNumberTrivia', () {
    const tNumber = 1;
    final tNumberTriviaModel =
        NumberTriviaModel(number: tNumber, text: 'test trivia');
    final NumberTrivia tNumberTrivia = tNumberTriviaModel;

    test(
      "should check if the device is online",
      () {
        //arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(mockNumberTriviaRemoteDataSource.getConcreteNumberTrivia(any))
            .thenAnswer((_) async => tNumberTriviaModel);
        //act
        repositoryImpl.getConcreteNumberTrivia(tNumber);

        //assert
        verify(mockNetworkInfo.isConnected);
      },
    );

    runTestOnline(() {
      test(
        "should return remote data when the call to the remote data source is sucessful",
        () async {
          //arrange
          when(mockNumberTriviaRemoteDataSource
                  .getConcreteNumberTrivia(tNumber))
              .thenAnswer((_) async => tNumberTriviaModel);

          //act
          final result = await repositoryImpl.getConcreteNumberTrivia(tNumber);

          //assert
          verify(mockNumberTriviaRemoteDataSource
              .getConcreteNumberTrivia(tNumber));

          expect(result, Right(tNumberTrivia));
        },
      );

      test(
        "should cache the data locally when the remote data source is succesful",
        () async {
          //arrange
          when(mockNumberTriviaRemoteDataSource
                  .getConcreteNumberTrivia(tNumber))
              .thenAnswer((_) async => tNumberTriviaModel);

          //act
          await repositoryImpl.getConcreteNumberTrivia(tNumber);

          //assert
          verify(mockNumberTriviaRemoteDataSource
              .getConcreteNumberTrivia(tNumber));
          verify(mockNumberTriviaLocalDataSource
              .cacheNumberTrivia(tNumberTriviaModel));
        },
      );

      test(
        "should return server failure when the call to the remote data source is unsucessful",
        () async {
          //arrange
          when(mockNumberTriviaRemoteDataSource
                  .getConcreteNumberTrivia(tNumber))
              .thenThrow(ServerException());

          //act
          final result = await repositoryImpl.getConcreteNumberTrivia(tNumber);

          //assert
          verify(mockNumberTriviaRemoteDataSource
              .getConcreteNumberTrivia(tNumber));
          verifyZeroInteractions(mockNumberTriviaLocalDataSource);
          expect(result, Left(ServerFailure()));
        },
      );
    });

    runTestOffline(() {
      test(
        "should return last locally cached data when the cached data is present",
        () async {
          //arrange
          when(mockNumberTriviaLocalDataSource.getLastNumberTrivia())
              .thenAnswer((_) async => tNumberTriviaModel);

          //act
          final result = await repositoryImpl.getConcreteNumberTrivia(tNumber);

          //assert
          verifyZeroInteractions(mockNumberTriviaRemoteDataSource);
          verify(mockNumberTriviaLocalDataSource.getLastNumberTrivia());
          expect(result, Right(tNumberTrivia));
        },
      );

      test(
        "should return Cachefailure when there is no cache data present",
        () async {
          //arrange
          when(mockNumberTriviaLocalDataSource.getLastNumberTrivia())
              .thenThrow(CacheException());

          //act
          final result = await repositoryImpl.getConcreteNumberTrivia(tNumber);

          //assert
          verifyZeroInteractions(mockNumberTriviaRemoteDataSource);
          verify(mockNumberTriviaLocalDataSource.getLastNumberTrivia());
          expect(result, Left(CacheFailure()));
        },
      );
    });
  });

  group('getRandomNumberTrivia', () {
    final tNumberTriviaModel =
        const NumberTriviaModel(number: 123, text: 'test trivia');

    final NumberTrivia tNumberTrivia = tNumberTriviaModel;

    test(
      "should check device is online",
      () async {
        //arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(mockNumberTriviaRemoteDataSource.getRandomNumberTrivia())
            .thenAnswer((_) async => tNumberTriviaModel);
        //act
        final result = await repositoryImpl.getRandomNumberTrivia();

        //assert
        verify(mockNetworkInfo.isConnected);
      },
    );
    runTestOnline(() {
      test(
        "should return remote data when the call to the remote data source is sucessful",
        () async {
          //arrange
          when(mockNumberTriviaRemoteDataSource.getRandomNumberTrivia())
              .thenAnswer((_) async => tNumberTriviaModel);

          //act
          final result = await repositoryImpl.getRandomNumberTrivia();

          //assert
          verify(mockNumberTriviaRemoteDataSource.getRandomNumberTrivia());

          expect(result, Right(tNumberTrivia));
        },
      );

      test(
        "should cache the data locally when the remote data source is succesful",
        () async {
          //arrange
          when(mockNumberTriviaRemoteDataSource.getRandomNumberTrivia())
              .thenAnswer((_) async => tNumberTriviaModel);

          //act
          await repositoryImpl.getRandomNumberTrivia();

          //assert
          verify(mockNumberTriviaRemoteDataSource.getRandomNumberTrivia());
          verify(mockNumberTriviaLocalDataSource
              .cacheNumberTrivia(tNumberTriviaModel));
        },
      );

      test(
        "should return server failure when the call to the remote data source is unsucessful",
        () async {
          //arrange
          when(mockNumberTriviaRemoteDataSource.getRandomNumberTrivia())
              .thenThrow(ServerException());

          //act
          final result = await repositoryImpl.getRandomNumberTrivia();

          //assert
          verify(mockNumberTriviaRemoteDataSource.getRandomNumberTrivia());
          verifyZeroInteractions(mockNumberTriviaLocalDataSource);
          expect(result, Left(ServerFailure()));
        },
      );
    });

    runTestOffline(() {
      test(
        "should return last locally cached data when the cached data is present",
        () async {
          //arrange
          when(mockNumberTriviaLocalDataSource.getLastNumberTrivia())
              .thenAnswer((_) async => tNumberTriviaModel);

          //act
          final result = await repositoryImpl.getRandomNumberTrivia();

          //assert
          verifyZeroInteractions(mockNumberTriviaRemoteDataSource);
          verify(mockNumberTriviaLocalDataSource.getLastNumberTrivia());
          expect(result, Right(tNumberTrivia));
        },
      );

      test(
        "should return Cachefailure when there is no cache data present",
        () async {
          //arrange
          when(mockNumberTriviaLocalDataSource.getLastNumberTrivia())
              .thenThrow(CacheException());

          //act
          final result = await repositoryImpl.getRandomNumberTrivia();

          //assert
          verifyZeroInteractions(mockNumberTriviaRemoteDataSource);
          verify(mockNumberTriviaLocalDataSource.getLastNumberTrivia());
          expect(result, Left(CacheFailure()));
        },
      );
    });
  });
}
