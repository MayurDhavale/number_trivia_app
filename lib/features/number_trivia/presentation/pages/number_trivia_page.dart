import 'package:flutter/material.dart';
import 'package:number_trivia_app/features/number_trivia/presentation/widgets/trivia_controls.dart';
import 'package:number_trivia_app/features/number_trivia/presentation/widgets/trivia_display.dart';
import '../bloc/number_trivia_bloc.dart';
import '../widgets/loading_widget.dart';
import '../widgets/message_display.dart';
import '../../../../injection_container.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NumberTriviaPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Number trivia'),
      ),
      body: SingleChildScrollView(child: buildBody(context)),
    );
  }

  BlocProvider<NumberTriviaBloc> buildBody(BuildContext context) {
    return BlocProvider(
        create: (_) => sl<NumberTriviaBloc>(),
        child: Center(
          child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  const SizedBox(
                    height: 10.0,
                  ),
                  BlocBuilder<NumberTriviaBloc, NumberTriviaState>(
                      builder: (context, state) {
                    if (state is Empty) {
                      return MessageDisplay(
                        message: 'Start Searching',
                      );
                    } else if (state is Error) {
                      return MessageDisplay(message: state.message);
                    } else if (state is Loading) {
                      return LoadingWidget();
                    } else if (state is Loaded) {
                      return TriviaDisplay(numberTrivia: state.numberTrivia,);
                    }
                    return Container();
                  }),
                  const SizedBox(
                    height: 20.0,
                  ),
                  TriviaControls(),
                ],
              )),
        ));
  }
}
