# Checklist design e rifinitura

Fonti: Impeccable (craft floor, audit), make-interfaces-feel-better, transitions-polish. Tenute solo le regole
verificabili e valide per qualunque progetto; esclusi i gusti assoluti (es. "mai etichette sopra i titoli",
"mai card uguali") che dipendono dal brief.

## 1. Contrasto e leggibilità (DESIGN-CONTRASTO)
- [ ] Testo ≥ 4.5:1, testo grande ≥ 3:1, ANCHE placeholder dei campi, testo su foto e su superfici colorate.
- [ ] Su superfici colorate il testo secondario prende la tinta della superficie, non un grigio neutro.
- [ ] Lunghezza di riga del testo corrente 65–75 caratteri (`max-width` in `ch`); oltre ~80 è difficile da leggere.
- [ ] Titoli con `text-wrap: balance`, paragrafi con `text-wrap: pretty` (niente parole orfane).

## 2. Stati e interazioni (DESIGN-STATI)
- [ ] Ogni controllo ha hover, focus visibile da tastiera, attivo, disabilitato; dove serve caricamento, errore, vuoto.
- [ ] Il movimento non è mai l'unico segnale: ogni cambio di stato animato ha anche colore, icona o testo.
- [ ] Area cliccabile ≥ 44×44 px su touch (≥ 40 su desktop denso), estesa con pseudo-elemento se il disegno è piccolo; aree vicine che non si sovrappongono.
- [ ] Pulsanti che dicono l'azione ("Aggiungi al carrello", non "Invia"); errori che dicono problema e soluzione.

## 3. Tipografia (DESIGN-TIPOGRAFIA)
- [ ] Gerarchia evidente: salti di dimensione e peso netti, più spazio sopra un titolo che sotto.
- [ ] Numeri che cambiano (prezzi, contatori, quantità) con `font-variant-numeric: tabular-nums`.
- [ ] Font del brand caricato e servito dal sito, non il carattere di sistema come voce dei titoli.
- [ ] Niente testo con gradiente: l'enfasi viene da peso o dimensione.

## 4. Superfici (DESIGN-SUPERFICI)
- [ ] Raggi concentrici: raggio esterno = raggio interno + padding (card con elemento arrotondato dentro).
- [ ] Ombre con spostamento e sfocatura morbida per l'elevazione; niente alone colorato a spostamento zero, niente ombra "a blocco" (`4px 4px 0`) fuori da uno stile neobrutalista scelto.
- [ ] Bordi per struttura e stato (separatori, selezione, focus), ombre per la profondità.
- [ ] Bordo laterale colorato > 1px su card/avvisi: da evitare salvo scelta esplicita del progetto.
- [ ] Immagini su sfondo chiaro: contorno sottile `1px` nero al 10% (bianco al 10% sul scuro), mai un grigio tinto.
- [ ] Niente card dentro card.

## 5. Icone (DESIGN-ICONE)
- [ ] Un solo set di icone per superficie, con spessore del tratto coerente col testo vicino (≈1.5px col regolare, 2px col semibold).
- [ ] Icone in SVG con `currentColor`; gli stati (hover, attivo, disabilitato) cambiano colore/opacità, non file.
- [ ] Niente emoji o caratteri Unicode al posto delle icone.
- [ ] Allineamento ottico, non solo geometrico, per icone asimmetriche (play, frecce) e pulsanti con icona.

## 6. Movimento (DESIGN-MOVIMENTO)
- [ ] `prefers-reduced-motion` gestito con un'alternativa che conserva il cambio di stato (non un azzeramento globale che toglie anche il feedback utile).
- [ ] Mai `transition: all`: elencare le proprietà. `will-change` solo su transform/opacity/filter e solo dove serve.
- [ ] Animare transform/opacity, non width/height/top/left (salvo resize voluto).
- [ ] Apertura più lenta della chiusura (es. tendina/modale 250 ms → 150 ms; pannello 400 → 350); mai ritardare una chiusura o un hover-out.
- [ ] Easing di uscita morbido (`cubic-bezier(0.22, 1, 0.36, 1)` o `ease-out`) per aperture, chiusure, scorrimenti; rimbalzo solo in entrata, mai in chiusura.
- [ ] Sfalsamento ≈ 40 ms per elemento, totale < ~300 ms; nessuna animazione di entrata su interazioni frequenti (hover, digitazione).
- [ ] Niente animazione d'ingresso al primo caricamento se non è un momento voluto; niente stessa entrata ripetuta su ogni sezione.
- [ ] Pressione dei pulsanti, se usata: `scale(0.96)`, mai sotto 0.95.

## 7. Superfici del browser (DESIGN-BROWSER)
- [ ] Anello di focus, colore della selezione del testo, cursore dei campi (`caret-color`), sottolineatura dei link (`text-underline-offset`) e barre di scorrimento personalizzate presi dalla palette, non lasciati di default.
- [ ] `-webkit-font-smoothing: antialiased` sul root se il progetto usa testo chiaro su scuro o font sottili (macOS).

## 8. Segnali di interfaccia "generata" (DESIGN-SLOP) — solo se NON sono scelte del progetto
- [ ] Hero col numerone e statistiche finte; sparkline, anelli di progresso o rettangoli decorativi al posto dei contenuti.
- [ ] Vetro/blur usati come decorazione; macchie radiali colorate dietro le sezioni come "spotlight".
- [ ] Numeri di sezione (01/02/03) che non portano informazione.
- [ ] Monospace come "costume tecnico" fuori da codice e dati.
- [ ] Testi segnaposto, statistiche o recensioni inventate, immagini di repertorio generiche dove servirebbero foto vere.
- [ ] Maschere geometriche (cerchio, poligono) al posto di uno scontorno vero del soggetto.
