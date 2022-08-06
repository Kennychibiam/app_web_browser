import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:web_browser/screens/HistoryScreen.dart';
import 'package:web_browser/screens/Tabs.dart';
import 'package:web_browser/screens/WebPageScreen.dart';
import 'package:web_browser/main.dart';



class RouteGenerator{
  static const String mainPage="/";
  static const String TabsPage="/TabPage";
  static const String webPageScreen="/WebPage";
  static const String webHistoryScreen="/HistoryPage";

  static Route<dynamic>routeController(RouteSettings settings){


    switch(settings.name){

      case mainPage:return MaterialPageRoute(builder: (builder)=>MyApp());
      case TabsPage:

        return MaterialPageRoute(builder: (builder)=>TabsScreen());

      case webHistoryScreen:

        return MaterialPageRoute(builder: (builder)=>HistoryClass());
      break;
      // case webPageScreen:
      //   dynamic pageNumber=settings.arguments as Map;
      //   return MaterialPageRoute(builder:(context)=>WebPage(pageNumber: pageNumber["0"],));
      default:return MaterialPageRoute(builder: (builder)=>MyApp());
     // case linearFittingPage:
       // dynamic arguments=settings.arguments as Map;
       // return MaterialPageRoute(builder:(context)=>LinearFitting(xInputs:arguments[0],yInputs:arguments[1]));


    }
  }
}
