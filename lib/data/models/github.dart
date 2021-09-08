class GitHubReleaseInfo {
  String webUrl;
  String tagName;
  bool preRelease;
  DateTime release;
  String releaseNotes;
  GitHubAssetInfo asset;

  GitHubReleaseInfo({
    this.tagName,
  });

  GitHubReleaseInfo.fromJson(Map<String, dynamic> json) {
    this.webUrl = json['html_url'];
    this.tagName = json['tag_name'];
    this.preRelease = json['prerelease'];
    this.release = DateTime.parse(json['published_at']);
    this.releaseNotes = json['body'];
    this.asset = GitHubAssetInfo.fromJson(json['assets'][0]);
  }

  String toString() {
    return 'GitHubReleaseInfo{webUrl: $webUrl, tagName: $tagName, preRelease: $preRelease, release: $release, releaseNotes: $releaseNotes, asset: $asset}';
  }
}

class GitHubAssetInfo {
  int downloadCount;
  String downloadUrl;

  GitHubAssetInfo.fromJson(Map<String, dynamic> json) {
    this.downloadCount = json['download_count'];
    this.downloadUrl = json['browser_download_url'];
  }
}
