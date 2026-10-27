/* PATCH 016 : couche Modele/validation utilisee par les controleurs de formulaires. */
'use strict';
const IkValidation = Object.freeze({
  validate(module, values) {
    if (!values || typeof values !== 'object') return 'Formulaire invalide';
    const required = {articles:['Référence','Désignation'], clients:['Nom'], fournisseurs:['Nom'], ventes:['Référence','Article'], achats:['Référence','Article'], devis:['Numéro'], commandes:['Numéro']};
    for (const f of (required[module] || [])) { if (!String(values[f] || '').trim()) return 'Champ obligatoire : ' + f; }
    for (const [field,value] of Object.entries(values)) {
      if (/^(Montant|Prix|Stock|Quantité|Seuil|Écart|Plafond|Coût)/.test(field) && value !== '') {
        const n = Number(String(value).replace(',', '.'));
        if (!Number.isFinite(n)) return 'Nombre invalide : ' + field;
        if (!/Écart/.test(field) && n < 0) return 'Valeur négative interdite : ' + field;
      }
    }
    return '';
  }
});
