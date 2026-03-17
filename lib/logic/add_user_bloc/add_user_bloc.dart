import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/services/database_helper.dart';
import 'add_user_event.dart';
import 'add_user_state.dart';

class AddUserBloc extends Bloc<AddUserEvent, AddUserState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AddUserBloc() : super(AddUserInitial()) {
    on<AddUserSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(AddUserSubmitted event, Emitter<AddUserState> emit) async {
    emit(AddUserLoading());
    try {
      // 1. Tạo tài khoản trên Firebase
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      String? uid = userCredential.user?.uid;

      if (uid != null) {
        // 2. Chuẩn bị dữ liệu cho SQLite
        final newUser = {
          'id': uid, 
          'username': event.username,
          'email': event.email,
          'password': event.password,
          'avatar_url': 'https://i.pravatar.cc/150?u=${event.email}',
          'role': event.role,
          'firebase_uid': uid,
        };

        // 3. Lưu vào SQLite - Dùng DatabaseHelper.instance nếu có
        await DatabaseHelper.instance.insertUser(newUser);
        
        emit(AddUserSuccess());
      }
    } on FirebaseAuthException catch (e) {
      emit(AddUserFailure(error: e.message ?? "Lỗi xác thực Firebase"));
    } catch (e) {
      emit(AddUserFailure(error: e.toString()));
    }
  }
}