import 'package:equatable/equatable.dart';
import 'package:visitor_management_app/models/visitor.dart';
import 'package:visitor_management_app/util/visitor_enum.dart';

class VisitorState extends Equatable {
  const VisitorState({
    this.status = VisitorStatus.initial,
    this.visitors = const [],
    this.searchQuery = '',
    this.errorMessage,
    this.selectedVisitor,
    this.notice,
  });
  final VisitorStatus status;
  final List<Visitor> visitors;
  final String searchQuery;
  final String? errorMessage;
  final Visitor? selectedVisitor;
  final String? notice;

  List<Visitor> get filteredVisitors {
    final q = searchQuery.trim().toLowerCase();
    if (q.isEmpty) return visitors;
    return visitors
        .where((v) =>
            v.name.toLowerCase().contains(q) ||
            v.mobile.contains(q) ||
            v.project.toLowerCase().contains(q) ||
            v.status.toLowerCase().contains(q))
        .toList();
  }

  int get registeredToday {
    final now = DateTime.now();
    return visitors.where((v) {
      final d = DateTime.tryParse(v.createdAt)?.toLocal();
      return d != null &&
          d.year == now.year &&
          d.month == now.month &&
          d.day == now.day;
    }).length;
  }

  int get checkedInNow =>
      visitors.where((v) => v.status == 'Checked In').length;
  int get checkedOutToday {
    final now = DateTime.now();
    return visitors.where((v) {
      final d = DateTime.tryParse(v.checkOutTime ?? '')?.toLocal();
      return d != null &&
          d.year == now.year &&
          d.month == now.month &&
          d.day == now.day;
    }).length;
  }

  VisitorState copyWith({
    VisitorStatus? status,
    List<Visitor>? visitors,
    String? searchQuery,
    String? errorMessage,
    bool clearError = false,
    Visitor? selectedVisitor,
    bool clearSelected = false,
    String? notice,
    bool clearNotice = false,
  }) =>
      VisitorState(
        status: status ?? this.status,
        visitors: visitors ?? this.visitors,
        searchQuery: searchQuery ?? this.searchQuery,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
        selectedVisitor:
            clearSelected ? null : (selectedVisitor ?? this.selectedVisitor),
        notice: clearNotice ? null : (notice ?? this.notice),
      );

  @override
  List<Object?> get props => [
        status,
        visitors,
        searchQuery,
        errorMessage,
        selectedVisitor,
        notice,
      ];
}
