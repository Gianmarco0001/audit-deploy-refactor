<?php
// BUG INTENZIONALI per test audit-deploy-pack:
// 1. SQL Injection classica via concatenazione (audit-database, audit-security)
// 2. Password admin hardcoded (audit-backend, audit-security)
// 3. Form senza CSRF token (audit-security)
// 4. Errori SQL esposti all'utente (audit-security A02)
// 5. Session ID non rigenerato dopo login (audit-security A07)
// 6. Password comparison via == invece di password_verify (audit-security A04)

require_once 'config.php';
session_start();

$ADMIN_BACKDOOR_PASSWORD = 'letmein2024';  // Backdoor hardcoded

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $username = $_POST['username'];
    $password = $_POST['password'];

    // SQLI: concatenazione diretta di input utente
    $query = "SELECT * FROM users WHERE username = '" . $username . "' AND password = '" . $password . "'";
    $result = $pdo->query($query);
    $user = $result->fetch(PDO::FETCH_ASSOC);

    if ($user || $password === $ADMIN_BACKDOOR_PASSWORD) {
        $_SESSION['user'] = $user;  // No session_regenerate_id
        header('Location: /dashboard.php');
        exit;
    } else {
        echo "Username errato o password sbagliata: $username";  // User enumeration
    }
}
?>
<!DOCTYPE html>
<html lang="it">
<head><title>Login</title></head>
<body>
  <!-- Form senza @csrf / token CSRF -->
  <form method="POST" action="login.php">
    <input type="text" name="username" placeholder="Username">
    <input type="password" name="password" placeholder="Password">
    <button type="submit">Login</button>
  </form>
</body>
</html>
