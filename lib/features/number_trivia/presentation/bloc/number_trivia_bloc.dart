import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:number_trivia_app/core/error/failures.dart';
import 'package:number_trivia_app/core/usecases/usecase.dart';
import 'package:number_trivia_app/core/util/input_convert.dart';
import 'package:number_trivia_app/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:number_trivia_app/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:number_trivia_app/features/number_trivia/domain/usecases/get_random_number_trivia.dart';

part 'number_trivia_event.dart';
part 'number_trivia_state.dart';

const String SERVER_FAILURE_MESSAGE = 'Server Failure';
const String CACHE_FAILURE_MESSAGE = 'Cache Failure';
const String INVALID_INPUT_FAILURE_MESSAGE =
    'Invalid Input-The number must be a positive or zero';

class NumberTriviaBloc extends Bloc<NumberTriviaEvent, NumberTriviaState> {
  final GetConcreteNumberTrivia getConcreteNumberTrivia;
  final GetRandomNumberTrivia getRandomNumberTrivia;
  final InputConverter inputConverter;
  NumberTriviaBloc(
      {required this.getConcreteNumberTrivia,
      required this.getRandomNumberTrivia,
      required this.inputConverter})
      : super(Empty()) {
    on<NumberTriviaEvent>((event, emit) async {
      if (event is GetTriviaForConcreteNumber) {
        final inputEither =
            inputConverter.stringToUnsignedInteger(event.numberString);
        inputEither.fold((failure) {
          emit(const Error(message: INVALID_INPUT_FAILURE_MESSAGE));
        }, (integer) async {
          emit(Loading());
          final failureOrTrivia =
              await getConcreteNumberTrivia(Params(number: integer));

          _eitherLoaderOrErrorState(failureOrTrivia);
        });
      }
    });

    on<GetTriviaForRandomNumber>((event, emit)async {
      emit(Loading());
      final failureOrTrivia =   await getRandomNumberTrivia(NoPrams());
      _eitherLoaderOrErrorState(failureOrTrivia);
    });
  }

  _eitherLoaderOrErrorState(Either<Failure, NumberTrivia>failureOrTrivia){

    failureOrTrivia.fold((failure) {
        emit(Error(message: _mapFailureToMessage(failure)));
      }, (trivia){
          emit(Loaded(numberTrivia: trivia));
      });

  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return SERVER_FAILURE_MESSAGE;
      case CacheFailure:
        return CACHE_FAILURE_MESSAGE;
      default:
        return 'Unexpected error';
    }
  }
}
