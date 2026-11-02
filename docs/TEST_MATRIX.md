# Vérifications
Commande exécutée : `node tests/transactions.test.cjs` : 4 réussites, 0 échec.
Cas : paiement partiel et final, double validation, surpaiement, sortie/entrée de stock, absence de mutation en cas d’erreur, dépassement entier, identifiants réservés, devis exact et montants invalides.
Non exécutés : flutter pub get, format, analyze, test, build web ; SDK absent, domaine storage.googleapis.com refusé par la politique réseau (403).
Ces tests ne couvrent ni la persistance réelle ni l’interface Flutter.

Chromium via Playwright : preview_pc.html et preview_mobile.html répondent 200, titres attendus et deux frames chacune. Les interactions métier ne sont pas couvertes.
