# Vania Backend - Architecture & Development Guidelines

> **CRITICAL**: This file MUST be read FIRST before writing any code. All AI agents and developers must follow these rules strictly.

---

## 🎯 Core Principles

### 1. Layered Architecture (NON-NEGOTIABLE)
```
Routes → Controllers → Services → Models → Database
```

**Rules:**
- ✅ **Routes:** ONLY route definitions, NO business logic
- ✅ **Controllers:** Handle HTTP (request/response), delegate to Services
- ✅ **Services:** Business logic, complex operations, external API calls
- ✅ **Models:** Database interactions ONLY
- ❌ **NEVER** write database queries in Controllers
- ❌ **NEVER** write business logic in Routes

### 2. Single Responsibility Principle
Each class/method does ONE thing:
```dart
// ❌ BAD: Controller doing everything
class UserController {
  Future<Response> register(Request req) async {
    // Validation inline ❌
    if (req.input('email') == null) return Response.json(...);
    
    // Business logic in controller ❌
    final hashedPassword = Hash.make(req.input('password'));
    
    // Direct database access ❌
    await User.create({...});
  }
}

// ✅ GOOD: Separation of concerns
class UserController {
  final UserService _service = UserService();

  Future<Response> register(Request req) async {
    await RegisterRequest().validate(req);  // Validation class
    
    final user = await _service.register({  // Service handles logic
      'name': req.input('name'),
      'email': req.input('email'),
      'password': req.input('password'),
    });
    
    return Response.json({'user': user}, 201);
  }
}
```

---

## 📂 Project Structure (MANDATORY)
```
lib/
├── app/
│   ├── http/
│   │   ├── controllers/           # HTTP handlers ONLY
│   │   │   ├── auth_controller.dart
│   │   │   ├── user_controller.dart
│   │   │   └── product_controller.dart
│   │   │
│   │   ├── requests/              # Validation classes (ALWAYS use)
│   │   │   ├── base_request.dart
│   │   │   ├── auth/
│   │   │   │   ├── login_request.dart
│   │   │   │   └── register_request.dart
│   │   │   └── user/
│   │   │       ├── create_user_request.dart
│   │   │       └── update_user_request.dart
│   │   │
│   │   └── middleware/            # Authentication, rate limiting, etc.
│   │       ├── authenticate.dart
│   │       ├── admin_only.dart
│   │       └── rate_limit.dart
│   │
│   ├── services/                  # Business logic layer (MANDATORY)
│   │   ├── auth_service.dart
│   │   ├── user_service.dart
│   │   ├── email_service.dart
│   │   └── payment_service.dart
│   │
│   ├── models/                    # Database models
│   │   ├── user.dart
│   │   ├── product.dart
│   │   └── order.dart
│   │
│   ├── validators/                # Custom validation rules
│   │   └── custom_rules.dart
│   │
│   └── providers/                 # Service initialization
│       ├── database_provider.dart
│       ├── cache_provider.dart
│       └── email_provider.dart
│
└── routes/
    ├── api.dart                   # API routes
    └── web.dart                   # Web routes
```

---

## 🛡️ Validation Rules (CRITICAL)

### Rule 1: ALWAYS Use Request Classes
```dart
// ❌ NEVER do inline validation
await req.validate({
  'email': 'required|email',
  'password': 'required|min:8',
});

// ✅ ALWAYS use Request classes
await LoginRequest().validate(req);
```

### Rule 2: Request Class Template
```dart
// lib/app/http/requests/user/create_user_request.dart
class CreateUserRequest extends FormRequest {
  @override
  Map<String, String> rules() {
    return {
      'name': 'required|string|min:3|max:50',
      'email': 'required|email|unique:users,email',
      'password': 'required|min:8|confirmed',
      'phone': 'nullable|numeric|min:10',
    };
  }

  @override
  Map<String, String> messages() {
    return {
      'name.required': 'Name is required',
      'email.unique': 'This email is already registered',
      'password.confirmed': 'Passwords do not match',
    };
  }
}
```

### Rule 3: Custom Validation Rules
Store ALL custom rules in `lib/app/validators/custom_rules.dart`:
```dart
class CustomRules {
  static CustomValidationRule uniqueEmail() {
    return CustomValidationRule(
      ruleName: 'unique_email',
      message: 'Email already exists',
      fn: (data, value, arguments) async {
        final exists = await User.where('email', value).exists();
        return !exists;
      },
    );
  }
  
  static List<CustomValidationRule> all() => [
    uniqueEmail(),
    strongPassword(),
    turkishPhone(),
  ];
}

// Usage
await req.setCustomRule(CustomRules.all()).validate({...});
```

### Rule 4: Nested Validation
```dart
// Object nesting: use dot notation
'address.city': 'required|string',
'address.zipcode': 'required|numeric',

// Array items: use asterisk
'items': 'required|array|min:1',
'items.*.product_id': 'required|exists:products,id',
'items.*.quantity': 'required|numeric|min:1',
```

---

## 🎮 Controllers (STRICT RULES)

### Controller Responsibilities
- ✅ Receive HTTP request
- ✅ Validate input (via Request classes)
- ✅ Call Service layer
- ✅ Return HTTP response
- ❌ NO business logic
- ❌ NO database queries
- ❌ NO complex calculations

### Controller Template
```dart
// lib/app/http/controllers/user_controller.dart
class UserController extends Controller {
  final UserService _service = UserService();

  // GET /api/users
  Future<Response> index() async {
    try {
      final users = await _service.getAllUsers();
      return Response.json({'users': users});
    } catch (e) {
      return Response.json({'error': 'Failed to fetch users'}, 500);
    }
  }

  // POST /api/users
  Future<Response> store(Request req) async {
    await CreateUserRequest().validate(req);

    try {
      final user = await _service.createUser({
        'name': req.input('name'),
        'email': req.input('email'),
        'password': req.input('password'),
      });

      return Response.json({'user': user}, 201);
    } catch (e) {
      return Response.json({'error': 'Failed to create user'}, 500);
    }
  }

  // PUT /api/users/{id}
  Future<Response> update(Request req) async {
    final id = int.parse(req.param('id'));
    await UpdateUserRequest().validate(req);

    try {
      final user = await _service.updateUser(id, {
        'name': req.input('name'),
        'email': req.input('email'),
      });

      return Response.json({'user': user});
    } catch (e) {
      return Response.json({'error': 'Failed to update user'}, 500);
    }
  }

  // DELETE /api/users/{id}
  Future<Response> destroy(Request req) async {
    final id = int.parse(req.param('id'));

    try {
      await _service.deleteUser(id);
      return Response.json({'message': 'User deleted successfully'});
    } catch (e) {
      return Response.json({'error': 'Failed to delete user'}, 500);
    }
  }
}
```

---

## 🔧 Services (MANDATORY LAYER)

### Service Responsibilities
- ✅ Business logic
- ✅ Complex operations
- ✅ External API calls
- ✅ Data transformation
- ✅ Orchestrate multiple models
- ❌ NO HTTP handling (no Request/Response objects)

### Service Template
```dart
// lib/app/services/user_service.dart
class UserService {
  Future<List<User>> getAllUsers() async {
    return await User.all();
  }

  Future<User?> getUserById(int id) async {
    return await User.find(id);
  }

  Future<User> createUser(Map<String, dynamic> data) async {
    // Business logic: Hash password
    data['password'] = Hash.make(data['password']);
    
    // Business logic: Set default values
    data['status'] = 'active';
    data['role'] = 'user';
    
    // Create user
    final user = await User.create(data);
    
    // Business logic: Send welcome email
    await EmailService().sendWelcomeEmail(user['email']);
    
    return user;
  }

  Future<User> updateUser(int id, Map<String, dynamic> data) async {
    final user = await User.find(id);
    
    if (user == null) {
      throw Exception('User not found');
    }
    
    await User.where('id', id).update(data);
    return await User.find(id);
  }

  Future<void> deleteUser(int id) async {
    // Business logic: Check dependencies
    final hasOrders = await Order.where('user_id', id).exists();
    
    if (hasOrders) {
      throw Exception('Cannot delete user with existing orders');
    }
    
    await User.destroy(id);
  }
}
```

---

## 🛣️ Routing (ORGANIZATION RULES)

### Rule 1: Use Route Groups
```dart
// ❌ BAD: Repetitive
Router.get('/api/v1/users', controller.index).middleware([Auth()]);
Router.post('/api/v1/users', controller.store).middleware([Auth()]);
Router.put('/api/v1/users/{id}', controller.update).middleware([Auth()]);

// ✅ GOOD: Grouped
Router.group(() {
  Router.get('/', controller.index);
  Router.post('/', controller.store);
  Router.put('/{id}', controller.update);
}, prefix: 'api/v1/users', middleware: [Authenticate()]);
```

### Rule 2: Organize by Module
```dart
// routes/api.dart
void apiRoutes() {
  final userController = UserController();
  final productController = ProductController();
  final orderController = OrderController();

  // API v1
  Router.group(() {
    
    // Public routes (no auth)
    Router.group(() {
      Router.get('/products', productController.index);
      Router.get('/products/{id}', productController.show);
    }, prefix: 'public');

    // User routes (auth required)
    Router.group(() {
      Router.get('/profile', userController.profile);
      Router.put('/profile', userController.updateProfile);
      Router.get('/orders', orderController.myOrders);
    }, prefix: 'user', middleware: [Authenticate()]);

    // Admin routes (auth + admin)
    Router.group(() {
      Router.get('/users', userController.index);
      Router.post('/users', userController.store);
      Router.delete('/users/{id}', userController.destroy);
    }, prefix: 'admin', middleware: [Authenticate(), AdminOnly()]);

  }, prefix: 'api/v1');
}
```

### Rule 3: Always Use Controller Instance
```dart
// ❌ BAD: Anonymous functions
Router.get('/users', () => Response.json({'users': []}));

// ✅ GOOD: Controller methods
final controller = UserController();
Router.get('/users', controller.index);
```

---

## 🔐 Middleware (SECURITY RULES)

### Rule 1: Critical Endpoints MUST Have Middleware
```dart
// ❌ BAD: No protection
Router.post('/login', authController.login);

// ✅ GOOD: Rate limiting
Router.post('/login', authController.login)
  .middleware([
    Throttle(maxAttempts: 5, duration: Duration(minutes: 15))
  ]);

// ✅ GOOD: Auth + throttle
Router.post('/orders', orderController.create)
  .middleware([
    Authenticate(),
    Throttle(maxAttempts: 20, duration: Duration(minutes: 1))
  ]);
```

### Rule 2: Use req.merge() for Backend Data
```dart
// Middleware: Auto-inject user_id
class InjectUserData extends Middleware {
  @override
  handle(Request req) async {
    final user = req.user();
    
    // Backend adds data (frontend CANNOT manipulate)
    req.merge({
      'user_id': user['id'],
      'ip_address': req.ip,
      'user_agent': req.header('User-Agent'),
      'timestamp': DateTime.now().toIso8601String(),
    });

    return next(req);
  }
}

// Controller: user_id automatically available
final userId = req.input('user_id');  // From middleware, not frontend
```

### Rule 3: Middleware Order Matters
```dart
Router.post('/payment', controller.process)
  .middleware([
    Authenticate(),           // 1. Check auth first
    ValidatePayment(),        // 2. Then validate data
    Throttle(maxAttempts: 3), // 3. Then rate limit
    LogPayment(),             // 4. Finally log
  ]);
```

---

## 📁 File Upload (SECURITY CRITICAL)

### Rule 1: store() vs move()
```dart
// Private files (NOT accessible via URL)
await file.store('app/documents', 'filename.pdf');
// Location: /storage/app/documents/filename.pdf
// Access: ONLY via backend controller with auth check

// Public files (accessible via URL)
await file.move('public/avatars', 'filename.jpg');
// Location: /storage/public/avatars/filename.jpg
// Access: https://yourdomain.com/avatars/filename.jpg
```

### Rule 2: ALWAYS Validate Files
```dart
await req.validate({
  'avatar': 'required|file:jpg,jpeg,png|max:2048',  // Max 2MB
  'document': 'required|file:pdf,doc,docx|max:10240',  // Max 10MB
});
```

### Rule 3: Use Unique Filenames
```dart
// ❌ BAD: Original filename (security risk)
await file.move('public/uploads', file.getClientOriginalName);

// ✅ GOOD: Unique filename
final filename = '${userId}_${DateTime.now().millisecondsSinceEpoch}.${file.extension}';
await file.move('public/uploads', filename);
```

### Rule 4: Store Path in Database, NOT Binary
```dart
// ❌ BAD: Store binary in database
await User.create({
  'avatar_binary': file.bytes,  // ❌ Database bloat
});

// ✅ GOOD: Store path
final path = await file.move('public/avatars', filename);
await User.create({
  'avatar_url': '/avatars/$filename',  // ✅ Only path
});
```

---

## 🚀 Service Providers (INITIALIZATION)

### What Needs a Provider?
- ✅ Database connections
- ✅ Cache (Redis, Memcached)
- ✅ Email (SMTP)
- ✅ Storage (S3, MinIO)
- ✅ Queue systems
- ✅ Schedulers (cron jobs)
- ✅ External API clients
- ❌ Routes (already handled)
- ❌ Middleware (register in routes)
- ❌ Models (use when needed)

### Provider Template
```dart
// lib/app/providers/cache_provider.dart
class CacheProvider extends ServiceProvider {
  @override
  Future<void> register() async {
    // ONLY register, DON'T use other services yet
    final redis = RedisConnection();
    App.bind('redis_connection', redis);
    print('💾 Cache registered');
  }

  @override
  Future<void> boot() async {
    // NOW you can use other services
    final conn = App.make<RedisConnection>('redis_connection');
    final redis = await conn.connect('localhost', 6379);
    App.bind('redis', redis);
    
    await redis.send_object(['PING']);
    print('✅ Redis connected');
  }
}

// config/app.dart
List<ServiceProvider> providers = [
  DatabaseProvider(),
  CacheProvider(),
  EmailProvider(),
];
```

### register() vs boot()
```dart
// ❌ BAD: Using services in register()
class EmailProvider extends ServiceProvider {
  @override
  Future<void> register() async {
    final db = App.make('database');  // ❌ Database might not be ready yet
    final config = await db.query('SELECT * FROM email_config');
  }
}

// ✅ GOOD: Use services in boot()
class EmailProvider extends ServiceProvider {
  @override
  Future<void> register() async {
    final smtp = gmail('user@example.com', 'password');
    App.bind('smtp', smtp);  // ✅ Only register
  }

  @override
  Future<void> boot() async {
    final db = App.make('database');  // ✅ Safe to use here
    final config = await db.query('SELECT * FROM email_config');
  }
}
```

---

## 🎨 Code Style (MANDATORY)

### Naming Conventions
```dart
// Classes: PascalCase
class UserController extends Controller { }
class CreateUserRequest extends FormRequest { }

// Methods: camelCase
Future<Response> getAllUsers() async { }
Future<User> createUser(Map<String, dynamic> data) async { }

// Variables: camelCase
final userService = UserService();
final userData = req.input('name');

// Constants: SCREAMING_SNAKE_CASE
const int MAX_FILE_SIZE = 5242880;
const String DEFAULT_TIMEZONE = 'UTC';

// Private members: _camelCase
final UserService _service = UserService();
Future<void> _sendEmail() async { }
```

### Error Handling
```dart
// ✅ ALWAYS use try-catch in controllers
Future<Response> store(Request req) async {
  try {
    final user = await _service.createUser({...});
    return Response.json({'user': user}, 201);
  } catch (e) {
    // Log error
    logger.error('Failed to create user', error: e);
    
    // Return user-friendly message
    return Response.json({
      'error': 'Failed to create user',
      'message': e.toString(),  // Only in development
    }, 500);
  }
}
```

### Async/Await
```dart
// ✅ ALWAYS mark database operations as async
Future<Response> index() async {
  final users = await User.all();  // ✅ await
  return Response.json({'users': users});
}

// ❌ NEVER forget await
Future<Response> index() async {
  final users = User.all();  // ❌ Missing await
  return Response.json({'users': users});
}
```

---

## 🚫 Common Mistakes (AVOID)

### 1. Business Logic in Controllers
```dart
// ❌ BAD
class UserController extends Controller {
  Future<Response> register(Request req) async {
    final password = Hash.make(req.input('password'));
    final user = await User.create({...});
    await sendWelcomeEmail(user['email']);  // ❌ Business logic
    return Response.json({...});
  }
}

// ✅ GOOD
class UserController extends Controller {
  Future<Response> register(Request req) async {
    final user = await UserService().register({...});  // ✅ Delegate to service
    return Response.json({...});
  }
}
```

### 2. Direct Database in Controllers
```dart
// ❌ BAD
class UserController extends Controller {
  Future<Response> index() async {
    final users = await User.all();  // ❌ Direct database access
    return Response.json({'users': users});
  }
}

// ✅ GOOD
class UserController extends Controller {
  final UserService _service = UserService();
  
  Future<Response> index() async {
    final users = await _service.getAllUsers();  // ✅ Via service
    return Response.json({'users': users});
  }
}
```

### 3. Inline Validation
```dart
// ❌ BAD
await req.validate({
  'email': 'required|email',
  'password': 'required|min:8',
});

// ✅ GOOD
await LoginRequest().validate(req);
```

### 4. No Middleware on Sensitive Routes
```dart
// ❌ BAD
Router.post('/admin/delete-all-users', adminController.deleteAll);

// ✅ GOOD
Router.post('/admin/delete-all-users', adminController.deleteAll)
  .middleware([Authenticate(), AdminOnly(), LogActivity()]);
```

### 5. Storing Binary in Database
```dart
// ❌ BAD
await User.create({
  'avatar_binary': file.bytes,  // ❌ Database bloat
});

// ✅ GOOD
final path = await file.move('public/avatars', filename);
await User.create({
  'avatar_url': '/avatars/$filename',  // ✅ Store path
});
```

---

## ✅ Checklist Before Writing Code

- [ ] Read this ARCHITECTURE.md completely
- [ ] Understand layered architecture (Routes → Controllers → Services → Models)
- [ ] Know when to use `store()` vs `move()` for files
- [ ] Understand `register()` vs `boot()` in Service Providers
- [ ] Know validation rules (`alpha` vs `string`, `numeric` vs `integer`)
- [ ] Understand `req.merge()` for backend-injected data
- [ ] Know middleware order matters
- [ ] Understand nested validation (`parent.child`, `items.*.field`)
- [ ] Know when to create Service Providers
- [ ] Understand application startup flow

---

## 📚 Quick Reference

### Project Structure
```
lib/app/http/controllers/    → HTTP handlers
lib/app/http/requests/       → Validation classes
lib/app/services/            → Business logic
lib/app/models/              → Database models
lib/app/validators/          → Custom validation rules
lib/app/providers/           → Service initialization
routes/                      → Route definitions
```

### Validation
```dart
await CreateUserRequest().validate(req);
await req.setCustomRule(CustomRules.all()).validate({...});
'address.city': 'required'            // Nested object
'items.*.quantity': 'required'        // Array items
```

### Middleware
```dart
.middleware([Authenticate()])
.middleware([Throttle(maxAttempts: 5, duration: Duration(minutes: 1))])
req.merge({'user_id': userId})        // Backend-injected data
```

### File Upload
```dart
await file.store('app/private', 'file.pdf');     // Private
await file.move('public/images', 'file.jpg');    // Public
```

### Route Groups
```dart
Router.group(() { ... }, prefix: 'api/v1', middleware: [Authenticate()]);
```

---

## 🎯 Final Rules (NON-NEGOTIABLE)

1. **ALWAYS** use Request classes for validation
2. **NEVER** put business logic in Controllers
3. **ALWAYS** create Service layer for complex operations
4. **NEVER** store binary data in database
5. **ALWAYS** use middleware for authentication
6. **NEVER** expose sensitive data via public storage
7. **ALWAYS** use try-catch in Controllers
8. **NEVER** forget to validate user input
9. **ALWAYS** use route groups for organization
10. **NEVER** skip reading this file before coding

---

**Last Updated:** 2026-02-17  
**Version:** 1.0.0  
**Framework:** Vania (Dart Backend)

---

**Remember:** Clean architecture is NOT optional. It's the foundation of maintainable, scalable, and secure applications.