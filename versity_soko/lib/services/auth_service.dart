import '../models/user_model.dart';

class AuthService {
  Future<UserModel> login(String email, String password) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    
    // Replace with actual API implementation
    return UserModel(
      id: '1',
      name: 'John Doe',
      email: email,
      university: 'University of Nairobi',
    );
  }

  Future<UserModel> register(String name, String email, String password, String university) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    
    // Replace with actual API implementation
    return UserModel(
      id: '1',
      name: name,
      email: email,
      university: university,
    );
  }

  Future<void> logout() async {
    // Simulate logout process
    await Future.delayed(const Duration(milliseconds: 500));
  }
}