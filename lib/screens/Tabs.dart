import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_browser/WebPageController.dart';
import 'package:web_browser/screens/WebPageScreen.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TabsScreen extends StatefulWidget {
  List<Uint8List?>allPagesImages=[];
  List<String>allPagesTitle=[];
  List<int>allPagesPermanentIndex=[];
  List<String>allPagesUrl=[];
  List<Uint8List?>allFavicons=[];
  int currentPageNum=0;
  TabsScreen({Key? key}) : super(key: key);

  @override
  State<TabsScreen> createState() => _TabsState();
}





class _TabsState extends State<TabsScreen> {
  List<Color?>colorPallete=[Colors.purple[100],Colors.purple[50],Colors.red[100],Colors.red[50],Colors.cyan[100],Colors.deepOrange[200],Colors.orange[50],Colors.brown[100],Colors.brown[200]];
  Random random = Random();
  late WebPageController provider;
  GlobalKey<AnimatedListState>animatedListGlobalKey=GlobalKey();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    provider=Provider.of<WebPageController>(context,listen: false);
    widget.allPagesImages=[];
    widget.allPagesUrl=[];
    widget.allPagesPermanentIndex=[];
    widget.allPagesTitle=[];
    widget.allFavicons=[];

    provider.webPageScreens.forEach((element) {
      widget.allPagesImages.add(element.screenshot);
      widget.allPagesUrl.add(element.currentUrl);
      widget.allPagesPermanentIndex.add(element.permanentIndexIdentifier??provider.getPermanentPageIndex());
      widget.allPagesTitle.add(element.pageTitle);
      widget.allFavicons.add(element.favicon);


    });
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
          backgroundColor:Colors.transparent,

          automaticallyImplyLeading: false,
          actions: [
        PopupMenuButton(
            onSelected: (num)async{
              if(num==0){
                provider.clearAllTabs();

                Navigator.pop(context);
              }
            },
            itemBuilder: (_)=>[
          PopupMenuItem<int>(child: Text("Clear Tabs"),value: 0),

        ]
            ),
      ]),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: (){
          Navigator.pop(context,[1]);//1 signifies add another tab
        },
        tooltip:"Add Tab",
      ),
      backgroundColor:Colors.white70,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
      key: animatedListGlobalKey,
      physics: BouncingScrollPhysics(),
      itemCount:provider.webPageScreens.length,
      itemBuilder: (context,index)=>listBuilderPageItems(index)

          ),
          ),


            ],

            ),
    );
  }
   List <Widget>scrollWheelItems(List<String> url){
        List<Widget>tabPages=[];
        url.forEach((element) {
          tabPages.add(GestureDetector(
            onTap:(){},
            child: Container(
              margin: EdgeInsets.fromLTRB(10, 0, 10,0),
              child: Column(
                children: [
                  Expanded(child: WebView(initialUrl:element,))
                ],
              ),

            ),
          ));
        });
        return tabPages;
   }





   Widget listBuilderPageItems(int index){




      return Dismissible(
        key: ValueKey(widget.allPagesPermanentIndex.elementAt(index)),
        onDismissed: (direction)async{
            deleteWebpage(index);


        },
        child: GestureDetector(
          onTap:(){
            Navigator.pop(context,[true,index]);


          },
          child: Container(
            height: 300,

            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top:Radius.circular(20),bottom: Radius.circular(20)),
              color: Colors.white,

            ),
            width: double.infinity,
            margin: EdgeInsets.fromLTRB(20, 0, 20,10),
            child: Column(
              children: [
                Container(
                    width:double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(top:Radius.circular(20),bottom: Radius.circular(20)),
                     // colorPallete[Random().nextInt(colorPallete.length)]
                      color:Colors.white,
                    ),
                    child: Row(

                      children: [
                        Container(
                            margin: EdgeInsets.fromLTRB(8, 0, 0, 0),

                            child:
                widget.allFavicons.elementAt(index)!=null?Image.memory(widget.allFavicons.elementAt(index)??Uint8List(0),height: 30,width: 30,fit: BoxFit.fill,)
                    :Image.asset("assets/images/google.png",width: 30,height: 30,fit:BoxFit.fill)),
                        Expanded(child: Container(
                            margin: EdgeInsets.fromLTRB(8, 0, 0, 0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,

                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${widget.allPagesUrl.elementAt(index)}",style:TextStyle(fontSize: 20), maxLines: 1,overflow: TextOverflow.ellipsis,),
                                SizedBox(height: 8,),
                                Text("${widget.allPagesTitle.elementAt(index)}",style:TextStyle(fontSize: 16), maxLines: 1,overflow: TextOverflow.ellipsis,),
                              ],
                            ))),


                                   SizedBox(width:40,height:40,child: IconButton(onPressed:()async{deleteWebpage(index);}, icon: Image.asset("assets/images/cancel.png")))
                      ],
                    )),
               //Expanded(child: image),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(top:Radius.circular(0),bottom: Radius.circular(20)),
                    ),
                    child:widget.allPagesImages.elementAt(index)!=null ? ClipRRect(
                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20),bottomRight: Radius.circular(20)),
                        child: Image.memory(widget.allPagesImages.elementAt(index)??Uint8List(0),width:double.infinity,fit: BoxFit.cover,)):Container(),

                     ),
                  ),

              ],
            ),

          ),
        ),
      );

  }
  void deleteWebpage(int index){
    if(provider.webPageScreens.length==1){
      //animatedListGlobalKey.currentState?.removeItem(index, (context, animation) => listBuilderPageItems(index,animation));
      provider.deleteWebPage(widget.allPagesPermanentIndex.elementAt(index));
      Navigator.pop(context,[0]);
    }
    else{
     // animatedListGlobalKey.currentState?.removeItem(index, (context, animation) => listBuilderPageItems(index,animation));

      provider.deleteWebPage(widget.allPagesPermanentIndex.elementAt(index));
      setState(() {});
    }
  }
}
