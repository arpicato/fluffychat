import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:fluffychat/widgets/app_lock.dart';
import 'package:fluffychat/widgets/future_loading_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

XFile? _platformFileToXFile(PlatformFile file) {
  if (kIsWeb) {
    final bytes = file.bytes;
    if (bytes == null) return null;
    return XFile.fromData(
      bytes,
      name: file.name,
      length: file.size,
    );
  }

  final path = file.path;
  if (path == null || path.isEmpty) return null;
  return XFile(
    path,
    name: file.name,
    bytes: file.bytes,
    length: file.size,
  );
}

Future<List<XFile>> selectFiles(
  BuildContext context, {
  String? title,
  FileType type = FileType.any,
  bool allowMultiple = false,
}) async {
  final result = await AppLock.of(context).pauseWhile(
    showFutureLoadingDialog(
      context: context,
      future: () => FilePicker.pickFiles(
        compressionQuality: 0,
        allowMultiple: allowMultiple,
        type: type,
        withData: kIsWeb,
      ),
    ),
  );
  return result.result?.files
          .map(_platformFileToXFile)
          .whereType<XFile>()
          .toList() ??
      [];
}
