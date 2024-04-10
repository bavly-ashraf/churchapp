import 'package:church/widgets/post.dart';
import 'package:flutter/material.dart';

class Announcements extends StatelessWidget{
  const Announcements({super.key});

  @override
  Widget build(BuildContext context){
      final List<String> body = ['اي كلام للتجربة', 'تاني بوست'];
      final List<String> attachments = ['assets/church_logo.png'];

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
        // don't forget to show it for admins only!
        floatingActionButton: const FloatingActionButton(
          onPressed: null,
          shape: CircleBorder(),
          child: Icon(Icons.add),
          ),
        // bottomNavigationBar: BottomNavigationBar(
        //   items: const <BottomNavigationBarItem>[
        //     BottomNavigationBarItem(icon: Icon(Icons.home), label: 'التنبيهات'),
        //     BottomNavigationBarItem(icon: Icon(Icons.lock_clock), label: 'حجز القاعات'),
        //     BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'تسجيل خروج'),
        //     ],
        // ),
      ));
  }
}