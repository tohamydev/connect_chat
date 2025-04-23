import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _auth;

  AuthCubit({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance,
        super(const AuthState());

  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      emit(state.copyWith(status: AuthStatus.loading));
      
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      emit(state.copyWith(status: AuthStatus.success));
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'لم يتم العثور على مستخدم بهذا البريد الإلكتروني';
          break;
        case 'wrong-password':
          errorMessage = 'كلمة المرور غير صحيحة';
          break;
        case 'invalid-email':
          errorMessage = 'البريد الإلكتروني غير صالح';
          break;
        case 'user-disabled':
          errorMessage = 'تم تعطيل هذا الحساب';
          break;
        default:
          errorMessage = 'حدث خطأ أثناء تسجيل الدخول';
      }
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: errorMessage,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'حدث خطأ غير متوقع',
      ));
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      emit(const AuthState());
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'حدث خطأ أثناء تسجيل الخروج',
      ));
    }
  }
} 