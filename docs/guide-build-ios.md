# Guide Build iOS — Daoukro Digital

Distribution directe comme pour l'APK Android : tu génères un fichier `.ipa`
et tu le mets sur ton serveur, les utilisateurs iOS l'installent via un lien.

---

## Ce qu'il faut avoir avant de commencer

- MacBook sous macOS 12 (Monterey) minimum — Catalina ne suffit pas
- Compte Apple Developer à 99$/an — obligatoire pour distribuer hors App Store
- Connexion internet
- Accès à la console Firebase du projet

---

## Étape 1 — Installer les outils de base

```bash
# Installer Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Installer Git
brew install git

# Installer CocoaPods (gestionnaire de dépendances iOS)
sudo gem install cocoapods
```

---

## Étape 2 — Installer Xcode

1. Ouvrir l'**App Store** sur le MacBook
2. Chercher **Xcode** et installer (environ 10 GB, prévoir du temps)
3. Lancer Xcode une première fois pour accepter les licences

```bash
# Accepter la licence Xcode
sudo xcodebuild -license accept

# Installer les outils en ligne de commande
xcode-select --install
```

---

## Étape 3 — Installer Flutter

```bash
# Créer le dossier de développement
mkdir -p ~/development
cd ~/development

# Télécharger Flutter — version Apple Silicon (M1/M2/M3)
curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_arm64_3.32.0-stable.zip

# Si le Mac est Intel (pas M1/M2), utiliser cette URL à la place :
# curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_3.32.0-stable.zip

# Décompresser
unzip flutter_macos_arm64_3.32.0-stable.zip

# Ajouter Flutter au PATH
echo 'export PATH="$HOME/development/flutter/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# Vérifier que Flutter est installé
flutter doctor
```

---

## Étape 4 — Récupérer le projet

```bash
# Cloner depuis GitHub
git clone https://github.com/Angekurt/daoukro-user.git
cd daoukro-user

# Installer les dépendances Flutter
flutter pub get

# Installer les dépendances iOS (CocoaPods)
cd ios
pod install
cd ..
```

---

## Étape 5 — Ajouter Firebase pour iOS

Le projet utilise Firebase (Analytics, Crashlytics, Notifications).
Il faut un fichier de config spécifique iOS.

1. Aller sur [console.firebase.google.com](https://console.firebase.google.com)
2. Sélectionner le projet **Daoukro**
3. Cliquer **Ajouter une application** → choisir iOS
4. Bundle ID : utiliser celui dans `ios/Runner/Info.plist`
   (chercher la ligne `CFBundleIdentifier`)
5. Télécharger `GoogleService-Info.plist`
6. Placer le fichier ici dans le projet :

```bash
# Vérifier que le fichier est au bon endroit
ls ios/Runner/GoogleService-Info.plist
```

---

## Étape 6 — Configurer la signature dans Xcode

```bash
# Ouvrir le projet dans Xcode (toujours avec .xcworkspace, pas .xcodeproj)
open ios/Runner.xcworkspace
```

Dans Xcode :
1. Cliquer sur **Runner** dans le panneau gauche
2. Onglet **Signing & Capabilities**
3. Cocher **Automatically manage signing**
4. **Team** : sélectionner ton compte Apple Developer (99$/an)
5. Le **Bundle Identifier** doit être unique (ex: `tech.akdev.daoukro`)

---

## Étape 7 — Builder le fichier IPA

```bash
# Build release
flutter build ipa --release
```

Le fichier généré sera ici :
```
build/ios/ipa/daoukro_user.ipa
```

---

## Étape 8 — Distribuer comme l'APK Android (sans App Store)

Sur iOS, la distribution directe d'un `.ipa` nécessite une configuration
spéciale appelée **Ad Hoc** ou **Enterprise**.

### Option A — Distribution Ad Hoc (recommandée, inclus dans les 99$/an)

Chaque iPhone qui installe l'app doit être enregistré dans ton compte
Apple Developer (limite : 100 appareils par an).

```bash
# Builder en mode Ad Hoc
flutter build ipa --release --export-options-plist=ios/ExportOptions.plist
```

Créer le fichier `ios/ExportOptions.plist` :
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>method</key>
  <string>ad-hoc</string>
  <key>teamID</key>
  <string>TON_TEAM_ID</string>
  <key>compileBitcode</key>
  <false/>
</dict>
</plist>
```

Remplacer `TON_TEAM_ID` par ton Team ID visible dans
[developer.apple.com/account](https://developer.apple.com/account)
sous Membership.

### Option B — Distribution via TestFlight (plus simple pour les utilisateurs)

TestFlight est l'outil Apple pour distribuer des betas.
Les utilisateurs reçoivent un lien d'invitation et installent depuis
l'app TestFlight — pas besoin d'enregistrer chaque appareil.

```bash
# Builder pour TestFlight (distribution App Store Connect)
flutter build ipa --release
```

Puis uploader via **Transporter** (app gratuite sur Mac App Store)
ou via Xcode → Product → Archive → Distribute App → TestFlight.

---

## Mettre l'IPA sur le serveur (comme l'APK)

Pour une installation directe via lien, il faut créer un manifest XML :

### Structure sur le serveur
```
https://daoukro.akdev.tech/ios/
  ├── daoukro.ipa
  └── manifest.plist
```

### Contenu du manifest.plist
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>items</key>
  <array>
    <dict>
      <key>assets</key>
      <array>
        <dict>
          <key>kind</key>
          <string>software-package</string>
          <key>url</key>
          <string>https://daoukro.akdev.tech/ios/daoukro.ipa</string>
        </dict>
      </array>
      <key>metadata</key>
      <dict>
        <key>bundle-identifier</key>
        <string>tech.akdev.daoukro</string>
        <key>bundle-version</key>
        <string>1.1.0</string>
        <key>kind</key>
        <string>software</string>
        <key>title</key>
        <string>Daoukro Digital</string>
      </dict>
    </dict>
  </array>
</dict>
</plist>
```

### Lien d'installation pour les utilisateurs
```
itms-services://?action=download-manifest&url=https://daoukro.akdev.tech/ios/manifest.plist
```

Ce lien, placé sur ta page de téléchargement, déclenche l'installation
directement sur l'iPhone — exactement comme le lien APK pour Android.

> **Important** : le serveur doit être en HTTPS. HTTP ne fonctionne pas
> pour l'installation d'IPA sur iOS.

---

## Commandes utiles en cas de problème

```bash
# Nettoyer et recommencer
flutter clean
flutter pub get
cd ios && pod install && cd ..

# Mettre à jour les dépendances iOS
cd ios && pod update && cd ..

# Diagnostic complet
flutter doctor -v

# Lister les appareils connectés
flutter devices

# Tester sur simulateur iPhone
flutter run -d "iPhone 15"
```

---

## Résumé des fichiers à préparer

| Fichier | Action |
|---|---|
| `ios/Runner/GoogleService-Info.plist` | Télécharger depuis Firebase Console |
| `ios/ExportOptions.plist` | Créer avec le contenu ci-dessus |
| `ios/Runner.xcworkspace` | Ouvrir dans Xcode pour configurer la signature |

---

## Version des outils au moment de la rédaction

| Outil | Version |
|---|---|
| Flutter | 3.32.x |
| Dart SDK | ^3.12.0 |
| Xcode requis | 15+ |
| macOS requis | 12 (Monterey) minimum |
| iOS déployé | 13.0 minimum |
