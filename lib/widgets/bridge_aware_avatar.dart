import 'package:fluffychat/services/bridge_room_presentation.dart';
import 'package:fluffychat/widgets/avatar.dart';
import 'package:flutter/material.dart';

class BridgeAwareAvatar extends StatelessWidget {
  const BridgeAwareAvatar({
    required this.name,
    required this.mxContent,
    required this.size,
    this.provider,
    this.onTap,
    this.presenceUserId,
    this.presenceBackgroundColor,
    this.borderRadius,
    this.shapeBorder,
    super.key,
  });

  final String name;
  final Uri? mxContent;
  final double size;
  final BridgeProviderDefinition? provider;
  final VoidCallback? onTap;
  final String? presenceUserId;
  final Color? presenceBackgroundColor;
  final BorderRadius? borderRadius;
  final ShapeBorder? shapeBorder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Avatar(
            mxContent: mxContent,
            name: name,
            size: size,
            onTap: onTap,
            presenceUserId: presenceUserId,
            presenceBackgroundColor: presenceBackgroundColor,
            borderRadius: borderRadius,
            shapeBorder: shapeBorder,
          ),
          if (provider != null)
            Positioned(
              top: -2,
              right: -2,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: provider!.badgeColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: presenceBackgroundColor ?? theme.colorScheme.surface,
                    width: 1.5,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: Icon(
                    provider!.badgeIcon,
                    size: 10,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
