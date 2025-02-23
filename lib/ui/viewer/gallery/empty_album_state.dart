import "package:flutter/material.dart";
import "package:photos/generated/l10n.dart";
import 'package:photos/models/collection/collection.dart';
import "package:photos/ui/components/buttons/button_widget.dart";
import "package:photos/ui/components/models/button_type.dart";
import "package:photos/ui/viewer/gallery/hooks/add_photos_sheet.dart";
import "package:photos/utils/dialog_util.dart";

class EmptyAlbumState extends StatelessWidget {
  final Collection c;
  const EmptyAlbumState(this.c, {super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Opacity(
            opacity: 0.5,
            child: Image.asset('assets/loading_photos_background.png'),
          ),
        ),
        Center(
          child: ButtonWidget(
            buttonType: ButtonType.primary,
            buttonSize: ButtonSize.small,
            labelText: S.of(context).addPhotos,
            icon: Icons.add_photo_alternate_outlined,
            shouldSurfaceExecutionStates: false,
            onTap: () async {
              try {
                await showAddPhotosSheet(context, c);
              } catch (e) {
                showGenericErrorDialog(context: context);
              }
            },
          ),
        ),
      ],
    );
  }
}
