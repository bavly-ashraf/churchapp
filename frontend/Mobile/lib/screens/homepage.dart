import 'package:church/widgets/post.dart';
import 'package:flutter/material.dart';

class Homepage extends StatelessWidget {
  Homepage({super.key});

  final List<String> body = ['اي كلام للتجربة', 'تاني بوست'];
  final List<String> attachments = ['assets/church_logo.png'];

  void _onExit(bool didpop) {
    if (didpop) {
      const AlertDialog(title: Text('عايز اخرج'));
    } else {
      const AlertDialog(title: Text('مش عايز اخرج'));
    }
  }

  @override
  Widget build(BuildContext context) {

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) => _onExit(didPop),
      child: (Scaffold(
        appBar: AppBar(
          title: const Text('ازيك يا يوزر'),
          centerTitle: true,
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
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
      )),
    );
  }
}
