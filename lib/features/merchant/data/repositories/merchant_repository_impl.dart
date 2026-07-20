import 'package:kept_aom/core/network/supabase_provider.dart';
import 'package:kept_aom/features/merchant/data/models/merchant_model.dart';
import 'package:kept_aom/features/merchant/domain/entities/merchant_entity.dart';
import 'package:kept_aom/features/merchant/domain/repositories/merchant_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kept_aom/core/utils/string_utils.dart';

part 'merchant_repository_impl.g.dart';

class MerchantRemoteDatasource {
  final SupabaseClient _supabase;

  MerchantRemoteDatasource(this._supabase);

  Future<MerchantModel?> findMerchantByNormalizedName(String rawName) async {
    final normalized = rawName.normalizeForSearch();
    if (normalized.isEmpty) return null;

    final response = await _supabase
        .from('merchants')
        .select()
        .eq('normalized_name', normalized)
        .maybeSingle();

    if (response != null) {
      return MerchantModel.fromJson(response);
    }
    return null;
  }

  Future<MerchantModel?> createMerchant(MerchantModel merchant) async {
    final Map<String, dynamic> data = merchant.toJson();
    if (merchant.normalizedName == null || merchant.normalizedName!.isEmpty) {
      data['normalized_name'] = merchant.name.normalizeForSearch();
    }

    final response = await _supabase
        .from('merchants')
        .insert(data)
        .select()
        .single();

    return MerchantModel.fromJson(response);
  }
}

class MerchantRepositoryImpl implements MerchantRepository {
  final MerchantRemoteDatasource _remoteDatasource;

  MerchantRepositoryImpl(this._remoteDatasource);

  @override
  Future<MerchantEntity?> findMerchantByNormalizedName(String rawName) {
    return _remoteDatasource.findMerchantByNormalizedName(rawName);
  }

  @override
  Future<MerchantEntity?> createMerchant(MerchantEntity merchant) {
    return _remoteDatasource.createMerchant(MerchantModel.fromEntity(merchant));
  }
}

@riverpod
MerchantRepository merchantRepository(MerchantRepositoryRef ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return MerchantRepositoryImpl(MerchantRemoteDatasource(supabase));
}
