import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_logcat/just_logcat.dart';
import 'package:web_browser/DatabaseClass.dart';
import 'package:web_browser/screens/WebPageScreen.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:math' as math;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'SaveWebPageModelClass.dart';

class WebPageController extends ChangeNotifier{
  int numberOfTabs=1;
  late InAppWebViewController webViewController;
  bool isInTabsView=false;
  List<WebPageScreen>webPageScreens=[WebPageScreen()];
  List <String>previousTabsHistory=[];
  bool canGoBack=false;
  bool canGoForward=false;
  bool canReturnToHome=true;
  int currentPagePermanentIndex=0;




WebPageController(){


}

void setWebViewCompleter(InAppWebViewController webViewControllerParam){
  webViewController=webViewControllerParam;
  notifyListeners();

}
void addNewWebPage(){
  webPageScreens.insert(0, WebPageScreen());
  currentPagePermanentIndex=webPageScreens.first.permanentIndexIdentifier??getPermanentPageIndex();
  //
  //updateWebPagesPosition();
  notifyListeners();
}

void returnToHomePage()async{
  if(webPageScreens.length>0){


    await webPageScreens.first.webViewController.loadUrl(urlRequest: URLRequest(url: Uri.parse("https://www.google.com")));
    notifyListeners();




  }

}




 int getPermanentPageIndex(){
  int maxIndex=-1;
  for(int i=0;i<webPageScreens.length;++i){
    maxIndex=math.max(webPageScreens.elementAt(i).permanentIndexIdentifier??0,maxIndex);
  }
  maxIndex+=1;
  return maxIndex;
}

void setNumberOfTabs(int num){
  numberOfTabs=num;
  notifyListeners();

}


  void setNavigationIcons()async{
    

    canGoBack=await webPageScreens.first.webViewController.canGoBack();
    canGoForward=await webPageScreens.first.webViewController.canGoForward();

    notifyListeners();

  }
  void moveSelectedTabToFront(int index){
  currentPagePermanentIndex=webPageScreens.elementAt(index).permanentIndexIdentifier??getPermanentPageIndex();
 WebPageScreen webPageScreen= webPageScreens.removeAt(index);
    webPageScreens.insert(0, webPageScreen);
  ///webViewController=webPageScreens.first.webViewController;
  //print("moved");
  notifyListeners();
  }

  void deleteWebPage(int pagePermanentIndex) {
  DatabaseClass.instance.deleteFromWebPagesTable(tableName:DatabaseClass.WEB_PAGES_SAVE_Table,permanentPageIndex: pagePermanentIndex);

    if(webPageScreens.length==1){
      webPageScreens.insert(0, WebPageScreen());
      webPageScreens.first.permanentIndexIdentifier=getPermanentPageIndex();
    }

  webPageScreens.removeWhere((element) => element.permanentIndexIdentifier==pagePermanentIndex);

    notifyListeners();

  }

  void clearAllTabs(){
  //webPageScreens=[];
  List<int?>indexes=[];
  webPageScreens.forEach((element) {indexes.add(element.permanentIndexIdentifier); });
   for (var element in indexes) {
    DatabaseClass.instance.deleteFromWebPagesTable(tableName:DatabaseClass.WEB_PAGES_SAVE_Table,permanentPageIndex: element??-1);

  }
  webPageScreens.insert(0, WebPageScreen());
  webPageScreens.first.permanentIndexIdentifier=getPermanentPageIndex();

  for(int i=webPageScreens.length-1;i>0;--i){
    webPageScreens.removeAt(i);
  }
  webPageScreens.first.permanentIndexIdentifier=getPermanentPageIndex();

  notifyListeners();

}


  void deleteHistory(String? date)async{

    DatabaseClass.instance.deleteFromHistoryTable(tableName:DatabaseClass.HISTORY_TABLE,date: date??"");

  }

  Future <void> deleteAllHistory()async{

    List<SaveWebPageModelClass> saveHistoryModelClass=await DatabaseClass.instance.retrieveHistoryTable(tableName: DatabaseClass.HISTORY_TABLE);
   saveHistoryModelClass.forEach((element)async {
     await DatabaseClass.instance.deleteFromHistoryTable(tableName: DatabaseClass.HISTORY_TABLE, date: element.date??"");
   });
  }





  void openLinkInCurrentTab(String? url){
   if(url!=null){
  webPageScreens.first.webViewController.loadUrl(urlRequest: URLRequest(url: Uri.parse(url)));
}

  }
  void openLinkInNewTab(String? url){
   if(url!=null){
     webPageScreens.insert(0, WebPageScreen());
     webPageScreens.first.currentUrl = url;
     notifyListeners();

   }

  }



  void openLinkInBackgroundTab(String? url){
  if(url!=null) {
    webPageScreens.insert(1, WebPageScreen());
    webPageScreens.elementAt(1).currentUrl = url;
    notifyListeners();
  }
  //webPageScreens.first.webViewController.loadUrl(urlRequest: URLRequest(url: Uri.parse(url)));

  }

}