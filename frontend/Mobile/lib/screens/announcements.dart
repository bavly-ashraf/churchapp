import 'package:church/widgets/post.dart';
import 'package:flutter/material.dart';

class Announcements extends StatelessWidget{
  const Announcements({super.key});

  @override
  Widget build(BuildContext context){
      final List<String> body = ['اي كلام للتجربة', 'تاني بوست', 'بإسم الآب والابن والروح القدس اله واحد امين'];
      final List<String> attachments = ['assets/images/church_logo.png'];

    return(
    Scaffold(
        body: ListView.builder(
          itemCount: body.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: Post(
              body: body[index],
              attachments: attachments,
              )
            ),
        ),
      ));
  }
}