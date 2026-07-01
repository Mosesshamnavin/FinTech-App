import '../models/cashout_model.dart';

abstract class CashOutRemoteDataSource {
  Future<CashOutModel> addCashOut(CashOutModel cashOut);
  Future<List<CashOutModel>> getActiveCashOuts(String? lineId);
  Future<List<CashOutModel>> getCashOutHistory(String? lineId);
  Future<void> settleCashOut(String id);
}
