// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$activityRepositoryHash() =>
    r'953777fce7ad6db0fe72fa3c002b0854bfd0d1a3';

/// See also [activityRepository].
@ProviderFor(activityRepository)
final activityRepositoryProvider =
    AutoDisposeProvider<ActivityRepository>.internal(
      activityRepository,
      name: r'activityRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$activityRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActivityRepositoryRef = AutoDisposeProviderRef<ActivityRepository>;
String _$activityNotifierHash() => r'f89535a93fe2f5f39ceb85b9ddc6ed3dde1e469c';

/// See also [ActivityNotifier].
@ProviderFor(ActivityNotifier)
final activityNotifierProvider =
    AutoDisposeNotifierProvider<ActivityNotifier, List<ActivityItem>>.internal(
      ActivityNotifier.new,
      name: r'activityNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$activityNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ActivityNotifier = AutoDisposeNotifier<List<ActivityItem>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
