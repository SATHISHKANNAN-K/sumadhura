import 'package:equatable/equatable.dart';

enum ScannerStatus {
  idle,
  processing,
  success,
  error,
}

class ScannerState extends Equatable {
  final ScannerStatus status;
  final String? message;
  final dynamic visitor;

  const ScannerState({
    this.status = ScannerStatus.idle,
    this.message,
    this.visitor,
  });

  bool get isProcessing => status == ScannerStatus.processing;

  bool get hasError => status == ScannerStatus.error;

  ScannerState copyWith({
    ScannerStatus? status,
    String? message,
    dynamic visitor,
    bool clearMessage = false,
    bool clearVisitor = false,
  }) {
    return ScannerState(
      status: status ?? this.status,
      message: clearMessage ? null : message ?? this.message,
      visitor: clearVisitor ? null : visitor ?? this.visitor,
    );
  }

  @override
  List<Object?> get props => [status, message, visitor];
}
