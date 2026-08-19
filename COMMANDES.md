# Commandes de déploiement — Daoukro (APK + API)

## Mettre à jour l'API Laravel sur le serveur

### Sur le serveur (terminal SSH cPanel)
```bash
cd ~/public_html/api-daoukro && git pull origin main
```

### Après un pull API (si besoin)
```bash
cd ~/public_html/api-daoukro
/opt/alt/php83/usr/bin/php artisan migrate --force
/opt/alt/php83/usr/bin/php artisan config:clear
/opt/alt/php83/usr/bin/php artisan cache:clear
```

---

## Builder un nouvel APK

### Sur ton PC (PowerShell)
```powershell
cd C:\projet\daoukro-user-main
flutter build apk --release
```

L'APK se trouve dans :
`build\app\outputs\flutter-apk\app-release.apk`

---

## Publier une nouvelle release APK sur GitHub

Remplace `v1.2.0` par le nouveau numéro de version :

```powershell
# 1. Créer le tag
git tag v1.2.0
git push origin v1.2.0

# 2. Créer la release avec l'APK (PowerShell)
$token = "TON_TOKEN_GITHUB"
$response = Invoke-RestMethod -Uri "https://api.github.com/repos/Angekurt/daoukro-pro/releases" `
  -Method POST `
  -Headers @{"Authorization"="token $token";"Accept"="application/vnd.github.v3+json"} `
  -ContentType "application/json" `
  -Body '{"tag_name":"v1.2.0","name":"Daoukro App v1.2.0","draft":false,"prerelease":false}'

# 3. Uploader l'APK
$bytes = [System.IO.File]::ReadAllBytes("build\app\outputs\flutter-apk\app-release.apk")
Invoke-RestMethod -Uri "https://uploads.github.com/repos/Angekurt/daoukro-pro/releases/$($response.id)/assets?name=daoukro-v1.2.0.apk" `
  -Method POST `
  -Headers @{"Authorization"="token $token";"Accept"="application/vnd.github.v3+json";"Content-Type"="application/vnd.android.package-archive"} `
  -Body $bytes
```

---

## Accès aux plateformes

| Plateforme   | URL                                     |
|--------------|-----------------------------------------|
| PWA          | https://daoukro-pro.akdev.ci            |
| Admin        | https://api-daoukro.akdev.ci/admin      |
| Landing page | https://daoukro.akdev.ci                |
