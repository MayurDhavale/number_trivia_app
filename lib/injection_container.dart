import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:number_trivia_app/core/network/network_info.dart';
import 'package:number_trivia_app/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:number_trivia_app/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:number_trivia_app/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:number_trivia_app/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/util/input_convert.dart';
import 'features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:http/http.dart' as http;

final sl = GetIt.instance;

Future<void> init() async{

  //! Features - number trivia
  //Bloc 
  sl.registerFactory(() => NumberTriviaBloc(getConcreteNumberTrivia: sl(), getRandomNumberTrivia: sl(), inputConverter: sl()) );

  //Usecases

  sl.registerLazySingleton(() => GetConcreteNumberTrivia(sl()));
  sl.registerLazySingleton(() => GetRandomNumberTrivia(repository:sl() ));
  
  //repository 
  sl.registerLazySingleton<NumberTriviaRepository>(() => NumberTriviaRepositoryImpl(remoteDataSource: sl(), localDataSource: sl(), networkInfo: sl()));
  // datasources
  sl.registerLazySingleton<NumberTriviaRemoteDataSource>(() => NumberTriviaRemoteDataSourceImpl(client: sl()));

  sl.registerLazySingleton<NumberTriviaLocalDataSource>(() => NumberTriviaLocalDataSourceImpl(sharedPreferences: sl()));
  //! core
  sl.registerLazySingleton(() =>InputConverter());

  sl.registerLazySingleton<NetworkInfo>(() =>NetworkInfoImpl(internetConnectionChecker: sl()));

  //!External Dependencies
  final sharedPrefrences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPrefrences);
  sl.registerLazySingleton(() =>http.Client());
  sl.registerLazySingleton(() => InternetConnectionChecker());
  


}