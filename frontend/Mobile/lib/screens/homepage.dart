import 'package:church/screens/announcements.dart';
import 'package:church/screens/halls.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _Homepage();
}

class _Homepage extends State<Homepage> with SingleTickerProviderStateMixin {
  late TabController controller = TabController(length: 2, vsync: this);
  // check user role (user || admin)
  bool showFab = 'userRole'.isEmpty? false: true;

  Future<void> createNew() {
    switch (controller.index) {
      case 0:
        return showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return SizedBox(
                height: 600,
                child: Center(
                  child: createNewAnnouncement(),
                ),
              );
            });
      case 1:
        return showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return const SizedBox(
                height: 200,
                child: Center(
                  child: Column(children: <Widget>[Text('new hall')]),
                ),
              );
            });
    }
    throw const FormatException('Error: modal not found');
  }

  Widget createNewAnnouncement(){
    return const Padding(
      padding: EdgeInsets.all(10),
      child: Column(
          children: <Widget>[
            Text('new announcement'),
            Text('test'),
            
          ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    void onExit(bool didpop, BuildContext context) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return Directionality(
                textDirection: TextDirection.rtl,
                child: AlertDialog(
                  title: const Text('خروج'),
                  content: const Text('متاكد انك عايز تخرج؟'),
                  actions: <Widget>[
                    TextButton(
                        onPressed: () => SystemChannels.platform
                            .invokeMethod('SystemNavigator.pop'),
                        child: const Text('اه')),
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('لا'))
                  ],
                ));
          });
    }

    void logout() {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return Directionality(
                textDirection: TextDirection.rtl,
                child: AlertDialog(
                  title: const Text('تسجيل خروج'),
                  content: const Text('متاكد انك عايز تسجل خروج؟'),
                  actions: <Widget>[
                    TextButton(
                        onPressed: () {
                          //don't forget to remove token from shared preferences
                          // Navigator.popUntil(context, ModalRoute.withName('/'));
                        },
                        child: const Text('اه')),
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('لا'))
                  ],
                ));
          });
    }

    return PopScope(
        canPop: false,
        onPopInvoked: (didPop) => onExit(didPop, context),
        child: Scaffold(
            appBar: AppBar(
              title: const Text('ازيك يا يوزر'),
              centerTitle: true,
              automaticallyImplyLeading: false,
              actions: <Widget>[
                IconButton(onPressed: logout, icon: const Icon(Icons.logout)),
                const SizedBox(width: 10),
              ],
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            ),
            // don't forget to show it for admins only!
            floatingActionButton: showFab?
            FloatingActionButton(
              onPressed: createNew,
              shape: const CircleBorder(),
              child: const Icon(Icons.add),
            ) : null,
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
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
            )));
  }
}
