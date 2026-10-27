// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../core/app_theme.dart';
import '../logic/visitor/visitor_bloc.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});
  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final MobileScannerController _controller = MobileScannerController();
  bool _processing = false;
  String? _message;
  bool _error = false;

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_processing) return;
    final raw =
        (capture.barcodes.isEmpty ? null : capture.barcodes.first.rawValue)
            ?.trim();
    if (raw == null || raw.isEmpty) {
      setState(() {
        _message = 'This QR code does not contain a visitor ID.';
        _error = true;
      });
      return;
    }
    setState(() {
      _processing = true;
      _message = 'Looking up visitor…';
      _error = false;
    });
    await _controller.stop();
    try {
      final bloc = context.read<VisitorBloc>();
      final visitor = await bloc.repositoryLookup(raw);
      if (!mounted) return;
      if (visitor == null) {
        setState(() {
          _message = 'No visitor found for ID: $raw';
          _error = true;
          _processing = false;
        });
        return;
      }
      setState(() {
        _message = 'Visitor verified';
        _error = false;
      });
      await context.push('/visitors', extra: visitor);
    } catch (_) {
      if (mounted) {
        setState(() {
          _message =
              'Unable to look up this QR code. Check API configuration and try again.';
          _error = true;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _processing = false);
        await _controller.start();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Scan visitor QR'), actions: [
          IconButton(
              onPressed: () => _controller.toggleTorch(),
              icon: const Icon(Icons.flash_on_outlined)),
          IconButton(
              onPressed: () => _controller.switchCamera(),
              icon: const Icon(Icons.cameraswitch_outlined)),
        ]),
        body: Column(children: [
          Expanded(
              child: Container(
            margin: const EdgeInsets.fromLTRB(18, 5, 18, 18),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
                color: Colors.black, borderRadius: BorderRadius.circular(24)),
            child: Stack(fit: StackFit.expand, children: [
              MobileScanner(controller: _controller, onDetect: _onDetect),
              Center(
                  child: Container(
                width: 245,
                height: 245,
                decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.primary, width: 4),
                    borderRadius: BorderRadius.circular(24)),
                child: const Align(
                    alignment: Alignment.topLeft,
                    child: Icon(Icons.crop_free_rounded,
                        color: AppTheme.primary, size: 36)),
              )),
              Positioned(
                  left: 20,
                  right: 20,
                  bottom: 22,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: .62),
                        borderRadius: BorderRadius.circular(14)),
                    child: const Text(
                        'Align the visitor QR code inside the frame',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w700)),
                  )),
            ]),
          )),
          if (_message != null)
            Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Row(children: [
                  Icon(_error ? Icons.error_outline : Icons.info_outline,
                      color: _error ? AppTheme.red : AppTheme.green),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(_message!,
                          style: TextStyle(
                              color: _error ? AppTheme.red : AppTheme.ink))),
                ])),
          const Padding(
              padding: EdgeInsets.fromLTRB(24, 0, 24, 25),
              child: Text(
                  'QR codes must contain the exact visitor ID returned by the REST API.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.muted, fontSize: 12))),
        ]),
      );
}

extension on VisitorBloc {
  Future<dynamic> repositoryLookup(String id) async {
    // Reuse the API-backed lookup event/state path via the repository is preferable;
    // this extension is implemented in the BLoC as a public helper below.
    return lookupVisitor(id);
  }
}
