import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visitor_management_app/logic/visitor/visitor_event.dart';
import 'package:visitor_management_app/logic/visitor/visitor_state.dart';
import 'package:visitor_management_app/util/visitor_enum.dart';
import '../core/app_theme.dart';
import '../logic/visitor/visitor_bloc.dart';
import '../models/visitor.dart';

class VisitorFormPage extends StatefulWidget {
  const VisitorFormPage({super.key, this.visitor});
  final Visitor? visitor;
  @override
  State<VisitorFormPage> createState() => _VisitorFormPageState();
}

class _VisitorFormPageState extends State<VisitorFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _mobile = TextEditingController();
  final _email = TextEditingController();
  final _purpose = TextEditingController();
  String _type = 'Customer';
  String _project = 'Project A';
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    final v = widget.visitor;
    if (v != null) {
      _name.text = v.name;
      _mobile.text = v.mobile;
      _email.text = v.email ?? '';
      _purpose.text = v.purpose;
      _type = v.visitorType;
      _project = v.project;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _mobile.dispose();
    _email.dispose();
    _purpose.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocListener<VisitorBloc, VisitorState>(
        listenWhen: (a, b) =>
            a.notice != b.notice || a.errorMessage != b.errorMessage,
        listener: (context, state) {
          if (state.errorMessage != null && _submitted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppTheme.red));
            _submitted = false;
          } else if (state.notice != null && _submitted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.notice!), backgroundColor: AppTheme.green));
            Navigator.pop(context);
          }
        },
        child: Scaffold(
          appBar: AppBar(
              title: Text(widget.visitor == null
                  ? 'Register visitor'
                  : 'Edit visitor')),
          body: Form(
            key: _formKey,
            child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
                children: [
                  Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                          color: const Color(0xFF292720),
                          borderRadius: BorderRadius.circular(20)),
                      child: const Row(children: [
                        Icon(Icons.badge_outlined,
                            color: AppTheme.primary, size: 30),
                        SizedBox(width: 13),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text('Visitor information',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 17)),
                              SizedBox(height: 4),
                              Text('Fields marked required must be completed.',
                                  style: TextStyle(
                                      color: Color(0xFFD7D2C5), fontSize: 12)),
                            ])),
                      ])),
                  const SizedBox(height: 23),
                  _label('Visitor name *'),
                  TextFormField(
                      controller: _name,
                      textCapitalization: TextCapitalization.words,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Enter visitor name'
                          : null,
                      decoration: const InputDecoration(
                          hintText: 'Full name',
                          prefixIcon: Icon(Icons.person_outline))),
                  const SizedBox(height: 16),
                  _label('Mobile number *'),
                  TextFormField(
                      controller: _mobile,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      decoration: const InputDecoration(
                          hintText: '10-digit mobile number',
                          prefixIcon: Icon(Icons.phone_outlined),
                          counterText: ''),
                      validator: (v) =>
                          v == null || !RegExp(r'^\d{10}$').hasMatch(v.trim())
                              ? 'Enter exactly 10 digits'
                              : null),
                  const SizedBox(height: 16),
                  _label('Email (optional)'),
                  TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                          hintText: 'name@example.com',
                          prefixIcon: Icon(Icons.mail_outline)),
                      validator: (v) {
                        final value = v?.trim() ?? '';
                        if (value.isNotEmpty &&
                            !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                .hasMatch(value)) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      }),
                  const SizedBox(height: 16),
                  _label('Visitor type *'),
                  DropdownButtonFormField<String>(
                      initialValue: _type,
                      items: const ['Customer', 'Vendor', 'Other']
                          .map(
                              (v) => DropdownMenuItem(value: v, child: Text(v)))
                          .toList(),
                      onChanged: (v) => setState(() => _type = v ?? 'Customer'),
                      decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.category_outlined))),
                  const SizedBox(height: 16),
                  _label('Project *'),
                  DropdownButtonFormField<String>(
                      initialValue: _project,
                      items: const ['Project A', 'Project B', 'Project C']
                          .map(
                              (v) => DropdownMenuItem(value: v, child: Text(v)))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _project = v ?? 'Project A'),
                      decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.apartment_outlined))),
                  const SizedBox(height: 16),
                  _label('Purpose of visit *'),
                  TextFormField(
                      controller: _purpose,
                      minLines: 2,
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Enter purpose of visit'
                          : null,
                      decoration: const InputDecoration(
                          hintText: 'e.g. Site visit, meeting with sales team',
                          alignLabelWithHint: true)),
                  const SizedBox(height: 26),
                  BlocBuilder<VisitorBloc, VisitorState>(
                      builder: (context, state) => Row(children: [
                            Expanded(
                                child: OutlinedButton(
                                    onPressed:
                                        state.status == VisitorStatus.saving
                                            ? null
                                            : () => Navigator.pop(context),
                                    child: const Text('Cancel'))),
                            const SizedBox(width: 12),
                            Expanded(
                                child: ElevatedButton.icon(
                              onPressed: state.status == VisitorStatus.saving
                                  ? null
                                  : _save,
                              icon: state.status == VisitorStatus.saving
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2))
                                  : const Icon(Icons.check_rounded),
                              label: Text(widget.visitor == null
                                  ? 'Register'
                                  : 'Save changes'),
                            )),
                          ])),
                ]),
          ),
        ),
      );

  Widget _label(String value) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(value,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)));
  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final existing = widget.visitor;
    final visitor = Visitor(
      id: existing?.id ?? '',
      name: _name.text.trim(),
      mobile: _mobile.text.trim(),
      email: _email.text.trim().isEmpty ? null : _email.text.trim(),
      visitorType: _type,
      project: _project,
      purpose: _purpose.text.trim(),
      status: existing?.status ?? 'Registered',
      createdAt: existing?.createdAt ?? DateTime.now().toIso8601String(),
      checkInTime: existing?.checkInTime,
      checkOutTime: existing?.checkOutTime,
    );
    _submitted = true;
    context.read<VisitorBloc>().add(VisitorSaved(visitor));
  }
}
