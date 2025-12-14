import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mydiary/databasehelper.dart';
import 'package:mydiary/diarylistdata.dart';
import 'package:path_provider/path_provider.dart';

class DiaryPage extends StatefulWidget {
  const DiaryPage({super.key});

  @override
  State<DiaryPage> createState() => _DiaryPage();
}

class _DiaryPage extends State<DiaryPage> {
  //stored the selected img file
  File? image;
  //to store data when edit
  DiaryListData? editDiary;

  //date  picker
  DateTime selectedDate = DateTime.now();
  String selectedEmoji = "🙂"; //selected emoji for title

  //controller for input
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final DateFormat formatter = DateFormat('dd MMM yyyy'); //format the date

  //emoji picker list
  final List<String> emojiList = [
    "😀",
    "😊",
    "🥰",
    "😍",
    "😎",
    "😢",
    "😭",
    "😡",
    "😴",
    "🤔",
    "😇",
    "🥳",
    "😌",
    "😔",
    "😤",
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    //get data from previous page
    final args = ModalRoute.of(context)?.settings.arguments;
    //if edit & data exist
    if (args != null && args is DiaryListData && editDiary == null) {
      editDiary = args;
      //Check if title start with emoji
      if (args.title.isNotEmpty && emojiList.contains(args.title[0])) {
        selectedEmoji = args.title[0];
        titleController.text = args.title.substring(2);
      } else {
        titleController.text = args.title;
      }

      //to set content text
      descriptionController.text = args.description;

      //convert string date format to datetime format
      selectedDate = formatter.parse(args.date);

      //load image if exist
      if (args.imagename != "NA") {
        image = File(args.imagename);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFCE1F3), Color(0xFFD2E4FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(
          child: Column(
            children: [
              // THE HEADER
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),

                //back btn
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),

                    //title text
                    const Spacer(),
                    Text(
                      editDiary == null ? "New Diary" : "Edit Diary",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFB03A75),
                      ),
                    ),

                    //save / update btn
                    const Spacer(),
                    TextButton(
                      onPressed: showConfirmDialog,
                      child: Text(
                        editDiary == null ? "SAVE" : "UPDATE",
                        style: const TextStyle(
                          color: Color(0xFFE06092),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // THE CONTENT
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // DATE + EMOJI
                      Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),

                        //Day num
                        child: Row(
                          children: [
                            Text(
                              DateFormat("dd").format(selectedDate),
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 14),

                            //day&month
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormat("EEEE").format(selectedDate),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  DateFormat("MMM yyyy").format(selectedDate),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),

                            //calendar btn
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.calendar_month),
                              onPressed: pickDate,
                            ),

                            //Emojic selector
                            GestureDetector(
                              onTap: showEmojiPicker,
                              child: Text(
                                selectedEmoji,
                                style: const TextStyle(fontSize: 28),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // intput title
                      TextField(
                        controller: titleController,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: const InputDecoration(
                          hintText: "Title of the day...",
                          border: InputBorder.none,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // content input
                      TextField(
                        controller: descriptionController,
                        maxLines: null,
                        style: const TextStyle(fontSize: 16, height: 1.6),
                        decoration: const InputDecoration(
                          hintText: "Write your thoughts here...",
                          border: InputBorder.none,
                        ),
                      ),

                      const SizedBox(height: 30),

                      // img selection area
                      GestureDetector(
                        onTap: selectCameraGalleryDialog,
                        child: Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.black26),
                          ),

                          //show img / placeholder
                          child: image == null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.camera_alt_rounded),
                                    SizedBox(height: 10),
                                    Text("Tap to add photo"),
                                  ],
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.file(image!, fit: BoxFit.cover),
                                ),
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // SET DATE PICKER
  Future<void> pickDate() async {
    //show date dialog
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2090),
    );

    //updated selected date
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  // SET EMOJI PICKER
  void showEmojiPicker() {
    showModalBottomSheet(
      context: context,

      //top corner
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),

          //display emoji
          child: GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            children: emojiList.map((emoji) {
              return GestureDetector(
                onTap: () {
                  setState(() => selectedEmoji = emoji);
                  Navigator.pop(context);
                },
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 32)),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  //CONFRIMATION TO SAVE OR UPDATE
  void showConfirmDialog() {
    if (titleController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Title and content cannot be empty")),
      );
      return;
    }

    //dialog confirmation
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(editDiary == null ? "Save Diary?" : "Update Diary?"),
          content: Text(
            editDiary == null
                ? "Do you want to save this diary entry?"
                : "Do you want to update this diary entry?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                saveItem();
              },
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  // save record diary to db
  Future<void> saveItem() async {
    //app directory
    Directory dir = await getApplicationDocumentsDirectory();
    //default img path
    String imagePath = editDiary?.imagename ?? "NA";

    //save img if selected
    if (image != null) {
      String name = "${DateTime.now().millisecondsSinceEpoch}.png";
      imagePath = "${dir.path}/$name";
      await image!.copy(imagePath);
    }

    //combine title+emoji
    final String finalTitle = "$selectedEmoji ${titleController.text.trim()}";

    //insert /upddate
    if (editDiary == null) {
      await DatabaseHelper().insertMyList(
        DiaryListData(
          0,
          finalTitle,
          descriptionController.text.trim(),
          "Pending",
          formatter.format(selectedDate),
          imagePath,
        ),
      );
    } else {
      editDiary!.title = finalTitle;
      editDiary!.description = descriptionController.text.trim();
      editDiary!.date = formatter.format(selectedDate);
      editDiary!.imagename = imagePath;
      await DatabaseHelper().updateMyList(editDiary!);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            editDiary == null
                ? "Diary saved successfully"
                : "Diary updated successfully",
          ),
        ),
      );
      Navigator.pop(context);
    }
  }

  // choose camera or gallery
  void selectCameraGalleryDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.camera_alt_rounded, size: 36),
                onPressed: () {
                  Navigator.pop(context);
                  openCamera();
                },
              ),
              IconButton(
                icon: const Icon(Icons.photo_library_rounded, size: 36),
                onPressed: () {
                  Navigator.pop(context);
                  openGallery();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  //open camera
  Future<void> openCamera() async {
    //launch camera use a image_picker
    final picked = await ImagePicker().pickImage(source: ImageSource.camera);

    //check if user take pic or not
    if (picked != null) {
      image = File(picked.path);
      cropImage(); //to crop image method
    }
  }

  //open gallery
  Future<void> openGallery() async {
    //open gallery use image_picker
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);

    //check if user selected pic or not
    if (picked != null) {
      image = File(picked.path);
      cropImage(); //crop pic method
    }
  }

  //crop picture
  Future<void> cropImage() async {
    //open crop interface
    final cropped = await ImageCropper().cropImage(
      //path img to be crop
      sourcePath: image!.path,
      aspectRatio: const CropAspectRatio(ratioX: 5, ratioY: 3),
    );

    //to update img with crop ver
    if (cropped != null) {
      //refreshes ui to show new image
      setState(() => image = File(cropped.path));
    }
  }
}
