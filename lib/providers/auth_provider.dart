import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart' as constants;

enum AuthStatus {
  uninitialized,
  authenticated,
  unauthenticated,
}

class AuthAPI extends ChangeNotifier {
  Client client = Client();
  late final Account account;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  late User _currentUser;
  String? _localUserName = '';
  String? _localUserEmail = '';

  AuthStatus _status = AuthStatus.uninitialized;

  // Getter methods
  User get currentUser => _currentUser;
  AuthStatus get status => _status;
  String? get username => _currentUser.name;
  String? get email => _currentUser.email;
  String get userid => _currentUser.$id;
  String? get localUserName => _localUserName;
  String? get localUserEmail => _localUserEmail;


  // Constructor
  AuthAPI() {
    init();
    loadUser();
  }

  // Initialize the Appwrite client
  init() {
    client
        .setEndpoint(constants.appwriteEndpoint)
        .setProject(constants.appwriteProjectId)
        .setSelfSigned();
    account = Account(client);
  }

  loadUser() async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      _localUserName = prefs.getString('userName');
      _localUserEmail = prefs.getString('userEmail');
      final user = await account.get();
      _status = AuthStatus.authenticated;
      _currentUser = user;
      await secureStorage.write(key: 'userID', value: _currentUser.$id);
      await prefs.setString('userEmail', _currentUser.email);
      await prefs.setString('userName', _currentUser.name);
    } catch (e) {
      _status = AuthStatus.unauthenticated;
    } finally {
      notifyListeners();
    }
  }

  //not currently used
  Future<User> signUp({required String email, required String password}) async {
    notifyListeners();

    try {
      final user = await account.create(
          userId: ID.unique(),
          email: email,
          password: password,
          name: 'Simon G');
      return user;
    } finally {
      notifyListeners();
    }
  }

  //not currently used
  Future<Session> signIn(
      {required String email, required String password}) async {
    notifyListeners();

    try {
      final session =
          await account.createEmailSession(email: email, password: password);
      _currentUser = await account.get();
      _status = AuthStatus.authenticated;
      return session;
    } finally {
      notifyListeners();
    }
  }

  signInWithEmail({required String email}) async {
    notifyListeners();
    try {
      Future result = account.createMagicURLSession(
        userId: ID.unique(),
        email: email,
      );
      result.then((response) {
        if (kDebugMode) {
          print(response);
        }
      }).catchError((error) {
        if (kDebugMode) {
          print(error);
        }
      });
    } finally {
      notifyListeners();
    }
  }

  verifyMagicURLSession(
      {required String userId, required String secret}) async {
    try {
      final session = await account.updateMagicURLSession(
        userId: userId,
        secret: secret,
      );
      _currentUser = await account.get();
      _status = AuthStatus.authenticated;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userID', _currentUser.$id);
      return session;
    } finally {
      notifyListeners();
    }
  }

  signInWithProvider({required String provider}) async {
    notifyListeners();
    try {
      final session = await account.createOAuth2Session(provider: provider);
      _currentUser = await account.get();
      _status = AuthStatus.authenticated;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userID', _currentUser.$id);
      return session;
    } finally {
      notifyListeners();
    }
  }

  signOut() async {
    try {
      await account.deleteSession(sessionId: 'current');
      _status = AuthStatus.unauthenticated;
    } finally {
      notifyListeners();
    }
  }

  Future<Preferences> getUserPreferences() async {
    return await account.getPrefs();
  }

  updatePreferences({required String bio}) async {
    return account.updatePrefs(prefs: {'bio': bio});
  }
}
