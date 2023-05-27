import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class UploadFileScreen extends StatefulWidget {
  const UploadFileScreen({super.key, this.title = 'Upload File'});

  final String title;

  @override
  State<UploadFileScreen> createState() => _UploadFileScreenState();
}

// Arrogante, Pepito
//This code defines the state class _UploadFileScreenState, which is associated
//with the UploadFileScreen widget. It includes methods for selecting a file using
//FilePicker and uploading it to Firebase Storage. The uploadFile method converts
//the selected file to a File object, uploads it to Firebase Storage, and retrieves
//the download URL of the uploaded file.
class _UploadFileScreenState extends State<UploadFileScreen> {
  PlatformFile? pickedFile;
  UploadTask? uploadTask;

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles();

    if (result == null) return;

    setState(() {
      pickedFile = result.files.first;
    });
  }

  Future uploadFile() async {
    // Define where you want to store the file on firebase
    final destination = 'files/${pickedFile!.name}';

    // Convert pickedFile to a File Object
    final file = File(pickedFile!.path!);

    // Create a reference to firebase
    final ref = FirebaseStorage.instance.ref().child(destination);
    setState(() {
      uploadTask = ref.putFile(file);
    });

    final snapshot = await uploadTask!.whenComplete(() {});

    final urlDownload = await snapshot.ref.getDownloadURL();
    debugPrint('Download-Link: $urlDownload');

    setState(() {
      uploadTask = null;
    });
  }

  //Zulueta, Egot
  //This code overrides the build method of the _UploadFileScreenState class.
  //It returns a Scaffold widget with an app bar and a body that consists of a
  //centered Column. Inside the column, it displays the selected file (if any) as
  //an image or text, and below it, there are buttons for selecting a file, uploading
  //a file, and going back. Additionally, it includes a progress indicator to show the
  //upload progress.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            pickedFile != null
                ? Expanded(
                    child: Center(
                      child: pickedFile!.extension == 'jpg'
                          ? Image.file(
                              File(pickedFile!.path!),
                            )
                          : Text(
                              pickedFile!.name,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                    ),
                  )
                : const Expanded(
                    child: Center(
                      child: Text(
                        'No File Selected',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                customElevatedButton(
                    onPressed: selectFile, text: 'Select File'),
                customElevatedButton(
                    onPressed: uploadFile, text: 'Upload File'),
                customElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    text: 'Go Back'),
                const SizedBox(height: 20),
                buildProgress(),
              ],
            )
          ],
        ),
      ),
    );
  }

  //Estoya
  //The buildProgress function returns a StreamBuilder widget that listens to the
  //snapshotEvents stream of the uploadTask. It displays the progress percentage
  //and a linear progress indicator based on the data received from the snapshot.
  //Additionally, it shows an error message if there is an error in the snapshot.
  Widget buildProgress() => StreamBuilder<TaskSnapshot>(
        stream: uploadTask?.snapshotEvents,
        builder: (context, snapshot) {
          // Get the progress
          final progress = snapshot.hasData
              ? snapshot.data!.bytesTransferred / snapshot.data!.totalBytes
              : 0.0;

          return Column(
            children: [
              if (snapshot.hasData)
                Text('${(progress * 100).toStringAsFixed(2)} %'),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey,
                color: Colors.green,
              ),
              if (snapshot.hasError)
                const Text(
                  'Something Went Wrong',
                  style: TextStyle(color: Colors.red),
                ),
            ],
          );
        },
      );

  //De Jesus
  //The customElevatedButton function returns a customized ElevatedButton widget
  //wrapped in a Padding widget with horizontal padding. It takes an onPressed
  //callback and a text parameter to define the behavior and display text of the
  //button, respectively. This function can be used to create consistent and
  //reusable elevated buttons with a specific style and padding.
  Widget customElevatedButton(
      {required VoidCallback onPressed, required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(0),
            ),
          ),
        ),
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }
}
