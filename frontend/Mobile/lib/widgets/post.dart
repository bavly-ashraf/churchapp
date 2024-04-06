import 'package:flutter/material.dart';

class Post extends StatefulWidget{
  const Post({super.key, required this.body, this.attachments});
  
  final String body;
  final List<String>? attachments;

  @override
  State<Post> createState() => _PostState(); 
}

class _PostState extends State<Post>{
  
  @override
  Widget build(BuildContext context) {
    const TextStyle txtStyle = TextStyle(fontSize: 10);

    return(
      Card(
              child: Column(
                children: <Widget>[
                  Text(
                    widget.body,
                    style: const TextStyle(fontSize: 20),
                  ),
                  widget.attachments != null && widget.attachments!.isNotEmpty?
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: Row(
                        textDirection: TextDirection.rtl,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Image.asset(
                            widget.attachments![0],
                            width: 100,
                          ),
                        ]),
                  ): Container(),
                  const Divider(
                    indent: 10,
                    endIndent: 10,
                  ),
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: Row(
                          textDirection: TextDirection.rtl,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            ElevatedButton.icon(
                                onPressed: () => 0,
                                icon: const Icon(Icons.thumb_up_outlined),
                                label: const Text(
                                  'عجبني',
                                  style: txtStyle,
                                )),
                            const SizedBox(width: 10),
                            ElevatedButton.icon(
                                onPressed: () => 0,
                                icon:
                                    const Icon(Icons.favorite_border_outlined),
                                label: const Text(
                                  'عجبني اوي',
                                  style: txtStyle,
                                )),
                            const SizedBox(width: 10),
                            ElevatedButton.icon(
                                onPressed: () => 0,
                                icon: const Icon(Icons.thumb_down_outlined),
                                label: const Text(
                                  'معجبنيش',
                                  style: txtStyle,
                                )),
                            const SizedBox(width: 10),
                            ElevatedButton.icon(
                                onPressed: () => 0,
                                icon: const Icon(Icons.heart_broken_outlined),
                                label: const Text(
                                  'حزين',
                                  style: txtStyle,
                                )),
                          ],
                        )),
                  ),
                  const Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 0))
                ],
              ),
            )
    );
  }
}