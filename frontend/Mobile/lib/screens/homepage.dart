import 'package:church/screens/announcements.dart';
import 'package:church/screens/halls.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class Homepage extends StatefulWidget{
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _Homepage();

}

class _Homepage extends State<Homepage> with SingleTickerProviderStateMixin {


  late TabController controller = TabController(length: 2, vsync: this); 



  @override
  Widget build(BuildContext context) {

    void _onExit(bool didpop, BuildContext context) {
    showDialog(context: context, builder: (BuildContext context) {
      return Directionality(
      textDirection: TextDirection.rtl,
      child:AlertDialog(
        title: const Text('خروج'),
        content: const Text('متاكد انك عايز تخرج؟'),
        actions: <Widget>[
          TextButton(onPressed: ()=> SystemChannels.platform.invokeMethod('SystemNavigator.pop'), child: const Text('اه')),
          TextButton(onPressed: ()=> Navigator.pop(context), child: const Text('لا'))
        ],
        )
        );
    });
  }

  void _Logout() {
    showDialog(context: context, builder: (BuildContext context){
      return Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
        title: const Text('تسجيل خروج'),
        content: const Text('متاكد انك عايز تسجل خروج؟'),
        actions: <Widget>[
          TextButton(onPressed: (){
            //don't forget to remove token from shared preferences
            // Navigator.popUntil(context, ModalRoute.withName('/'));
          } , child: const Text('اه')),
          TextButton(onPressed: ()=> Navigator.pop(context), child: const Text('لا'))
        ],
        )
        );
    });
  }
    

    return 
      PopScope(
      canPop: false,
      onPopInvoked: (didPop) => _onExit(didPop, context),
      child: Scaffold(
      appBar: AppBar(
          title: const Text('ازيك يا يوزر'),
          centerTitle: true,
          automaticallyImplyLeading: false,
          actions: <Widget>[
            IconButton(onPressed: _Logout, icon: const Icon(Icons.logout)),
            const SizedBox(width: 10),
          ],
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        bottomNavigationBar: Material(
          child: TabBar(
            tabs: const <Tab>[
              Tab(
                icon: Icon(Icons.home),
                text: 'التنبيهات',
              ),
              Tab(
                icon: Icon(Icons.lock_clock),
                text: 'حجز القاعات',
              ),
            ],
            controller: controller,
            ),
        ),
        body: TabBarView(
          controller: controller,
          children: <Widget>[const Announcements(), Halls()],
        )
        ));
  }
}
