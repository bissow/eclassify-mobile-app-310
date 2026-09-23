import 'package:eClassify/app/routes.dart';
import 'package:eClassify/features/location/cubits/leaf_location_cubit.dart';
import 'package:eClassify/features/location/models/leaf_location.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LocationWidget extends StatefulWidget {
  const LocationWidget({super.key});

  @override
  State<LocationWidget> createState() => _LocationWidgetState();
}

class _LocationWidgetState extends State<LocationWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        final location =
            await Navigator.of(context).pushNamed(Routes.locationScreen)
                as LeafLocation?;

        if (location == null) return;

        context.read<LeafLocationCubit>().setLocation(location);
      },
      child: Row(
        spacing: 10,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox.square(
            dimension: 40,
            child: Icon(
              AppIcons.mapPinLine,
              color: context.colorScheme.primary,
            ),
          ),
          Expanded(
            child: BlocBuilder<LeafLocationCubit, LeafLocation?>(
              builder: (context, state) {
                final location = state;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location?.primaryText ?? "location".translate(context),
                      style: context.bodyMedium.semiBold,
                    ),
                    if (location?.secondaryText != null)
                      Text(
                        location!.secondaryText!,
                        style: context.bodySmall,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    if (location == null || location.isEmpty)
                      Text(
                        'global'.translate(context),
                        style: context.bodySmall,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                  ],
                );
              },
            ),
          ),
          SizedBox(width: 10),
        ],
      ),
    );
  }
}
