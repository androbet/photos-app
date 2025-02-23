import 'dart:io';
import 'dart:typed_data';

import "package:computer/computer.dart";
import 'package:dio/dio.dart';
import 'package:logging/logging.dart';
import 'package:photos/core/configuration.dart';
import 'package:photos/core/network/network.dart';
import 'package:photos/models/file/file.dart';
import 'package:photos/services/collections_service.dart';
import 'package:photos/utils/crypto_util.dart';
import "package:photos/utils/data_util.dart";

final _logger = Logger("file_download_util");

Future<File?> downloadAndDecrypt(
  EnteFile file, {
  ProgressCallback? progressCallback,
}) {
  final String logPrefix = 'File-${file.uploadedFileID}:';
  _logger.info('$logPrefix starting download');
  final encryptedFilePath = Configuration.instance.getTempDirectory() +
      file.generatedID.toString() +
      ".encrypted";
  final encryptedFile = File(encryptedFilePath);
  final startTime = DateTime.now().millisecondsSinceEpoch;
  return NetworkClient.instance
      .getDio()
      .download(
        file.downloadUrl,
        encryptedFilePath,
        options: Options(
          headers: {"X-Auth-Token": Configuration.instance.getToken()},
        ),
        onReceiveProgress: progressCallback,
      )
      .then((response) async {
    if (response.statusCode != 200) {
      _logger.warning('$logPrefix download failed  ${response.toString()}');
      return null;
    } else if (!encryptedFile.existsSync()) {
      _logger.warning('$logPrefix incomplete download, file not found');
      return null;
    }
    final int sizeInBytes = ((file.fileSize ?? 0) > 0)
        ? file.fileSize!
        : await encryptedFile.length();
    final double speedInKBps = sizeInBytes /
        1024.0 /
        ((DateTime.now().millisecondsSinceEpoch - startTime) / 1000);
    _logger.info(
      "$logPrefix download completed: ${formatBytes(sizeInBytes)}, avg speed: ${speedInKBps.toStringAsFixed(2)} KB/s",
    );

    final decryptedFilePath = Configuration.instance.getTempDirectory() +
        file.generatedID.toString() +
        ".decrypted";
    try {
      await CryptoUtil.decryptFile(
        encryptedFilePath,
        decryptedFilePath,
        CryptoUtil.base642bin(file.fileDecryptionHeader!),
        getFileKey(file),
      );
    } catch (e, s) {
      _logger.severe("failed to decrypt file", e, s);
      return null;
    }
    _logger.info('$logPrefix decryption completed');
    await encryptedFile.delete();
    return File(decryptedFilePath);
  });
}

Uint8List getFileKey(EnteFile file) {
  final encryptedKey = CryptoUtil.base642bin(file.encryptedKey!);
  final nonce = CryptoUtil.base642bin(file.keyDecryptionNonce!);
  final collectionKey =
      CollectionsService.instance.getCollectionKey(file.collectionID!);
  return CryptoUtil.decryptSync(encryptedKey, collectionKey, nonce);
}

Future<Uint8List> getFileKeyUsingBgWorker(EnteFile file) async {
  final collectionKey =
      CollectionsService.instance.getCollectionKey(file.collectionID!);
  return await Computer.shared().compute(
    _decryptFileKey,
    param: <String, dynamic>{
      "encryptedKey": file.encryptedKey,
      "keyDecryptionNonce": file.keyDecryptionNonce,
      "collectionKey": collectionKey,
    },
  );
}

Uint8List _decryptFileKey(Map<String, dynamic> args) {
  final encryptedKey = CryptoUtil.base642bin(args["encryptedKey"]);
  final nonce = CryptoUtil.base642bin(args["keyDecryptionNonce"]);
  return CryptoUtil.decryptSync(
    encryptedKey,
    args["collectionKey"],
    nonce,
  );
}
