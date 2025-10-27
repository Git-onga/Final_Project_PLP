import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

ValueNotifier<AuthService> authService = ValueNotifier(AuthService());

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => firebaseAuth.currentUser;

  Stream<User?> get getStateChanges => firebaseAuth.authStateChanges();

  Future<UserCredential> login({
    required String email, 
    required String password}) 
    async {
    // Simulate API call
    return await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> createAccount({
    required String name,
    required String email, 
    required String password,}) 
    async {
    // Simulate API call
    return await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() 
    async {
    // Simulate API call
    await firebaseAuth.signOut();
  }

  Future<void> resetPassword({
    required String email}) 
    async {
    // Simulate API call
    await firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> updateUsername({
    required String username}) 
    async {
    // Simulate API call
    await currentUser!.updateDisplayName(username);
  }

  Future<void> updateEmail({
    required String email}) 
    async {
    // Simulate API call
    await currentUser!.updateDisplayName(email);
  }

  Future<void> deleteAccount({
    required String email,
    required String password}) 
    async {
    // Simulate API call
    AuthCredential credential = EmailAuthProvider.credential(email: email, password: password);
    await currentUser!.reauthenticateWithCredential(credential);
    await currentUser!.delete();
    await firebaseAuth.signOut();
  }

  Future<void> resetPasswordFromCurrentPassword({
    required String currentPassword,
    required String newPassword,
    required String email}) 
    async {
    // Simulate API call
    AuthCredential credential = EmailAuthProvider.credential(email: email, password: currentPassword);
    await currentUser!.reauthenticateWithCredential(credential);
    await currentUser!.updatePassword(newPassword);
  }

  
}