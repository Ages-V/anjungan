import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<UserModel?> login(String email, String password) async {
    try {
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      
      DocumentSnapshot doc = await _db.collection('user').doc(cred.user!.uid).get();
      
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, cred.user!.uid);
      } else {
        return null;
      }
    } catch (e) {
      rethrow; 
    }
  }

  Future<void> createUserByAdmin({
    required String email,
    required String password,
    required String nama,
    required String role,
    String? nomorInduk,
    String? prodi,
    String? dospemID,
  }) async {
    FirebaseApp tempApp;
    try {
      tempApp = Firebase.app('TempApp');
    } catch (e) {
      tempApp = await Firebase.initializeApp(
        name: 'TempApp',
        options: Firebase.app().options,
      );
    }

    try {
      UserCredential result = await FirebaseAuth.instanceFor(app: tempApp)
          .createUserWithEmailAndPassword(email: email, password: password);

      String newUid = result.user!.uid;

      UserModel newUser = UserModel(
        uid: newUid,
        email: email,
        nama: nama,
        role: role,
        nomorInduk: nomorInduk,
        prodi: prodi,
        dospemID: dospemID,
      );

      await _db.collection('user').doc(newUid).set(newUser.toMap());
      await FirebaseAuth.instanceFor(app: tempApp).signOut();
      
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}