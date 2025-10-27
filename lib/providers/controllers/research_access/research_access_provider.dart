import 'package:disease_tracker/models/research_access_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ResearchAccessController
    extends StateNotifier<List<ResearchAccessRequest>> {
  ResearchAccessController() : super([]);

  void addRequest(ResearchAccessRequest request) {
    state = [...state, request];
  }

  void updateRequestStatus(String requestId, String newStatus) {
    state =
        state.map((request) {
          if (request.id == requestId) {
            return request.copyWith(status: newStatus);
          }
          return request;
        }).toList();
  }

  List<ResearchAccessRequest> getPendingRequests() {
    return state.where((request) => request.status == 'Pending').toList();
  }

  List<ResearchAccessRequest> getApprovedRequests() {
    return state.where((request) => request.status == 'Approved').toList();
  }

  List<ResearchAccessRequest> getRejectedRequests() {
    return state.where((request) => request.status == 'Rejected').toList();
  }

  int get pendingRequestCount => getPendingRequests().length;
}

final researchAccessControllerProvider = StateNotifierProvider<
  ResearchAccessController,
  List<ResearchAccessRequest>
>((ref) => ResearchAccessController());
