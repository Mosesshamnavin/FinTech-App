import '../models/cashout_model.dart';

class CashOutRemoteDataSource {
  // In-memory storage for mock data
  final List<CashOutModel> _cashOuts = [];

  Future<CashOutModel> addCashOut(CashOutModel cashOut) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    _cashOuts.add(cashOut);
    return cashOut;
  }

  Future<List<CashOutModel>> getActiveCashOuts(String? lineId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _cashOuts.where((c) => c.isActive && (lineId == null || c.lineId == lineId)).toList();
  }

  Future<List<CashOutModel>> getCashOutHistory(String? lineId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _cashOuts.where((c) => !c.isActive && (lineId == null || c.lineId == lineId)).toList();
  }

  Future<void> settleCashOut(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _cashOuts.indexWhere((c) => c.id == id);
    if (index != -1) {
      _cashOuts[index] = _cashOuts[index].copyWith(isActive: false);
    } else {
      throw Exception('CashOut not found');
    }
  }
}
