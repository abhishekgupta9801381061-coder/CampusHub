import 'partner_request.dart';

abstract class PartnerRequestRepository {
  Future<List<PartnerRequest>> getActiveRequests({String? typeFilter, String? query});
  Future<List<PartnerRequest>> getMyRequests(String userId);
  Future<PartnerRequest> getRequestById(String id);
  Future<PartnerRequest> createRequest({
    required String authorId,
    required String authorName,
    required String authorHandle,
    required String authorBranch,
    required String authorHostel,
    required String type,
    required String title,
    required String description,
    required List<String> tags,
  });
  Future<PartnerRequest> updateRequest({
    required String requestId,
    required String userId,
    required String title,
    required String description,
    required List<String> tags,
  });
  Future<void> deleteRequest({required String requestId, required String userId});
  Future<void> reportRequest(String requestId);
  Future<bool> canUserCreateToday(String userId);
}
