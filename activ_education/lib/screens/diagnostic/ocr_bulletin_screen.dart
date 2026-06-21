import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../widgets/common_widgets.dart';

class OcrBulletinScreen extends StatefulWidget {
  final String eleveTrackingId;
  const OcrBulletinScreen({super.key, required this.eleveTrackingId});

  @override
  State<OcrBulletinScreen> createState() => _OcrBulletinScreenState();
}

class _OcrBulletinScreenState extends State<OcrBulletinScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>>? _notes;
  String? _error;

  Future<void> _analyser() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService().dio.post(
        '/api/v1/eleves/${widget.eleveTrackingId}/ocr',
        data: {'file': 'pending'},
      );
      setState(() {
        _notes = (res.data['notes'] as List).cast<Map<String, dynamic>>();
        _error = null;
      });
    } catch (e) {
      setState(() => _error = 'Erreur lors de l\'analyse');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Analyse de bulletin'), backgroundColor: AppColors.background),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.document_scanner, size: 64, color: AppColors.primary),
            const SizedBox(height: 16),
            const Text('Prends en photo ou importe ton bulletin', style: AppTextStyles.headingLarge),
            const SizedBox(height: 24),
            PrimaryButton(label: 'Analyser le bulletin', isLoading: _isLoading, onPressed: _analyser),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: const TextStyle(color: AppColors.error)),
            ],
            if (_notes != null) ...[
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: _notes!.length,
                  itemBuilder: (_, i) {
                    final n = _notes![i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(n['matiere'] ?? ''),
                        trailing: Text('${n['note']}/20', style: AppTextStyles.headingMedium),
                        subtitle: n['coefficient'] != null ? Text('Coeff: ${n['coefficient']}') : null,
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
