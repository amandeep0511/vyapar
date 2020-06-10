import 'package:app/model/user.dart';

import '../model/entry.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:csv/csv.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/subjects.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import 'dart:convert';
import 'dart:async';
import 'dart:io';

User _authenticatedUser;
String _userIdentity = "12345";

class ConnectedEntry extends Model {
  List<Entry> _entries = [];
  List<Entry> get entries => _entries;
  bool isLoading = false;
  String email = "amandeep";

  Future<bool> addEntry(String title, String description, String image,
      double amount, String transactionType) {
    isLoading = true;
    DateTime date = DateTime.now();
    String getDate = DateFormat("dd-MM-yyyy").format(date);
    String getTime = DateFormat("Hms").format(date);

    print(_userIdentity);

    notifyListeners();

    // print(_authenticatedUser.userId);

    // print(_authenticatedUser.email);
    final Map<String, dynamic> entryData = {
      'title': title,
      'description': description,
      'image':
          'https://upload.wikimedia.org/wikipedia/commons/7/70/Chocolate_%28blue_background%29.jpg',
      'amount': amount,
      'transactionType': transactionType,
      'userEmail': _authenticatedUser.email,
      'userId': _userIdentity
    };
    print(entryData['userEmail']);

    return http
        .put(
            'https://vyapar-fca10.firebaseio.com/entries/${entryData["userId"]}/${getDate}/${getTime}.json?auth=${_authenticatedUser.token}',
            body: json.encode(entryData))
        .then((http.Response response) {
      if (response.statusCode != 200 && response.statusCode != 201) {
        isLoading = false;
        notifyListeners();
        return false;
      }
      final Map<String, dynamic> responseData = json.decode(response.body);
      print(responseData);
      final Entry newEntry = Entry(
          id: responseData['name'],
          amount: amount,
          image: image,
          transactionType: transactionType,
          description: description,
          title: title,
          userEmail: _authenticatedUser.email,
          userId: _userIdentity);
      _entries.add(newEntry);
      isLoading = false;
      getCsv();
      notifyListeners();
      return true;
    }).catchError((error) {
      isLoading = false;
      notifyListeners();
      return false;
    });
  }

  getCsv() async {
    //create an element rows of type list of list. All the above data set are stored in associate list
//Let associate be a model class with attributes name,gender and age and _entries be a list of associate model class.

    List<List<dynamic>> rows = List<List<dynamic>>();
    for (int i = 0; i < _entries.length; i++) {
//row refer to each column of a row in csv file and rows refer to each row in a file
      List<dynamic> row = List();
      row.add(_entries[i].title);
      row.add(_entries[i].description);
      row.add(_entries[i].amount);
      rows.add(row);
    }

    //await SimplePermissions.requestPermission(Permission.WriteExternalStorage);
    bool checkPermission = await Permission.storage.isGranted;
    print("Permission");
    if (checkPermission) {
//store file in documents folder
      print("Permisiom Granted");
      String dir =
          (await getExternalStorageDirectory()).absolute.path + "/documents";
      print(dir);
      String file = "$dir";
      //print(LOGTAG + " FILE " + file);
      File f = new File(file + "filename.csv");

// convert rows to String and write as csv file

      String csv = const ListToCsvConverter().convert(rows);
      f.writeAsString(csv);
    }
  }

  User get user {
    return _authenticatedUser;
  }

  PublishSubject<bool> _userSubject = PublishSubject();

  PublishSubject<bool> get userSubject {
    return _userSubject;
  }

  Future<Map<String, dynamic>> signUp(String email, String password,
      String name, String desgn, String mob) async {
    isLoading = true;
    notifyListeners();

    final Map<String, dynamic> authData = {
      'email': email,
      'password': password,
      'returnSecureToken': true
    };

    http.Response response;
    response = await http.post(
        'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyCgWaMUXoSAEcoFo5I5Ww-3gHb67jko1Jw',
        body: json.encode(authData),
        headers: {'Content-Type': 'application/json'});

    final Map<String, dynamic> responseData = json.decode(response.body);

    bool hasError = true;
    String message = "Something went wrong";

    print("Hey signup 1st stage");

    if (responseData.containsKey('idToken')) {
      hasError = false;
      message = "Authentication Succeded";
      _authenticatedUser = User(
          email: email,
          userId: responseData['localId'],
          token: responseData['idToken'],
          name: name,
          designation: desgn,
          mob: mob);

      notifyListeners();

      Map<String, String> _authenticatedUserMap = {
        "email": email,
        "userId": responseData['localId'],
        "name": name,
        "designation": desgn,
        "mob": mob
      };

      //_userSubject.add(true);
      final DateTime now = DateTime.now();
      final DateTime expiryTime =
          now.add(Duration(seconds: int.parse(responseData['expiresIn'])));

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('token', responseData['idToken']);
      prefs.setString('userEmail', email);
      prefs.setString('userId', responseData['localId']);
      prefs.setString('expiryTime', expiryTime.toIso8601String());

      DateTime date = DateTime.now();
      String day = DateFormat('EEEE').format(date);

      http
          .put(
              'https://vyapar-fca10.firebaseio.com/users/${_authenticatedUser.userId}.json?auth=${_authenticatedUser.token}',
              body: json.encode(_authenticatedUserMap))
          .then((http.Response response) {
        if (response.statusCode != 200 && response.statusCode != 201) {
          isLoading = false;
          hasError = true;
          message = 'Something went wrong';
          notifyListeners();
        }
      });
    } else if (responseData['error']['message'] == 'EMAIL_EXISTS') {
      hasError = true;
      message = "Email Already registered";
    } else if (responseData['error']['message'] == 'EMAIL_NOT_FOUND') {
      hasError = true;
      message = "Email not found";
    } else if (responseData['error']['message'] == 'INVALID_PASSWORD') {
      hasError = true;
      message = "Password is invalid";
    }

    isLoading = false;
    notifyListeners();
    return {'success': !hasError, 'message': message};
  }

  Future<Map<String, dynamic>> logIn(String email, String password) async {
    isLoading = true;
    notifyListeners();

    final Map<String, dynamic> authData = {
      'email': email,
      'password': password,
      'returnSecureToken': true
    };

    http.Response response;
    response = await http.post(
        'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyCgWaMUXoSAEcoFo5I5Ww-3gHb67jko1Jw',
        body: json.encode(authData),
        headers: {'Content-Type': 'application/json'});

    final Map<String, dynamic> responseData = json.decode(response.body);

    bool hasError = true;
    String message = "Something went wrong";

    if (responseData.containsKey('idToken')) {
      hasError = false;
      message = "Authentication Succeded";

      await fetchCurrUser(responseData['localId'], responseData['idToken']);

      print(_authenticatedUser.email);
      print(_authenticatedUser.userId);
      _userIdentity = _authenticatedUser.userId;
      print(_userIdentity);
      notifyListeners();
      DateTime date = DateTime.now();
      String day = DateFormat('EEEE').format(date);

      print(responseData['localId']);

      //_userSubject.add(true);
      final DateTime now = DateTime.now();
      final DateTime expiryTime =
          now.add(Duration(seconds: int.parse(responseData['expiresIn'])));

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('token', responseData['idToken']);
      prefs.setString('userEmail', email);
      prefs.setString('userId', responseData['localId']);
      prefs.setString('expiryTime', expiryTime.toIso8601String());
    } else if (responseData['error']['message'] == 'EMAIL_EXISTS') {
      hasError = true;
      message = "Email Already registered";
    } else if (responseData['error']['message'] == 'EMAIL_NOT_FOUND') {
      hasError = true;
      message = "Email not found";
    } else if (responseData['error']['message'] == 'INVALID_PASSWORD') {
      hasError = true;
      message = "Password is invalid";
    }

    isLoading = false;
    notifyListeners();
    return {'success': !hasError, 'message': message};
  }

  Future<Null> fetchCurrUser(String userId, String authToken) async {
    isLoading = true;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return http
        .get(
            'https://vyapar-fca10.firebaseio.com/users/${userId}.json?auth=${authToken}')
        .then<Null>((http.Response response) {
      print(json.decode(response.body));
      Map<String, dynamic> fetchedData = json.decode(response.body);
      _authenticatedUser = new User(
          name: fetchedData['name'],
          email: fetchedData['email'],
          mob: fetchedData['mob'],
          userId: userId,
          token: authToken,
          designation: fetchedData['designation'],
          image: fetchedData['image']);

      _userIdentity = _authenticatedUser.userId;

      notifyListeners();

      prefs.setString('name', fetchedData['name']);
      prefs.setString('mob', fetchedData['mob']);
      prefs.setString('image', fetchedData['image']);
      prefs.setString('designation', fetchedData['designation']);

      //print(_authenticatedUser.designation);
    });
  }

  void autoAuth() async {
    final DateTime now = DateTime.now();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token");
    final String expiryTimeString = prefs.getString('expiryTime');
    DateTime parseExpiryTime;
    if (token != null) {
      if (expiryTimeString != null) {
        parseExpiryTime = DateTime.parse(expiryTimeString);
        if (parseExpiryTime != null && parseExpiryTime.isBefore(now)) {
          _authenticatedUser = null;
          notifyListeners();
          return;
        }
      }

      String userEmail = prefs.getString("email");
      String userId = prefs.getString("userId");

      fetchCurrUser(userId, token);

      if (parseExpiryTime != null) {
        _userSubject.add(true);
      }

      notifyListeners();
    }
  }
}
