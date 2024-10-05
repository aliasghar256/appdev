import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class PostListUser extends StatefulWidget {
  const PostListUser({super.key});

  @override
  State<PostListUser> createState() => _PostListUserState();
}
//Function to caulculate relative time
String _calculateTimeDifference(String jobUpdatedDate) {
    DateTime currentDate = DateTime.now(); 
    DateTime jobUpdateDate = DateTime.parse(jobUpdatedDate);  

    Duration difference = currentDate.difference(jobUpdateDate);  

    if (difference.inDays > 0) {
      return "${difference.inDays} days ago";
    } else if (difference.inHours > 0) {
      return "${difference.inHours} hours ago";
    } else if (difference.inMinutes > 0) {
      return "${difference.inMinutes} minutes ago";
    } else {
      return "Just now";
    }
  }

class _PostListUserState extends State<PostListUser> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Jobs"),
        actions: [IconButton(
          onPressed: () {},
          icon: Icon(Icons.notifications_outlined),
        ),]
      ),
      body: Center(
        child: FutureBuilder<List<Post>>(
            future: fetchAllPosts(),
            builder: (context, snap) {
              if (snap.hasData)
                return ListView.builder(itemCount: snap.data?.length,itemBuilder: (c, i) {
                  var _item = snap.data?[i];
                  return ListTile(
                    title: Text(_item!.job_title,style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [Text(_item.company_title), Text(_item!.job_location +" . "+ _item!.workplace_type + " . "+_item!.job_type)],
                    
                    ),
                    leading: CircleAvatar(
                      child: Image.network(_item.company_logo),
                      radius: 30,
                    ),
                    trailing: Container(
  width: 80,
  height: 40,
  child: Align(
    alignment: Alignment.bottomRight,
    child: Text(
      _calculateTimeDifference(_item.job_updated_date),
      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
    ),
  ),
),
                  );
                });
              else if (snap.hasError) {
                return Text("Error ${snap.error}");
              }
              return Center(child: CircularProgressIndicator());
            }),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.work),
            label: 'Jobs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Resume',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Future<List<Post>> fetchAllPosts() async {
    final response =
        await http.get(Uri.parse('https://mpa0771a40ef48fcdfb7.free.beeceptor.com/jobs'));
    if (response.statusCode == 200) {
      List jsonResponse = jsonDecode(response.body)["data"];
      return jsonResponse.map((post) => Post.fromJson(post)).toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }
}

class Post {
  final int id;
  final String job_title;
  final String company_title;
  final String job_location;
  final String workplace_type;
  final String job_type;
  final String job_updated_date;
  final String company_logo;

  Post({
    required this.id,
    required this.job_title,
    required this.company_title,
    required this.job_location,
    required this.workplace_type,
    required this.job_type,
    required this.job_updated_date,
    required this.company_logo,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['job']['id'],
      job_title: json['job']['title'],
      company_title: json['job']['company']['name'],
      job_location: json['job']['location']['name_en'],
      workplace_type: json['job']['workplace_type']['name_en'],
      job_type: json['job']['type']['name_en'],
      job_updated_date: json['job']['updated_date'],
      company_logo: json['job']['company']['logo'],
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFFF3F4F6)),
        useMaterial3: true,
      ),
      home: const PostListUser(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Colors.white,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
