'use strict';
const defs={
 articles:['Référence','Désignation','Catégorie','Unité','Stock','Seuil alerte','Prix achat','Prix vente','Fournisseur','Statut','Date','Notes'],
 ventes:['Référence','Date','Client','Article','Quantité','Prix unitaire','Montant','Mode paiement','Statut','Notes'],
 clients:['Code','Nom','Téléphone','Adresse','Email','Plafond crédit','Statut','Date','Notes'],
 fournisseurs:['Code','Nom','Téléphone','Adresse','Email','Délai livraison','Statut','Date','Notes'],
 achats:['Référence','Date','Fournisseur','Article','Quantité','Prix unitaire','Montant','Statut','Notes'],
 devis:['Numéro','Date','Client','Objet','Montant','Validité','Statut','Notes'],
 commandes:['Numéro','Date','Client','Objet','Montant','Livraison prévue','Statut','Notes'],
 livraisons:['Référence','Date','Commande','Client','Transporteur','Statut','Notes'],
 retours:['Référence','Date','Type','Tiers','Article','Quantité','Motif','Statut','Notes'],
 depenses:['Référence','Date','Libellé','Catégorie','Montant','Mode paiement','Statut','Notes'],
 caisse:['Référence','Date','Type','Libellé','Montant','Mode paiement','Statut','Notes'],
 mouvements:['Référence','Date','Article','Type','Quantité','Dépôt','Motif','Notes'],
 depots:['Code','Nom','Adresse','Responsable','Statut','Notes'],
 categories:['Code','Nom','Description','Statut'],
 reglements:['Référence','Date','Tiers','Type','Montant','Échéance','Mode paiement','Statut','Notes'],
 inventaires:['Référence','Date','Dépôt','Article','Stock théorique','Stock compté','Écart','Statut','Notes'],
 utilisateurs:['Identifiant','Nom','Rôle','Email','Statut','Notes'],
 taches:['Référence','Date','Tâche','Responsable','Priorité','Échéance','Statut','Notes'],
 tarifs:['Code','Article','Type tarif','Prix','Date','Statut','Notes'],
 credits:['Référence','Date','Client','Montant','Échéance','Statut','Notes'],
 garanties:['Référence','Date','Client','Article','Durée','Statut','Notes'],
 maintenance:['Référence','Date','Équipement','Intervention','Responsable','Coût','Statut','Notes'],
 audits:['Référence','Date','Opération','Responsable','Résultat','Notes']
};
const labels={dashboard:'Tableau de bord',articles:'Articles & stock',ventes:'Ventes',clients:'Clients',fournisseurs:'Fournisseurs',achats:'Achats',devis:'Devis',commandes:'Commandes',livraisons:'Livraisons',retours:'Retours',depenses:'Dépenses',caisse:'Caisse',mouvements:'Mouvements de stock',depots:'Dépôts',categories:'Catégories',reglements:'Règlements',inventaires:'Inventaires',utilisateurs:'Utilisateurs',taches:'Tâches',rapports:'Rapports',settings:'Paramètres & sauvegardes',tarifs:'Tarifs & promotions',credits:'Crédits clients',garanties:'Garanties',maintenance:'Maintenance',audits:'Journal des contrôles'};
const icons={dashboard:'▦',articles:'▤',ventes:'◈',clients:'♙',fournisseurs:'♟',achats:'↙',devis:'▧',commandes:'▣',livraisons:'▸',retours:'↶',depenses:'↗',caisse:'▥',mouvements:'⇄',depots:'⌂',categories:'≡',reglements:'✓',inventaires:'☷',utilisateurs:'♧',taches:'☑',rapports:'▥',settings:'⚙',tarifs:'¤',credits:'₳',garanties:'◉',maintenance:'⚒',audits:'◷'};

Object.assign(defs,{"factures": ["Numéro", "Date", "Client", "Commande", "Montant", "TVA", "Total TTC", "Échéance", "Statut", "Notes"], "avoirs": ["Numéro", "Date", "Facture", "Client", "Motif", "Montant", "Statut", "Notes"], "bons_reception": ["Numéro", "Date", "Fournisseur", "Commande", "Dépôt", "Article", "Quantité", "Statut", "Notes"], "bons_sortie": ["Numéro", "Date", "Client", "Dépôt", "Article", "Quantité", "Motif", "Statut", "Notes"], "transferts": ["Référence", "Date", "Article", "Dépôt source", "Dépôt destination", "Quantité", "Statut", "Notes"], "prix": ["Code", "Article", "Catégorie", "Prix achat", "Prix vente", "Marge", "Date", "Statut"], "codes_barres": ["Code", "Article", "Code-barres", "Unité", "Statut", "Notes"], "alertes": ["Référence", "Date", "Type", "Article", "Niveau", "Responsable", "Statut", "Notes"], "budgets": ["Référence", "Date", "Centre de coût", "Catégorie", "Budget", "Réalisé", "Écart", "Statut", "Notes"], "taxes": ["Référence", "Date", "Type taxe", "Base", "Taux", "Montant", "Statut", "Notes"], "roles": ["Code", "Nom", "Description", "Permissions", "Statut"], "journaux": ["Référence", "Date", "Utilisateur", "Action", "Module", "Détail", "Statut"], "sauvegardes": ["Référence", "Date", "Type", "Fichier", "Responsable", "Statut", "Notes"], "contacts": ["Code", "Nom", "Organisation", "Fonction", "Téléphone", "Email", "Statut", "Notes"], "objectifs": ["Référence", "Date", "Période", "Responsable", "Indicateur", "Objectif", "Réalisé", "Statut"], "points_vente": ["Code", "Nom", "Adresse", "Responsable", "Téléphone", "Statut", "Notes"]});
Object.assign(labels,{"factures": "Factures", "avoirs": "Avoirs", "bons_reception": "Bons de réception", "bons_sortie": "Bons de sortie", "transferts": "Transferts entre dépôts", "prix": "Grilles de prix", "codes_barres": "Codes-barres", "alertes": "Alertes et notifications", "budgets": "Budgets", "taxes": "Taxes", "roles": "Rôles et permissions", "journaux": "Journal des opérations", "sauvegardes": "Historique des sauvegardes", "contacts": "Contacts", "objectifs": "Objectifs commerciaux", "points_vente": "Points de vente"});

if(!defs.articles.includes('Image')) defs.articles.push('Image');

if(!defs.utilisateurs.includes('Image'))defs.utilisateurs.push('Image');
