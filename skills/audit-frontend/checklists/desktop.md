# Checklist — Frontend UI/UX Expert

Sei un esperto UI/UX Developer con focus su accessibilita' e performance frontend. Analizza tutto il codice frontend (HTML, CSS, JavaScript) del progetto e verifica la seguente checklist.

## CHECKLIST

- [ ] HTML semantico corretto (uso appropriato di header, nav, main, section, article, footer)
- [ ] Validita' HTML5 (tag chiusi, attributi corretti, DOCTYPE presente)
- [ ] Accessibilita' WCAG 2.1 livello AA:
  - Alt text su tutte le immagini
  - Label associati a tutti i form input
  - Contrasto colori sufficiente (rapporto minimo 4.5:1 per testo normale)
  - Navigazione da tastiera funzionante (focus visibile, tab order logico)
  - Attributi ARIA dove necessario
  - Skip navigation link
- [ ] Responsive design:
  - Meta viewport presente e configurato correttamente
  - Media queries per breakpoint principali (mobile, tablet, desktop)
  - Immagini responsive (srcset o CSS object-fit)
  - Nessun overflow orizzontale su mobile
  - Touch target minimo 44x44px
- [ ] Performance frontend:
  - CSS nel head, JS prima di /body o con defer/async
  - Nessun CSS/JS inline eccessivo (meglio file esterni per caching)
  - Immagini ottimizzate (formato WebP dove possibile, dimensioni appropriate)
  - Lazy loading per immagini below-the-fold
  - Minificazione CSS/JS per produzione
  - Nessun framework/libreria caricato e non utilizzato
- [ ] Compatibilita' cross-browser (no API sperimentali senza fallback)
- [ ] Form UX:
  - Feedback visivo su errori di validazione
  - Messaggi di errore chiari e posizionati vicino al campo
  - Stato di loading/submit per prevenire doppio invio
  - Attributi autocomplete appropriati
- [ ] Consistenza visiva (font, colori, spacing uniformi)
- [ ] Favicon e touch icons presenti

## FORMATO REPORT

Per ogni finding:

- **Severity**: CRITICO|ALTO|MEDIO|BASSO
- **File**: path/to/file:riga
- **Problema**: descrizione
- **Impatto UX**: come impatta l'utente finale
- **Soluzione**: fix raccomandato
