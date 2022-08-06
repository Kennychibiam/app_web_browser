import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../DatabaseClass.dart';
import '../SaveWebPageModelClass.dart';
import '../WebPageController.dart';


class HistoryClass extends StatefulWidget {
  const HistoryClass({Key? key}) : super(key: key);

  @override
  State<HistoryClass> createState() => _HistoryClassState();
}

class _HistoryClassState extends State<HistoryClass> {
  late WebPageController provider;

  @override
  Widget build(BuildContext context)  {
    provider=Provider.of<WebPageController>(context,listen: false);

    return Scaffold(
      appBar: AppBar(
        title:Text("History"),
        backgroundColor:Colors.transparent,
        actions: [
          PopupMenuButton(
              onSelected: (num)async{
                if(num==0){
                  await provider.deleteAllHistory();
                  setState(() {});
                  Navigator.pop(context);
                }
              },
              itemBuilder: (itemBuilder)=>[
            PopupMenuItem<int>(value: 0,
                child:Text("Clear History"),),

          ]),
        ],
      ),
      body: FutureBuilder<List<SaveWebPageModelClass>>(
          future: DatabaseClass.instance.retrieveHistoryTable(tableName: DatabaseClass.HISTORY_TABLE)
          ,
          builder: (builder,snapshot){
              if(snapshot.hasData && snapshot.data!.isNotEmpty){
                return buildHistoryList(snapshot.data!.length,snapshot.data);
              }
              return Container(
                color: Colors.white,
                child: Center(child: Text("NO HISTORY",style: TextStyle(fontSize: 18,color: Colors.black87),),),);
          }
      ),
    );

  }

  Widget buildHistoryList(int itemCount,List<SaveWebPageModelClass>?historyModelClass){
    return ListView.builder(

      itemCount:itemCount ,
        itemBuilder: (context,index)=>Dismissible(
        key: ValueKey(historyModelClass?.elementAt(index).date),
    onDismissed: (direction){
          provider.deleteHistory(historyModelClass?.elementAt(index).date);
    },
    child:GestureDetector(
      onTap: (){
        provider.openLinkInNewTab(historyModelClass?.elementAt(index).webPageUrl);
        Navigator.pop(context);
      },
      child: Container(
          width:double.infinity,
          margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
          decoration: BoxDecoration(
            //borderRadius: BorderRadius.vertical(top:Radius.circular(20),bottom: Radius.circular(20)),
            // colorPallete[Random().nextInt(colorPallete.length)]
           // color:Colors.white,
          ),
          child: Column(
            children: [
              Row(

                children: [
                  Container(
                      margin: EdgeInsets.fromLTRB(8, 0, 0, 0),

                      child:
                      historyModelClass?.elementAt(index).favicon!=null?Image.memory(historyModelClass?.elementAt(index).favicon??Uint8List(0),height: 30,width: 30,fit: BoxFit.fill,)
                          :Image.asset("assets/images/google.png",width: 30,height: 30,fit:BoxFit.fill)),
                  Expanded(child: Container(
                      margin: EdgeInsets.fromLTRB(8, 0, 0, 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,

                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${historyModelClass?.elementAt(index).webPageUrl}",style:TextStyle(fontSize: 20), maxLines: 1,overflow: TextOverflow.ellipsis,),
                          SizedBox(height: 8,),
                          Text("${historyModelClass?.elementAt(index).webPageTitle}",style:TextStyle(fontSize: 16), maxLines: 1,overflow: TextOverflow.ellipsis,),
                        ],
                      ))),


                  //SizedBox(width:40,height:40,child: IconButton(onPressed:(){deleteWebpage(index);}, icon: Image.asset("assets/images/cancel.png")))
                ],
              ),
              Divider(color: Colors.grey),
            ],
          )),
    ),

        )
    );

  }
}
