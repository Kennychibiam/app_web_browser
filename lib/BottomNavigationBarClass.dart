import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_browser/RouteGenerator.dart';
import 'package:web_browser/WebPageController.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BottomNavigationBarClass extends StatefulWidget {
  int ?numOfPages=0;
  int ?currentSelectedBottomNavView=0;
  WebViewController ? webViewController;
  BottomNavigationBarClass({Key? key}) : super(key: key);

  @override
  State<BottomNavigationBarClass> createState() => _BottomNavigationBarClassState();
}

class _BottomNavigationBarClassState extends State<BottomNavigationBarClass> {
  bool ?canGoBack=false;
  bool ?canGoForward=false;
  @override
  Widget build(BuildContext context) {

    var provider=Provider.of<WebPageController>(context,listen: false);
    widget.numOfPages=provider.webPageScreens.length;


    return BottomNavigationBar(
      onTap: (index)async{

        widget.currentSelectedBottomNavView=index;
        switch(index){
          case 0:
            bool canGoBack=await provider.webPageScreens.first.webViewController.canGoBack();
            if(canGoBack) {
              await provider.webPageScreens.first.webViewController.goBack();
              // setState(() {
              //
              // });
            }else{


            }
            break;
          case 1:

            bool canGoForward=await provider.webPageScreens.first.webViewController.canGoForward();
            if(canGoForward) {
             await provider.webPageScreens.first.webViewController.goForward();
              // setState(() {
              //
              // });
            }

            break;
          case 2:
              showModalBottomSheet(

                isScrollControlled: true,
                  isDismissible: true,
                  shape: RoundedRectangleBorder(
                    borderRadius:BorderRadius.vertical(top:Radius.circular(20) ) ,
                  ),
                  context: context, builder: (builder)=>
                  Container(
                    height: 200,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(iconSize: 30,
                    icon: const ImageIcon(AssetImage("assets/images/history.png")),
                    color: Colors.black38,
                    onPressed: () {
                      Navigator.pop(context);

                      Navigator.pushNamed(context,RouteGenerator.webHistoryScreen);

                    },),
                  IconButton(iconSize: 40,
                    icon: Icon(Icons.refresh),
                    color: Colors.black38,
                    onPressed: () {
                      provider.webPageScreens.first.webViewController.reload();
                      Navigator.pop(context);
                    },),

                ],
              ),
                  ));
            break;

          case 3:




              dynamic resultFromTab=await Navigator.pushNamed(context, RouteGenerator.TabsPage);

              if(resultFromTab!=null && resultFromTab[0]==1){//added a new tab
                provider.addNewWebPage();
              }
              else if(resultFromTab!=null && resultFromTab[0]==0){//deleted all tabs
                //do nothing deleted all tabs
              }
              else if(resultFromTab!=null && resultFromTab[0]==true){//clicked on a tab
                provider.moveSelectedTabToFront(resultFromTab[1]);
              }


            break;

          case 4:
            provider.returnToHomePage();
            break;
        }

        },
      showUnselectedLabels:false,
      showSelectedLabels: false,
      unselectedItemColor:Colors.black38,
      selectedItemColor:Colors.black38,
      items:[

        BottomNavigationBarItem(
          label: "Back",
          tooltip: "Back",
          icon:provider.canGoBack ? Icon(Icons.arrow_back_ios ,color: Colors.blue,):Icon(Icons.arrow_back_ios),
        ),

        BottomNavigationBarItem(

          label: "Forward",
          tooltip: "Forward",
          icon:provider.canGoForward ? Icon(Icons.arrow_forward_ios ,color: Colors.blue,):Icon(Icons.arrow_forward_ios),
        ),
      BottomNavigationBarItem(
          label: "Home",
          tooltip: "Home",
          icon: ImageIcon(AssetImage("assets/images/nav_settings.png"))
      ),

        BottomNavigationBarItem(

          label: "Tab",
          tooltip: "Tab",
          icon: Stack(alignment:Alignment.center,children: [ImageIcon(AssetImage("assets/images/tab.png")),Text("${widget.numOfPages}"),]),
        ),
      BottomNavigationBarItem(
          label: "Settings",
          tooltip: "Settings",
          icon: ImageIcon(AssetImage("assets/images/home.png"))
      ),

    ],);
  }




}
