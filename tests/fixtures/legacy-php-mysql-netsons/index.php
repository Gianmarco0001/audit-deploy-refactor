<?php
// BUG INTENZIONALI per test audit-deploy-pack:
// 1. mail() nativo PHP (audit-email general)
// 2. Header injection possibile via $_POST['email'] non sanitizzato (audit-email)
// 3. var_dump lasciato nel codice (audit-backend, audit-algorithms quality)
// 4. Nessun rate limiting su form contatto (audit-security A01)
// 5. No CAPTCHA su form contatto (audit-email anti-spam-relay)

require_once 'config.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['email'])) {
    $to = 'admin@example.com';
    $subject = 'Contatto da sito';
    $message = $_POST['message'];
    $headers = "From: " . $_POST['email'];  // Header injection!

    // mail() nativo, inaffidabile su shared hosting
    mail($to, $subject, $message, $headers);

    var_dump($_POST);  // Debug lasciato in produzione

    echo "Messaggio inviato";
}
?>
<!DOCTYPE html>
<html lang="it">
<head>
  <!-- No meta description, no canonical, no Open Graph: audit-seo trovera' problemi -->
  <title>Home</title>
</head>
<body>
  <!-- Form contatto senza CSRF, senza CAPTCHA, accessibilita' scarsa -->
  <form method="POST">
    <input type="text" name="email" placeholder="Email">
    <textarea name="message"></textarea>
    <button type="submit">Invia</button>
  </form>

  <!-- Touch target sotto 44x44px, no alt sulle immagini: audit-mobile-ux + audit-frontend trovano problemi -->
  <button style="width:20px;height:20px">x</button>
  <img src="logo.jpg">
</body>
</html>
