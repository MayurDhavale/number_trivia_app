import 'package:flutter_test/flutter_test.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:number_trivia_app/core/network/network_info.dart';

import 'network_info_test.mocks.dart';

@GenerateMocks([InternetConnectionChecker])
void main() {
  late NetworkInfoImpl networkInfoImpl;
  late MockInternetConnectionChecker mockInternetConnectionChecker;

  setUp(() {
    mockInternetConnectionChecker = MockInternetConnectionChecker();
    networkInfoImpl = NetworkInfoImpl(
        internetConnectionChecker: mockInternetConnectionChecker);
  });

  group('isConnected', () {
    test(
      "should forward the call to InternetConnectionChecker.hasConnection",
      () async {
        //arrange
        final tHasConnection = Future.value(true);
        when(mockInternetConnectionChecker.hasConnection)
            .thenAnswer((_) => tHasConnection);

        //act
        final result = networkInfoImpl.isConnected;

        //assert
        verify(mockInternetConnectionChecker.hasConnection);
        expect(result, tHasConnection);
      },
    );
  });
}
