import 'package:eClassify/core/widgets/feedback/q_error_widget.dart';
import 'package:eClassify/app/routes.dart';
import 'package:eClassify/features/subscription/cubits/active_subscription_package_cubit.dart';
import 'package:eClassify/features/notification/models/server_notification.dart';
import 'package:eClassify/features/subscription/models/subscription_package.dart';
import 'package:eClassify/features/notification/listeners/server_notification_listener.dart';
import 'package:eClassify/features/subscription/screens/widgets/package_widget.dart';
import 'package:eClassify/core/widgets/inputs/app_button.dart';
import 'package:eClassify/core/widgets/feedback/loading_indicator.dart';
import 'package:eClassify/core/extensions/number_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/widgets/layout/app_scaffold.dart';
import 'package:eClassify/core/extensions/build_context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ActivePlanScreen extends StatelessWidget {
  const ActivePlanScreen({super.key});

  static Route<dynamic> route(RouteSettings routeSettings) {
    final args = routeSettings.arguments;
    final activePlanCubit = args as ActiveSubscriptionPackageCubit?;

    return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => activePlanCubit == null
          ? BlocProvider(
              create: (_) => ActiveSubscriptionPackageCubit(),
              child: ActivePlanScreen(),
            )
          : BlocProvider.value(
              value: activePlanCubit,
              child: ActivePlanScreen(),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ServerNotificationListener<PaymentNotification>(
      onNotification: (context, notification) {
        context.read<ActiveSubscriptionPackageCubit>().getPackages(
          silent: true,
        );
      },
      child: AppScaffold(
        appBar: AppBar(title: Text('activePlans'.translate(context))),
        bottomAction: AppButton(
          variant: AppButtonVariant.filled,
          onPressed: () {
            Navigator.of(context).pushNamed(Routes.subscriptionScreen);
          },
          title: 'browseAllPackages',
        ),
        body:
            BlocBuilder<
              ActiveSubscriptionPackageCubit,
              ActiveSubscriptionPackageState
            >(
              builder: (context, state) {
                if (state is ActiveSubscriptionPackageInitial) {
                  context.read<ActiveSubscriptionPackageCubit>().getPackages();
                }
                if (state is ActiveSubscriptionPackageFailure) {
                  return QErrorWidget(type: QErrorType.api);
                }
                if (state is ActiveSubscriptionPackageSuccess) {
                  if (state.activePackages.isEmpty) {
                    return QErrorWidget.emptyData();
                  }
                  final packages = state.activePackages;
                  return ListView.separated(
                    padding: context.bodyPadding(top: 40),
                    itemCount: packages.length,
                    itemBuilder: (context, index) => PackageWidget(
                      package: packages[index],
                      activePlanCapLabel: switch (packages[index].type) {
                        SubscriptionPackageType.featuredAds =>
                          'featuredAds'.translate(context),
                        SubscriptionPackageType.itemListing =>
                          'adsPackage'.translate(context),
                      },
                    ),
                    separatorBuilder: (context, index) => 30.vGap,
                  );
                }
                return Center(child: LoadingIndicator());
              },
            ),
      ),
    );
  }
}
