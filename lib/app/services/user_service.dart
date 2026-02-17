import 'package:first_vania_project/app/dto/user_dto.dart';
import 'package:first_vania_project/app/models/user.dart';

class UserService {
  /// Kullanıcı profilini getir
  Future<Map<String, dynamic>?> getProfile(int userId) async {
    final user = await User().findById(userId);
    if (user == null) return null;
    return user.toSanitizedMap();
  }

  /// Profili güncelle
  Future<Map<String, dynamic>> updateProfile(
      int userId, Map<String, dynamic> data) async {
    final user = await User().findById(userId);
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

    final updatedUser = await User().findById(userId);
    return updatedUser!.toSanitizedMap();
  }

  /// Tüm kullanıcıları listele (admin)
  Future<List<Map<String, dynamic>>> getAllUsers(
      {int page = 1, int perPage = 20}) async {
    final offset = (page - 1) * perPage;
    final userMaps = await User()
        .query
        .orderBy('id', 'desc')
        .limit(perPage)
        .offset(offset)
        .get();

    return userMaps
        .map((m) => UserDto.fromMap(m).toSanitizedMap())
        .toList();
  }

  /// Kullanıcı sayısını getir
  Future<int> getUserCount() async {
    final result = await User().query.get();
    return result.length;
  }

  /// Kullanıcıyı getir (admin)
  Future<Map<String, dynamic>?> getUserById(int id) async {
    final user = await User().findById(id);
    if (user == null) return null;
    return user.toSanitizedMap();
  }

  /// Kullanıcıyı sil (admin)
  Future<void> deleteUser(int id) async {
    final user = await User().findById(id);
    if (user == null) {
      throw Exception('User not found');
    }
    if (user.isAdmin) {
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
}
