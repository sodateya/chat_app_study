import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CustomCacheManager {
  static const key = 'customCacheKey';
  static CacheManager instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 30),
    ),
  );
}

final customCacheManager = CustomCacheManager.instance;

// class CustomCacheManagerForFriendList {
//   static const key = 'customCacheKey';
//   static CacheManager instance = CacheManager(
//     Config(
//       key,
//       stalePeriod: const Duration(days: 30),
//     ),
//   );
// }
// final customCacheManagerForFriendList = CustomCacheManager.instance;
