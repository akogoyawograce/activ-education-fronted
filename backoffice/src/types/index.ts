export interface PageResponse<T> {
  content: T[]
  totalPages: number
  totalElements: number
  last: boolean
  first: boolean
  size: number
  number: number
  numberOfElements: number
  empty: boolean
}

export interface LoginRequest {
  email: string
  motDePasse: string
}

export interface TokenResponse {
  accessToken: string
  refreshToken: string
  trackingId: string
  typeUtilisateur: string
  roles: string[]
  expiresInMs: number
  requires2fa?: boolean
  challengeToken?: string
}

export interface EleveResponse {
  trackingId: string
  nom: string
  prenom: string
  email: string
  telephone: string
  niveauEtude: string
  etablissementActuel: string
  filiere: string
  typeApprenant: string
  actif: boolean
  matieresPreferees?: string[]
  styleApprentissage?: string
  metierSouhaite?: string
  createdAt: string
}

export interface EleveRequest {
  nom: string
  prenom: string
  email: string
  telephone?: string
  motDePasse: string
  niveauEtude?: string
  etablissementActuel?: string
  filiere?: string
  typeApprenant: string
}

export interface ParentResponse {
  trackingId: string
  nom: string
  prenom: string
  email: string
  telephone: string
  enfantsTrackingIds: string[]
  actif: boolean
  createdAt: string
}

export interface ParentRequest {
  nom: string
  prenom: string
  email: string
  telephone?: string
  motDePasse: string
  enfantsTrackingIds?: string[]
}

export interface ConseillerResponse {
  trackingId: string
  nom: string
  prenom: string
  email: string
  telephone: string
  specialites: string
  biographie: string
  qualifications: string
  anneesExperience: number
  chargeTravail: number
  actif: boolean
  createdAt: string
}

export interface ConseillerRequest {
  nom: string
  prenom: string
  email: string
  telephone?: string
  motDePasse: string
  specialites?: string
  biographie?: string
  qualifications?: string
  anneesExperience?: number
}

export interface AdministrateurResponse {
  trackingId: string
  nom: string
  prenom: string
  email: string
  telephone: string
  niveauAcces: string
  actif: boolean
  createdAt: string
}

export interface AdministrateurRequest {
  nom: string
  prenom: string
  email: string
  telephone?: string
  motDePasse: string
  niveauAcces?: string
}

export interface QuizResponse {
  trackingId: string
  titre: string
  description: string
  estActif: boolean
  nombreQuestions: number
  createdAt: string
}

export interface QuizRequest {
  titre: string
  description?: string
  estActif?: boolean
}

export interface QuestionResponse {
  trackingId: string
  texteQuestion: string
  ordre: number
  quizTrackingId: string
  nombreReponses: number
  niveauCible?: string
  domaine?: string
  difficulte?: number
  tags?: string
  typeQuestion?: string
  createdAt: string
}

export interface QuestionRequest {
  texteQuestion: string
  ordre?: number
  niveauCible?: string
  domaine?: string
  difficulte?: number
  tags?: string
  typeQuestion?: string
}

export interface ReponseResponse {
  trackingId: string
  texteReponse: string
  categoriePoint: string
  points: number
  questionTrackingId: string
  createdAt: string
}

export interface ReponseRequest {
  texteReponse: string
  categoriePoint?: string
  points?: number
}

export interface FicheResponse {
  trackingId: string
  titre: string
  resume: string
  contenu: string
  imageUrls: string[]
  videoUrls: string[]
  documentUrls: string[]
  estPublie: boolean
  nbConsultations: number
  typeFiche: string
}

export interface FicheSerieResponse extends FicheResponse {
  niveau: string
  matieresPrincipales: string
  debouches: string
  coefficients: string
  filieresAssociees: FicheResponse[]
}

export interface FicheFiliereResponse extends FicheResponse {
  duree: string
  niveauRequis: string
  conditionsAdmission: string
  programme: string
  debouchesMetiers: string
  domaine: string
  metiersPrepares: FicheResponse[]
  etablissements: FicheResponse[]
}

export interface FicheMetierResponse extends FicheResponse {
  secteur: string
  missions: string
  competences: string
  formationsAcces: string
  debouchesTogo: string
  fourchetteSalaire: string
  filieresPreparantes: FicheResponse[]
}

export interface FicheEtablissementResponse extends FicheResponse {
  adresse: string
  ville: string
  typeEtablissement: string
  niveau: string
  contacts: string
  siteWeb: string
  offreFormation: string
  estPublic: boolean
  filieresProposees: FicheResponse[]
}

export interface FicheSerieRequest {
  titre: string
  resume: string
  contenu: string
  estPublie: boolean
  niveau: string
  matieresPrincipales?: string
  debouches?: string
  coefficients?: string
}

export interface FicheFiliereRequest {
  titre: string
  resume: string
  contenu: string
  estPublie: boolean
  duree: string
  niveauRequis: string
  conditionsAdmission?: string
  programme?: string
  debouchesMetiers?: string
  domaine?: string
  seriesTrackingIds?: string[]
}

export interface FicheMetierRequest {
  titre: string
  resume: string
  contenu: string
  estPublie: boolean
  secteur: string
  missions?: string
  competences?: string
  formationsAcces?: string
  debouchesTogo?: string
  fourchetteSalaire?: string
  filieresTrackingIds?: string[]
}

export interface FicheEtablissementRequest {
  titre: string
  resume: string
  contenu: string
  estPublie: boolean
  adresse: string
  ville: string
  typeEtablissement: string
  niveau?: string
  contacts?: string
  siteWeb?: string
  offreFormation?: string
  estPublic: boolean
  filieresTrackingIds?: string[]
}

export interface FAQResponse {
  trackingId: string
  question: string
  reponse: string
  categorie: string
  estPublie: boolean
  nbVues: number
  createdAt: string
  updatedAt: string
}

export interface FAQRequest {
  question: string
  reponse: string
  categorie?: string
  estPublie: boolean
}

export interface MessageResponse {
  trackingId: string
  contenu: string
  dateEnvoi: string
  lu: boolean
  expediteurTrackingId: string
  destinataireTrackingId: string
  createdAt: string
}

export interface MessageRequest {
  contenu: string
  destinataireTrackingId: string
}

export interface RendezVousResponse {
  trackingId: string
  dateHeurePrevue: string
  statut: string
  lienVisio: string
  notes: string
  eleveTrackingId: string
  conseillerTrackingId: string
  createdAt: string
}

export interface RendezVousRequest {
  eleveTrackingId: string
  conseillerTrackingId: string
  dateHeurePrevue: string
  lienVisio?: string
  notes?: string
}

export interface ScoreMatriceResponse {
  trackingId: string
  titreMatrice: string
  scoreGoutsPersonnel: number
  scoreAcademique: number
  scoreMarcheTravail: number
  scoreTotalEstime: number
  createdAt: string
}

export interface ScoreMatriceRequest {
  titreMatrice: string
  scoreGoutsPersonnel?: number
  scoreAcademique?: number
  scoreMarcheTravail?: number
  scoreTotalEstime?: number
}

export interface SeuilAdmissionResponse {
  trackingId: string
  matiereRequise: string
  noteMinimum: number
  conditionsTextuelles: string
  filiereTrackingId: string
  filiereTitre: string
  createdAt: string
}

export interface SeuilAdmissionRequest {
  matiereRequise: string
  noteMinimum: number
  conditionsTextuelles?: string
  filiereTrackingId?: string
}

export interface NombreNonLusResponse {
  nonLus: number
}

export interface NoteResponse {
  trackingId: string
  matiere: string
  note: number
  appreciation: string
  eleveTrackingId: string
  createdAt: string
}

export interface NotificationResponse {
  trackingId: string
  titre: string
  message: string
  lue: boolean
  utilisateurTrackingId: string
  createdAt: string
}
