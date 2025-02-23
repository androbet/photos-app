import 'package:photos/models/collection/collection_items.dart';
import 'package:photos/models/file/file.dart';
import 'package:photos/models/search/search_result.dart';

class AlbumSearchResult extends SearchResult {
  final CollectionWithThumbnail collectionWithThumbnail;

  AlbumSearchResult(this.collectionWithThumbnail);

  @override
  ResultType type() {
    return ResultType.collection;
  }

  @override
  String name() {
    return collectionWithThumbnail.collection.displayName;
  }

  @override
  EnteFile? previewThumbnail() {
    return collectionWithThumbnail.thumbnail;
  }

  @override
  List<EnteFile> resultFiles() {
    // for album search result, we should open the album page directly
    throw UnimplementedError();
  }
}
