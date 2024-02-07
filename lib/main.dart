import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

// TODO: Breakout to model folder/file
class Post {
  final String title;
  final String body;
  final String timestamp;
  final String author;

  const Post(
      {required this.title,
      required this.body,
      required this.timestamp,
      required this.author});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
        title: json['title'].toString(),
        body: json['body'].toString(),
        timestamp: json['timestamp'].toString(),
        author: json['author'].toString());
  }
}

class Profile {
  final String name;
  final String email;
  final List<Post> posts;
  const Profile(this.name, this.email, this.posts);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Demo App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        home: DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: AppBar(
                bottom: const TabBar(
                  tabs: [
                    Tab(icon: Icon(Icons.home)),
                    Tab(icon: Icon(Icons.emoji_people))
                  ],
                ),
                title: const Text('Demo App'),
              ),
              body: const TabBarView(
                  children: [MyHomePage(title: 'My Profile'), PostListPage()]),
            )));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _userProfile =
      const Profile('Marty McFly', 'marty@timetraveler.com', []);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(_userProfile.name,
                style: Theme.of((context)).textTheme.displaySmall),
            const SizedBox(height: 10),
            Text(_userProfile.email,
                style: Theme.of((context)).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}

class PostListPage extends StatefulWidget {
  const PostListPage({super.key});

  @override
  State<PostListPage> createState() => _PostListState();
}

class _PostListState extends State<PostListPage> {
  // Mocked data would be loaded from api. Loading from local JSON for now.

  // TODO: Move this to a service
  Future<List<Post>> getAllPosts() async {
    final response = await rootBundle.loadString('assets/posts.json');
    return allPostsFromJson(response);
  }

  // TODO: Move this to model
  List<Post> allPostsFromJson(String str) {
    final jsonData = json.decode(str);
    return List<Post>.from(jsonData.map((x) => Post.fromJson(x)));
  }

  late Future<List<Post>> _posts;

  @override
  void initState() {
    super.initState();
    setState(() {
      _posts = getAllPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Recent Posts'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: FutureBuilder(
          future: _posts,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(snapshot.data![index].title),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PostDetailScreen(post: snapshot.data![index]),
                          ));
                    },
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }
            // By default, show a loading spinner.
            return const CircularProgressIndicator();
          },
        ));
  }
}

class PostDetailScreen extends StatelessWidget {
  // In the constructor, require a Todo.
  const PostDetailScreen({super.key, required this.post});

  // Declare a field that holds the Todo.
  final Post post;

  @override
  Widget build(BuildContext context) {
    // Use the Todo to create the UI.
    return Scaffold(
      appBar: AppBar(
        title: Text(post.title),
      ),
      body: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Posted By: ${post.author}',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 10),
              Text(post.timestamp),
              const SizedBox(height: 60),
              Text(post.body, style: Theme.of(context).textTheme.displaySmall),
            ],
          )),
    );
  }
}
