# Android update signing

Android only allows an installed app to update when the new APK has the same
application ID and is signed by the same certificate. The CI workflow therefore
supports a stable release keystore through these GitHub repository secrets:

- `ANDROID_KEYSTORE_BASE64`: base64 contents of the `.jks` file
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`

Create one release keystore once, encode it as base64, and add the four values
under **Repository Settings → Secrets and variables → Actions**. The workflow
also sets the Android `versionCode` from the GitHub run number, so each CI APK
has a newer build number.

Until the secrets are configured, CI falls back to its runner-generated debug
key. Those fallback APKs are for fresh installs only and can still require an
uninstall between different GitHub runners.
