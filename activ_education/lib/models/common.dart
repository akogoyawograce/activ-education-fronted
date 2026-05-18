class PageResponse<T> {
  final int totalElements;
  final int totalPages;
  final int size;
  final int number;
  final bool first;
  final bool last;
  final List<T> content;

  PageResponse({
    required this.totalElements,
    required this.totalPages,
    required this.size,
    required this.number,
    required this.first,
    required this.last,
    required this.content,
  });

  factory PageResponse.fromJson(
      Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJson) {
    return PageResponse(
      totalElements: json['totalElements'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      size: json['size'] ?? 0,
      number: json['number'] ?? 0,
      first: json['first'] ?? true,
      last: json['last'] ?? true,
      content: (json['content'] as List? ?? [])
          .map((e) => fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class FileUploadResponse {
  final String fileName;
  final String? fileUrl;
  final String? contentType;
  final int? fileSize;

  FileUploadResponse({
    required this.fileName,
    this.fileUrl,
    this.contentType,
    this.fileSize,
  });

  factory FileUploadResponse.fromJson(Map<String, dynamic> json) =>
      FileUploadResponse(
        fileName: json['fileName'] ?? '',
        fileUrl: json['fileUrl'],
        contentType: json['contentType'],
        fileSize: json['fileSize'],
      );
}

class HistoriqueResponse {
  final String trackingId;
  final String action;
  final String? details;
  final String utilisateurTrackingId;
  final DateTime? createdAt;

  HistoriqueResponse({
    required this.trackingId,
    required this.action,
    this.details,
    required this.utilisateurTrackingId,
    this.createdAt,
  });

  factory HistoriqueResponse.fromJson(Map<String, dynamic> json) =>
      HistoriqueResponse(
        trackingId: json['trackingId'] ?? '',
        action: json['action'] ?? '',
        details: json['details'],
        utilisateurTrackingId: json['utilisateurTrackingId'] ?? '',
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'])
            : null,
      );
}

class FavoriRequest {
  final String utilisateurTrackingId;
  final String ficheTrackingId;
  final String? notePersonnelle;

  FavoriRequest({
    required this.utilisateurTrackingId,
    required this.ficheTrackingId,
    this.notePersonnelle,
  });

  Map<String, dynamic> toJson() => {
        'utilisateurTrackingId': utilisateurTrackingId,
        'ficheTrackingId': ficheTrackingId,
        if (notePersonnelle != null) 'notePersonnelle': notePersonnelle,
      };
}

class FavoriResponse {
  final String trackingId;
  final String utilisateurTrackingId;
  final String ficheTrackingId;
  final String? ficheTitre;
  final String? notePersonnelle;

  FavoriResponse({
    required this.trackingId,
    required this.utilisateurTrackingId,
    required this.ficheTrackingId,
    this.ficheTitre,
    this.notePersonnelle,
  });

  factory FavoriResponse.fromJson(Map<String, dynamic> json) => FavoriResponse(
        trackingId: json['trackingId'] ?? '',
        utilisateurTrackingId: json['utilisateurTrackingId'] ?? '',
        ficheTrackingId: json['ficheTrackingId'] ?? '',
        ficheTitre: json['ficheTitre'],
        notePersonnelle: json['notePersonnelle'],
      );
}
