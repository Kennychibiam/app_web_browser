
import "dart:convert" as toJSONconverter;
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:web_browser/WebPageController.dart';
import 'package:web_browser/screens/WebPageScreen.dart';

class SaveWebPageModelClass{

  String? webPageTitle;
  String? webPageUrl;
  int? webPagePermanentIndex;
  Uint8List ?favicon;
  Uint8List ?webScreenshot;
  String ?date;


 SaveWebPageModelClass({required this.webPageUrl, required this.webPageTitle,required this.webPagePermanentIndex,required this.favicon,required this.webScreenshot});
 SaveWebPageModelClass.toMap();
 SaveWebPageModelClass.saveHistory({required this.webPageUrl, required this.webPageTitle, required this.favicon, this.date});

  Map<String,Object?> convertDataToSaveWebPageMap(){
   

      //String pageEncodedUrls=toJSONconverter.json.encode(webPageUrls);
      //String pageEncodedTitles=toJSONconverter.json.encode(webPageTitle);
      //String webPageEncodedPermanentIndexes=toJSONconverter.json.encode(webPagePermanentIndexes);

      return {"PAGE_URL":webPageUrl,"PAGE_TITLE":webPageTitle,
        "PAGE_PERMANENT_INDEX":webPagePermanentIndex,
        "FAVICON":convertUint8ListImageToString(favicon),
        "WEB_IMAGE":convertUint8ListImageToString(webScreenshot),
        "DATE":dateConversion()
      };

    

  }




  String dateConversion(){
    String date=DateTime.now().toString();
    List<String>dateList=date.split(" ");
    List<String>dateList2=dateList.first.split("-");
    String dateTime=dateList2[1]+"-"+dateList2.last+"-"+dateList2.first+" "+dateList.last;
    return dateTime;
    //07-30-2022 18:43:17.849331 ----result
  }


  Map<String,Object?> convertDataToHistoryMap(){


      //String pageEncodedUrls=toJSONconverter.json.encode(webPageUrls);
      //String pageEncodedTitles=toJSONconverter.json.encode(webPageTitle);
      //String webPageEncodedPermanentIndexes=toJSONconverter.json.encode(webPagePermanentIndexes);

      return {"PAGE_URL":webPageUrl,"PAGE_TITLE":webPageTitle,
        "FAVICON":convertUint8ListImageToString(favicon),"DATE":dateConversion()
      };



  }

  String? convertUint8ListImageToString(Uint8List? data){
      if(data==null)return null;

    return base64Encode(data.toList());

  }
  Uint8List ?convertStringToUint8List(String ?imageUint){
    if(imageUint==null)return null;
    return base64Decode(imageUint);
  }


  List<SaveWebPageModelClass>convertToSaveWebPageModelClass(List<Map<String, dynamic>>?queryResult){
    //it can also be a type Object?\
    return queryResult?.map((e) =>SaveWebPageModelClass(
        webPageUrl: e["PAGE_URL"],
        webPageTitle:e["PAGE_TITLE"],
        webPagePermanentIndex:e["PAGE_PERMANENT_INDEX"],
        favicon: convertStringToUint8List(e["FAVICON"]),
        webScreenshot: convertStringToUint8List(e["WEB_IMAGE"])

    )).toList()??[];
  }
  List<SaveWebPageModelClass>convertToSaveWebHistoryModelClass(List<Map<String, dynamic>>?queryResult){
    //it can also be a type Object?\
    return queryResult?.map((e) =>SaveWebPageModelClass.saveHistory(
        webPageUrl: e["PAGE_URL"],
        webPageTitle:e["PAGE_TITLE"],
        favicon: convertStringToUint8List(e["FAVICON"]),
        date:e["DATE"]

    )).toList()??[];
  }

}