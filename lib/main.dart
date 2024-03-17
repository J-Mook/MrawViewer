import 'dart:ffi';
import 'dart:io';

import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:rinf/rinf.dart';
import 'package:file_picker/file_picker.dart';
import 'package:window_manager/window_manager.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:sidebarx/sidebarx.dart';


import './messages/generated.dart';
import './messages/mooksviewer.pb.dart';

import './RGBpage.dart';
import './ViewerPage.dart';
import 'provider/themeprovider.dart';
import 'provider/rawimageprovider.dart';

void main() async {
  await initializeRust();

  WidgetsFlutterBinding.ensureInitialized();
  await WindowManager.instance.ensureInitialized();
  windowManager.waitUntilReadyToShow().then((_) async {
    await windowManager.setTitleBarStyle(
      TitleBarStyle.hidden,
      windowButtonVisibility: false,
    );
    // await windowManager.setMinimumSize(const Size(500, 600));
    await windowManager.show();
    await windowManager.focus();
    await windowManager.setPreventClose(true);
    await windowManager.setSkipTaskbar(false);
  });

  // await windowManager.ensureInitialized();
  // WindowOptions windowOptions = WindowOptions(
  //   // size: Size(800, 600),
  //   center: true,
  //   backgroundColor: Colors.transparent,
  //   skipTaskbar: true,
  //   titleBarStyle: TitleBarStyle.hidden,
  // );
  // windowManager.waitUntilReadyToShow(windowOptions, () async {
  //   await windowManager.show();
  //   await windowManager.focus();
  // });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider( create: (context) => ThemeProvider(), ),
        ChangeNotifierProvider( create: (context) => RawImageProvider(), ),
      ],
      child: MainApp()
    )
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: "jmook",
      initialRoute: '/',
      routes: {
        '/' : (context) => MRawViewer(),
        '/home' : (context) => MRawViewer(),
        '/rgb' : (context) => RGBPage(),
      },
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeProvider.themeMode,

      debugShowCheckedModeBanner: false,
    );
  }
}

class MRawViewer extends StatelessWidget {
  MRawViewer({super.key});

  ThemeMode _themeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Mook's Viewer", style: TextStyle(fontSize: 15, color: themeProvider.isDarkMode ? Colors.white : Colors.black),),
        toolbarHeight: 30.0,
        // backgroundColor: Color.fromARGB(255, 127, 127, 127),
        // foregroundColor: Color.fromARGB(255, 127, 127, 127),
        backgroundColor: themeProvider.isDarkMode ? Color.fromARGB(255, 100, 100, 100) : Color.fromARGB(255, 200, 200, 200),
        foregroundColor: themeProvider.isDarkMode ? Color.fromARGB(255, 100, 100, 100) : Color.fromARGB(255, 200, 200, 200),
        // backgroundColor: themeProvider.isDarkMode ? Color.fromARGB(64, 255, 255, 255) : Color.fromARGB(164, 0, 0, 0),
        // foregroundColor: themeProvider.isDarkMode ? Color.fromARGB(64, 255, 255, 255) : Color.fromARGB(164, 0, 0, 0),
        // leading: IconButton(
        //     onPressed:() => exit(0),
        //     icon: const Icon(Icons.close),
        //     iconSize: 18,
        //   ),
        actions: <Widget>[
          // Text("Dark Mode "),
          // Switch(
          //   value: themeProvider.isDarkMode,
          //   inactiveTrackColor: Colors.black38,
          //   activeColor: Colors.white38,
          //   onChanged: (value) {
          //     themeProvider.toggleTheme(value);
          //   },
          // ),
          // IconButton(
          //   onPressed:() {
          //     Navigator.pushNamed(context, '/rgb');
          //   },
          //   icon: const Icon(Icons.palette)
          // ),
          IconButton(
            onPressed:() => exit(0),
            icon: Icon(Icons.close, color: themeProvider.isDarkMode ? Colors.white : Colors.black,),
            iconSize: 18,
          ),
        ],
      ),
      body: MainBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // setState(() { Navigator.pushNamed(context, '/RandColor'); });
        },
        child: const Icon(Icons.link),
      ),
    );
  }
}

class MainBody extends StatefulWidget {
  const MainBody({super.key});

  @override
  State<MainBody> createState() => _MainBody();
}

class _MainBody extends State<MainBody> {

  SidebarXController _controller = SidebarXController(selectedIndex: 0);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Row(
      children: [
        Container(
          margin: EdgeInsets.fromLTRB(5, 5, 0, 5),
          child: SidebarX(
            controller: _controller,
            items: const [
              SidebarXItem(icon: Icons.home, label: ' Home'),
              SidebarXItem(icon: Icons.palette, label: ' RGBpalette'),
            ],
            theme: SidebarXTheme(
              width: 60,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 76, 119, 140),
                borderRadius: BorderRadius.circular(15),
              ),
              margin: EdgeInsets.only(right: 10),
            ),
            extendedTheme: SidebarXTheme(
              width: 150,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 96, 125, 139),
                borderRadius: BorderRadius.circular(15),
              ),
              margin: EdgeInsets.only(right: 20),
            ),
            footerBuilder: (context, extended) {
              return extended ?
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("DarkMode"),
                  SizedBox(height: 35,
                    child: FittedBox(
                      fit:BoxFit.fitHeight,
                      child: Switch(
                        value: themeProvider.isDarkMode,
                        inactiveTrackColor: Colors.black38,
                        activeColor: Colors.white38,
                        onChanged: (value) {
                          themeProvider.toggleTheme(value);
                        },
                      ),
                    ),
                  ),
                ],
              ) : Icon(Icons.dark_mode);
            },
          ),
        ),
        // ViewerBody(),
        Expanded(
          child: AnimatedBuilder(
            animation: _controller,
            builder:(context, child) {
              switch (_controller.selectedIndex) {
                case 0:
                  return ViewerBody();
                case 1:
                  return RGBPage();
                
                default:
                  return ViewerBody();
              }
            },
          )
        ),
      ],
    );
  }
}
