import "package:photo_manager/photo_manager.dart";

enum FileType {
  image,
  video,
  livePhoto,
  other,
}

int getInt(FileType fileType) {
  switch (fileType) {
    case FileType.image:
      return 0;
    case FileType.video:
      return 1;
    case FileType.livePhoto:
      return 2;
    default:
      return -1;
  }
}

FileType getFileType(int fileType) {
  switch (fileType) {
    case 0:
      return FileType.image;
    case 1:
      return FileType.video;
    case 2:
      return FileType.livePhoto;
    default:
      return FileType.other;
  }
}

FileType fileTypeFromAsset(AssetEntity asset) {
  FileType type = FileType.image;
  switch (asset.type) {
    case AssetType.image:
      type = FileType.image;
      // PHAssetMediaSubtype.photoLive.rawValue is 8
      // This hack should go away once photos_manager support livePhotos
      if (asset.subtype > -1 && (asset.subtype & 8) != 0) {
        type = FileType.livePhoto;
      }
      break;
    case AssetType.video:
      type = FileType.video;
      break;
    default:
      type = FileType.other;
      break;
  }
  return type;
}

String getHumanReadableString(FileType fileType) {
  switch (fileType) {
    case FileType.image:
      return "Image";
    case FileType.video:
      return "Video";
    case FileType.livePhoto:
      return "Live Photo";
    default:
      return fileType.name.toUpperCase();
  }
}
