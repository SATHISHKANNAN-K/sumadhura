import 'package:flutter_bloc/flutter_bloc.dart';
import 'scanner_event.dart';
import 'scanner_state.dart';

class ScannerBloc extends Bloc<ScannerEvent, ScannerState> {
  ScannerBloc() : super(const ScannerState()) {
    on<ScannerLookupStarted>((event, emit) {
      emit(
        const ScannerState(
          status: ScannerStatus.processing,
          message: 'Looking up visitor…',
        ),
      );
    });

    on<ScannerVisitorFound>((event, emit) {
      emit(
        ScannerState(
          status: ScannerStatus.success,
          message: 'Visitor verified',
          visitor: event.visitor,
        ),
      );
    });

    on<ScannerVisitorNotFound>((event, emit) {
      emit(
        ScannerState(
          status: ScannerStatus.error,
          message: 'No visitor found for ID: ${event.visitorId}',
        ),
      );
    });

    on<ScannerLookupFailed>((event, emit) {
      emit(
        const ScannerState(
          status: ScannerStatus.error,
          message:
              'Unable to look up this QR code. Check API configuration and try again.',
        ),
      );
    });

    on<ScannerInvalidQr>((event, emit) {
      emit(
        const ScannerState(
          status: ScannerStatus.error,
          message: 'This QR code does not contain a visitor ID.',
        ),
      );
    });

    on<ScannerReset>((event, emit) {
      emit(const ScannerState());
    });
  }
}
