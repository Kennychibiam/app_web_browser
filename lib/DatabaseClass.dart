
import 'dart:io';

import "package:sqflite/sqflite.dart";
import "package:path_provider/path_provider.dart";
import 'package:path/path.dart';
import 'package:web_browser/SaveWebPageModelClass.dart';
import 'package:web_browser/WebPageController.dart';
import 'package:web_browser/screens/WebPageScreen.dart';



class DatabaseClass{
  static DatabaseClass instance=DatabaseClass();
  static Database? database;
  static final String WEB_PAGES_SAVE_Table="WEB_PAGES_TABLE";
  static final String HISTORY_TABLE="HISTORY_TABLE";


  DatabaseClass(){

  }

  //gets the instance of the Database if database object is null
  Future<Database>get openGetDatabase async{return database ?? await createOrOpenTableDatabase();}

  Future<Database>createOrOpenTableDatabase()async{
    Directory path= Platform.isIOS ? await getLibraryDirectory() : await getApplicationDocumentsDirectory();;
    return openDatabase(
      join(path.path, 'example.db'),

      onCreate: (database, version) async {
        await database.execute(
          "CREATE TABLE WEB_PAGES_TABLE(ID INTEGER PRIMARY KEY AUTOINCREMENT, PAGE_URL TEXT NOT NULL, PAGE_TITLE TEXT NOT NULL, PAGE_PERMANENT_INDEX INTEGER NOT NULL, FAVICON STRING, WEB_IMAGE STRING, DATE STRING NOT NULL )",
        );
        await database.execute(
          "CREATE TABLE HISTORY_TABLE(ID INTEGER PRIMARY KEY AUTOINCREMENT, PAGE_URL TEXT NOT NULL, PAGE_TITLE TEXT NOT NULL, FAVICON STRING, DATE STRING NOT NULL)",
        );
        

      },
      version: 1,
    );

  }

  Future<int?>insertIntoWebPagesTable ({required String tableName,required SaveWebPageModelClass modelDatabase}) async{
    int? result;

    database=await instance.openGetDatabase;
    List<Map<String, Object?>>? resultCheck=await database?.query(tableName,where: "PAGE_PERMANENT_INDEX=?",whereArgs: [modelDatabase.webPagePermanentIndex]);
    // if database does not receive a value the result is []

    if(resultCheck?.isNotEmpty??false){
         result=await  updateWebPagesTable(tableName: tableName, modelDatabase: modelDatabase);
    }
    else{
      if(modelDatabase.webPagePermanentIndex!=null){
      result=await database?.insert(tableName, modelDatabase.convertDataToSaveWebPageMap());}
    }    return result;


  }



  Future<int?>updateWebPagesTable ({required String tableName,required SaveWebPageModelClass modelDatabase}) async{

    int? result;
    database=await instance.openGetDatabase;

    result=await database?.update(tableName, modelDatabase.convertDataToSaveWebPageMap(),where:"PAGE_PERMANENT_INDEX=?",whereArgs: [modelDatabase.webPagePermanentIndex]);
    //print(result??""+ "  update");



  }




    Future<List<SaveWebPageModelClass>>retrieveWebPagesTable ({required String tableName}) async{
    database=await instance.openGetDatabase;//returns instance of itself if not null

    List<Map<String, Object?>>? result=await database?.query(tableName,orderBy: "DATE DESC");
    return SaveWebPageModelClass.toMap().convertToSaveWebPageModelClass(result);
  }


  Future<int?>deleteFromWebPagesTable ({required String tableName,required int permanentPageIndex}) async{
    database=await instance.openGetDatabase;//returns instance of itself if not null

    int? result=await database?.delete(tableName, where:"PAGE_PERMANENT_INDEX=?",whereArgs: [permanentPageIndex]);

    return result;
  }


  Future<int?>insertIntoHistoryTable ({required String tableName,required SaveWebPageModelClass modelDatabase}) async {
    int? result;
    database = await instance.openGetDatabase;

    List<Map<String, Object?>>? resultCheck = await database?.query(
        tableName, where: "PAGE_URL=?", whereArgs: [modelDatabase.webPageUrl]);
    // // if database does not receive a value the result is []
    //
    if (resultCheck?.isNotEmpty ?? false) {
      result = await updateHistoryTable(
          tableName: tableName, modelDatabase: modelDatabase);
    }
    else {
      result = await database?.insert(
          tableName, modelDatabase.convertDataToHistoryMap());
      // }
      return result;
    }
  }


  Future<int?>updateHistoryTable({required String tableName,required SaveWebPageModelClass modelDatabase}) async{

    int? result;
    database=await instance.openGetDatabase;

    result=await database?.update(tableName, modelDatabase.convertDataToHistoryMap(),where:"PAGE_URL=?",whereArgs: [modelDatabase.webPageUrl]);
    //print(result??""+ "  update");



  }




  Future<List<SaveWebPageModelClass>>retrieveHistoryTable ({required String tableName}) async{
    database=await instance.openGetDatabase;//returns instance of itself if not null

    List<Map<String, Object?>>? result=await database?.query(tableName,orderBy: "DATE DESC");
    return SaveWebPageModelClass.toMap().convertToSaveWebHistoryModelClass(result);
  }



  Future<int?>deleteFromHistoryTable ({required String tableName,required String date}) async{
    database=await instance.openGetDatabase;//returns instance of itself if not null

    int? result=await database?.delete(tableName, where:"DATE=?",whereArgs: [date]);

    return result;
  }

}