import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:visitor_management_app/logic/visitor/visitor_event.dart';
import 'package:visitor_management_app/logic/visitor/visitor_state.dart';
import 'package:visitor_management_app/util/visitor_enum.dart';
import '../core/app_theme.dart';
import '../logic/visitor/visitor_bloc.dart';
import '../models/visitor.dart';
import 'widgets/common_widgets.dart';

class VisitorListPage extends StatelessWidget {
  const VisitorListPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Visitors'), actions: [
          IconButton(
              tooltip: 'Refresh',
              onPressed: () =>
                  context.read<VisitorBloc>().add(const VisitorsRequested()),
              icon: const Icon(Icons.refresh_rounded)),
          IconButton(
              tooltip: 'Register visitor',
              onPressed: () => context.push('/visitors/add'),
              icon: const Icon(Icons.person_add_alt_1_rounded)),
          const SizedBox(width: 6),
        ]),
        body: BlocConsumer<VisitorBloc, VisitorState>(
          listenWhen: (a, b) =>
              a.errorMessage != b.errorMessage || a.notice != b.notice,
          listener: (context, state) {
            final message = state.errorMessage ?? state.notice;
            if (message != null) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(message),
                  backgroundColor: state.errorMessage != null
                      ? AppTheme.red
                      : AppTheme.green));
            }
          },
          builder: (context, state) {
            final visitors = state.filteredVisitors;
            return Column(children: [
              Padding(
                  padding: const EdgeInsets.fromLTRB(18, 6, 18, 14),
                  child: TextField(
                    onChanged: (q) => context
                        .read<VisitorBloc>()
                        .add(VisitorSearchChanged(q)),
                    decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search_rounded),
                        hintText: 'Search name, mobile, project or status',
                        isDense: true),
                  )),
              Expanded(
                  child: state.status == VisitorStatus.loading &&
                          state.visitors.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : state.status == VisitorStatus.failure &&
                              state.visitors.isEmpty
                          ? EmptyState(
                              title: 'Could not load visitors',
                              subtitle: state.errorMessage ??
                                  'Check your network and API configuration.',
                              icon: Icons.cloud_off_rounded)
                          : visitors.isEmpty
                              ? EmptyState(
                                  title: 'No matching visitors',
                                  subtitle: state.searchQuery.isEmpty
                                      ? 'Register a visitor to get started.'
                                      : 'Try another name, mobile number or status.')
                              : RefreshIndicator(
                                  onRefresh: () async => context
                                      .read<VisitorBloc>()
                                      .add(const VisitorsRequested()),
                                  child: ListView.builder(
                                    padding: const EdgeInsets.fromLTRB(
                                        18, 0, 18, 20),
                                    itemCount: visitors.length,
                                    itemBuilder: (context, index) {
                                      final visitor = visitors[index];
                                      return VisitorCard(
                                        visitor: visitor,
                                        onTap: () => context.push('/visitors',
                                            extra: visitor),
                                        onEdit: () => context.push(
                                            '/visitors/edit',
                                            extra: visitor),
                                        onDelete: () =>
                                            _confirmDelete(context, visitor),
                                      );
                                    },
                                  ),
                                )),
            ]);
          },
        ),
      );

  void _confirmDelete(BuildContext context, Visitor visitor) {
    showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
              title: const Text('Delete visitor?'),
              content: Text(
                  'This will permanently delete ${visitor.name} from the visitor records.'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Cancel')),
                FilledButton(
                  style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.red,
                      foregroundColor: Colors.white),
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    context.read<VisitorBloc>().add(VisitorDeleted(visitor.id));
                  },
                  child: const Text('Delete'),
                ),
              ],
            ));
  }
}
