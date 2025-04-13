import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mass_manager/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Check if user is logged in
  bool get isLoggedIn => _auth.currentUser != null;

  // Stream of auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Register user
  Future<UserModel> registerUser({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      // Create user in Firebase Auth
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = result.user;
      if (user == null) throw Exception('User creation failed');

      // Create user profile in Firestore
      final UserModel userModel = UserModel(
          id: user.uid,
          email: email,
          name: name,
          phone: phone,
          role: 'admin', // First user is admin by default
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(user.uid).set(userModel.toMap());

      return userModel;
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  // Login user
  Future<UserModel> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      // Sign in with Firebase Auth
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = result.user;
      if (user == null) throw Exception('Login failed');

      // Get user profile from Firestore
      final DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) throw Exception('User profile not found');

      return UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  // Logout user
  Future<void> logoutUser() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Logout failed: ${e.toString()}');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }

  // Get current user profile
  Future<UserModel> getCurrentUserProfile() async {
    try {
      if (currentUser == null) throw Exception('User not logged in');

      final DocumentSnapshot userDoc = await _firestore.collection('users').doc(currentUserId).get();

      if (!userDoc.exists) throw Exception('User profile not found');

      return UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to get user profile: ${e.toString()}');
    }
  }

  // Check if user is admin
  Future<bool> isUserAdmin() async {
    try {
      final userModel = await getCurrentUserProfile();
      return userModel.role == 'admin';
    } catch (e) {
      return false;
    }
  }

  // Update user profile
  Future<UserModel> updateUserProfile({
    required String name,
    required String phone,
  }) async {
    try {
      if (currentUser == null) throw Exception('User not logged in');

      final userRef = _firestore.collection('users').doc(currentUserId);

      await userRef.update({
        'name': name,
        'phone': phone,
        'updatedAt': DateTime.now(),
      });

      final updatedDoc = await userRef.get();

      return UserModel.fromMap(updatedDoc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }
}