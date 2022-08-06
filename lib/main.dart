import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:web_browser/DatabaseClass.dart';
import 'package:web_browser/SaveWebPageModelClass.dart';
import 'package:web_browser/screens/WebPageScreen.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'RouteGenerator.dart';
import 'WebPageController.dart';
import 'BottomNavigationBarClass.dart';
import 'package:provider/provider.dart';

import 'WebPageController.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  List<SaveWebPageModelClass> saveWebPageModelClass=await DatabaseClass.instance.retrieveWebPagesTable(tableName: DatabaseClass.WEB_PAGES_SAVE_Table);
  //List<SaveWebPageModelClass> saveWebPageModelClass2=await DatabaseClass.instance.retrieveHistoryTable(tableName: DatabaseClass.HISTORY_TABLE);


  WebPageController webPageController=WebPageController();
 // print(saveWebPageModelClass.length.toString()+ " length of database");
  //print(saveWebPageModelClass2.length.toString()+ " length of history database");
  if(saveWebPageModelClass.length>0){
    webPageController.webPageScreens=[];
    String initialUrl="https://www.google.com";
    saveWebPageModelClass.forEach((element) {
      webPageController.webPageScreens.add(new WebPageScreen(isFromDatabase: true,));
      webPageController.webPageScreens.last.currentUrl=element.webPageUrl??initialUrl;
      webPageController.webPageScreens.last.pageTitle=element.webPageTitle??"Google";
      webPageController.webPageScreens.last.screenshot=element.webScreenshot;
      webPageController.webPageScreens.last.favicon=element.favicon;
      webPageController.webPageScreens.last.permanentIndexIdentifier=element.webPagePermanentIndex??webPageController.getPermanentPageIndex();


    });

  }

  runApp( ChangeNotifierProvider<WebPageController>(
    create:(context)=>webPageController,
    child: MaterialApp(onGenerateRoute:RouteGenerator.routeController,
                 initialRoute: RouteGenerator.mainPage,
                 debugShowCheckedModeBanner:false ,
    ),
  ));
}

class MyApp extends StatelessWidget {


  MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      children:[ Consumer<WebPageController>(
        builder:(context,webPageControllerInstance,child)=> WillPopScope(

          onWillPop: () async{
            bool? canGoBack=await webPageControllerInstance.webPageScreens.first.webViewController.canGoBack();
            if(canGoBack){
              webPageControllerInstance.webPageScreens.first.webViewController.goBack();
              return false;
            }
            else{
              dynamic response=await showDialog(context: context, builder:(context)=>AlertDialog(title: Text("Exit Application"),
                content: Text("Do you want to exit from this app"),
                 actions: [
                   TextButton(onPressed: (){Navigator.pop(context,true);}, child: Text("Yes")),
                   TextButton(onPressed: (){Navigator.pop(context,false);}, child: Text("No")),
                 ],
              ));
              if(response==true){
                return true;

              }return false;
            }


          },
          child: Scaffold(
           body:webPageControllerInstance.webPageScreens.first,
           bottomNavigationBar:BottomNavigationBarClass(),
          ),
        ),
      ),]
    );
    //);
  }

}
