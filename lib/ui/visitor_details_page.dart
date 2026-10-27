import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:visitor_management_app/logic/visitor/visitor_event.dart';
import 'package:visitor_management_app/logic/visitor/visitor_state.dart';
import 'package:visitor_management_app/util/visitor_enum.dart';
import '../core/app_theme.dart';
import '../logic/visitor/visitor_bloc.dart';
import '../models/visitor.dart';
import 'widgets/common_widgets.dart';

class VisitorDetailsPage extends StatelessWidget {
  const VisitorDetailsPage({super.key, required this.visitor});
  final Visitor visitor;

  String _date(String? value) {
    if (value == null || value.isEmpty) return 'Not recorded';
    final parsed = DateTime.tryParse(value)?.toLocal();
    return parsed == null
        ? value
        : DateFormat('dd MMM yyyy, hh:mm a').format(parsed);
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<VisitorBloc, VisitorState>(
        listenWhen: (a, b) =>
            a.notice != b.notice || a.errorMessage != b.errorMessage,
        listener: (context, state) {
          final msg = state.errorMessage ?? state.notice;
          if (msg != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(msg),
                backgroundColor: state.errorMessage != null
                    ? AppTheme.red
                    : AppTheme.green));
          }
        },
        builder: (context, state) {
          final current =
              (state.visitors.where((v) => v.id == visitor.id).isEmpty
                      ? null
                      : state.visitors.firstWhere((v) => v.id == visitor.id)) ??
                  state.selectedVisitor ??
                  visitor;
          final saving = state.status == VisitorStatus.saving;
          return Scaffold(
            appBar: AppBar(title: const Text('Visitor details'), actions: [
              IconButton(
                  tooltip: 'Edit visitor',
                  onPressed: () =>
                      context.push('/visitors/edit', extra: visitor),
                  icon: const Icon(Icons.edit_outlined)),
            ]),
            body: ListView(
                padding: const EdgeInsets.fromLTRB(20, 5, 20, 28),
                children: [
                  Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: AppTheme.border)),
                      child: Column(children: [
                        CircleAvatar(
                            radius: 34,
                            backgroundColor: const Color(0xFFF0E8D4),
                            child: Text(
                                current.name.isEmpty
                                    ? '?'
                                    : current.name[0].toUpperCase(),
                                style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.ink))),
                        const SizedBox(height: 13),
                        Text(current.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 23, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 8),
                        StatusChip(status: current.status),
                        const SizedBox(height: 8),
                        Text('Visitor ID  ${current.id}',
                            style: const TextStyle(
                                color: AppTheme.muted, fontSize: 12)),
                      ])),
                  const SizedBox(height: 18),
                  _infoCard('VISITOR INFORMATION', [
                    _row(Icons.phone_outlined, 'Mobile', current.mobile),
                    _row(
                        Icons.mail_outline,
                        'Email',
                        (current.email?.isNotEmpty ?? false)
                            ? current.email!
                            : 'Not provided'),
                    _row(Icons.category_outlined, 'Visitor type',
                        current.visitorType),
                    _row(Icons.apartment_outlined, 'Project', current.project),
                    _row(Icons.assignment_outlined, 'Purpose', current.purpose),
                    _row(Icons.calendar_today_outlined, 'Registered',
                        _date(current.createdAt)),
                  ]),
                  const SizedBox(height: 14),
                  _infoCard('VISIT TIMELINE', [
                    _row(Icons.login_rounded, 'Checked in',
                        _date(current.checkInTime)),
                    _row(Icons.logout_rounded, 'Checked out',
                        _date(current.checkOutTime)),
                  ]),
                  const SizedBox(height: 14),
                  Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.border)),
                      child: Column(children: [
                        const Text('VISITOR PASS',
                            style: TextStyle(
                                fontSize: 11,
                                letterSpacing: 2,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.muted)),
                        const SizedBox(height: 12),
                        QrImageView(
                            data: current.id,
                            version: QrVersions.auto,
                            size: 190,
                            backgroundColor: Colors.white),
                        const SizedBox(height: 8),
                        Text(current.id,
                            style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2)),
                        const SizedBox(height: 5),
                        const Text('Present this QR code at the entrance.',
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(color: AppTheme.muted, fontSize: 12)),
                      ])),
                  const SizedBox(height: 20),
                  if (current.status == 'Registered')
                    ElevatedButton.icon(
                        onPressed: saving
                            ? null
                            : () => context
                                .read<VisitorBloc>()
                                .add(VisitorCheckInRequested(current)),
                        icon: const Icon(Icons.login_rounded),
                        label: const Text('Check in visitor'))
                  else if (current.status == 'Checked In')
                    ElevatedButton.icon(
                        onPressed: saving
                            ? null
                            : () => context
                                .read<VisitorBloc>()
                                .add(VisitorCheckOutRequested(current)),
                        icon: const Icon(Icons.logout_rounded),
                        label: const Text('Check out visitor'))
                  else
                    Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: AppTheme.green.withValues(alpha: .1),
                            borderRadius: BorderRadius.circular(14)),
                        child: const Row(children: [
                          Icon(Icons.check_circle_outline,
                              color: AppTheme.green),
                          SizedBox(width: 10),
                          Expanded(
                              child: Text(
                                  'Visit completed. This registration cannot be checked in again.',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.green)))
                        ])),
                  if (saving)
                    const Padding(
                        padding: EdgeInsets.all(12),
                        child: Center(child: CircularProgressIndicator())),
                ]),
          );
        },
      );

  Widget _infoCard(String title, List<Widget> children) => Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 10,
                  letterSpacing: 1.5,
                  color: AppTheme.muted,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          ...children,
        ]),
      );

  Widget _row(IconData icon, String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 18, color: AppTheme.primary),
          const SizedBox(width: 10),
          SizedBox(
              width: 92,
              child: Text(label,
                  style: const TextStyle(color: AppTheme.muted, fontSize: 12))),
          Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700))),
        ]),
      );
}
