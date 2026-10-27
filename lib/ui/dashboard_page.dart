import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:visitor_management_app/logic/visitor/visitor_event.dart';
import 'package:visitor_management_app/logic/visitor/visitor_state.dart';
import 'package:visitor_management_app/util/visitor_enum.dart';
import '../core/app_theme.dart';
import '../logic/visitor/visitor_bloc.dart';
import 'widgets/common_widgets.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) => BlocConsumer<VisitorBloc, VisitorState>(
        listenWhen: (a, b) => a.errorMessage != b.errorMessage,
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppTheme.red));
          }
        },
        builder: (context, state) {
          final loading =
              state.status == VisitorStatus.loading && state.visitors.isEmpty;
          return RefreshIndicator(
            onRefresh: () async =>
                context.read<VisitorBloc>().add(const VisitorsRequested()),
            child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                children: [
                  Row(children: [
                    Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(15)),
                        child: const Icon(Icons.apartment_rounded,
                            color: AppTheme.ink)),
                    const SizedBox(width: 12),
                    const Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text('FRONT DESK',
                              style: TextStyle(
                                  fontSize: 10,
                                  letterSpacing: 1.5,
                                  color: AppTheme.muted,
                                  fontWeight: FontWeight.w800)),
                          SizedBox(height: 3),
                          Text('Visitor overview',
                              style: TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.ink)),
                        ])),
                    IconButton(
                        onPressed: () => context
                            .read<VisitorBloc>()
                            .add(const VisitorsRequested()),
                        icon: const Icon(Icons.refresh_rounded)),
                  ]),
                  const SizedBox(height: 23),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFF292720), Color(0xFF494333)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('VISITOR MANAGEMENT',
                              style: TextStyle(
                                  color: AppTheme.primary,
                                  fontSize: 10,
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.w900)),
                          SizedBox(height: 12),
                          Text('Every visit,\naccounted for.',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 27,
                                  height: 1.12,
                                  fontWeight: FontWeight.w900)),
                          SizedBox(height: 10),
                          Text('Register. Verify. Welcome.',
                              style: TextStyle(
                                  color: Color(0xFFD7D2C5), fontSize: 13)),
                        ]),
                  ),
                  const SizedBox(height: 24),
                  const SectionTitle('Today at a glance'),
                  const SizedBox(height: 12),
                  if (loading)
                    const Padding(
                        padding: EdgeInsets.all(25),
                        child: Center(child: CircularProgressIndicator()))
                  else
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: StatCard(
                                  label: 'Registered today',
                                  value: state.registeredToday,
                                  icon: Icons.person_add_alt_1_rounded,
                                  tint: AppTheme.primary)),
                          const SizedBox(width: 9),
                          Expanded(
                              child: StatCard(
                                  label: 'Checked in',
                                  value: state.checkedInNow,
                                  icon: Icons.login_rounded,
                                  tint: AppTheme.green)),
                          const SizedBox(width: 9),
                          Expanded(
                              child: StatCard(
                                  label: 'Checked out',
                                  value: state.checkedOutToday,
                                  icon: Icons.logout_rounded,
                                  tint: AppTheme.blue)),
                        ]),
                  const SizedBox(height: 25),
                  const SectionTitle('Quick actions'),
                  const SizedBox(height: 12),
                  _ActionTile(
                      icon: Icons.person_add_alt_1_rounded,
                      title: 'Register a visitor',
                      subtitle: 'Create a new visitor pass',
                      onTap: () => context.push('/visitors/add')),
                  const SizedBox(height: 10),
                  _ActionTile(
                      icon: Icons.people_alt_outlined,
                      title: 'View visitor directory',
                      subtitle: '${state.visitors.length} visitor records',
                      onTap: () => context.push('/visitors')),
                  const SizedBox(height: 10),
                  _ActionTile(
                      icon: Icons.qr_code_scanner_rounded,
                      title: 'Scan visitor QR',
                      subtitle: 'Verify a pass at the gate',
                      onTap: () => context.push('/scanner')),
                  if (state.status == VisitorStatus.failure &&
                      state.visitors.isEmpty)
                    Padding(
                        padding: const EdgeInsets.only(top: 18),
                        child: OutlinedButton.icon(
                            onPressed: () => context
                                .read<VisitorBloc>()
                                .add(const VisitorsRequested()),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry loading visitors'))),
                  const SizedBox(height: 24),
                  const SectionTitle('Recent visitors'),
                  const SizedBox(height: 10),
                  if (state.visitors.isEmpty && !loading)
                    const EmptyState(
                        title: 'No visitor records yet',
                        subtitle:
                            'Register your first visitor to see activity here.')
                  else
                    ...state.visitors.take(3).map((v) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                              backgroundColor: const Color(0xFFF0E8D4),
                              child: Text(v.name.isEmpty
                                  ? '?'
                                  : v.name[0].toUpperCase())),
                          title: Text(v.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w800)),
                          subtitle: Text('${v.project} • ${v.mobile}'),
                          trailing: StatusChip(status: v.status),
                          onTap: () => context.push('/visitors', extra: v),
                        )),
                ]),
          );
        },
      );
}

class _ActionTile extends StatelessWidget {
  const _ActionTile(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.border)),
              child: Row(children: [
                Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                        color: const Color(0xFFF0E8D4),
                        borderRadius: BorderRadius.circular(13)),
                    child: Icon(icon, color: AppTheme.ink)),
                const SizedBox(width: 13),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(title,
                          style: const TextStyle(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text(subtitle,
                          style: const TextStyle(
                              color: AppTheme.muted, fontSize: 12)),
                    ])),
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 15, color: AppTheme.muted),
              ]),
            )),
      );
}
