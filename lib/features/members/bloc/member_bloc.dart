import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mass_manager/core/services/auth_service.dart';
import 'package:mass_manager/core/services/firestore_service.dart';
import 'package:mass_manager/models/user_model.dart';

// Member Events
abstract class MemberEvent extends Equatable {
  const MemberEvent();

  @override
  List<Object?> get props => [];
}

class LoadMembersEvent extends MemberEvent {}

class AddMemberEvent extends MemberEvent {
  final String email;
  final String name;
  final String phone;
  final String role;

  const AddMemberEvent({
    required this.email,
    required this.name,
    required this.phone,
    required this.role,
  });

  @override
  List<Object?> get props => [email, name, phone, role];
}

class UpdateMemberEvent extends MemberEvent {
  final UserModel member;
  final String name;
  final String phone;
  final String role;

  const UpdateMemberEvent({
    required this.member,
    required this.name,
    required this.phone,
    required this.role,
  });

  @override
  List<Object?> get props => [member, name, phone, role];
}

class DeleteMemberEvent extends MemberEvent {
  final String memberId;

  const DeleteMemberEvent({required this.memberId});

  @override
  List<Object?> get props => [memberId];
}

// Member States
abstract class MemberState extends Equatable {
  const MemberState();

  @override
  List<Object?> get props => [];
}

class MemberInitialState extends MemberState {}

class MemberLoadingState extends MemberState {}

class MembersLoadedState extends MemberState {
  final List<UserModel> members;
  final bool isCurrentUserAdmin;

  const MembersLoadedState({
    required this.members,
    required this.isCurrentUserAdmin,
  });

  @override
  List<Object?> get props => [members, isCurrentUserAdmin];
}

class MemberOperationSuccessState extends MemberState {
  final String message;

  const MemberOperationSuccessState({required this.message});

  @override
  List<Object?> get props => [message];
}

class MemberErrorState extends MemberState {
  final String message;

  const MemberErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}

// Member Bloc
class MemberBloc extends Bloc<MemberEvent, MemberState> {
  final FirestoreService firestoreService;
  final AuthService authService;

  MemberBloc({
    required this.firestoreService,
    required this.authService,
  }) : super(MemberInitialState()) {
    on<LoadMembersEvent>(_onLoadMembers);
    on<AddMemberEvent>(_onAddMember);
    on<UpdateMemberEvent>(_onUpdateMember);
    on<DeleteMemberEvent>(_onDeleteMember);
  }

  Future<void> _onLoadMembers(
      LoadMembersEvent event,
      Emitter<MemberState> emit,
      ) async {
    emit(MemberLoadingState());

    try {
      final members = await firestoreService.getUsers().first;
      final isAdmin = await authService.isUserAdmin();

      emit(MembersLoadedState(
        members: members,
        isCurrentUserAdmin: isAdmin,
      ));
    } catch (e) {
      emit(MemberErrorState(message: e.toString()));
    }
  }

  Future<void> _onAddMember(
      AddMemberEvent event,
      Emitter<MemberState> emit,
      ) async {
    emit(MemberLoadingState());

    try {
      // Check if user is admin
      final isAdmin = await authService.isUserAdmin();
      if (!isAdmin) {
        throw Exception('Only admins can add members');
      }

      // TODO: Implement actual user registration and addition
      // For now, we'll just add a placeholder user to Firestore

      // Generate a random ID for the user
      final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';

      final newUser = UserModel(
        id: userId,
        email: event.email,
        name: event.name,
        phone: event.phone,
        role: event.role,
        createdAt: DateTime.now(),
      );

      await firestoreService.addUser(newUser);

      emit(const MemberOperationSuccessState(
        message: 'Member added successfully',
      ));
    } catch (e) {
      emit(MemberErrorState(message: e.toString()));
    }
  }

  Future<void> _onUpdateMember(
      UpdateMemberEvent event,
      Emitter<MemberState> emit,
      ) async {
    emit(MemberLoadingState());

    try {
      // Check if user is admin
      final isAdmin = await authService.isUserAdmin();
      if (!isAdmin) {
        throw Exception('Only admins can update members');
      }

      final updatedUser = event.member.copyWith(
        name: event.name,
        phone: event.phone,
        role: event.role,
      );

      await firestoreService.updateUser(updatedUser);

      emit(const MemberOperationSuccessState(
        message: 'Member updated successfully',
      ));
    } catch (e) {
      emit(MemberErrorState(message: e.toString()));
    }
  }

  Future<void> _onDeleteMember(
      DeleteMemberEvent event,
      Emitter<MemberState> emit,
      ) async {
    emit(MemberLoadingState());

    try {
      // Check if user is admin
      final isAdmin = await authService.isUserAdmin();
      if (!isAdmin) {
        throw Exception('Only admins can delete members');
      }

      // Check if trying to delete current user
      final currentUserId = authService.currentUserId;
      if (event.memberId == currentUserId) {
        throw Exception('You cannot delete your own account');
      }

      await firestoreService.deleteUser(event.memberId);

      emit(const MemberOperationSuccessState(
        message: 'Member deleted successfully',
      ));
    } catch (e) {
      emit(MemberErrorState(message: e.toString()));
    }
  }
}