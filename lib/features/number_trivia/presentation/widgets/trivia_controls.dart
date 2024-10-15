import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:number_trivia_app/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:number_trivia_app/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';

class TriviaControls extends StatefulWidget {
  const TriviaControls({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => TriviaControlsState();
}

class TriviaControlsState extends State<TriviaControls> {
  final controller = TextEditingController();
  String? inputStr;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Input a Number',
          ),
          onChanged: (value) {
            inputStr = value;
          },
          onSubmitted: (_) {
            dispatchConcrete();
          },
        ),
        SizedBox(
          height: 10.0,
        ),
        Row(
          children: [
            Expanded(
                child: ElevatedButton(
              child: Text('Search'),
              onPressed: dispatchConcrete,
            )),
            SizedBox(
              width: 20.0,
            ),
            Expanded(
                child: ElevatedButton(
              child: Text('GetRandomNumberTrivia'),
              onPressed: dispatchRandom,
            )),
          ],
        )
      ],
    );
  }

  void dispatchConcrete() {
    controller.clear();
    if (inputStr != null) {
      BlocProvider.of<NumberTriviaBloc>(context)
          .add(GetTriviaForConcreteNumber(inputStr!));
    } else {
      BlocProvider.of<NumberTriviaBloc>(context)
          .emit(Error(message: 'Text field is Empty'));
    }
  }

  void dispatchRandom() {
    controller.clear();
    BlocProvider.of<NumberTriviaBloc>(context).add(GetTriviaForRandomNumber());
  }
}
