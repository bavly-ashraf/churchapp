import 'package:church/widgets/hall.dart';
import 'package:flutter/material.dart';

class Halls extends StatelessWidget{
     Halls({super.key});

    final List<String> hallNames = ['قاعة 1', 'قاعة 2','قاعة 3','قاعة 4','قاعة 5','قاعة 6','قاعة 7'];

    @override
    Widget build(BuildContext context){
      return Scaffold(
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: (
            GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
            itemCount: hallNames.length,
            itemBuilder: (context , index)=> Hall(hallName: hallNames[index])
            )
          ),
        ),
      );
    }
}