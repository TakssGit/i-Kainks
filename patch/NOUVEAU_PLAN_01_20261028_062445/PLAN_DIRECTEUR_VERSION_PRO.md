# i-Kaink's — Plan directeur consolidé Version Pro

## Règlement obligatoire pour chaque pack
1. Une gestion = un périmètre verrouillé. Aucune modification d'une autre gestion, sauf dépendance transversale identifiée, sauvegardée et approuvée.
2. Une gestion ne passe à « terminée » qu'après : CRUD, listes/tableaux, filtres/recherche/tri/pagination, contrôles, impression/aperçu, responsive PC/mobile, base et migrations, journalisation pertinente, tests de non-régression, et preuves.
3. Les suppressions métier sont confirmées et cohérentes avec les documents associés (archivage/désactivation si nécessaire). Les opérations de stock sont transactionnelles, pas de modification silencieuse des historiques.
4. Toutes les mises à jour de schéma sont versionnées, avec migration testée sur copie, sauvegarde et procédure de restauration. Aucun écrasement automatique des bases.
5. Pas de doublons de scripts, pages ou menus. Élimination des anciens composants seulement après vérification de non-régression.
6. Livrables par pack : ZIP, .bat, script d'installation idempotent, sauvegarde, rapport détaillé, résumé développeur, état des tests, plan de retour arrière, ouverture des aperçus Chrome si serveur valide.
7. Pas de Git push ni de modification des données réelles sans accord explicite. Tests avec données fictives.
8. Aucun « 100 % » de gestion sans preuves de réussite des tests fonctionnels et de persistance, et compilation Flutter Windows/Android lorsque cette plateforme est dans le périmètre.
9. Les règles d'impression communes : identité société configurable, en-tête/pied uniformes, pagination, totaux, aucune consigne technique visible sur document client.
10. Déclarer clairement les limites : prototype Web/IndexedDB et Flutter/Isar sont deux environnements distincts, sans synchronisation prouvée.

## Audit de départ — faits et limites
- Rapports des packs 100–115 : prototypes multi-lignes et passerelle de lecture seule, sans migration de la base commerciale.
- Rapports 116–135 : enrichissements génériques de tableaux, impressions Web, consolidation de scripts.
- Aucune preuve disponible de 5 workflows critiques validés en production.
- La source actuelle complète et ses exports d'audit navigateur n'ont pas été fournis dans le dernier message. Un audit statique est exécuté localement par le pack 01, mais ne prouve pas le fonctionnement.
- Source historique i-Kainks-main.zip du 26/10 : Flutter minimal avec écran Paramètres comme accueil. Il ne faut pas présumer qu'elle correspond à l'état actuel du PC.

## Lots de réalisation — nouvelle numérotation
| Lot | Gestion unique / périmètre | Critère de clôture |
|---|---|---|
| 01 | Socle : inventaire, empreintes, état de référence, plan et sauvegarde des sources | Inventaire et archive contrôlés, aucun module métier modifié |
| 02 | Clients | CRUD, statut/archivage, validation, tableaux, recherche/tri/filtres, export, aperçu/impression, tests de persistance |
| 03 | Fournisseurs | Même recette complète, sans toucher aux clients |
| 04 | Paramètres communs & identité société | CRUD paramétrages, unités, catégories, numérotation, taxes configurables, permissions, tests |
| 05 | Produits & catégories | CRUD, unités, prix, codes uniques, images, filtres, impression, tests |
| 06 | Stocks & dépôts | Mouvements, inventaire, seuils, transferts, intégrité, historiques, tests |
| 07 | Approvisionnements & achats | En-tête/détails, réception, prix, fournisseurs, validation, impression, stock atomique |
| 08 | Devis & commandes clients | Multi-lignes, états, conversion, aperçu/impression, cohérence des montants |
| 09 | Ventes & factures | Multi-lignes, remises, taxes, numérotation, stock, impression, annulation contrôlée |
| 10 | Livraisons, retours & avoirs | Traçabilité et mises à jour cohérentes |
| 11 | Paiements, caisse, créances/dettes | Règlements partiels, lettrage, historique, rapprochement |
| 12 | Utilisateurs, authentification & rôles | Authentification sécurisée et autorisations par opération, audit |
| 13 | Sauvegarde/restauration & maintenance | Restauration sur copie, contrôles d'intégrité, procédure documentée |
| 14 | Dashboard & rapports | KPI, filtres période, export, graphiques, données vérifiées |
| 15 | Documents & impression globale | Harmonisation A4/A5 de tous les documents réels Web et natifs |
| 16 | Consolidation interface & performances | Menus sans doublons, responsive, accessibilité, nettoyage sûr |
| 17 | Compilation Windows et Android | Build réel sur machines équipées, tests d'installation, journaux |
| 18 | Recette transversale et livraison | 5/5 workflows critiques, tests d'intégration, sauvegarde, décision Go/No-Go |

Les lots peuvent regrouper des sous-domaines couplés (ex. produits+catégories), mais pas sauter la recette de clôture. Les dépendances transversales sont isolées dans un contrat commun et testées.

## Recette standard de chaque gestion (minimum)
- Création avec données valides et invalides, détection des doublons.
- Modification puis relecture après redémarrage.
- Suppression/archivage et intégrité des références.
- Recherche, tri asc/desc, filtres combinés, pagination, export.
- Impression/aperçu sans texte technique et identité société correcte.
- Responsive PC/mobile, navigation clavier, boutons actifs, messages d'erreur utiles.
- Tests base et migration sur copie, rollback, non-régression des autres gestions.
- Tests Windows/Android pour le module natif concerné; journal des échecs.

## Preuves nécessaires pour démarrer le Lot 02
- `SOURCES_CODE_A_VERIFIER_AVANT_PARTAGE.zip` du lot 01 (retirer secrets et données personnelles avant envoi).
- `INVENTAIRE_SOURCES.json` et `RESULTAT_NOUVEAU_PLAN_01.txt`.
- Export de schéma IndexedDB et source Flutter/Isar actuelle si gestion Clients existe déjà.
- Un exemple anonymisé de fiche Client et d'impression souhaitée.
