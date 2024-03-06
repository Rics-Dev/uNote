const appwriteEndpoint = 'https://cloud.appwrite.io/v1';
const appwriteProjectId = '65d27111905153a13785';
const appwriteDatabaseId = '65d3b7e1d578f11bd4b4';
const appwriteTasksCollectionId = '65d3b7eec7c87bf861e6';
const appwriteTagsCollectionId = '65d8c44e3ceb6190a867';
const appwriteListsCollectionId = '65d8c4fcf2d08a8d99cc';
const appwriteSelfSigned = true;

class AppwriteConfig {
  final String _host = "cloud.appwrite.io";
  final String _project = "64a361341648c1235de9";

  static const String appwriteDatabaseId = '65d3b7e1d578f11bd4b4';
  static const String appwriteTasksCollectionId = '65d3b7eec7c87bf861e6';
  static const String appwriteTagsCollectionId = '65d8c44e3ceb6190a867';
  static const String appwriteListsCollectionId = '65d8c4fcf2d08a8d99cc';
  static const bool appwriteSelfSigned = true;

  String get endpoint => "https://$_host/v1";
  String get host => _host;
  String get callback => "appwrite-callback-$_project";
  String get project => _project;
}
