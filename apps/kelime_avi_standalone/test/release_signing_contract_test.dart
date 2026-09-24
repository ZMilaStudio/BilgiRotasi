import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final repositoryRoot = Directory.current.parent.parent;

  test('standalone release identity stays canonical', () {
    final gradle = File(
      '${repositoryRoot.path}/apps/kelime_avi_standalone/android/app/build.gradle.kts',
    ).readAsStringSync();
    final manifest = File(
      '${repositoryRoot.path}/apps/kelime_avi_standalone/android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    final pubspec = File(
      '${repositoryRoot.path}/apps/kelime_avi_standalone/pubspec.yaml',
    ).readAsStringSync();

    expect(gradle, contains('namespace = "com.zmilastudio.kelimeavi"'));
    expect(gradle, contains('applicationId = "com.zmilastudio.kelimeavi"'));
    expect(manifest, contains('android:label="Kelime Avı"'));
    expect(pubspec, contains('name: kelime_avi_standalone'));
    expect(pubspec, contains('version: 1.0.0+1'));
  });

  test(
    'release requires upload signing and never falls back to debug signing',
    () {
      final gradle = File(
        '${repositoryRoot.path}/apps/kelime_avi_standalone/android/app/build.gradle.kts',
      ).readAsStringSync();

      expect(gradle, contains('rootProject.file("key.properties")'));
      expect(
        gradle,
        contains('Release AAB requires standalone upload signing.'),
      );
      expect(gradle, contains('gradle.taskGraph.whenReady'));
      expect(gradle, contains('create("upload")'));
      expect(gradle, isNot(contains('signingConfigs.getByName("debug")')));
    },
  );

  test(
    'manual release workflow materializes and verifies only temporary keys',
    () {
      final workflow = File(
        '${repositoryRoot.path}/.github/workflows/kelime_avi_standalone_release_validation.yml',
      ).readAsStringSync();

      expect(workflow, contains('workflow_dispatch:'));
      expect(workflow, isNot(contains('pull_request:')));
      expect(workflow, isNot(contains('push:')));
      expect(workflow, contains('KELIME_AVI_UPLOAD_KEYSTORE_BASE64'));
      expect(workflow, contains('flutter build appbundle --release'));
      expect(workflow, contains('jarsigner -verify "$aab"'));
      expect(workflow, isNot(contains('jarsigner -verify -strict')));
      expect(workflow, contains('keytool -printcert -jarfile "$aab"'));
      expect(
        workflow,
        contains(
          '66:32:75:3D:43:3F:2A:E9:96:A5:CB:6B:AB:25:98:A9:22:A8:4D:03:40:CF:0F:15:DC:E3:69:0D:21:A9:4B:7F',
        ),
      );
      expect(
        workflow,
        contains('sha256sum "$aab" | tee app-release.aab.sha256'),
      );
      expect(workflow, contains('actions/upload-artifact@v4'));
      expect(workflow, contains('JARSIGNER_VERIFY.txt'));
      expect(workflow, contains('retention-days: 7'));
      expect(workflow, contains('rm -f android/key.properties'));
      expect(workflow, contains('test ! -e android/app/kelime_avi_upload.jks'));
    },
  );
}
