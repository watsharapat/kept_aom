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
