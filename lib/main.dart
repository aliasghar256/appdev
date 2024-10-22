import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Counter()),
      ],
      child: const MyApp(),
    ),
  );
}

//Defining the Class for an individual Mission Post
class missionEntry {
  //Needed to add these as I was facing an infinite loading error.
  final String? mission_name;
  final String? mission_id;
  final List<String>? manufacturers;
  final List<String>? payload_ids;
  final String? wikipedia;
  final String? website;
  final String? twitter;
  final String? description;

  const missionEntry({
    required this.mission_name,
    required this.mission_id,
    required this.manufacturers,
    required this.payload_ids,
    required this.wikipedia,
    required this.website,
    required this.twitter,
    required this.description,
  });
  factory missionEntry.fromJson(Map<String, dynamic> json) {
    return missionEntry(
      mission_name: json['mission_name'],
      mission_id: json['mission_id'],
      manufacturers: json['manufacturers'].cast<String>(),
      payload_ids: json['payload_ids'].cast<String>(),
      wikipedia: json['wikipedia'],
      website: json['website'],
      twitter: json['twitter'],
      description: json['description'],
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Space Missions',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: const MissionPage(),
    );
  }
}

class MissionPage extends StatelessWidget {
  const MissionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Space Missions'), // Fixed the spelling of 'Space'
        backgroundColor: Colors.green[900],
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
      ),
      body: Center(
        child: ListView.builder(
          itemCount: context.watch<Counter>().missionentrylength,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.all(8),
              child: MissionPost(
                missionentry: context.watch<Counter>()._missionentries[index],
              ),
            );
          },
        ),
      ),
    );
  }
}

class Counter with ChangeNotifier {
  List<missionEntry> _missionentries = [];
  List<missionEntry> get posts => _missionentries;
  int get missionentrylength => _missionentries.length;

  void fetchPost() async {
    final response =
        await http.get(Uri.parse('https://api.spacexdata.com/v3/missions'));
    if (response.statusCode == 200) {
      List jsonResponse = jsonDecode(response.body);
      _missionentries = jsonResponse
          .map((missionentry) => missionEntry.fromJson(missionentry))
          .toList();
    } else {
      throw Exception('Failed to load posts');
    }
    notifyListeners();
  }
}

//We make a stateful mission post as it's state can change depending upon the pressing of a button.
class MissionPost extends StatefulWidget {
  final missionEntry missionentry;
  const MissionPost({super.key, required this.missionentry});

  @override
  State<MissionPost> createState() => _MissionPostState();
}

//We now assemble the composition of the mission post.
//Since I need rounded corners and a shadow I use card
class _MissionPostState extends State<MissionPost> {
  bool viewMoreClicked = false;
  //Random Color Function
  // Function to generate a random color
  Color getRandomColor() {
    final Random random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shadowColor: Colors.grey,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('${widget.missionentry.mission_name}',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12), // Spacing
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(
                    "${widget.missionentry.description}",
                    overflow: viewMoreClicked
                        ? TextOverflow.visible
                        : TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MaterialButton(
                  onPressed: () {
                    setState(() {
                      viewMoreClicked = !viewMoreClicked;
                    });
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        viewMoreClicked
                            ? Icons.arrow_drop_up
                            : Icons.arrow_drop_down,
                        color: Colors.green,
                      ),
                      Text(
                        viewMoreClicked ? 'Less' : 'More',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  color: Colors.grey[200],
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
              ],
            ),

            // Payload IDs
            if (widget.missionentry.payload_ids != null &&
                widget.missionentry.payload_ids!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: widget.missionentry.payload_ids!.map((id) {
                        final color = getRandomColor(); // random color
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 6.0),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Text(
                            id,
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
