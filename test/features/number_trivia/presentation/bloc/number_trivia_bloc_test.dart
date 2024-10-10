import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:number_trivia_app/core/error/failures.dart';
import 'package:number_trivia_app/core/usecases/usecase.dart';
import 'package:number_trivia_app/core/util/input_convert.dart';
import 'package:number_trivia_app/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:number_trivia_app/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:number_trivia_app/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:number_trivia_app/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';

import 'number_trivia_bloc_test.mocks.dart';

@GenerateMocks([GetConcreteNumberTrivia, GetRandomNumberTrivia, InputConverter])
void main() {
  late NumberTriviaBloc bloc;
  late MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  late MockGetRandomNumberTrivia mockGetRandomNumberTrivia;

  late MockInputConverter mockInputConverter;

  setUp(() {
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();

    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    mockInputConverter = MockInputConverter();

    bloc = NumberTriviaBloc(
        getConcreteNumberTrivia: mockGetConcreteNumberTrivia,
        getRandomNumberTrivia: mockGetRandomNumberTrivia,
        inputConverter: mockInputConverter);
  });

  test('initial state should be empty', () async {
    //assert
    expect(bloc.state, Empty());
  });

  group('getTriviaForConcreteNumber', () {
    const tNumberString = '1';

    final tNumberParsed = int.parse(tNumberString);

    final tNumberTrivia =
        NumberTrivia(text: 'test trivia', number: tNumberParsed);

    void setUpMockInputConverterSucess() =>
        when(mockInputConverter.stringToUnsignedInteger(any))
            .thenReturn(Right(tNumberParsed));

    void setUpMockGetConcreteNumberTriviaSucess() =>
        when(mockGetConcreteNumberTrivia(any))
            .thenAnswer((_) async => Right(tNumberTrivia));
    

    test(
        "should call the inputconverter to validate and convert the string to an unsigned int",
        () async {
      //arrange
      setUpMockInputConverterSucess();
      when(mockGetConcreteNumberTrivia(any))
          .thenAnswer((_) async => Right(tNumberTrivia));

      //act
      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
      await untilCalled(mockInputConverter.stringToUnsignedInteger(any));

      //assert
      verify(mockInputConverter.stringToUnsignedInteger(tNumberString));
    });

    test(
      "should emit [Error] when input is invalid",
      () async {
        //arrange
        when(mockInputConverter.stringToUnsignedInteger(any))
            .thenReturn(Left(InvalidInputFailure()));

        //when(mockGetConcreteNumberTrivia(any))
        //   .thenAnswer((_) async => Right(tNumberTrivia));

        //assert later
        final expected = [const Error(message: INVALID_INPUT_FAILURE_MESSAGE)];

        expectLater(bloc.stream, emitsInOrder(expected));
        //act
        bloc.add(const GetTriviaForConcreteNumber(tNumberString));
      },
    );
    test(
      "should get data from the concrete use case",
      () async {
        //arrange
        setUpMockInputConverterSucess();
        setUpMockGetConcreteNumberTriviaSucess();

        //act
        bloc.add(const GetTriviaForConcreteNumber(tNumberString));
        await untilCalled(mockGetConcreteNumberTrivia(any));

        //assert
        verify(mockGetConcreteNumberTrivia(Params(number: tNumberParsed)));
      },
    );

    test(
      "should emit [Loading, Loaded] when data is gotten sucessfully",
      () async {
        //arrange
        setUpMockInputConverterSucess();
        setUpMockGetConcreteNumberTriviaSucess();
        //assert later
        final expected = [
          Loading(),
          Loaded(numberTrivia: tNumberTrivia),
        ];
        expectLater(bloc.stream, emitsInAnyOrder(expected));

        //act
        bloc.add(const GetTriviaForConcreteNumber(tNumberString));
      },
    );

    test(
      "should emit [Loading , Error] when getting data fails",
      () async {
        //arrange
        setUpMockInputConverterSucess();
        when(mockGetConcreteNumberTrivia(any))
            .thenAnswer((_) async => Left(ServerFailure()));

        //assert later

        final expected = [
          Loading(),
          const Error(message: SERVER_FAILURE_MESSAGE),
        ];
        expectLater(bloc.stream, emitsInAnyOrder(expected));

        //act
        bloc.add(const GetTriviaForConcreteNumber(tNumberString));
      },
    );

    test(
      "should emit [Loading, Error] with a proper message for the error when getting data fails",
      () async {
        //arrange
        setUpMockInputConverterSucess();
        when(mockGetConcreteNumberTrivia(any))
            .thenAnswer((_) async => Left(CacheFailure()));

        //assert later 
        
        final expected = [
          Loading(),
          const Error(message: CACHE_FAILURE_MESSAGE),
        ];
        expectLater(bloc.stream, emitsInAnyOrder(expected));

        //act
        bloc.add(const GetTriviaForConcreteNumber(tNumberString));

        
      },
    );
  });


  group('getRandomNumberTrivia',
  () {
    final tNumberTrivia =
        NumberTrivia(text: 'test trivia', number: 1);

        void setMockGetRandomNumberSucess() => when(mockGetRandomNumberTrivia(any)).thenAnswer((_) async => Right(tNumberTrivia));

  
  test(
      "should get data from the random use case",
      () async {
        //arrange
        when(mockGetRandomNumberTrivia(any)).thenAnswer((_) async => Right(tNumberTrivia));
     

        //act
        bloc.add(GetTriviaForRandomNumber());
        await untilCalled(mockGetRandomNumberTrivia(any));

        //assert
        verify(mockGetRandomNumberTrivia(NoPrams()));
      },
    );


    test(
      "should emit [Loading, Loaded] when data is gotten sucessfully",
      () async {
        //arrange
        setMockGetRandomNumberSucess();
        //assert later
        final expected = [
          Loading(),
          Loaded(numberTrivia: tNumberTrivia),
        ];
        expectLater(bloc.stream, emitsInAnyOrder(expected));

        //act
        bloc.add( GetTriviaForRandomNumber());
      },
    );


     test(
      "should emit [Loading , Error] when getting data fails",
      () async {
        //arrange
        setMockGetRandomNumberSucess();
        when(mockGetRandomNumberTrivia(any))
            .thenAnswer((_) async => Left(ServerFailure()));

        //assert later

        final expected = [
          Loading(),
          const Error(message: SERVER_FAILURE_MESSAGE),
        ];
        expectLater(bloc.stream, emitsInAnyOrder(expected));

        //act
        bloc.add( GetTriviaForRandomNumber());
      },
    );


        test(
      "should emit [Loading, Error] with a proper message for the error when getting data fails",
      () async {
        //arrange
        setMockGetRandomNumberSucess();
        when(mockGetRandomNumberTrivia(any))
            .thenAnswer((_) async => Left(CacheFailure()));

        //assert later 
        
        final expected = [
          Loading(),
          const Error(message: CACHE_FAILURE_MESSAGE),
        ];
        expectLater(bloc.stream, emitsInAnyOrder(expected));

        //act
        bloc.add(GetTriviaForRandomNumber());

        
      },
    );
  
  });
  
}
