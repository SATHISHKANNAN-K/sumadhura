import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visitor_management_app/logic/visitor/visitor_event.dart';
import 'package:visitor_management_app/logic/visitor/visitor_state.dart';
import 'package:visitor_management_app/util/visitor_enum.dart';
import '../../data/visitor_repository.dart';
import '../../models/visitor.dart';

class VisitorBloc extends Bloc<VisitorEvent, VisitorState> {
  VisitorBloc(this._repository) : super(const VisitorState()) {
    on<VisitorsRequested>(_onLoad);
    on<VisitorSaved>(_onSave);
    on<VisitorDeleted>(_onDelete);
    on<VisitorCheckInRequested>(_onCheckIn);
    on<VisitorCheckOutRequested>(_onCheckOut);
    on<VisitorByIdRequested>(_onById);
    on<VisitorSearchChanged>(
        (event, emit) => emit(state.copyWith(searchQuery: event.query)));
  }
  final VisitorRepository _repository;

  Future<Visitor?> lookupVisitor(String id) async {
    try {
      return await _repository.getVisitor(id);
    } catch (_) {
      return null;
    }
  }

  Future<void> _onLoad(
      VisitorsRequested event, Emitter<VisitorState> emit) async {
    emit(state.copyWith(
        status: VisitorStatus.loading, clearError: true, clearNotice: true));
    try {
      final list = await _repository.getVisitors();
      emit(state.copyWith(
          status: VisitorStatus.loaded, visitors: list, clearError: true));
    } catch (e) {
      emit(state.copyWith(
          status: VisitorStatus.failure, errorMessage: _message(e)));
    }
  }

  Future<void> _onSave(VisitorSaved event, Emitter<VisitorState> emit) async {
    emit(state.copyWith(
        status: VisitorStatus.saving, clearError: true, clearNotice: true));
    try {
      if (event.visitor.id.isEmpty) {
        await _repository.createVisitor(event.visitor);
      } else {
        await _repository.updateVisitor(event.visitor);
      }
      final list = await _repository.getVisitors();
      emit(state.copyWith(
          status: VisitorStatus.loaded,
          visitors: list,
          notice: 'Visitor saved successfully.'));
    } catch (e) {
      emit(state.copyWith(
          status: VisitorStatus.loaded, errorMessage: _message(e)));
    }
  }

  Future<void> _onDelete(
      VisitorDeleted event, Emitter<VisitorState> emit) async {
    emit(state.copyWith(
        status: VisitorStatus.saving, clearError: true, clearNotice: true));
    try {
      await _repository.deleteVisitor(event.id);
      final list = await _repository.getVisitors();
      emit(state.copyWith(
          status: VisitorStatus.loaded,
          visitors: list,
          notice: 'Visitor deleted.'));
    } catch (e) {
      emit(state.copyWith(
          status: VisitorStatus.loaded, errorMessage: _message(e)));
    }
  }

  Future<void> _onCheckIn(
      VisitorCheckInRequested event, Emitter<VisitorState> emit) async {
    await _changeStatus(event.visitor, true, emit);
  }

  Future<void> _onCheckOut(
      VisitorCheckOutRequested event, Emitter<VisitorState> emit) async {
    await _changeStatus(event.visitor, false, emit);
  }

  Future<void> _changeStatus(
      Visitor visitor, bool checkIn, Emitter<VisitorState> emit) async {
    emit(state.copyWith(
        status: VisitorStatus.saving, clearError: true, clearNotice: true));
    try {
      if (checkIn) {
        await _repository.checkIn(visitor);
      } else {
        await _repository.checkOut(visitor);
      }
      final list = await _repository.getVisitors();
      final updated = list.where((v) => v.id == visitor.id).isEmpty
          ? null
          : list.firstWhere((v) => v.id == visitor.id);
      emit(state.copyWith(
        status: VisitorStatus.loaded,
        visitors: list,
        selectedVisitor: updated,
        notice: checkIn ? 'Visitor checked in.' : 'Visitor checked out.',
      ));
    } catch (e) {
      emit(state.copyWith(
          status: VisitorStatus.loaded, errorMessage: _message(e)));
    }
  }

  Future<void> _onById(
      VisitorByIdRequested event, Emitter<VisitorState> emit) async {
    try {
      final visitor = await _repository.getVisitor(event.id);
      emit(state.copyWith(
          status: VisitorStatus.loaded,
          selectedVisitor: visitor,
          clearError: true));
    } catch (e) {
      emit(state.copyWith(
          status: VisitorStatus.loaded,
          errorMessage: _message(e),
          clearSelected: true));
    }
  }

  String _message(Object error) =>
      error.toString().replaceFirst('Exception: ', '');
}
