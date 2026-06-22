import '../models/models.dart';
import 'base_service.dart';

class ExplorerService extends BaseService {
  static final ExplorerService _instance = ExplorerService._internal();
  factory ExplorerService() => _instance;
  ExplorerService._internal();

  // Bibliothèque
  Future<PageResponse<FicheSerieResponse>> listerSeries({int page = 0, int size = 10}) async {
    final res = await dioGet('/api/v1/bibliotheque/series', queryParameters: {'page': page, 'size': size});
    return PageResponse.fromJson(res.data, (json) => FicheSerieResponse.fromJson(json));
  }

  Future<PageResponse<FicheFiliereResponse>> listerFilieres({int page = 0, int size = 10}) async {
    final res = await dioGet('/api/v1/bibliotheque/filieres', queryParameters: {'page': page, 'size': size});
    return PageResponse.fromJson(res.data, (json) => FicheFiliereResponse.fromJson(json));
  }

  Future<PageResponse<FicheMetierResponse>> listerMetiers({int page = 0, int size = 10}) async {
    final res = await dioGet('/api/v1/bibliotheque/metiers', queryParameters: {'page': page, 'size': size});
    return PageResponse.fromJson(res.data, (json) => FicheMetierResponse.fromJson(json));
  }

  Future<PageResponse<FicheEtablissementResponse>> listerEtablissements({int page = 0, int size = 10}) async {
    final res = await dioGet('/api/v1/bibliotheque/etablissements', queryParameters: {'page': page, 'size': size});
    return PageResponse.fromJson(res.data, (json) => FicheEtablissementResponse.fromJson(json));
  }

  // Favoris
  Future<FavoriResponse> ajouterFavori(FavoriRequest request) async {
    final res = await dio.post('/api/v1/bibliotheque/favoris', data: request.toJson());
    return FavoriResponse.fromJson(res.data);
  }

  Future<PageResponse<FavoriResponse>> getFavorisUtilisateur(String utilisateurId, {int page = 0, int size = 20}) async {
    final res = await dio.get('/api/v1/bibliotheque/favoris/utilisateur/$utilisateurId', queryParameters: {'page': page, 'size': size});
    return PageResponse.fromJson(res.data, (json) => FavoriResponse.fromJson(json));
  }

  Future<void> supprimerFavori(String trackingId) async {
    await dio.delete('/api/v1/bibliotheque/favoris/$trackingId');
  }

  Future<PageResponse<EntreeFAQResponse>> listerFAQ({int page = 0, int size = 20}) async {
    final res = await dioGet('/api/v1/bibliotheque/faq', queryParameters: {'page': page, 'size': size});
    return PageResponse.fromJson(res.data, (json) => EntreeFAQResponse.fromJson(json));
  }

  Future<List<EntreeFAQResponse>> getFAQParCategorie(String categorie) async {
    final res = await dioGet('/api/v1/bibliotheque/faq/categorie/$categorie');
    return (res.data as List).map((e) => EntreeFAQResponse.fromJson(e)).toList();
  }

  Future<List<String>> getCategoriesFAQ() async {
    final res = await dioGet('/api/v1/bibliotheque/faq/categories');
    return List<String>.from(res.data);
  }

  Future<EntreeFAQResponse> voterFAQ(String trackingId, bool utile) async {
    final res = await dio.post('/api/v1/bibliotheque/faq/$trackingId/voter',
        queryParameters: {'utile': utile});
    return EntreeFAQResponse.fromJson(res.data);
  }

  // Recherche
  Future<List<RechercheGlobaleResponse>> rechercherGlobalement(String phrase, {int limite = 10}) async {
    final res = await dioGet('/api/v1/bibliotheque/recherche-fiche-ia/globale', queryParameters: {'phrase': phrase, 'limite': limite});
    return (res.data as List).map((e) => RechercheGlobaleResponse.fromJson(e)).toList();
  }

  Future<PageResponse<FicheSerieResponse>> rechercherSeries(String motCle, {int page = 0, int size = 10}) async {
    final res = await dioGet('/api/v1/bibliotheque/series/recherche', queryParameters: {'motCle': motCle, 'page': page, 'size': size});
    return PageResponse.fromJson(res.data, (json) => FicheSerieResponse.fromJson(json));
  }

  Future<PageResponse<FicheFiliereResponse>> rechercherFilieres(String motCle, {int page = 0, int size = 10}) async {
    final res = await dioGet('/api/v1/bibliotheque/filieres/recherche', queryParameters: {'motCle': motCle, 'page': page, 'size': size});
    return PageResponse.fromJson(res.data, (json) => FicheFiliereResponse.fromJson(json));
  }

  Future<PageResponse<FicheMetierResponse>> rechercherMetiers(String motCle, {int page = 0, int size = 10}) async {
    final res = await dioGet('/api/v1/bibliotheque/metiers/recherche', queryParameters: {'motCle': motCle, 'page': page, 'size': size});
    return PageResponse.fromJson(res.data, (json) => FicheMetierResponse.fromJson(json));
  }

  Future<PageResponse<FicheEtablissementResponse>> rechercherEtablissements(String motCle, {int page = 0, int size = 10}) async {
    final res = await dioGet('/api/v1/bibliotheque/etablissements/recherche', queryParameters: {'motCle': motCle, 'page': page, 'size': size});
    return PageResponse.fromJson(res.data, (json) => FicheEtablissementResponse.fromJson(json));
  }

  Future<List<String>> getEtablissementsList() async {
    try {
      final res = await listerEtablissements(page: 0, size: 100);
      return res.content.map((e) => e.titre).toList();
    } catch (_) {
      return ['Lycée de Tokoin', 'Lycée de Kégué', 'Lycée Technique de Lomé'];
    }
  }

  Future<List<String>> getFilieresList() async {
    try {
      final res = await listerFilieres(page: 0, size: 50);
      return res.content.map((e) => e.titre).toList();
    } catch (_) {
      return ['Informatique', 'Mathématiques', 'Droit', 'Médecine'];
    }
  }

  Future<List<String>> getVilles() async {
    try {
      final res = await dioGet('/api/v1/bibliotheque/etablissements/villes');
      return List<String>.from(res.data);
    } catch (_) {
      return ['Lomé', 'Kara', 'Sokodé', 'Kpalimé', 'Atakpamé', 'Tsévié'];
    }
  }
}
