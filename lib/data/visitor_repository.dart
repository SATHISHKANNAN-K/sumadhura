import '../models/visitor.dart';
import 'visitor_api.dart';

class VisitorRepository {
  VisitorRepository({VisitorApi? api}) : _api = api ?? VisitorApi();
  final VisitorApi _api;

  Future<List<Visitor>> getVisitors() => _api.getVisitors();
  Future<Visitor> getVisitor(String id) => _api.getVisitor(id);
  Future<Visitor> createVisitor(Visitor visitor) => _api.createVisitor(visitor);
  Future<Visitor> updateVisitor(Visitor visitor) => _api.updateVisitor(visitor);
  Future<void> deleteVisitor(String id) => _api.deleteVisitor(id);

  Future<Visitor> checkIn(Visitor visitor) {
    if (visitor.status != 'Registered') {
      throw const ApiException('Only registered visitors can check in.');
    }
    return updateVisitor(visitor.copyWith(
      status: 'Checked In',
      checkInTime: DateTime.now().toIso8601String(),
    ));
  }

  Future<Visitor> checkOut(Visitor visitor) {
    if (visitor.status != 'Checked In') {
      throw const ApiException('Only checked-in visitors can check out.');
    }
    return updateVisitor(visitor.copyWith(
      status: 'Checked Out',
      checkOutTime: DateTime.now().toIso8601String(),
    ));
  }
}
