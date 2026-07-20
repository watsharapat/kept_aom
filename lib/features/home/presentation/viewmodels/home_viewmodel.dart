import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_viewmodel.g.dart';

@riverpod
class MonthlyBalanceToggle extends _$MonthlyBalanceToggle {
  @override
  bool build() {
    return false;
  }

  void toggle() {
    state = !state;
  }
}
