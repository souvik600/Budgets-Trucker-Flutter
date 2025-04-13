import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mass_manager/core/constants/colors.dart';
import 'package:mass_manager/core/constants/strings.dart';
import 'package:mass_manager/core/constants/styles.dart';
import 'package:mass_manager/core/utils/helpers.dart';
import 'package:mass_manager/core/utils/validators.dart';
import 'package:mass_manager/features/members/bloc/member_bloc.dart';
import 'package:mass_manager/features/members/widgets/member_tile.dart';
import 'package:mass_manager/models/user_model.dart';

import '../../../layout/bottom_nav.dart';
import '../../../layout/custom_app_bar.dart';


class ManageMembersScreen extends StatefulWidget {
  const ManageMembersScreen({super.key});

  @override
  State<ManageMembersScreen> createState() => _ManageMembersScreenState();
}

class _ManageMembersScreenState extends State<ManageMembersScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MemberBloc>().add(LoadMembersEvent());
  }

  void _showAddMemberDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddMemberDialog(),
    ).then((_) {
      // Reload members after dialog is closed
      context.read<MemberBloc>().add(LoadMembersEvent());
    });
  }

  void _showEditMemberDialog(UserModel member) {
    showDialog(
      context: context,
      builder: (context) => EditMemberDialog(member: member),
    ).then((_) {
      // Reload members after dialog is closed
      context.read<MemberBloc>().add(LoadMembersEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: AppStrings.members),
      body: BlocConsumer<MemberBloc, MemberState>(
        listener: (context, state) {
          if (state is MemberOperationSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state is MemberErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is MemberLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MembersLoadedState) {
            return Column(
              children: [
                // Admin controls
                if (state.isCurrentUserAdmin)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _showAddMemberDialog,
                        icon: const Icon(Icons.person_add),
                        label: const Text(AppStrings.addMember),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),

                // Member stats
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatColumn(
                            'Total Members',
                            state.members.length.toString(),
                            Icons.people,
                            AppColors.primary,
                          ),
                          _buildStatColumn(
                            'Admins',
                            state.members
                                .where((m) => m.role == 'admin')
                                .length
                                .toString(),
                            Icons.admin_panel_settings,
                            AppColors.accent,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Member list
                Expanded(
                  child:
                      state.members.isEmpty
                          ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.people_outline,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No members found',
                                  style: AppStyles.subtitle1,
                                ),
                              ],
                            ),
                          )
                          : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: state.members.length,
                            itemBuilder: (context, index) {
                              final member = state.members[index];
                              return MemberTile(
                                member: member,
                                isAdmin: state.isCurrentUserAdmin,
                                onEdit: () => _showEditMemberDialog(member),
                                onDelete: () {
                                  Helpers.showConfirmDialog(
                                    context,
                                    'Delete Member',
                                    'Are you sure you want to delete ${member.name}?',
                                  ).then((confirmed) {
                                    if (confirmed) {
                                      context.read<MemberBloc>().add(
                                        DeleteMemberEvent(memberId: member.id),
                                      );
                                    }
                                  });
                                },
                              );
                            },
                          ),
                ),
              ],
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 3),
    );
  }

  Widget _buildStatColumn(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(value, style: AppStyles.headline3),
        Text(label, style: AppStyles.caption),
      ],
    );
  }
}

class AddMemberDialog extends StatefulWidget {
  const AddMemberDialog({super.key});

  @override
  State<AddMemberDialog> createState() => _AddMemberDialogState();
}

class _AddMemberDialogState extends State<AddMemberDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedRole = 'member';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      context.read<MemberBloc>().add(
        AddMemberEvent(
          email: _emailController.text.trim(),
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          role: _selectedRole,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppStrings.addMember),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: AppStyles.inputDecoration(
                  AppStrings.name,
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: Validators.validateName,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: AppStyles.inputDecoration(
                  AppStrings.email,
                  prefixIcon: const Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: Validators.validateEmail,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: AppStyles.inputDecoration(
                  AppStrings.phone,
                  prefixIcon: const Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: Validators.validatePhone,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: AppStyles.inputDecoration(
                  AppStrings.role,
                  prefixIcon: const Icon(Icons.admin_panel_settings),
                ),
                items: const [
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  DropdownMenuItem(value: 'member', child: Text('Member')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedRole = value;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(AppStrings.cancel),
        ),
        ElevatedButton(
          onPressed: _submitForm,
          child: const Text(AppStrings.save),
        ),
      ],
    );
  }
}

class EditMemberDialog extends StatefulWidget {
  final UserModel member;

  const EditMemberDialog({super.key, required this.member});

  @override
  State<EditMemberDialog> createState() => _EditMemberDialogState();
}

class _EditMemberDialogState extends State<EditMemberDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late String _selectedRole;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.member.name);
    _phoneController = TextEditingController(text: widget.member.phone);
    _selectedRole = widget.member.role;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      context.read<MemberBloc>().add(
        UpdateMemberEvent(
          member: widget.member,
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          role: _selectedRole,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppStrings.editMember),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Email (read-only)
              TextFormField(
                initialValue: widget.member.email,
                decoration: AppStyles.inputDecoration(
                  AppStrings.email,
                  prefixIcon: const Icon(Icons.email),
                ),
                readOnly: true,
                enabled: false,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: AppStyles.inputDecoration(
                  AppStrings.name,
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: Validators.validateName,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: AppStyles.inputDecoration(
                  AppStrings.phone,
                  prefixIcon: const Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: Validators.validatePhone,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: AppStyles.inputDecoration(
                  AppStrings.role,
                  prefixIcon: const Icon(Icons.admin_panel_settings),
                ),
                items: const [
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  DropdownMenuItem(value: 'member', child: Text('Member')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedRole = value;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(AppStrings.cancel),
        ),
        ElevatedButton(
          onPressed: _submitForm,
          child: const Text(AppStrings.save),
        ),
      ],
    );
  }
}
