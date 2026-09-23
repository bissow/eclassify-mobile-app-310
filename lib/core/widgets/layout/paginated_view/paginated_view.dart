import 'package:eClassify/core/cubits/paginated_cubit.dart';
import 'package:eClassify/core/widgets/inputs/app_button.dart';
import 'package:eClassify/core/widgets/feedback/loading_indicator.dart';
import 'package:eClassify/core/widgets/feedback/q_error_widget.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/core/extensions/scroll_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'paginated_grid_view.dart';
part 'paginated_list_view.dart';
part 'src/paginated_base_view.dart';

typedef PaginatedItemBuilder<T> = Widget Function(BuildContext, T);
