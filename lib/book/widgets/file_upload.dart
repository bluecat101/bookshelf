import 'package:bookshelf/book/logic/file_upload.dart';
import 'package:flutter/material.dart';

class FileUploadWidget extends StatefulWidget {
  final String label;
  final FileUploader fileUploader;
  const FileUploadWidget({
    super.key,
    required this.label,
    required this.fileUploader,
  });
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
            result = await widget.fileUploader.pickFile();
            setState(() {});
          },
          child: const Text('アップロード'),
        ),
        Text(result.fileSelectionDisplayText()),
      ],
    );
  }
}
