import 'package:flutter/widgets.dart';
import 'package:photos/models/file/file.dart';
import 'package:photos/ui/viewer/file/no_thumbnail_widget.dart';
import 'package:photos/ui/viewer/file/thumbnail_widget.dart';

class SearchThumbnailWidget extends StatelessWidget {
  final EnteFile? file;
  final String tagPrefix;

  const SearchThumbnailWidget(
    this.file,
    this.tagPrefix, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tagPrefix + (file?.tag ?? ""),
      child: SizedBox(
        height: 58,
        width: 58,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: file != null
              ? ThumbnailWidget(
                  file!,
                )
              : const NoThumbnailWidget(),
        ),
      ),
    );
  }
}
