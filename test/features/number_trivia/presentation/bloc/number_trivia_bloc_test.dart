
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:number_trivia_app/core/util/input_convert.dart';
import 'package:number_trivia_app/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:number_trivia_app/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:number_trivia_app/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:number_trivia_app/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';

import 'number_trivia_bloc_test.mocks.dart';

@GenerateMocks([GetConcreteNumberTrivia,GetRandomNumberTrivia,InputConverter])
void main(){
late NumberTriviaBloc bloc;
  late MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  late MockGetRandomNumberTrivia
  mockGetRandomNumberTrivia;

  late MockInputConverter mockInputConverter;

  setUp((){
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();

    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    mockInputConverter = MockInputConverter();

    bloc = NumberTriviaBloc(getConcreteNumberTrivia : mockGetConcreteNumberTrivia,
    getRandomNumberTrivia : mockGetRandomNumberTrivia,
    inputConverter : mockInputConverter
    );
  });

   test('initial state should be empty', 
  () async {
      //assert
      expect(bloc.state, Empty());
  });

   group('getTriviaForConcreteNumber', (){
      final tNumberString = '1';

      final tNumberParsed = int.parse(tNumberString);

      final tNumberTrivia = NumberTrivia(text: 'test trivia', number: tNumberParsed);

      test("should call the inputconverter to validate and convert the string to an unsigned int",
      () async {
        //arrange 
        when(mockInputConverter.stringToUnsignedInteger(any)).thenReturn(Right(tNumberParsed));

        //act
        bloc.add(GetTriviaForConcreteNumber(tNumberString));
        await untilCalled(mockInputConverter.stringToUnsignedInteger(any));

        //assert
        verify(mockInputConverter.stringToUnsignedInteger(tNumberString));

      }
      );
  });

}