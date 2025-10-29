// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Bit Money';

  @override
  String get login => 'Se connecter';

  @override
  String get profile => 'Profil';

  @override
  String get personalInfo => 'Informations Personnelles';

  @override
  String get firstName => 'Prénom';

  @override
  String get lastName => 'Nom';

  @override
  String get email => 'Adresse e-mail';

  @override
  String get phone => 'Téléphone';

  @override
  String get accountType => 'Type de compte';

  @override
  String get commission => 'Commission';

  @override
  String get password => 'Mot de passe';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get save => 'Enregistrer';

  @override
  String get cancel => 'Annuler';

  @override
  String get language => 'Langue';

  @override
  String get logout => 'Déconnexion';

  @override
  String get logoutConfirmation =>
      'Êtes-vous sûr de vouloir vous déconnecter ?';

  @override
  String get loading => 'Chargement...';

  @override
  String get administrator => 'Administrateur';

  @override
  String get pointOfSale => 'Point de vente';

  @override
  String get pdv => 'PDV';

  @override
  String get pdvName => 'Nom du PDV';

  @override
  String get address => 'Adresse';

  @override
  String get times => 'Horaires';

  @override
  String get openOnWeekends => 'Ouvert le week-end ?';

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Non';

  @override
  String get updateProfile => 'Modifier le profil';

  @override
  String get updatePassword => 'Changer le mot de passe';

  @override
  String get optional => 'Optionnel';

  @override
  String get newPassword => 'Nouveau mot de passe';

  @override
  String get enterAFirstName => 'Veuillez entrer un prénom';

  @override
  String get enterALastName => 'Veuillez entrer un prénom';

  @override
  String get passwordRegex =>
      'Le mot de passe doit contenir au moins 6 caractères';

  @override
  String get passwordNotConfirmed => 'Les mots de passe ne correspondent pas';

  @override
  String get profileUpdated => 'Profil mis à jour avec succès';

  @override
  String get updateFailed => 'Échec de la mise à jour';

  @override
  String get pleaseLogin => 'Connectez-vous pour accéder à votre compte';

  @override
  String get emailOrPhone => 'Email ou Téléphone';

  @override
  String get enterYourPassword => 'Entrez votre mot de passe';

  @override
  String get enterYourPasswordError => 'Veuillez saisir votre mot de passe';

  @override
  String get enterEmailOrPhoneError =>
      'Veuillez saisir votre email ou téléphone';

  @override
  String get emailOrPhoneInvalid => 'Format eamil ou téléphone invalide';

  @override
  String get errorOccured => 'Une erreur s\'est produite. Veuillez réessayer.';

  @override
  String get retry => 'Réessayer';

  @override
  String get invalidCredentials => 'Identifiants invalides';

  @override
  String get hello => 'Bonjour';

  @override
  String get welcome => 'Bienvenue sur votre tableau de bord';

  @override
  String get transactions => 'Transactions';

  @override
  String get total => 'Total';

  @override
  String get thisWeek => 'cette semaine';

  @override
  String get thisMonth => 'ce mois';

  @override
  String get currency => 'GNF';

  @override
  String get send => 'Envoyer';

  @override
  String get receive => 'Recevoir';

  @override
  String get enroll => 'Enrôler';

  @override
  String get ourPdv => 'Nos PDV';

  @override
  String get quote => 'Devis';

  @override
  String get recentActivities => 'Activités récentes';

  @override
  String get noRecentActivity => 'Aucune activité récente';

  @override
  String get ourPdvs => 'Nos Points de Vente';

  @override
  String get searchPdv => 'Rechercher un PDV';

  @override
  String get filters => 'Filtres';

  @override
  String get openPdvs => 'PDV ouverts';

  @override
  String pdvsFound(int count, String plural) {
    return '$count PDV$plural trouvé$plural';
  }

  @override
  String lastUpdate(String time) {
    return 'Dernière mise à jour: $time';
  }

  @override
  String get noPdvFound => 'Aucun PDV trouvé';

  @override
  String get tryModifySearch => 'Essayez de modifier vos critères de recherche';

  @override
  String get noAddressSpecified => 'Adresse non spécifiée';

  @override
  String get hours => 'Heures';

  @override
  String get weekend => 'Weekend';

  @override
  String get open => 'Ouvert';

  @override
  String get closed => 'Fermé';

  @override
  String get notSpecified => 'Non spécifiée';

  @override
  String get close => 'Fermer';

  @override
  String loadPdvsError(String error) {
    return 'Impossible de charger les PDVs: $error';
  }

  @override
  String get quotesList => 'Liste des Devis';

  @override
  String quoteNumber(String id) {
    return 'Devis #$id';
  }

  @override
  String get amountToSend => 'Montant à envoyer';

  @override
  String get amountToReceive => 'Montant à recevoir';

  @override
  String get notDefined => 'Non défini';

  @override
  String get fees => 'Frais';

  @override
  String get recipientCountry => 'Pays de réception';

  @override
  String get operator => 'Opérateur';

  @override
  String get noQuoteAvailable => 'Aucun devis disponible';

  @override
  String get createNewQuote =>
      'Créez un nouveau devis en appuyant sur le bouton +';

  @override
  String quotesCount(int count) {
    return '$count Devis';
  }

  @override
  String loadQuotesError(String error) {
    return 'Impossible de charger les devis: $error';
  }
}
