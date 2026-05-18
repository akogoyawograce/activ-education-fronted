import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  final _api = ApiService();
  final _searchController = TextEditingController();
  
  List<EntreeFAQResponse> _allFaqs = [];
  List<EntreeFAQResponse> _filteredFaqs = [];
  bool _isLoading = true;
  String? _selectedCategory;

  final Set<String> _openQuestions = {};

  @override
  void initState() {
    super.initState();
    _loadFaqs();
  }

  Future<void> _loadFaqs() async {
    try {
      setState(() => _isLoading = true);
      // Utilisation de listerFAQ qui retourne une PageResponse
      final res = await _api.explorer.listerFAQ(page: 0, size: 100);
      setState(() {
        _allFaqs = res.content;
        _filteredFaqs = res.content;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${_api.handleError(e as dynamic)}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _filterFaqs(String query) {
    setState(() {
      _filteredFaqs = _allFaqs.where((faq) {
        final matchesQuery = faq.question.toLowerCase().contains(query.toLowerCase()) || 
                             faq.reponse.toLowerCase().contains(query.toLowerCase());
        final matchesCategory = _selectedCategory == null || faq.categorie == _selectedCategory;
        return matchesQuery && matchesCategory;
      }).toList();
    });
  }

  List<String> get _categories {
    final cats = _allFaqs
        .where((e) => e.categorie != null)
        .map((e) => e.categorie!)
        .toSet()
        .toList();
    cats.sort();
    return cats;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Foire Aux Questions', style: AppTextStyles.headingMedium),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Header & Search
          _buildSearchHeader(),
          
          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredFaqs.isEmpty
                    ? _buildEmptyState()
                    : _buildFaqList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: _filterFaqs,
            decoration: InputDecoration(
              hintText: 'Comment pouvons-nous vous aider ?',
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
              filled: true,
              fillColor: AppColors.backgroundGrey,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          if (_categories.isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length + 1,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    final isSelected = _selectedCategory == null;
                    return _buildCategoryChip('Tous', isSelected, () {
                      setState(() {
                        _selectedCategory = null;
                        _filterFaqs(_searchController.text);
                      });
                    });
                  }
                  final cat = _categories[index - 1];
                  final isSelected = _selectedCategory == cat;
                  return _buildCategoryChip(cat, isSelected, () {
                    setState(() {
                      _selectedCategory = cat;
                      _filterFaqs(_searchController.text);
                    });
                  });
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.cardBorder,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.textMedium,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFaqList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _filteredFaqs.length,
      itemBuilder: (context, index) {
        final faq = _filteredFaqs[index];
        final isOpen = _openQuestions.contains(faq.question);
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              ListTile(
                onTap: () {
                  setState(() {
                    if (isOpen) {
                      _openQuestions.remove(faq.question);
                    } else {
                      _openQuestions.add(faq.question);
                    }
                  });
                },
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                title: Text(
                  faq.question,
                  style: AppTextStyles.label.copyWith(
                    color: isOpen ? AppColors.primary : AppColors.textDark,
                  ),
                ),
                trailing: AnimatedRotation(
                  turns: isOpen ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: isOpen ? AppColors.primary : AppColors.textLight,
                  ),
                ),
              ),
              if (isOpen)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Text(
                    faq.reponse,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textMedium,
                      height: 1.5,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off_rounded, size: 80, color: AppColors.textLight),
          const SizedBox(height: 16),
          Text(
            'Aucun résultat trouvé',
            style: AppTextStyles.headingSmall.copyWith(color: AppColors.textMedium),
          ),
          const SizedBox(height: 8),
          const Text(
            'Essayez avec d\'autres mots clés',
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }
}
