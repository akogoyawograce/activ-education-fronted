import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_routes.dart';
import '../../widgets/common_widgets.dart';

class EtablissementsMapScreen extends StatefulWidget {
  const EtablissementsMapScreen({super.key});

  @override
  State<EtablissementsMapScreen> createState() =>
      _EtablissementsMapScreenState();
}

class _EtablissementsMapScreenState extends State<EtablissementsMapScreen> {
  final _api = ApiService();
  List<FicheEtablissementResponse> _etablissements = [];
  bool _isLoading = true;

  static const _center = LatLng(8.6195, 0.8248); // Centered on Togo

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final etablissements = await _api.explorer.listerEtablissements(
        size: 200,
      );
      setState(() {
        _etablissements = etablissements.content;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  List<Marker> _buildMarkers() {
    return _etablissements
        .where((e) => e.latitude != null && e.longitude != null)
        .map((e) => Marker(
              point: LatLng(e.latitude!, e.longitude!),
              width: 40,
              height: 40,
              child: GestureDetector(
                onTap: () => _showDetail(e),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      e.titre.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ))
        .toList();
  }

  void _showDetail(FicheEtablissementResponse etablissement) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(etablissement.titre, style: AppTextStyles.headingMedium),
            const SizedBox(height: 8),
            if (etablissement.ville != null)
              Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 16, color: AppColors.textLight),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(etablissement.ville!,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyMedium),
                  ),
                ],
              ),
            if (etablissement.adresse != null) ...[
              const SizedBox(height: 4),
              Text(etablissement.adresse!, style: AppTextStyles.bodyMedium),
            ],
            if (etablissement.siteWeb != null) ...[
              const SizedBox(height: 4),
              Text(etablissement.siteWeb!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                  )),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                label: 'Voir la fiche',
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(
                    context,
                    AppRoutes.ficheDetail,
                    arguments: {'fiche': etablissement},
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Établissements'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              options: MapOptions(
                initialCenter: _center,
                initialZoom: 7.5,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'tg.edtch.activEducation',
                ),
                MarkerLayer(markers: _buildMarkers()),
              ],
            ),
    );
  }
}
