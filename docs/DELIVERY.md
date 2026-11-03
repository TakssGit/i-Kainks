# Builds et aperçu — état réel

Les lots métier B–G ne sont pas terminés. Les workflows sont une préparation de livraison, pas une preuve de compilation réussie.

## Compilation distante
Le workflow « Builds de test Android et Windows » est déclenché sur la branche codex/i-kainks-pro-v2. Flutter 3.44.0 est sélectionné pour respecter le minimum du lockfile (Dart >=3.13) ; compatibilité effective à confirmer dans les jobs. L’installation conserve le lockfile, puis analyse et tests doivent réussir avant compilation. Aucun échec obligatoire n’est ignoré.

Dans GitHub > Actions, ouvrir le workflow et télécharger les artifacts du commit voulu si les jobs sont verts. Les archives portent le commit source.
- Android : `build/app/outputs/flutter-apk/app-release.apk`. Signature debug existante : essais uniquement, pas livraison commerciale signée.
- Windows : `build/windows/x64/runner/Release/`. Conserver le dossier complet (EXE, DLL et data), pas seulement l’EXE. Ce paquet n’est pas un installateur signé.

Sur Windows, après compilation locale, exécuter `powershell -File scripts/open_build_outputs.ps1` pour ouvrir les dossiers existants. Après téléchargement d’un artifact GitHub, extraire son ZIP et ouvrir le dossier d’extraction. L’agent cloud ne contrôle pas l’Explorateur du PC utilisateur.

## Aperçu actuel
Adresse prévue : https://takssgit.github.io/i-Kainks/ . Vérification publique toujours bloquée depuis l’environnement par HTTP 403 du proxy ; ne pas conclure que le site est indisponible ou publié.
Le workflow current-preview.yml publie le prototype HTML existant, distinct de Flutter. Dans Settings > Pages choisir GitHub Actions si nécessaire ; l’environnement github-pages doit autoriser la branche de développement.

## Prérequis cloud
Appliquer l’autorisation réseau de storage.googleapis.com pour télécharger Flutter et takssgit.github.io pour vérifier Pages. L’accès à api.github.com est également nécessaire pour consulter les jobs et récupérer leurs artifacts ; l’authentification Git actuelle ne prouve pas l’accès API.
Ne fournir aucun secret dans le chat.
