<?php
// BUG INTENZIONALI per test audit-deploy-pack:
// 1. No verifica MIME type reale (magic bytes) - si fida di $_FILES['type'] (audit-backend)
// 2. No whitelist estensioni - accetta exploit.php.jpg, file.pHp (audit-backend, audit-security)
// 3. Nome file originale preservato (no rename random) (audit-backend)
// 4. Upload direttamente in /uploads/ dentro document root SENZA protezione esecuzione PHP
// 5. Nessuna dimensione massima esplicita
// 6. Nessun controllo path traversal

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_FILES['file'])) {
    $file = $_FILES['file'];
    $allowed_types = ['image/jpeg', 'image/png', 'image/gif'];

    // Si fida del MIME inviato dal client (bypass triviale)
    if (in_array($file['type'], $allowed_types)) {
        $dest = __DIR__ . '/uploads/' . $file['name'];  // nome originale, no rename
        move_uploaded_file($file['tmp_name'], $dest);
        echo "Upload riuscito: " . $file['name'];  // Output non sanitizzato (XSS)
    } else {
        echo "Tipo file non ammesso";
    }
}
?>
<form method="POST" enctype="multipart/form-data">
  <!-- No @csrf -->
  <input type="file" name="file">
  <button type="submit">Upload</button>
</form>
