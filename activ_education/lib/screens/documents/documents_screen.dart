import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';

class DocumentsScreen extends StatefulWidget {
  final String trackingId;
  const DocumentsScreen({super.key, required this.trackingId});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final _api = ApiService();
  List<DocumentResponse> _documents = [];
  bool _isLoading = true;
  int _totalPages = 1;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments({int page = 0}) async {
    try {
      final pageRes = await _api.getDocuments(widget.trackingId, page: page, size: 20);
      if (!mounted) return;
      setState(() {
        _documents = pageRes.content;
        _totalPages = pageRes.totalPages;
        _currentPage = page;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt', 'jpg', 'jpeg', 'png'],
    );
    if (result == null || result.files.isEmpty) return;
    final pickedFile = result.files.single;

    if (!mounted) return;

    String? typeDocument;
    String? description;
    String? dateDocument;

    final formResult = await showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        String selectedType = 'AUTRE';
        final descCtrl = TextEditingController();
        final dateCtrl = TextEditingController();
        return AlertDialog(
          title: const Text('Ajouter un document'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Fichier : ${result.files.single.name}',
                    style: AppTextStyles.bodyMedium),
                const SizedBox(height: 16),
                const Text('Type de document', style: AppTextStyles.label),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  items: DocumentType.values.map((t) {
                    final label = _typeLabel(t.name);
                    return DropdownMenuItem(value: t.name, child: Text(label));
                  }).toList(),
                  onChanged: (v) {
                    if (v != null) selectedType = v;
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Description (optionnelle)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: dateCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Date du document (optionnelle, yyyy-MM-dd)',
                    border: OutlineInputBorder(),
                    hintText: '2025-06-15',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, null),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx, {
                  'typeDocument': selectedType,
                  'description': descCtrl.text,
                  'dateDocument': dateCtrl.text,
                });
              },
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );

    if (formResult == null || !mounted) return;

    typeDocument = formResult['typeDocument'];
    description = formResult['description'];
    dateDocument = formResult['dateDocument'];

    if (description?.isEmpty == true) description = null;
    if (dateDocument?.isEmpty == true) dateDocument = null;

    try {
      await _api.uploadDocument(
        widget.trackingId,
        pickedFile,
        typeDocument: typeDocument!,
        description: description,
        dateDocument: dateDocument,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document ajouté')),
        );
        _loadDocuments();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${_api.handleError(e)}')),
        );
      }
    }
  }

  Future<void> _deleteDocument(DocumentResponse doc) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer le document'),
        content: Text('Supprimer "${doc.nomFichier}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _api.deleteDocument(widget.trackingId, doc.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Document supprimé')),
          );
          _loadDocuments();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: ${_api.handleError(e)}')),
          );
        }
      }
    }
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'BULLETIN': return 'Bulletin';
      case 'ATTESTATION': return 'Attestation';
      case 'RELEVE_NOTES': return 'Relevé de notes';
      case 'CERTIFICAT_SCOLARITE': return 'Certificat de scolarité';
      default: return 'Autre';
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'BULLETIN': return Icons.grading;
      case 'ATTESTATION': return Icons.verified;
      case 'RELEVE_NOTES': return Icons.assignment;
      case 'CERTIFICAT_SCOLARITE': return Icons.school;
      default: return Icons.description;
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return dateStr;
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Mes documents',
            style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _uploadDocument,
            tooltip: 'Ajouter un document',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _documents.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.folder_open, size: 64,
                          color: AppColors.textLight),
                      const SizedBox(height: 16),
                      Text("Aucun document",
                          style: AppTextStyles.headingSmall),
                      const SizedBox(height: 8),
                      Text("Ajoutez bulletins, attestations…",
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.textLight)),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _uploadDocument,
                        icon: const Icon(Icons.add),
                        label: const Text('Ajouter un document'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => _loadDocuments(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _documents.length,
                    itemBuilder: (_, i) {
                      final doc = _documents[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(_typeIcon(doc.typeDocument),
                                color: AppColors.primary, size: 22),
                          ),
                          title: Text(doc.nomFichier,
                              style: AppTextStyles.bodyLarge,
                              overflow: TextOverflow.ellipsis),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  if (doc.typeDocumentLabel.isNotEmpty) ...[
                                    Text(doc.typeDocumentLabel,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w500)),
                                    const SizedBox(width: 8),
                                  ],
                                  if (doc.tailleFormatted.isNotEmpty)
                                    Text(doc.tailleFormatted,
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textLight)),
                                ],
                              ),
                              if (doc.description != null &&
                                  doc.description!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(doc.description!,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textMedium),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                ),
                              if (_formatDate(doc.dateDocument).isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(_formatDate(doc.dateDocument),
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textLight)),
                                ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: AppColors.error, size: 20),
                            onPressed: () => _deleteDocument(doc),
                          ),
                          onTap: () {
                            // Open file URL in browser
                            // launchUrl(Uri.parse(doc.urlFichier));
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
