import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rika_store/AppTheme/app_colors.dart';
import 'package:rika_store/Helpers/app_strings.dart';
import 'package:rika_store/ViewModel/personal_details_viewmodel.dart';
import 'package:rika_store/ViewModel/settings_viewmodel.dart';

class PersonalDetailsScreen extends StatefulWidget {
  const PersonalDetailsScreen({super.key});

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController ageController;
  String selectedGenderKey = "male";
  String? _localImagePath;

  @override
  void initState() {
    super.initState();
    final vm = Provider.of<PersonalDetailsViewModel>(context, listen: false);
    nameController = TextEditingController(text: vm.userName);
    emailController = TextEditingController(text: vm.email);
    ageController = TextEditingController(text: vm.age);
    selectedGenderKey = vm.genderKey;
    _localImagePath = vm.imagePath;
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _localImagePath = image.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final String lang = Provider.of<SettingsViewModel>(
      context,
    ).appLocale.languageCode;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppStrings.get('personal_details', lang),
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.primaryNavy,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : AppColors.primaryNavy,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildProfileImagePicker(lang),
            const SizedBox(height: 40),
            _buildInputField(
              AppStrings.get('name_label', lang),
              nameController,
              isDark,
            ),
            const SizedBox(height: 25),
            _buildGenderSelector(isDark, lang),
            const SizedBox(height: 25),
            _buildInputField(
              AppStrings.get('age_label', lang),
              ageController,
              isDark,
            ),
            const SizedBox(height: 25),
            _buildInputField(
              AppStrings.get('email_label', lang),
              emailController,
              isDark,
            ),
            const SizedBox(height: 50),
            _buildSaveButton(context, isDark, theme, lang),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(
    BuildContext context,
    bool isDark,
    ThemeData theme,
    String lang,
  ) {
    return ElevatedButton(
      onPressed: () async {
        await context.read<PersonalDetailsViewModel>().updateUserInfo(
          name: nameController.text,
          newEmail: emailController.text,
          newGenderKey: selectedGenderKey,
          newAge: ageController.text,
          newImagePath: _localImagePath,
        );

        if (context.mounted) {
          Navigator.pop(context);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isDark
            ? theme.colorScheme.secondary
            : AppColors.primaryNavy,
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      child: Text(
        AppStrings.get('save_changes', lang),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildProfileImagePicker(String lang) {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: CircleAvatar(
            radius: 55,
            backgroundColor: Colors.grey.shade200,
            backgroundImage:
                (_localImagePath != null &&
                    _localImagePath!.isNotEmpty &&
                    File(_localImagePath!).existsSync())
                ? FileImage(File(_localImagePath!))
                : const AssetImage('assets/images/user-male.png')
                      as ImageProvider,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          AppStrings.get('change_photo', lang),
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        TextField(
          controller: controller,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: InputDecoration(
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: isDark ? Colors.white24 : Colors.black12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelector(bool isDark, String lang) {
    return Row(
      children: [
        Text(
          AppStrings.get('gender_label', lang),
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const Spacer(),
        _buildGenderOption("Male", AppStrings.get('male', lang), isDark),
        const SizedBox(width: 12),
        _buildGenderOption("Female", AppStrings.get('female', lang), isDark),
      ],
    );
  }

  Widget _buildGenderOption(String key, String label, bool isDark) {
    bool isSelected = selectedGenderKey == key;
    return GestureDetector(
      onTap: () => setState(() => selectedGenderKey = key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? Colors.white : AppColors.primaryNavy)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected
                ? (isDark ? Colors.black : Colors.white)
                : (isDark ? Colors.white70 : Colors.black54),
          ),
        ),
      ),
    );
  }
}
