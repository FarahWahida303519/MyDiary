import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mydiary/databasehelper.dart';
import 'package:mydiary/diarylistdata.dart';
import 'package:path_provider/path_provider.dart';

class NewItemScreen extends StatefulWidget {
  const NewItemScreen({super.key});

  @override
  State<NewItemScreen> createState() => _NewItemScreenState();
}

class _NewItemScreenState extends State<NewItemScreen> {
  File? image;
  DiaryListData? editDiary;

  DateTime selectedDate = DateTime.now();
  String selectedEmoji = "🙂";

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final DateFormat formatter = DateFormat('dd MMM yyyy');

  final List<String> emojiList = [
    "😀","😊","🥰","😍","😎","😢","😭","😡",
    "😴","🤔","😇","🥳","😌","😔","😤","🤍"
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is DiaryListData && editDiary == null) {
      editDiary = args;

      if (args.title.isNotEmpty && emojiList.contains(args.title[0])) {
        selectedEmoji = args.title[0];
        titleController.text = args.title.substring(2);
      } else {
        titleController.text = args.title;
      }

      descriptionController.text = args.description;
      selectedDate = formatter.parse(args.date);

      if (args.imagename != "NA") {
        image = File(args.imagename);
      }
    }
  }

  // ================= DATE PICKER =================
  Future<void> pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFE06092),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  // ================= EMOJI PICKER =================
  void showEmojiPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
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
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFFCE9F3),
      body: SafeArea(
        child: Column(
          children: [
            // ================= HEADER =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  const Text(
                    "My Diary",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: showConfirmDialog,
                    child: const Text(
                      "SAVE",
                      style: TextStyle(
                        color: Color(0xFFE06092),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ================= CONTENT =================
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ========== DATE CARD ==========
                    Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                      ),
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
                          const Spacer(),

                          // 🔹 Calendar icon cue
                          IconButton(
                            icon: const Icon(
                              Icons.calendar_month,
                              color: Colors.black54,
                            ),
                            onPressed: pickDate,
                          ),

                          // 🔹 Emoji picker
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

                    // ========== TITLE ==========
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

                    // ========== CONTENT ==========
                    TextField(
                      controller: descriptionController,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      style: const TextStyle(fontSize: 16, height: 1.6),
                      decoration: const InputDecoration(
                        hintText:
                            "Write your thoughts here\nThis is your safe space 💗",
                        border: InputBorder.none,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ========== IMAGE ==========
                    const Text(
                      "Memory Photo",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),

                    GestureDetector(
                      onTap: selectCameraGalleryDialog,
                      child: Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.black26),
                        ),
                        child: image == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.camera_alt_rounded,
                                      size: 36, color: Colors.black54),
                                  SizedBox(height: 10),
                                  Text("Tap to add a memory photo"),
                                ],
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.file(
                                  image!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
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
    );
  }

  // ================= IMAGE PICKER =================
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

  Future<void> openCamera() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.camera);
    if (picked != null) {
      image = File(picked.path);
      cropImage();
    }
  }

  Future<void> openGallery() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      image = File(picked.path);
      cropImage();
    }
  }

  Future<void> cropImage() async {
    final cropped = await ImageCropper().cropImage(
      sourcePath: image!.path,
      aspectRatio: const CropAspectRatio(ratioX: 5, ratioY: 3),
    );
    if (cropped != null) {
      setState(() => image = File(cropped.path));
    }
  }

  // ================= CONFIRM SAVE =================
  void showConfirmDialog() {
    if (titleController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Title and content cannot be empty.")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Save Diary"),
        content: const Text("Save this diary entry?"),
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
      ),
    );
  }

  // ================= SAVE =================
  Future<void> saveItem() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String imagePath = editDiary?.imagename ?? "NA";

    if (image != null) {
      String name = "${DateTime.now().millisecondsSinceEpoch}.png";
      imagePath = "${dir.path}/$name";
      await image!.copy(imagePath);
    }

    final String finalTitle =
        "$selectedEmoji ${titleController.text.trim()}";

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
        const SnackBar(content: Text("Diary saved 💗")),
      );
      Navigator.pop(context);
    }
  }
}
