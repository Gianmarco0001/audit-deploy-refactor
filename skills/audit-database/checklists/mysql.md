# Checklist — Database MySQL/MariaDB (engine-specific)

Sei un Database Security Expert specializzato in MySQL/MariaDB. Questa checklist e' applicata in AGGIUNTA a `general.md`.

## CHECKLIST MYSQL/MARIADB-SPECIFIC

- [ ] NESSUN uso di mysql_* functions (deprecate e rimosse da PHP 7+)
- [ ] Connessione DB usa PDO con configurazione corretta:
  - `PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION`
  - `PDO::ATTR_EMULATE_PREPARES => false` (prepared statements nativi MySQL)
  - `PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC`
  - Charset specificato nella DSN: `charset=utf8mb4`
- [ ] In alternativa MySQLi: bind_param con type specifier corretti
- [ ] Charset utf8mb4 su tabelle e colonne di testo (NON utf8 che e' 3-byte e non gestisce emoji/CJK)
- [ ] Collation utf8mb4_unicode_ci o utf8mb4_0900_ai_ci (MySQL 8) per ordinamento corretto
- [ ] Storage engine InnoDB su tutte le tabelle (no MyISAM per nuovi progetti)
- [ ] Indici su colonne usate in JOIN/WHERE/ORDER BY verificati con `EXPLAIN`
- [ ] InnoDB locks: attenzione a deadlock su transazioni concorrenti, ordine acquisizione lock consistente
- [ ] Slow query log abilitato in produzione (configurazione MySQL server side, valutare se hosting condiviso lo permette)
- [ ] Replication lag monitorato se setup master-slave/replica
- [ ] Versione MySQL 8.0+ o MariaDB 10.6+ (versioni precedenti hanno limitazioni JSON e CTE)
- [ ] No utente `root@%` (root accessibile da rete) — solo `root@localhost`
- [ ] Backup strategy compatibile con engine:
  - `mysqldump --single-transaction` per InnoDB
  - oppure XtraBackup per snapshot consistenti senza lock

## FORMATO REPORT

Per ogni finding:

- **Severity**: CRITICO|ALTO|MEDIO|BASSO
- **File**: path/to/file:riga
- **Query/codice vulnerabile**: snippet
- **Tipo di vulnerabilita' o problema**: (SQLi, schema MyISAM, charset utf8, ecc.)
- **Soluzione**: codice corretto
- **Categoria**: prefix `DATABASE-MYSQL-NNN`
