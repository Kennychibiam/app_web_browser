import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import "package:flutter/material.dart";
import 'package:flutter/rendering.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:focused_menu/modals.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:web_browser/SaveWebPageModelClass.dart';
import 'package:web_browser/SpeechToTextClass.dart';
import 'package:web_browser/WebPageController.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:just_logcat/just_logcat.dart';
import 'package:focused_menu/focused_menu.dart';
import '../DatabaseClass.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:http/http.dart' as http;


class WebPageScreen extends StatefulWidget {
  late InAppWebViewController webViewController;
  bool isTyping=false;
  TextEditingController webPageTextController=TextEditingController();
  FocusNode webPageTextFieldFocusNode=FocusNode();
  bool hasMadeSearchFirstTime=false;
  bool hasSuccessfulCompletedSearchFirstTime=false;
  bool hasSuccessfulMadeSearch=false;
  bool hasAttemptedSearch=false;
  bool isTypingInSearchField=false;
  int progressValue=0;
  String currentUrl="";
  String pageTitle="";
  int? permanentIndexIdentifier;
  String webViewScreenshotImageString="";
  bool isPageLoading=false;
  bool isTextSelectDisabled=false;
  Uint8List? screenshot;
  Uint8List? favicon;
  List<String>tabHistory=[];
  bool ?isFromDatabase=false;// if isFromDatabase  then do not save to database for thefirst creation of class
  bool isSpeaking=false;
  bool canShowSpeechMic=false;
  String speechToTextResult="";
  Uri ? faviconUri;
  bool isPageCreated=false;













  WebPageScreen({Key? key, this.isFromDatabase}) : super(key: key);

  @override
  State<WebPageScreen> createState() => _WebPageState();
}

class _WebPageState extends State<WebPageScreen> {
  //late GlobalKey objectKeyRepaint;
  ScreenshotController screenshotController = ScreenshotController();
  ValueKey ?webValueKey;


  @override
  void initState() {
    //objectKeyRepaint=GlobalKey();
    widget.webPageTextController = TextEditingController();
    widget.webPageTextFieldFocusNode = FocusNode();


    //this is to prevent the webview from resaving to database when they are being queried from database

  }


  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (widget.isFromDatabase ?? true) {
        widget.isFromDatabase = false;
      }
    });
    var provider = Provider.of<WebPageController>(context, listen: false);
    widget.permanentIndexIdentifier ??= provider.getPermanentPageIndex();

    widget.isFromDatabase ??= false;
    webValueKey = ValueKey(widget.permanentIndexIdentifier);

    return SafeArea(child: Scaffold(
      body: Column(children: [
        Row(
          children: [
            const SizedBox(width: 25, height: 25,
                child: Image(
                    image: const AssetImage("assets/images/google.png"))),
            Expanded(
              child: AnimatedContainer(
                padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                margin: const EdgeInsets.fromLTRB(5, 5, 8, 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: Colors.black26,
                ),
                duration: const Duration(milliseconds: 5000),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    Expanded(
                      child: FocusScope(
                        child: Focus(
                          onFocusChange: (hasFocus) {
                            if (!hasFocus) {
                              widget.isTextSelectDisabled = false;
                            }
                          },
                          child: TextField(


                            controller: widget.webPageTextController,
                            focusNode: widget.webPageTextFieldFocusNode,

                            onTap: () {
                              //widget.isTyping=true;
                              setState(() {

                              });
                              if (!widget.isTextSelectDisabled) {
                                widget.isTextSelectDisabled = true;
                                widget.webPageTextController.selection =
                                    TextSelection(baseOffset: 0,
                                        extentOffset: widget
                                            .webPageTextController.text.length);
                              }
                            },
                            onChanged: (text) {
                              setState(() {
                                if (widget.webPageTextController.text
                                    .toString()
                                    .isNotEmpty) {
                                  widget.isTyping = true;
                                }
                                else {
                                  widget.isTyping = false;
                                }
                              });
                            },
                            onSubmitted: (text) {
                              setState(() {
                                widget.isTyping = false;
                                validateStringAndSearch();
                              });
                            },
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: "Search or Type URL",
                            ),

                          ),
                        ),
                      ),

                    ),
                    selectSearchBarIcon(
                        widget.webPageTextController.text.toString()),
                  ],
                ),
              ),
            ),
            if(!widget.isTyping)
              IconButton(iconSize: 25,
                icon: const Icon(Icons.mic_none_rounded),
                color: Colors.black38,
                onPressed: () {
                  if (!widget.canShowSpeechMic) {
                    setUpSpeechToText();
                  }
                },)
            else
              IconButton(iconSize: 25,
                icon: const Icon(Icons.search),
                color: Colors.black38,
                onPressed: () {
                  validateStringAndSearch();
                },)

          ],
        ),
        showHomeDefaultView(),
      ],),
    ));
  }

  //search bar icons
  Widget selectSearchBarIcon(String queryText) {
    if (queryText.isEmpty) {
      return IconButton(iconSize: 25,
        icon: const Icon(Icons.search),
        color: Colors.black38,
        onPressed: () {
          bool isUrlFieldEmpty = widget.webPageTextController.text.isEmpty;
          if (!isUrlFieldEmpty) {
            validateStringAndSearch();
          }
          else {
            widget.webPageTextFieldFocusNode.requestFocus();
          }
        },);
    }
    else
    if (queryText.isNotEmpty && !widget.hasAttemptedSearch || widget.isTyping) {
      return IconButton(iconSize: 18,
        icon: const ImageIcon(const AssetImage("assets/images/cancel.png"),
            color: Colors.black38),
        onPressed: () {
          if (widget.isPageLoading) {
            widget.webViewController.goBack();
          } else {
            setState(() {
              widget.webPageTextController.clear();
            });
          }
        },);
    }
    else {
      return IconButton(iconSize: 25,
        icon: const Icon(Icons.refresh),
        color: Colors.black38,
        onPressed: () {
          widget.webViewController.reload();
        },);
    }
  }

  Widget showHomeDefaultView() {
    return Expanded(
      child: Stack(
        children: [
          InAppWebView(

            shouldOverrideUrlLoading: (controller, navigationAction) async {
              Uri ?url = navigationAction.request.url;
              bool isHTTPS = url?.scheme.contains("https") ?? false;
              if (!isHTTPS) {
                validateNavigationDelegate(
                    navigationAction.request.url.toString());
                return NavigationActionPolicy.CANCEL;
              }
              else {
                return NavigationActionPolicy.ALLOW;
              }
            },
            initialUrlRequest: widget.currentUrl == "" ? URLRequest(
                url: Uri.parse("https://www.google.com")) : URLRequest(
                url: Uri.parse(widget.currentUrl)),
            onLongPressHitTestResult: (controller, hitResult) {
              int type = hitResult.type?.toValue() ?? 0;
              String ?url = hitResult.extra;
              if (type == 7 || type == 8) {
                showDialog(

                  context: context, builder: (context) =>
                    AlertDialog(
                        backgroundColor: Colors.white,

                        content: dialogItemWidgets(type, url)),
                );
              }
            },
            //
            key: ValueKey(widget.permanentIndexIdentifier),
            onWebViewCreated: (controller) async {
              widget.webViewController = controller;
              widget.isPageCreated=true;

              Provider.of<WebPageController>(context, listen: false)
                  .setWebViewCompleter(widget.webViewController);

              if (widget.isFromDatabase == false && widget.isPageCreated) {
                //print("reached saved to database");
                await saveWebPageToDataBase();
              }
            },
            // gestureRecognizers: Set().add(value),
            onLoadStart: (controller, url) async {
              String? title = await controller.getTitle();

              setState(() {
                widget.isTyping = false;
                widget.webPageTextFieldFocusNode.unfocus();
                widget.isPageLoading = true;
                widget.webPageTextController.text = title ?? "Google";
                widget.hasAttemptedSearch = true;
                widget.currentUrl = url.toString();
                widget.progressValue = 0;
                widget.pageTitle = title ?? "Google";
              });
            },

            onProgressChanged: (controller, progress) {
              setState(() {
                widget.isPageLoading = true;
                widget.progressValue = progress;
                widget.isPageLoading = true;
              });
            },
            onLoadStop: (controller, url) async {
              var provider = Provider.of<WebPageController>(
                  context, listen: false);
              String? title = await widget.webViewController.getTitle();
              provider.setNavigationIcons();

              setState(() {
                widget.isPageLoading = false;
                widget.progressValue = 0;
                widget.isPageLoading = false;
                widget.currentUrl = url.toString();
                if (!provider.canGoBack) {
                  widget.webPageTextController.text = title ?? "Google";
                  widget.pageTitle = title ?? "Google";
                }
                else if (provider.canGoBack) {
                  widget.webPageTextController.text = title ?? "Error";
                  widget.pageTitle = title ?? "Error";
                }
              });
              // print(widget.isFromDatabase);
              if (widget.isFromDatabase == false &&widget.isPageCreated) {
                //print("reached saved to database");
                await saveWebPageToDataBase();
                await saveHistoryToDataBase();
              }
            },
          ),
          //Image.memory()
          if(widget.progressValue < 100)
            LinearProgressIndicator(color: Colors.blue,
                value: widget.progressValue / 100.0,
                backgroundColor: Colors.white),
          if(widget.canShowSpeechMic)
            Center(child: speechToTextWidget()),

        ],
      ),
    );
  }

  Widget dialogItemWidgets(int type, String? url) {
    switch (type) {
      case 8:
        WebPageController provider = Provider.of<WebPageController>(
            context, listen: false);
        return SizedBox(
          height: 180,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              TextButton(onPressed: () {
                provider.openLinkInCurrentTab(url);
                Navigator.pop(context);
              },
                  child: Text("Open Image",
                      style: TextStyle(color: Colors.black87, fontSize: 18))),

              TextButton(onPressed: () {
                provider.openLinkInBackgroundTab(url);
                Navigator.pop(context);
              },
                  child: Text("Open In Background",
                      style: TextStyle(color: Colors.black87, fontSize: 18))),

              TextButton(onPressed: () {
                provider.openLinkInNewTab(url);
                Navigator.pop(context);
              },
                  child: Text("Open In New Tab",
                      style: TextStyle(color: Colors.black87, fontSize: 18))),
            ],),
        );
      case 7:
        WebPageController provider = Provider.of<WebPageController>(
            context, listen: false);

        return SizedBox(
          height: 180,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(onPressed: () {
                provider.openLinkInCurrentTab(url);
                Navigator.pop(context);
              },
                  child: Text("Open",
                      style: TextStyle(color: Colors.black87, fontSize: 18))),
              TextButton(onPressed: () {
                provider.openLinkInBackgroundTab(url);
                Navigator.pop(context);
              },
                  child: Text("Open In Background",
                      style: TextStyle(color: Colors.black87, fontSize: 18))),
              TextButton(onPressed: () {
                provider.openLinkInNewTab(url);
                Navigator.pop(context);
              },
                  child: Text("Open In New Tab",
                      style: TextStyle(color: Colors.black87, fontSize: 18))),
            ],),
        );


      default:
        return SizedBox();
    }
  }


  void validateStringAndSearch({String ?url}) {
    if (widget.webPageTextController.text.isNotEmpty) {
      String urlQueried = widget.webPageTextController.text.toString();
      if (!urlQueried.contains("https")) {
        urlQueried = urlQueried.replaceAll("http", "");
      }
      if (!urlQueried.contains("https://")) {
        if (urlQueried.contains("www.")) {
          String validateString = urlQueried.trim();
          widget.webViewController.loadUrl(urlRequest: URLRequest(
              url: Uri.parse("https://$validateString")));
        }
        else if (!urlQueried.contains("www.")) {
          String validateString = urlQueried.trimLeft().trimRight().replaceAll(
              new RegExp(r"\s+"), "+");
          widget.webViewController.loadUrl(urlRequest: URLRequest(
              url: Uri.parse(
                  "https://www.google.com/search?q=$validateString")));
        }
      }
      else if (urlQueried.contains("https://")) {

        if (urlQueried.contains("www.")) {
          String validateString = urlQueried.trim();
          widget.webViewController.loadUrl(
              urlRequest: URLRequest(url: Uri.parse("$validateString")));
        }
        else if (!urlQueried.contains("www.")) {
          String validateString = urlQueried.trim();
          widget.webViewController.loadUrl(urlRequest: URLRequest(
              url: Uri.parse("https://$validateString")));
        }
      }
    }
  }

  void validateNavigationDelegate(String url) async {
    if (url.isNotEmpty) {
      String urlQueried = url;

      if (!urlQueried.contains("https")) {
        if (urlQueried.contains("http")) {
          urlQueried = urlQueried.replaceAll("http", "https");
          widget.webViewController.loadUrl(
              urlRequest: URLRequest(url: Uri.parse(urlQueried)));
        }
      }
    }
  }
  Future<void> saveHistoryToDataBase() async {
    List<Favicon>favicon=await widget.webViewController.getFavicons();

    var response=await http.get(favicon.first.url);
    if(response.statusCode==200){
      widget.favicon=response.bodyBytes;}

    SaveWebPageModelClass saveHistoryClass = SaveWebPageModelClass.saveHistory(
        webPageUrl: widget.currentUrl,
        webPageTitle: widget.pageTitle,
        favicon: widget.favicon);
    await DatabaseClass.instance.insertIntoHistoryTable(
        tableName: DatabaseClass.HISTORY_TABLE,
        modelDatabase: saveHistoryClass);


  }
  Future<void> saveWebPageToDataBase() async {
    widget.screenshot = await widget.webViewController.takeScreenshot();

    List<Favicon>favicon=await widget.webViewController.getFavicons();

      var response=await http.get(favicon.first.url);
      if(response.statusCode==200){
      widget.favicon=response.bodyBytes;}


    SaveWebPageModelClass saveWebPageModelClass = SaveWebPageModelClass(
        webPagePermanentIndex: widget.permanentIndexIdentifier,
        webPageTitle:
        widget.pageTitle,
        webPageUrl: widget.currentUrl,
        webScreenshot: widget.screenshot,
        favicon: widget.favicon);
    await DatabaseClass.instance.insertIntoWebPagesTable(
        tableName: DatabaseClass.WEB_PAGES_SAVE_Table,
        modelDatabase: saveWebPageModelClass);

    // SaveWebPageModelClass saveHistoryClass = SaveWebPageModelClass.saveHistory(
    //     webPageUrl: widget.currentUrl,
    //     webPageTitle: widget.pageTitle,
    //     favicon: widget.favicon);
    // await DatabaseClass.instance.insertIntoHistoryTable(
    //     tableName: DatabaseClass.HISTORY_TABLE,
    //     modelDatabase: saveHistoryClass);
  }


  void setUpSpeechToText() async {
    SpeechToTextClass.speechRecognition = SpeechToText();
    bool isSpeechProcessAvailable = await SpeechToTextClass.speechRecognition
        .initialize(
        onStatus: (status) {
          switch (status) {
            case SpeechToText.doneStatus:
              setState(() {
                widget.canShowSpeechMic = false;
              });
              SpeechToTextClass.speechRecognition.stop();
              processSpeechToText();

              break;
            case SpeechToText.listeningStatus:
              setState(() {
                widget.isSpeaking = true;

              });
          }
        },
        onError: (error) {
          setState(() {
            widget.canShowSpeechMic = false;

          });
          SpeechToTextClass.speechRecognition.stop();
          processSpeechToText();
        });

    if (isSpeechProcessAvailable) {
      setState(() {
        widget.canShowSpeechMic = true;
      });
      SpeechToTextClass.speechRecognition.listen(
          onResult: (speechToTextResult) {
            setState(() {
              widget.speechToTextResult +=
                  speechToTextResult.recognizedWords + " ";
            });
          });
    } else {
    }
  }

  Widget speechToTextWidget() {
    return SingleChildScrollView(
      child: Container(
        color: Colors.white,
        width: double.infinity,
        height:MediaQuery.of(context).size.height-100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Text("${widget.speechToTextResult}",
                style: TextStyle(color: Colors.black87, fontSize: 20)),
            AvatarGlow(

              endRadius: 90.0,
              glowColor: Theme
                  .of(context)
                  .primaryColor,
              duration: const Duration(milliseconds: 2000),
              repeatPauseDuration: const Duration(milliseconds: 150),
              repeat: true,
              animate: widget.isSpeaking,
              child: FloatingActionButton(
                onPressed: () {},
                child: Icon(
                  widget.isSpeaking ? Icons.mic : Icons.mic_none,
                ),
              ),
            ),
            TextButton(onPressed: () {
              setState(() {
                widget.canShowSpeechMic = false;
                SpeechToTextClass.speechRecognition.stop();
                processSpeechToText();
              });
            }, child: Text("Finish", style: TextStyle(fontSize: 20,color: Colors.black87 ),)),
          ],
        ),
      ),
    );
  }

  void processSpeechToText() {
    String speechString = widget.speechToTextResult;

    if (speechString.isNotEmpty) {
      setState(() {
        widget.webPageTextController.text = speechString;

      });
      validateStringAndSearch(url: speechString);
      widget.speechToTextResult="";

    }
  }


}