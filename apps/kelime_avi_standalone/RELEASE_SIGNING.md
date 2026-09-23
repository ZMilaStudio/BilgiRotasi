# Kelime Avı closed-test upload signing

The standalone app uses Android application ID `com.zmilastudio.kelimeavi`
and version `1.0.0+1`. Google Play distribution will use Play App Signing;
this repository only configures the developer/CI upload key.

## Local release build

Create `android/key.properties` locally. It is ignored and must never be
committed:

```properties
storeFile=app/kelime_avi_upload.jks
storePassword=<upload-store-password>
keyAlias=<upload-key-alias>
keyPassword=<upload-key-password>
```

Store the `.jks` outside version control or at the ignored path above, then run:

```sh
flutter build appbundle --release
```

The expected output is:

`build/app/outputs/bundle/release/app-release.aab`

The release build deliberately fails when these values are absent; it does not
fall back to debug signing.

## Manual GitHub validation

Run `Kelime Avı Standalone Release Validation` manually only after repository
secrets are provisioned:

- `KELIME_AVI_UPLOAD_KEYSTORE_BASE64`
- `KELIME_AVI_UPLOAD_STORE_PASSWORD`
- `KELIME_AVI_UPLOAD_KEY_ALIAS`
- `KELIME_AVI_UPLOAD_KEY_PASSWORD`

The workflow materializes the key only in the runner, verifies the signed AAB,
uploads a short-retention candidate artifact, and removes temporary signing
files before the runner exits. It does not upload to Google Play.
