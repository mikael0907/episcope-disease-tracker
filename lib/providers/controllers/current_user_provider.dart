// providers/current_user_provider.dart
import 'package:disease_tracker/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final currentUserProvider = StateProvider<AppUser?>((ref) => null);
