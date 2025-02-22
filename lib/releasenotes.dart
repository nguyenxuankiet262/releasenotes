library releasenotes;

import 'dart:io';

import 'package:releasenotes/itunes_search_api.dart';
import 'package:releasenotes/models/release_notes_model.dart';
import 'package:releasenotes/play_store_search_api.dart';
import 'package:releasenotes/update_checker.dart';
import 'package:releasenotes/update_checker_result.dart';

class ReleaseNotes {
  final String currentVersion;
  final String appBundleId;

  ReleaseNotes({
    required this.currentVersion,
    required this.appBundleId,
  });

  Future<ReleaseNotesModel?> getReleaseNotes(String lang, String country) async {
    final playStoreSearch = PlayStoreSearchAPI();
    final itunesSoreSearch = ITunesSearchAPI();
    String? result;

    late ReleaseNotesModel releaseNotes;

    // Get the last version of the store
    final UpdateCheckerResult updateCheckerResult = await UpdateChecker().checkIfAppHasUpdates(
      currentVersion: currentVersion,
      appBundleId: appBundleId,
      isAndroid: Platform.isAndroid,
    );

    if (currentVersion == updateCheckerResult.newVersion) return null;

    // Get release notes from the store selected
    if (Platform.isAndroid) {
      final storeInfos = await playStoreSearch.lookupById(
        appBundleId,
        language: lang,
        country: country,
      );
      result = PlayStoreResults.releaseNotes(storeInfos!);
    } else {
      final Map<dynamic, dynamic>? storeInfos = await itunesSoreSearch.lookupByBundleId(
        appBundleId,
        country: country,
      );
      result = ITunesResults.releaseNotes(storeInfos!);
    }

    releaseNotes = ReleaseNotesModel(
      notes: result,
      version: updateCheckerResult.newVersion,
    );

    return releaseNotes;
  }
}
