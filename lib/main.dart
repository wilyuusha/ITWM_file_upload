import 'package:file_upload/screens/upload_file_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase app
  await Firebase.initializeApp(options: DefaultFirebaseOptions.android);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'File Manager'),
    );
  }
}

//Bacus
//This code defines a Flutter widget called MyHomePage that represents the home page
//of an application. It has a getFileUrls method that retrieves a list of file URLs
//from Firebase Storage by looping through the files in the 'files' directory and adding
//their download URLs to a list, which is then returned. The MyHomePage widget can be used
//in a Flutter application to display the retrieved file URLs or perform other operations
//with them.
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Get all the file links from firebase storage
  Future<List<String>> getFileUrls() async {
    final List<String> files = [];
    final ref = FirebaseStorage.instance.ref();
    final list = await ref.child('files').listAll();

    // Loop through the list
    for (final item in list.items) {
      final url = await item.getDownloadURL();
      files.add(url);
    }

    // Return the list
    return files;
  }

  //Queruela, Gandalla
  //This code overrides the build method to display a Scaffold with a grid of file
  //items obtained from getFileUrls(). If files are found, it shows images for image
  //files and displays file names for non-image files. If no files are found, it displays
  //a "No files found" message.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: FutureBuilder<List<String>>(
        future: getFileUrls(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return RefreshIndicator(
              onRefresh: () async {
                setState(() {});
              },
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                ),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  // If the file is an image
                  if (snapshot.data![index].contains('.jpg') ||
                      snapshot.data![index].contains('.jpeg') ||
                      snapshot.data![index].contains('.png')) {
                    return GridTile(
                      child: Image.network(
                        snapshot.data![index],
                        fit: BoxFit.cover,
                      ),
                    );
                  }

                  // If the file is not an image, show the file name
                  return GridTile(
                      child: Container(
                    color: Colors.grey,
                    child: Center(
                      child: Text(
                        snapshot.data![index],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ));
                },
              ),
            );
          } else {
            // If there are no files uploaded
            return const Center(
              child: Text('No files found'),
            );
          }
        },
      ),

      // Resurreccion
      //This code defines a floating action button at the bottom of the screen,
      //which is wrapped in a Column widget with MainAxisAlignment.end to align it
      //at the bottom. The button allows the user to select a file and triggers a
      //navigation to the UploadFileScreen when pressed. The button has a tooltip
      //"Upload New File" and displays an icon of a plus sign.
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Select file button
          FloatingActionButton(
            // Redirect to UploadFileScreen
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UploadFileScreen(),
              ),
            ),
            tooltip: 'Upload New File',
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
