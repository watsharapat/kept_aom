import 'package:kept_aom/features/merchant/domain/entities/merchant_entity.dart';

abstract class MerchantRepository {
  Future<MerchantEntity?> findMerchantByNormalizedName(String rawName);
  Future<MerchantEntity?> createMerchant(MerchantEntity merchant);
}
