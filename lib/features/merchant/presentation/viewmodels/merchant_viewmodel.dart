import 'package:kept_aom/features/merchant/data/repositories/merchant_repository_impl.dart';
import 'package:kept_aom/features/merchant/domain/entities/merchant_entity.dart';
import 'package:kept_aom/features/merchant/domain/repositories/merchant_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'merchant_viewmodel.g.dart';

@riverpod
class MerchantViewModel extends _$MerchantViewModel {
  @override
  void build() {}

  Future<MerchantEntity?> findMerchantByNormalizedName(String rawName) {
    return ref.read(merchantRepositoryProvider).findMerchantByNormalizedName(rawName);
  }

  Future<MerchantEntity?> createMerchant(MerchantEntity merchant) {
    return ref.read(merchantRepositoryProvider).createMerchant(merchant);
  }
}
