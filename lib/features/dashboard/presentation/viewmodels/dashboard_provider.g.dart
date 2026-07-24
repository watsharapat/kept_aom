// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dashboardHash() => r'bfff2d24b1c1a8185036eede182e115750c80e5a';

/// See also [dashboard].
@ProviderFor(dashboard)
final dashboardProvider = AutoDisposeProvider<DashboardState>.internal(
  dashboard,
  name: r'dashboardProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$dashboardHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DashboardRef = AutoDisposeProviderRef<DashboardState>;
String _$sixMonthCategoryComparisonHash() =>
    r'070ffd8bea52983868b7c20c8f5808556a5e7d9a';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [sixMonthCategoryComparison].
@ProviderFor(sixMonthCategoryComparison)
const sixMonthCategoryComparisonProvider = SixMonthCategoryComparisonFamily();

/// See also [sixMonthCategoryComparison].
class SixMonthCategoryComparisonFamily
    extends Family<SixMonthCategoryComparisonData> {
  /// See also [sixMonthCategoryComparison].
  const SixMonthCategoryComparisonFamily();

  /// See also [sixMonthCategoryComparison].
  SixMonthCategoryComparisonProvider call(bool isExpense) {
    return SixMonthCategoryComparisonProvider(isExpense);
  }

  @override
  SixMonthCategoryComparisonProvider getProviderOverride(
    covariant SixMonthCategoryComparisonProvider provider,
  ) {
    return call(provider.isExpense);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'sixMonthCategoryComparisonProvider';
}

/// See also [sixMonthCategoryComparison].
class SixMonthCategoryComparisonProvider
    extends AutoDisposeProvider<SixMonthCategoryComparisonData> {
  /// See also [sixMonthCategoryComparison].
  SixMonthCategoryComparisonProvider(bool isExpense)
    : this._internal(
        (ref) => sixMonthCategoryComparison(
          ref as SixMonthCategoryComparisonRef,
          isExpense,
        ),
        from: sixMonthCategoryComparisonProvider,
        name: r'sixMonthCategoryComparisonProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$sixMonthCategoryComparisonHash,
        dependencies: SixMonthCategoryComparisonFamily._dependencies,
        allTransitiveDependencies:
            SixMonthCategoryComparisonFamily._allTransitiveDependencies,
        isExpense: isExpense,
      );

  SixMonthCategoryComparisonProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.isExpense,
  }) : super.internal();

  final bool isExpense;

  @override
  Override overrideWith(
    SixMonthCategoryComparisonData Function(
      SixMonthCategoryComparisonRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SixMonthCategoryComparisonProvider._internal(
        (ref) => create(ref as SixMonthCategoryComparisonRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        isExpense: isExpense,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<SixMonthCategoryComparisonData> createElement() {
    return _SixMonthCategoryComparisonProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SixMonthCategoryComparisonProvider &&
        other.isExpense == isExpense;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, isExpense.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SixMonthCategoryComparisonRef
    on AutoDisposeProviderRef<SixMonthCategoryComparisonData> {
  /// The parameter `isExpense` of this provider.
  bool get isExpense;
}

class _SixMonthCategoryComparisonProviderElement
    extends AutoDisposeProviderElement<SixMonthCategoryComparisonData>
    with SixMonthCategoryComparisonRef {
  _SixMonthCategoryComparisonProviderElement(super.provider);

  @override
  bool get isExpense =>
      (origin as SixMonthCategoryComparisonProvider).isExpense;
}

String _$dashboardPeriodStateHash() =>
    r'd2f5893baed224de6ce4b64380123257dcda82a2';

/// See also [DashboardPeriodState].
@ProviderFor(DashboardPeriodState)
final dashboardPeriodStateProvider =
    AutoDisposeNotifierProvider<DashboardPeriodState, DashboardPeriod>.internal(
      DashboardPeriodState.new,
      name: r'dashboardPeriodStateProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$dashboardPeriodStateHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$DashboardPeriodState = AutoDisposeNotifier<DashboardPeriod>;
String _$dashboardAnchorDateStateHash() =>
    r'f262d0d1a1a995b2f5ac9ca649194d98292285a0';

/// See also [DashboardAnchorDateState].
@ProviderFor(DashboardAnchorDateState)
final dashboardAnchorDateStateProvider =
    AutoDisposeNotifierProvider<DashboardAnchorDateState, DateTime>.internal(
      DashboardAnchorDateState.new,
      name: r'dashboardAnchorDateStateProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$dashboardAnchorDateStateHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$DashboardAnchorDateState = AutoDisposeNotifier<DateTime>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
