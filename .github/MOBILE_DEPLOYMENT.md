# Mobile deployment setup

The `Mobile build and deployment` workflow runs tests and compile checks on
pull requests and every push to `main`. A successful `main` run publishes a
debug Android APK and an unsigned iOS build as GitHub Actions artifacts.

Store deployment is deliberately manual. Open **Actions**, choose
**Mobile build and deployment**, select **Run workflow**, and choose Google
Play, TestFlight, or both. The workflow uses build number `1000 + run number`
so each store upload receives a monotonically increasing build number.

## Google Play secrets

Create the `google-play` GitHub environment and add:

- `ANDROID_KEYSTORE_BASE64`: base64-encoded Android upload keystore.
- `ANDROID_KEY_ALIAS`: alias inside the upload keystore.
- `ANDROID_KEY_PASSWORD`: password for the key alias.
- `ANDROID_STORE_PASSWORD`: password for the upload keystore.
- `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`: Google Play Console service-account JSON.

The service account must have permission to release package
`com.odadee.project.odadee` to the selected track.

## TestFlight secrets

Create the `app-store` GitHub environment and add:

- `IOS_DISTRIBUTION_CERTIFICATE_BASE64`: base64-encoded distribution `.p12`.
- `IOS_CERTIFICATE_PASSWORD`: password protecting the `.p12`.
- `IOS_PROVISIONING_PROFILE_BASE64`: base64-encoded App Store provisioning profile.
- `APP_STORE_CONNECT_API_KEY_BASE64`: base64-encoded App Store Connect `.p8` key.
- `APP_STORE_CONNECT_KEY_ID`: App Store Connect API key ID.
- `APP_STORE_CONNECT_ISSUER_ID`: App Store Connect issuer ID.

The provisioning profile must cover bundle ID `com.odadee.project` and Apple
Developer team `LPD3CFZ2YG`.

Never commit signing files, service-account JSON, or passwords to the repository.
