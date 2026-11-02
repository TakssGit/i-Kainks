# Architecture observée
Deux applications coexistent : Flutter dans lib/ et prototype HTML/JS dans web/. Isar contient clients, fournisseurs et paramètres natifs. Des registres commerciaux Flutter sont stockés séparément dans SharedPreferences. Le prototype utilise IndexedDB ; le simulateur IKTransactions052055 ne persiste rien. Ces systèmes ne sont pas synchronisés.
La source de vérité commerciale unifiée reste à concevoir avec sauvegarde, compatibilité et tests avant migration. Le point d’entrée natif importe dart:io ; une compilation web doit être vérifiée explicitement.
