<?php
// BUG INTENZIONALI per test audit-deploy-pack:
// 1. Credenziali DB hardcoded in chiaro (audit-backend, audit-security, audit-database)
// 2. display_errors = 1 esplicito in produzione (audit-backend)
// 3. Connessione PDO senza charset utf8mb4 (audit-database/mysql)
// 4. Nessun ATTR_EMULATE_PREPARES => false

ini_set('display_errors', '1');
error_reporting(E_ALL);

$DB_HOST = 'localhost';
$DB_NAME = 'fixturedb';
$DB_USER = 'root';
$DB_PASS = 'rootroot123';  // Password hardcoded

try {
    $pdo = new PDO(
        "mysql:host={$DB_HOST};dbname={$DB_NAME}",  // manca charset=utf8mb4
        $DB_USER,
        $DB_PASS
    );
    // manca PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    // manca PDO::ATTR_EMULATE_PREPARES => false
} catch (PDOException $e) {
    echo "DB Error: " . $e->getMessage();  // Espone messaggio errore SQL all'utente
}
