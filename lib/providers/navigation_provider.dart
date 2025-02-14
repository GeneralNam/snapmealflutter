import 'package:flutter_riverpod/flutter_riverpod.dart';

// StateProvider로 변경 (더 간단한 상태 관리를 위해)
final navigationProvider = StateProvider<int>((ref) => 0);
