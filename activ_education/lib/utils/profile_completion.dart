double calculateProfileCompletion({
  required String? telephone,
  required String? etablissementActuel,
  required String? filiere,
  required List<String>? matieresPreferees,
  required bool hasNotes,
  required bool hasDiagnostic,
}) {
  int score = 0;
  int total = 0;

  total++;
  if (telephone != null && telephone.isNotEmpty) score++;

  total++;
  if (etablissementActuel != null && etablissementActuel.isNotEmpty) score++;

  total++;
  if (filiere != null && filiere.isNotEmpty) score++;

  total++;
  if (matieresPreferees != null && matieresPreferees.isNotEmpty) score++;

  total++;
  if (hasNotes) score++;

  total++;
  if (hasDiagnostic) score++;

  return total > 0 ? (score / total) * 100 : 0;
}
