import 'package:eClassify/core/cubits/paginated_cubit.dart';
import 'package:eClassify/core/models/paginated_result.dart';
import 'package:eClassify/features/subscription/models/transaction.dart';
import 'package:eClassify/features/subscription/repository/subscription_repository.dart';

class TransactionCubit extends PaginatedCubit<Transaction, void> {
  @override
  Future<PaginatedResult<Transaction>> getPage(int page, {void params}) {
    return SubscriptionRepository.instance.getTransactions(page);
  }

  void updateBankTransferTransaction(int transactionId) {
    if (state case DataState<Transaction> s) {
      final transactions = s.result.data;
      final index = transactions.indexWhere(
        (element) => element.id == transactionId,
      );
      if (index != -1) {
        transactions[index] = transactions[index].copyWith(
          hasUploadedReceipt: true,
        );
        emit(s.toSuccess(s.result.copyWithData(transactions, s.result.total)));
      }
    }
  }
}
