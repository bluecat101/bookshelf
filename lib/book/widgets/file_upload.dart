import 'package:bookshelf/book/logic/file_upload.dart';
import 'package:flutter/material.dart';

class FileUploadWidget extends StatefulWidget {
  final String label;
  const FileUploadWidget({super.key, required this.label});
  @override
  State<FileUploadWidget> createState() => _FileUploadWidgetState();
}

class _FileUploadWidgetState extends State<FileUploadWidget> {
  FileUploader result = FileUploader();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('${widget.label}の画像'),
        ElevatedButton(
          onPressed: () async {
            final FileUploader fileUploader = FileUploader();
            result = await fileUploader.pickFile();
            setState(() {});
          },
          child: const Text('アップロード'),
        ),
        Text(result.fileSelectionDisplayText()),
      ],
    );
  }
}
