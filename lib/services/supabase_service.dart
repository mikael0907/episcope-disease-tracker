//lib/services/supabase_service.dart




import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // Fetch available roles from PostgreSQL enum
  Future<List<Map<String, dynamic>>> getUserRoles() async {
    try {
      // Query using the RPC function we created
      final response = await _client.rpc('get_user_roles');
      
      if (response.isEmpty) {
        // Fallback to hardcoded values if query fails or returns empty
        return [
          {'label': 'Regular User', 'value': 'regular_user', 'icon': 'person'},
          {'label': 'Academic Researcher', 'value': 'academic_researcher', 'icon': 'library_books'},
          {'label': 'Organization', 'value': 'organization', 'icon': 'groups'},
          {'label': 'Government', 'value': 'government', 'icon': 'assured_workload'},
          {'label': 'Hospital', 'value': 'hospital', 'icon': 'local_hospital'},
        ];
      }
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      // Fallback to hardcoded values if query fails
      return [
        {'label': 'Regular User', 'value': 'regular_user', 'icon': 'person'},
        {'label': 'Academic Researcher', 'value': 'academic_researcher', 'icon': 'library_books'},
        {'label': 'Organization', 'value': 'organization', 'icon': 'groups'},
        {'label': 'Government', 'value': 'government', 'icon': 'assured_workload'},
        {'label': 'Hospital', 'value': 'hospital', 'icon': 'local_hospital'},
      ];
    }
  }
}