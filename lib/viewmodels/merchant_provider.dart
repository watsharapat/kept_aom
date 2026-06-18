import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kept_aom/models/merchant_model.dart';
import 'package:kept_aom/services/supabase_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kept_aom/utils/string_utils.dart'; // Ensure this exists

final merchantProvider = ChangeNotifierProvider(
  (ref) => MerchantProvider(ref.read(supabaseClientProvider)),
);

class MerchantProvider extends ChangeNotifier {
  final SupabaseClient _supabase;

  MerchantProvider(this._supabase);

  /// Searches for a merchant by its normalized name.
  /// Used by OCR to identify if a receiver is known.
  Future<Merchant?> findMerchantByNormalizedName(String rawName) async {
    final normalized = rawName.normalizeForSearch();
    if (normalized.isEmpty) return null;

    try {
      final response = await _supabase
          .from('merchants')
          .select()
          .eq('normalized_name', normalized)
          .maybeSingle();

      if (response != null) {
        return Merchant.fromJson(response);
      }
    } catch (e) {
      debugPrint('Error finding merchant: \$e');
    }
    return null;
  }

  /// Creates a new merchant from user classifications 
  /// and returns the newly created ID to attach to the transaction.
  Future<Merchant?> createMerchant(Merchant merchant) async {
    try {
      // Ensure the normalized name is set before inserting
      final Map<String, dynamic> data = merchant.toJson();
      if (merchant.normalizedName == null || merchant.normalizedName!.isEmpty) {
        data['normalized_name'] = merchant.name.normalizeForSearch();
      }

      final response = await _supabase
          .from('merchants')
          .insert(data)
          .select()
          .single();

      return Merchant.fromJson(response);
    } catch (e) {
      debugPrint('Error creating merchant: \$e');
      return null;
    }
  }
}
