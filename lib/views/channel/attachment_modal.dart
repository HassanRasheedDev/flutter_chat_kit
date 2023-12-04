import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_chat_kit/styles/colors.dart';
import 'package:image_picker/image_picker.dart';

class AttachmentModal {
  final BuildContext context;

  AttachmentModal({required this.context});

  Future<File?> getFile() {
    final wait = Completer<File?>();

    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
              child: Container(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    title: const Text(
                      'Camera',
                      ),
                    trailing: ImageIcon(
                      const AssetImage('assets/iconCamera@3x.png'),
                      color: primaryColor,
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      final res = await _showPicker(ImageSource.camera);
                      wait.complete(res);
                    }),
                ListTile(
                    title: const Text(
                      'Photo & Video Library',
                    ),
                    trailing: ImageIcon(
                      const AssetImage('assets/iconPhoto@3x.png'),
                      color: primaryColor,
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      final res = await _showPicker(ImageSource.gallery);
                      wait.complete(res);
                    }),
                ListTile(
                  title: const Text('Cancel'),
                  onTap: () {
                    Navigator.pop(context);
                    wait.complete(null);
                  },
                ),
              ],
            ),
          ));
        });

    return wait.future;
  }

  Future<File?> _showPicker(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }
}
