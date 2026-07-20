// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$categoriesByTypeHash() => r'b289a2bbd95b2e5919c7cfad6e803d359b874f0e';

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

/// See also [categoriesByType].
@ProviderFor(categoriesByType)
const categoriesByTypeProvider = CategoriesByTypeFamily();

/// See also [categoriesByType].
class CategoriesByTypeFamily extends Family<List<CategoryEntity>> {
  /// See also [categoriesByType].
  const CategoriesByTypeFamily();

  /// See also [categoriesByType].
  CategoriesByTypeProvider call(int typeId) {
    return CategoriesByTypeProvider(typeId);
  }

  @override
  CategoriesByTypeProvider getProviderOverride(
    covariant CategoriesByTypeProvider provider,
  ) {
    return call(provider.typeId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'categoriesByTypeProvider';
}

/// See also [categoriesByType].
class CategoriesByTypeProvider
    extends AutoDisposeProvider<List<CategoryEntity>> {
  /// See also [categoriesByType].
  CategoriesByTypeProvider(int typeId)
    : this._internal(
        (ref) => categoriesByType(ref as CategoriesByTypeRef, typeId),
        from: categoriesByTypeProvider,
        name: r'categoriesByTypeProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$categoriesByTypeHash,
        dependencies: CategoriesByTypeFamily._dependencies,
        allTransitiveDependencies:
            CategoriesByTypeFamily._allTransitiveDependencies,
        typeId: typeId,
      );

  CategoriesByTypeProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.typeId,
  }) : super.internal();

  final int typeId;

  @override
  Override overrideWith(
    List<CategoryEntity> Function(CategoriesByTypeRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CategoriesByTypeProvider._internal(
        (ref) => create(ref as CategoriesByTypeRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        typeId: typeId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<List<CategoryEntity>> createElement() {
    return _CategoriesByTypeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CategoriesByTypeProvider && other.typeId == typeId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, typeId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CategoriesByTypeRef on AutoDisposeProviderRef<List<CategoryEntity>> {
  /// The parameter `typeId` of this provider.
  int get typeId;
}

class _CategoriesByTypeProviderElement
    extends AutoDisposeProviderElement<List<CategoryEntity>>
    with CategoriesByTypeRef {
  _CategoriesByTypeProviderElement(super.provider);

  @override
  int get typeId => (origin as CategoriesByTypeProvider).typeId;
}

String _$categoryByIdHash() => r'94f5f0e8951440de7a64e20038b3977ecdb64698';

/// See also [categoryById].
@ProviderFor(categoryById)
const categoryByIdProvider = CategoryByIdFamily();

/// See also [categoryById].
class CategoryByIdFamily extends Family<CategoryEntity?> {
  /// See also [categoryById].
  const CategoryByIdFamily();

  /// See also [categoryById].
  CategoryByIdProvider call(int id) {
    return CategoryByIdProvider(id);
  }

  @override
  CategoryByIdProvider getProviderOverride(
    covariant CategoryByIdProvider provider,
  ) {
    return call(provider.id);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'categoryByIdProvider';
}

/// See also [categoryById].
class CategoryByIdProvider extends AutoDisposeProvider<CategoryEntity?> {
  /// See also [categoryById].
  CategoryByIdProvider(int id)
    : this._internal(
        (ref) => categoryById(ref as CategoryByIdRef, id),
        from: categoryByIdProvider,
        name: r'categoryByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$categoryByIdHash,
        dependencies: CategoryByIdFamily._dependencies,
        allTransitiveDependencies:
            CategoryByIdFamily._allTransitiveDependencies,
        id: id,
      );

  CategoryByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final int id;

  @override
  Override overrideWith(
    CategoryEntity? Function(CategoryByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CategoryByIdProvider._internal(
        (ref) => create(ref as CategoryByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<CategoryEntity?> createElement() {
    return _CategoryByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CategoryByIdProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CategoryByIdRef on AutoDisposeProviderRef<CategoryEntity?> {
  /// The parameter `id` of this provider.
  int get id;
}

class _CategoryByIdProviderElement
    extends AutoDisposeProviderElement<CategoryEntity?>
    with CategoryByIdRef {
  _CategoryByIdProviderElement(super.provider);

  @override
  int get id => (origin as CategoryByIdProvider).id;
}

String _$categoryViewModelHash() => r'c5d257487f262841dc884afb80a02204d499698b';

/// See also [CategoryViewModel].
@ProviderFor(CategoryViewModel)
final categoryViewModelProvider =
    AutoDisposeAsyncNotifierProvider<
      CategoryViewModel,
      List<CategoryEntity>
    >.internal(
      CategoryViewModel.new,
      name: r'categoryViewModelProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$categoryViewModelHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CategoryViewModel = AutoDisposeAsyncNotifier<List<CategoryEntity>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
