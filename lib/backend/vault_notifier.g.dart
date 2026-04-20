// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vault_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$vaultRepositoryHash() => r'1294445df6e203e9dd1c1c83b20c07a4e59a14e3';

/// See also [vaultRepository].
@ProviderFor(vaultRepository)
final vaultRepositoryProvider = AutoDisposeProvider<VaultRepository>.internal(
  vaultRepository,
  name: r'vaultRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$vaultRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef VaultRepositoryRef = AutoDisposeProviderRef<VaultRepository>;
String _$vaultNotifierHash() => r'339b979a19667dd5df0582113d096d479f552441';

/// See also [VaultNotifier].
@ProviderFor(VaultNotifier)
final vaultNotifierProvider =
    AutoDisposeNotifierProvider<VaultNotifier, List<VaultItem>>.internal(
      VaultNotifier.new,
      name: r'vaultNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$vaultNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$VaultNotifier = AutoDisposeNotifier<List<VaultItem>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
