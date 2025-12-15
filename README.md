# Accountaries – Fonctionnalités et parcours

Une vue d'ensemble condensée de l'application pour cadrer la navigation, les flux clés et les calculs budgétaires.

## 1) Navigation et écrans
- **Accueil (Dashboard)** : résumé du mois, prévision de fin de mois, alertes budgets.
- **Mouvements** : toutes les entrées, dépenses et transferts (épargne).
- **Graphiques** : camemberts dépenses/revenus + courbes de tendance optionnelles.
- **Objectifs** : liste des objectifs (ex. « Vacances ») avec progression.
- **Livrets** : comptes/livrets avec solde, rendement annuel et simulateur.
- **Tableau budget** : calculs des dépenses max, épargne et livret max.
- **Budgets** : enveloppes par catégorie avec plafonds et alertes.
- **Règles** : auto-catégorisation (ex. « Amazon » → « Achats »).
- **Automatisations** : mouvements récurrents (salaire, loyer, abonnements…).
- **Réglages** : aide et configuration générale.

## 2) Démarrage (onboarding)
Au premier lancement (ou lors d’une reconfiguration) :
1. Créer un **objectif** (nom, montant cible, date limite optionnelle).
2. Créer un **livret** (nom, solde, rendement annuel).
3. Ajouter un **revenu mensuel** (ex. salaire).

Ces étapes permettent d’afficher immédiatement :
- Les graphiques utiles.
- Un tableau budget cohérent.
- Un objectif et un livret « vivants ».

## 3) Mouvements (noyau de l’app)
Chaque mouvement inclut :
- **Type** : Entrée / Dépense / Transfert (Épargne).
- **Titre** : ex. Salaire, Courses, Loyer (sert aussi aux règles auto).
- **Montant** et **Catégorie**.
- **Date** et **Périodicité** (pour usage futur).

Actions possibles :
- **Ajouter**, **modifier** (icône crayon ou menu contextuel) et **supprimer** un mouvement.

## 4) Épargne vers objectifs et livrets
- **Épargne vers un objectif** : coche dédiée → mouvement devient un Transfert, choix de l’objectif, le montant alimente la progression.
- **Transfert vers un livret** : coche dédiée → mouvement devient un Transfert, choix du livret, le montant s’ajoute au solde.

Résultat : l’app détecte l’épargne dès qu’elle est affectée à une destination claire.

## 5) Budgets / Enveloppes et alertes
- Création d’enveloppes par catégorie (ex. Courses 250€/mois, Sorties 120€/mois).
- Chaque enveloppe affiche : montant dépensé / plafond, jauge visuelle et badge d’état :
  - OK
  - Attention (seuil d’alerte configurable, ex. 80%)
  - Dépassement
- L’Accueil remonte les 3 enveloppes à surveiller.

## 6) Règles automatiques (auto-catégorisation)
- Règles du type « si le titre contient Amazon → catégorie Achats ».
- En saisie, si la catégorie automatique est activée : l’app applique la meilleure règle au titre saisi.
- Fonctions annexes : tester une règle (mini écran) et appliquer à l’historique pour recatégoriser.

## 7) Automatisations (récurrences)
- Création de modèles récurrents : Salaire mensuel le 1, Loyer le 5, Assurance annuelle, etc.
- À l’ouverture ou au retour d’activité, l’app vérifie les récurrences dues et génère les mouvements correspondants.

## 8) Tableau budget (formules clés)
Calculs automatiques :
- **ET = EV + EL** (Épargne totale = Épargne Vacances + Épargne Livret).
- **DMAX = R − CF − ET** (dépenses max possibles après charges fixes et épargne).
- **LMAX = R − CF − DV − EV** (max possible vers livret après dépenses variables et épargne vacances).
- **RV = R − CF − DV − ET** (reste à vivre estimé).

Bouton **« Pré-remplir depuis ce mois »** : récupère revenus du mois, dépenses du mois et transferts vers objectifs/livrets.

## 9) Livrets, rendement et simulateur
- Par livret : solde actuel, rendement annuel, intérêts/an estimés.
- **Simulation livret** : choisir un versement mensuel et une durée (12–60 mois) pour afficher courbe du solde, total des versements et intérêts cumulés.

## 10) Graphiques
- Camembert des dépenses par catégorie.
- Camembert des revenus par catégorie.
- (Optionnel) courbe du net mensuel pour un effet « coach ».

## 11) Scénarios d’usage
- **Vacances** : objectif 1500€, versement de 200€ par mois en épargne vers l’objectif → progression + date estimée selon le rythme.
- **Budget courses** : enveloppe Courses à 250€, dépenses Carrefour alimentent la jauge, badge « Attention » à 80% puis « Dépassement » si le plafond est dépassé.

---

## Application macOS (maquette SwiftUI)
Une maquette macOS SwiftUI est fournie dans `AccountariesApp/` et couvre les écrans décrits ci-dessus :

- **Barre latérale** avec Accueil, Mouvements, Graphiques, Objectifs, Livrets, Tableau budget, Budgets, Règles, Automatisations et Réglages.
- **Données de démonstration** : mouvements, enveloppes, objectifs, livrets (avec rendement), règles d’auto-catégorisation et modèles récurrents.
- **Écrans clés** :
  - Accueil avec résumé du mois, alertes budgets et prévisions fin de mois.
  - Liste des mouvements (entrées/dépenses/transferts) avec destinations d’épargne (objectifs ou livrets) + ajout/suppression via une fiche dédiée.
  - Graphiques placeholder (camemberts revenus/dépenses, net mensuel optionnel).
  - Objectifs avec progression et échéance optionnelle.
  - Livrets avec rendement annuel, intérêts estimés et simulateur (versement mensuel + durée + rendement).
  - Tableau budget (ET, EV, EL, DMAX, LMAX, RV) calculé en temps réel et mis à jour lors de l’ajout/suppression d’un mouvement.
  - Enveloppes/budgets avec jauges et badges OK/Attention/Dépassement.
  - Règles et automatisations listées avec actions de test/appliquer/générer.

### Lancer la maquette
1. Ouvrir le dossier `AccountariesApp/` dans Xcode 15+ (ou `swift package generate-xcodeproj` si besoin).
2. Cible : **AccountariesApp** (plateforme macOS 13+), app SwiftUI sans dépendance externe.
3. Cliquer sur **Run** : la fenêtre affiche la barre latérale et les écrans alimentés par les données de démonstration.

Les artefacts locaux générés par Xcode et SwiftPM (`DerivedData`, `.build`, projets générés) sont ignorés via le `.gitignore` fourni
afin de garder le dépôt propre lors des expérimentations sur la maquette.

> La maquette se concentre sur la navigation et les données d’exemple pour illustrer les flux décrits dans ce README.
