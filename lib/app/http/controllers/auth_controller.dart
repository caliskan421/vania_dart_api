import 'package:first_vania_project/app/http/requests/auth/forgot_password_request.dart';
import 'package:first_vania_project/app/http/requests/auth/login_request.dart';
import 'package:first_vania_project/app/http/requests/auth/register_request.dart';
import 'package:first_vania_project/app/http/requests/auth/reset_password_request.dart';
import 'package:first_vania_project/app/http/requests/auth/update_profile_request.dart';
import 'package:first_vania_project/app/services/auth_service.dart';
import 'package:first_vania_project/app/services/user_service.dart';
import 'package:vania/authentication.dart';
import 'package:vania/http/controller.dart';
import 'package:vania/http/request.dart';
import 'package:vania/http/response.dart';
import 'package:vania/src/exception/invalid_argument_exception.dart';
import 'package:vania/vania.dart';

class AuthController extends Controller {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  int? _authUserId() {
    final rawUserId = Auth().user()['id'];
    if (rawUserId == null) return null;
    if (rawUserId is int) return rawUserId;
    if (rawUserId is num) return rawUserId.toInt();
    return int.tryParse(rawUserId.toString());
  }

  /// POST /api/v1/auth/register
  Future<Response> register(Request request) async {
    try {
      await RegisterRequest().validate(request);
    } on ValidationException catch (e) {
      return Response.json({
        'success': false,
        'message': 'Validation failed',
        'errors': e.message,
      }, 422);
    } on InvalidArgumentException catch (e) {
      return Response.json({
        'success': false,
        'message': 'Validation failed',
        'errors': e.message,
      }, 422);
    } catch (e) {
      return Response.json({
        'success': false,
        'message': 'Validation failed',
        'errors': e.toString().replaceFirst('Exception: ', ''),
      }, 422);
    }

    try {
      final user = await _authService.register({
        'name': request.input('name'),
        'email': request.input('email'),
        'password': request.input('password'),
        'phone': request.input('phone'),
      });

      return Response.json({
        'success': true,
        'message': 'Registration successful',
        'data': user,
      }, 201);
    } on InvalidArgumentException catch (e) {
      return Response.json({
        'success': false,
        'message': e.message,
      }, 400);
    } on Exception catch (e) {
      return Response.json({
        'success': false,
        'message': e.toString().replaceFirst('Exception: ', ''),
      }, 400);
    } catch (e) {
      return Response.json({
        'success': false,
        'message': e.toString(),
      }, 500);
    }
  }

  /// POST /api/v1/auth/login
  Future<Response> login(Request request) async {
    try {
      await LoginRequest().validate(request);
    } on ValidationException catch (e) {
      return Response.json({
        'success': false,
        'message': 'Validation failed',
        'errors': e.message,
      }, 422);
    } on InvalidArgumentException catch (e) {
      return Response.json({
        'success': false,
        'message': 'Validation failed',
        'errors': e.message,
      }, 422);
    }

    try {
      final result = await _authService.login(
        request.input('email').toString(),
        request.input('password').toString(),
      );

      return Response.json({
        'success': true,
        'message': 'Login successful',
        'data': result,
      }, 200);
    } on InvalidArgumentException catch (e) {
      return Response.json({
        'success': false,
        'message': e.message,
      }, 400);
    } on Exception catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      final statusCode = message.contains('not found') ? 404 : 401;
      return Response.json({
        'success': false,
        'message': message,
      }, statusCode);
    }
  }

  /// POST /api/v1/auth/forgot-password
  Future<Response> forgotPassword(Request request) async {
    try {
      await ForgotPasswordRequest().validate(request);
    } on ValidationException catch (e) {
      return Response.json({
        'success': false,
        'message': 'Validation failed',
        'errors': e.message,
      }, 422);
    } on InvalidArgumentException catch (e) {
      return Response.json({
        'success': false,
        'message': 'Validation failed',
        'errors': e.message,
      }, 422);
    }

    try {
      await _authService.forgotPassword(request.input('email').toString());

      return Response.json({
        'success': true,
        'message': 'Password reset link has been sent to your email (simulated)',
      }, 200);
    } on InvalidArgumentException catch (e) {
      return Response.json({
        'success': false,
        'message': e.message,
      }, 400);
    } on Exception catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      return Response.json({
        'success': false,
        'message': message,
      }, 404);
    }
  }

  /// POST /api/v1/auth/reset-password
  Future<Response> resetPassword(Request request) async {
    try {
      await ResetPasswordRequest().validate(request);
    } on ValidationException catch (e) {
      return Response.json({
        'success': false,
        'message': 'Validation failed',
        'errors': e.message,
      }, 422);
    } on InvalidArgumentException catch (e) {
      return Response.json({
        'success': false,
        'message': 'Validation failed',
        'errors': e.message,
      }, 422);
    }

    try {
      await _authService.resetPassword(
        request.input('email').toString(),
        request.input('token').toString(),
        request.input('password').toString(),
      );

      return Response.json({
        'success': true,
        'message': 'Password reset successful',
      }, 200);
    } on InvalidArgumentException catch (e) {
      return Response.json({
        'success': false,
        'message': e.message,
      }, 400);
    } on Exception catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      return Response.json({
        'success': false,
        'message': message,
      }, 400);
    }
  }

  /// GET /api/v1/auth/profile
  Future<Response> profile(Request request) async {
    try {
      final userId = _authUserId();
      if (userId == null) {
        return Response.json({
          'success': false,
          'message': 'Authentication required',
        }, 401);
      }

      final user = await _userService.getProfile(userId);
      if (user == null) {
        return Response.json({
          'success': false,
          'message': 'User not found',
        }, 404);
      }

      return Response.json({
        'success': true,
        'data': user,
      }, 200);
    } catch (e) {
      return Response.json({
        'success': false,
        'message': 'Failed to fetch profile',
      }, 500);
    }
  }

  /// PUT /api/v1/auth/profile
  Future<Response> updateProfile(Request request) async {
    try {
      await UpdateProfileRequest().validate(request);
    } on ValidationException catch (e) {
      return Response.json({
        'success': false,
        'message': 'Validation failed',
        'errors': e.message,
      }, 422);
    } on InvalidArgumentException catch (e) {
      return Response.json({
        'success': false,
        'message': 'Validation failed',
        'errors': e.message,
      }, 422);
    }

    try {
      final userId = _authUserId();
      if (userId == null) {
        return Response.json({
          'success': false,
          'message': 'Authentication required',
        }, 401);
      }

      final user = await _userService.updateProfile(userId, {
        'name': request.input('name'),
        'phone': request.input('phone'),
        'address': request.input('address'),
      });

      return Response.json({
        'success': true,
        'message': 'Profile updated successfully',
        'data': user,
      }, 200);
    } on InvalidArgumentException catch (e) {
      return Response.json({
        'success': false,
        'message': e.message,
      }, 400);
    } on Exception catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      return Response.json({
        'success': false,
        'message': message,
      }, 400);
    }
  }

  /// POST /api/v1/auth/logout
  Future<Response> logout(Request request) async {
    try {
      final userId = _authUserId();
      if (userId == null) {
        return Response.json({
          'success': false,
          'message': 'Authentication required',
        }, 401);
      }
      await Auth().deleteTokens(userId);
      return Response.json({
        'success': true,
        'message': 'Logout successful',
      }, 200);
    } catch (e) {
      return Response.json({
        'success': false,
        'message': 'Logout failed',
      }, 500);
    }
  }
}
