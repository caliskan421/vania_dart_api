import 'package:first_vania_project/app/models/user.dart';

class UserService {
  /// Kullanıcı profilini getir
  Future<Map<String, dynamic>?> getProfile(int userId) async {
    final user = await User().query.where('id', '=', userId).first();
    if (user == null) return null;
    return _sanitizeUser(user);
  }

  /// Profili güncelle
  Future<Map<String, dynamic>> updateProfile(int userId, Map<String, dynamic> data) async {
    final user = await User().query.where('id', '=', userId).first();
    if (user == null) {
      throw Exception('User not found');
    }

    final updateData = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (data['name'] != null) updateData['name'] = data['name'];
    if (data['phone'] != null) updateData['phone'] = data['phone'];
    if (data['address'] != null) updateData['address'] = data['address'];

    await User().query.where('id', '=', userId).update(updateData);

    final updatedUser = await User().query.where('id', '=', userId).first();
    return _sanitizeUser(updatedUser!);
  }

  /// Tüm kullanıcıları listele (admin)
  Future<List<Map<String, dynamic>>> getAllUsers({
    int page = 1,
    int perPage = 20,
  }) async {
    final offset = (page - 1) * perPage;
    final users = await User().query.orderBy('id', 'desc').limit(perPage).offset(offset).get();

    return users.map((u) => _sanitizeUser(u)).toList().cast<Map<String, dynamic>>();
  }

  /// Kullanıcı sayısını getir
  Future<int> getUserCount() async {
    final result = await User().query.get();
    return result.length;
  }

  /// Kullanıcıyı getir (admin)
  Future<Map<String, dynamic>?> getUserById(int id) async {
    final user = await User().query.where('id', '=', id).first();
    if (user == null) return null;
    return _sanitizeUser(user);
  }

  /// Kullanıcıyı sil (admin)
  Future<void> deleteUser(int id) async {
    final user = await User().query.where('id', '=', id).first();
    if (user == null) {
      throw Exception('User not found');
    }
    if (user['role'] == 'admin') {
      throw Exception('Cannot delete an admin user');
    }
    await User().query.where('id', '=', id).update({
      'deleted_at': DateTime.now().toIso8601String(),
    });
  }

  /// Avatar URL güncelle
  Future<void> updateAvatarUrl(int userId, String avatarUrl) async {
    await User().query.where('id', '=', userId).update({
      'avatar_url': avatarUrl,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Map<String, dynamic> _sanitizeUser(Map<String, dynamic> user) {
    return {
      'id': user['id'],
      'name': user['name'],
      'email': user['email'],
      'phone': user['phone'],
      'role': user['role'],
      'avatar_url': user['avatar_url'],
      'address': user['address'],
      'created_at': user['created_at']?.toString(),
      'updated_at': user['updated_at']?.toString(),
    };
  }
}
