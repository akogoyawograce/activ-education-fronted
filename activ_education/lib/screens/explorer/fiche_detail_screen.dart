// lib/screens/explorer/fiche_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_routes.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';
import '../../widgets/common_widgets.dart';

class FicheDetailScreen extends StatefulWidget {
  final FicheBase fiche;

  const FicheDetailScreen({super.key, required this.fiche});

  @override
  State<FicheDetailScreen> createState() => _FicheDetailScreenState();
}

class _FicheDetailScreenState extends State<FicheDetailScreen> {
  final _api = ApiService();
  bool _isFavori = false;
  String? _favoriId;
  List<FicheBase> _relatedFiches = [];
  bool _loadingRelated = true;

  // Accordéons ouverts
  final Set<String> _openSections = {'programme'};

  @override
  void initState() {
    super.initState();
    _checkFavori();
    _loadRelatedFiches();
  }

  Future<void> _checkFavori() async {
    try {
      final userId = await _api.getTrackingId();
      if (userId == null) return;
      final favs = await _api.explorer.getFavorisUtilisateur(userId, size: 100);
      if (!mounted) return;
      final match = favs.content.cast<FavoriResponse?>().firstWhere(
        (f) => f?.ficheTrackingId == widget.fiche.trackingId,
        orElse: () => null,
      );
      if (match != null) {
        setState(() {
          _isFavori = true;
          _favoriId = match.trackingId;
        });
      }
    } catch (_) {}
  }

  Future<void> _loadRelatedFiches() async {
    try {
      final type = widget.fiche.typeFiche?.toLowerCase() ?? '';
      PageResponse result;
      if (type.contains('serie')) {
        result = await _api.listerSeries(page: 0, size: 6);
      } else if (type.contains('filiere')) {
        result = await _api.listerFilieres(page: 0, size: 6);
      } else if (type.contains('metier')) {
        result = await _api.listerMetiers(page: 0, size: 6);
      } else {
        result = await _api.listerEtablissements(page: 0, size: 6);
      }
      setState(() {
        _relatedFiches = (result.content as List<FicheBase>)
            .where((f) => f.trackingId != widget.fiche.trackingId)
            .take(4)
            .toList();
        _loadingRelated = false;
      });
    } catch (_) {
      setState(() => _loadingRelated = false);
    }
  }

  Color get _typeColor {
    final type = widget.fiche.typeFiche?.toLowerCase() ?? '';
    if (type.contains('serie')) return AppColors.primary;
    if (type.contains('filiere')) return const Color(0xFF10B981);
    if (type.contains('metier')) return AppColors.accent;
    return const Color(0xFF8B5CF6);
  }

  String get _typeLabel {
    final type = widget.fiche.typeFiche?.toLowerCase() ?? '';
    if (type.contains('serie')) return 'Série';
    if (type.contains('filiere')) return 'Filière';
    if (type.contains('metier')) return 'Métier';
    return 'Établissement';
  }

  Future<void> _toggleFavori() async {
    try {
      final userId = await _api.getTrackingId();
      if (userId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Connectez-vous pour ajouter aux favoris')),
          );
        }
        return;
      }

      if (_isFavori && _favoriId != null) {
        await _api.supprimerFavori(_favoriId!);
        if (mounted) {
          setState(() {
            _isFavori = false;
            _favoriId = null;
          });
        }
      } else {
        final favori = await _api.ajouterFavori(FavoriRequest(
          utilisateurTrackingId: userId,
          ficheTrackingId: widget.fiche.trackingId,
        ));
        if (mounted) {
          setState(() {
            _isFavori = true;
            _favoriId = favori.trackingId;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_api.handleError(e))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Header ──────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: _typeColor,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 16),
              ),
            ),
            actions: [
              IconButton(
                onPressed: _toggleFavori,
                icon: Icon(
                  _isFavori
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: _share,
                icon: const Icon(Icons.share_outlined, color: Colors.white),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (widget.fiche.imageUrl != null && widget.fiche.imageUrl!.isNotEmpty)
                    AuthImage(
                      imageUrl: widget.fiche.imageUrl,
                      fit: BoxFit.cover,
                    )
                  else
                    Container(color: _typeColor),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.6),
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _typeLabel.toUpperCase(),
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.fiche.titre,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Contenu ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Niveau 1 : En bref ───────────────────────────────
                  _buildEnBref(),
                  const SizedBox(height: 24),

                  // ── Niveau 2 : Vidéo ─────────────────────────────────
                  if (widget.fiche.videoUrls.isNotEmpty)
                    _buildVideoSection(),

                  // ── Galerie photos ───────────────────────────────────
                  if (widget.fiche.imageUrls.length > 1)
                    _buildImageGallery(),

                  const SizedBox(height: 24),

                  // ── Niveau 3 : Pour aller plus loin ─────────────────
                  _buildPourAllerPlusLoin(),

                  const SizedBox(height: 32),

                  // ── Site web (établissements) ─────────────────────────
                  if (widget.fiche is FicheEtablissementResponse) _buildSiteWeb(),

                  // ── CTA Conseiller ───────────────────────────────────
                  _buildCTAConseiller(),

                  // ── Fiches similaires ────────────────────────────────
                  if (!_loadingRelated && _relatedFiches.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    _buildRelatedFiches(),
                  ],

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── NIVEAU 1 : EN BREF ───────────────────────────────────────────────────
  Widget _buildEnBref() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _typeColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: _typeColor.withValues(alpha: 0.15), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _typeColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'En bref',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.fiche.resume,
            style: AppTextStyles.bodyLarge,
          ),
          const SizedBox(height: 12),
          // Tags matières / spécialités
          _buildTags(),
        ],
      ),
    );
  }

  Widget _buildTags() {
    List<String> tags = [];

    if (widget.fiche is FicheSerieResponse) {
      final s = widget.fiche as FicheSerieResponse;
      if (s.matieresPrincipales != null) {
        tags = s.matieresPrincipales!.split(',').map((e) => e.trim()).toList();
      }
    } else if (widget.fiche is FicheFiliereResponse) {
      final f = widget.fiche as FicheFiliereResponse;
      if (f.duree != null) tags.add(f.duree!);
      if (f.niveauRequis != null) tags.add(f.niveauRequis!);
    } else if (widget.fiche is FicheMetierResponse) {
      final m = widget.fiche as FicheMetierResponse;
      if (m.secteur != null) tags.add(m.secteur!);
    } else if (widget.fiche is FicheEtablissementResponse) {
      final e = widget.fiche as FicheEtablissementResponse;
      final type = e.typeEtablissement ?? '';
      if (type.isNotEmpty) tags.add(type.replaceAll('_', ' ').toLowerCase());
      if (e.niveau != null) tags.add(e.niveau!);
    }

    if (tags.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: tags
          .take(4)
          .map((tag) => Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: _typeColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _typeColor,
                  ),
                ),
              ))
          .toList(),
    );
  }

  // ── NIVEAU 2 : VIDÉO ─────────────────────────────────────────────────────
  Widget _buildVideoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Comprendre en vidéo', style: AppTextStyles.headingMedium),
        const SizedBox(height: 12),
        ...widget.fiche.videoUrls.map((url) => Padding(
          padding: EdgeInsets.only(bottom: widget.fiche.videoUrls.length > 1 ? 12 : 0),
          child: _buildVideoCard(url),
        )),
      ],
    );
  }

  Widget _buildVideoCard(String videoUrl) {
    return GestureDetector(
      onTap: () => _launchUrl(videoUrl),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: 190,
          child: Stack(
            children: [
              if (widget.fiche.imageUrl != null)
                AuthImage(
                  imageUrl: widget.fiche.imageUrl,
                  height: 190,
                  fit: BoxFit.cover,
                )
              else
                Container(height: 190, color: AppColors.textDark),
              Container(color: Colors.black.withValues(alpha: 0.4)),
              Center(
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.play_arrow_rounded,
                      color: Colors.white, size: 30),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── GALERIE PHOTOS ────────────────────────────────────────────────────────
  Widget _buildImageGallery() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text('Photos', style: AppTextStyles.headingMedium),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: widget.fiche.imageUrls.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AuthImage(
                  imageUrl: widget.fiche.imageUrls[index],
                  height: 140,
                  width: 200,
                  fit: BoxFit.cover,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── NIVEAU 3 : POUR ALLER PLUS LOIN ──────────────────────────────────────
  Widget _buildPourAllerPlusLoin() {
    // Sections selon le type de fiche
    List<_Section> sections = _getSections();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pour aller plus loin', style: AppTextStyles.headingMedium),
        const SizedBox(height: 12),
        ...sections.map((s) => _buildAccordion(s)),
      ],
    );
  }

  List<_Section> _getSections() {
    if (widget.fiche is FicheSerieResponse) {
      final s = widget.fiche as FicheSerieResponse;
      return [
        _Section('Programme détaillé', s.matieresPrincipales ?? ''),
        const _Section('Profil idéal', 'Élève curieux, rigoureux, passionné par les matières de cette série.'),
        _Section('Débouchés', s.debouches ?? 'Plusieurs filières universitaires accessibles.'),
        const _Section('Témoignages', 'Des anciens élèves partagent leur expérience dans cette série.'),
      ];
    } else if (widget.fiche is FicheFiliereResponse) {
      final f = widget.fiche as FicheFiliereResponse;
      return [
        _Section('Conditions d\'admission', f.conditionsAdmission ?? ''),
        _Section('Programme pédagogique', f.programme ?? ''),
        _Section('Débouchés professionnels', f.debouchesMetiers ?? ''),
      ];
    } else if (widget.fiche is FicheMetierResponse) {
      final m = widget.fiche as FicheMetierResponse;
      return [
        _Section('Missions principales', m.missions ?? ''),
        _Section('Compétences requises', m.competences ?? ''),
        _Section('Débouchés au Togo', m.debouchesTogo ?? ''),
        _Section('Fourchette de salaire', m.fourchetteSalaire ?? ''),
      ];
    } else if (widget.fiche is FicheEtablissementResponse) {
      final e = widget.fiche as FicheEtablissementResponse;
      final filieresText = e.filieresProposees.isNotEmpty
          ? e.filieresProposees.map((f) => f.titre).join('\n')
          : '';
      return [
        _Section('Localisation', '${e.adresse ?? ''}\n${e.ville ?? ''}'),
        _Section('Offre de formation', e.offreFormation ?? ''),
        _Section('Filières proposées', filieresText),
        _Section('Contacts', e.contacts ?? ''),
        _Section('Site web', e.siteWeb ?? ''),
      ];
    }
    return [];
  }

  Widget _buildAccordion(_Section section) {
    final isOpen = _openSections.contains(section.titre);
    final hasContent = section.contenu.trim().isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              if (!hasContent) return;
              setState(() {
                if (isOpen) {
                  _openSections.remove(section.titre);
                } else {
                  _openSections.add(section.titre);
                }
              });
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      section.titre,
                      style: AppTextStyles.label,
                    ),
                  ),
                  if (hasContent)
                    AnimatedRotation(
                      turns: isOpen ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textMedium,
                        size: 20,
                      ),
                    )
                  else
                    const Icon(Icons.chevron_right_rounded,
                        color: AppColors.textLight, size: 20),
                ],
              ),
            ),
          ),
          if (isOpen && hasContent)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                section.contenu,
                style: AppTextStyles.bodyMedium,
              ),
            ),
        ],
      ),
    );
  }

  // ── CTA CONSEILLER ───────────────────────────────────────────────────────
  Widget _buildCTAConseiller() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          const Icon(Icons.support_agent_rounded,
              color: AppColors.primary, size: 28),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Une question sur cette fiche ?',
                  style: AppTextStyles.label,
                ),
                Text(
                  'Pose ta question à un conseiller',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(
              context, AppRoutes.messages,
              arguments: {'ficheContexte': widget.fiche.titre},
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Contacter',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── FICHES SIMILAIRES ─────────────────────────────────────────────────────
  Widget _buildRelatedFiches() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Fiches similaires', style: AppTextStyles.headingMedium),
        const SizedBox(height: 12),
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _relatedFiches.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) => _RelatedFicheCard(
              fiche: _relatedFiches[i],
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FicheDetailScreen(fiche: _relatedFiches[i]),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // ── HELPERS ───────────────────────────────────────────────────────────────
  // ── SITE WEB ──────────────────────────────────────────────────────────────
  Widget _buildSiteWeb() {
    final e = widget.fiche as FicheEtablissementResponse;
    final url = e.siteWeb;
    if (url == null || url.isEmpty) return const SizedBox.shrink();
    final displayUrl = url.replaceFirst(RegExp(r'^https?://'), '');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: InkWell(
        onTap: () => _launchUrl(url),
        child: Row(
          children: [
            const Icon(Icons.public_rounded, color: AppColors.primary, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Site officiel',
                      style: AppTextStyles.label),
                  Text(displayUrl,
                      style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary)),
                ],
              ),
            ),
            const Icon(Icons.open_in_new_rounded,
                color: AppColors.primary, size: 18),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _share() async {
    final text = '${widget.fiche.titre} — ${widget.fiche.resume}';
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Copié dans le presse-papier')),
      );
    }
  }
}

class _Section {
  final String titre;
  final String contenu;
  const _Section(this.titre, this.contenu);
}

class _RelatedFicheCard extends StatelessWidget {
  final FicheBase fiche;
  final VoidCallback onTap;

  const _RelatedFicheCard({required this.fiche, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              fiche.titre,
              style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w700, fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              fiche.resume,
              style: AppTextStyles.caption,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
