import 'dart:io';

import 'package:eClassify/features/subscription/cubits/bank_transfer_receipt_cubit.dart';
import 'package:eClassify/features/subscription/cubits/transaction_cubit.dart';
import 'package:eClassify/features/subscription/models/transaction.dart';
import 'package:eClassify/features/subscription/screens/transaction/receipt_file_display_sheet.dart';
import 'package:eClassify/features/subscription/screens/transaction/transaction_item.dart';
import 'package:eClassify/core/widgets/layout/paginated_view/paginated_view.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/utils/file_picker_utility.dart';
import 'package:eClassify/core/utils/helper_utils.dart';
import 'package:eClassify/core/widgets/ads/interstitial_ad_on_exit_mixin.dart';
import 'package:eClassify/core/widgets/feedback/loading_overlay.dart';
import 'package:eClassify/core/extensions/build_context_extensions.dart';
import 'package:eClassify/core/widgets/layout/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransactionHistory extends StatefulWidget {
  const TransactionHistory({super.key});

  static Route route(RouteSettings settings) {
    return MaterialPageRoute(
      settings: settings,
      builder: (context) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => TransactionCubit()),
            BlocProvider(create: (_) => BankTransferReceiptCubit()),
          ],
          child: const TransactionHistory(),
        );
      },
    );
  }

  @override
  State<TransactionHistory> createState() => _TransactionHistoryState();
}

class _TransactionHistoryState extends State<TransactionHistory>
    with InterstitialAdOnExitMixin {
  void _onUploadReceipt(Transaction transaction) async {
    final xfile = await FilePickerUtility.pickWithSheet(context: context);

    if (xfile == null) return;

    final file = File(xfile.first.path);

    final shouldUpload = await ReceiptFileDisplaySheet.show(context, file);

    if (shouldUpload ?? false) {
      context.read<BankTransferReceiptCubit>().uploadReceipt(
        transactionId: transaction.id,
        receipt: file,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BankTransferReceiptCubit, BankTransferReceiptState>(
      listener: (context, state) {
        if (state is BankTransferReceiptUploading) {
          LoadingOverlay.show(context);
        }
        if (state is BankTransferReceiptSuccess) {
          LoadingOverlay.hide();
          HelperUtils.showSnackBarMessage(context, state.responseMessage);
          context.read<TransactionCubit>().updateBankTransferTransaction(
            state.transactionId,
          );
        }
        if (state is BankTransferReceiptFailure) {
          LoadingOverlay.hide();
          HelperUtils.showSnackBarMessage(context, state.errorMessage);
        }
      },
      child: AppScaffold(
        appBar: AppBar(title: Text('transactionHistory'.translate(context))),
        body: PaginatedListView<TransactionCubit, Transaction, void>(
            padding: context.bodyPadding(),
            itemBuilder: (context, transaction) => TransactionItem(
              transaction: transaction,
              onUploadReceipt: () => _onUploadReceipt(transaction),
            ),
          ),
      ),
    );
  }
}
