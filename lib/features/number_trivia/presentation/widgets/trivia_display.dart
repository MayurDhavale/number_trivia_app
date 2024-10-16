import 'package:flutter/widgets.dart';
import 'package:number_trivia_app/features/number_trivia/domain/entities/number_trivia.dart';

class TriviaDisplay extends StatelessWidget {
  final NumberTrivia numberTrivia;

  
  
  const TriviaDisplay({Key?  key, required this.numberTrivia}):super(key:  key);

  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height/3,
      child: Column(children: [
        Text(
          numberTrivia.number.toString(),
          style: TextStyle(fontSize: 50.0, fontWeight: FontWeight.bold),

        ),
       // Expanded(child: Center(child: SingleChildScrollView(child: ,),))
      ],),
    );
  }
}
