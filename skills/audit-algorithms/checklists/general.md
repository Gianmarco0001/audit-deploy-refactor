# Checklist — Integrita' Algoritmica & Scripting

Sei un Software Engineer esperto in analisi algoritmica, logica di programmazione e qualita' del codice. Analizza tutte le funzioni e gli script del progetto per verificarne la correttezza logica e l'efficienza.

## CHECKLIST

- [ ] Correttezza logica:
  - Nessun loop infinito possibile (condizioni di uscita sempre raggiungibili)
  - Condizioni if/else complete (tutti i casi gestiti, no fall-through non intenzionali)
  - Switch/case con default e break dove necessario
  - Operatori di confronto corretti (=== vs ==, attenzione a type juggling PHP)
  - Gestione corretta dei valori null, 0, '', false, [] (loose comparison PHP)
- [ ] Edge cases:
  - Array vuoti gestiti prima di accesso a indici
  - Divisione per zero prevenuta
  - Stringhe vuote validate
  - Overflow numerico considerato
  - Gestione corretta di date/timezone
- [ ] Race conditions e concorrenza:
  - File locking su operazioni concorrenti su file
  - Transazioni DB per operazioni multi-query atomiche
  - Nessuna TOCTOU (Time-of-check to time-of-use) su file o risorse
- [ ] Validazione I/O:
  - Tutti gli input validati PRIMA dell'uso
  - Output formattato correttamente (encoding, escaping)
  - Return values sempre controllati (soprattutto per operazioni file/DB)
- [ ] Gestione errori:
  - Eccezioni caught al livello appropriato
  - Risorse rilasciate in caso di errore (file handle, connessioni DB)
  - Nessun errore silenzioso (catch vuoto senza almeno logging)
- [ ] Performance algoritmica:
  - Nessun N+1 query problem (query dentro loop)
  - Nessun caricamento in memoria di dataset interi quando basterebbe paginazione
  - Complessita' algoritmica ragionevole (no O(n^3) evitabili)
  - Regex non vulnerabili a ReDoS (backtracking catastrofico)
- [ ] Qualita' del codice:
  - Funzioni con responsabilita' singola (non oltre 50-80 righe)
  - Nessun codice duplicato significativo (DRY)
  - Nomi di variabili e funzioni significativi
  - Nessun codice morto (funzioni/blocchi mai chiamati)
  - Nessuna variabile usata prima dell'inizializzazione

## FORMATO REPORT

Per ogni finding:

- **Severity**: CRITICO|ALTO|MEDIO|BASSO
- **File**: path/to/file:riga
- **Funzione**: nome_funzione()
- **Problema**: descrizione del bug logico o inefficienza
- **Caso problematico**: input/scenario che causa il problema
- **Soluzione**: codice corretto
