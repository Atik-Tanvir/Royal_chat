import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/config/auth_session_manager.dart';
import '../../../../core/services/r2_storage_service.dart';
import '../../../../core/widgets/royal_brand_logo.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';

class EditProfileSheet extends StatefulWidget {
  final bool isInitialSetup;

  const EditProfileSheet({
    super.key,
    this.isInitialSetup = false,
  });

  static Future<void> show(BuildContext context, {bool isInitialSetup = false}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditProfileSheet(isInitialSetup: isInitialSetup),
    );
  }

  static const List<Map<String, String>> supportedCountries = [
    {'name': 'Bangladesh', 'flag': '🇧🇩', 'code': 'BD'},
    {'name': 'India', 'flag': '🇮🇳', 'code': 'IN'},
    {'name': 'Pakistan', 'flag': '🇵🇰', 'code': 'PK'},
    {'name': 'Saudi Arabia', 'flag': '🇸🇦', 'code': 'SA'},
    {'name': 'United Arab Emirates', 'flag': '🇦🇪', 'code': 'AE'},
    {'name': 'United States', 'flag': '🇺🇸', 'code': 'US'},
    {'name': 'United Kingdom', 'flag': '🇬🇧', 'code': 'GB'},
    {'name': 'Canada', 'flag': '🇨🇦', 'code': 'CA'},
    {'name': 'Malaysia', 'flag': '🇲🇾', 'code': 'MY'},
    {'name': 'Indonesia', 'flag': '🇮🇩', 'code': 'ID'},
    {'name': 'Nepal', 'flag': '🇳🇵', 'code': 'NP'},
    {'name': 'Qatar', 'flag': '🇶🇦', 'code': 'QA'},
    {'name': 'Kuwait', 'flag': '🇰🇼', 'code': 'KW'},
    {'name': 'Oman', 'flag': '🇴🇲', 'code': 'OM'},
    {'name': 'Turkey', 'flag': '🇹🇷', 'code': 'TR'},
    {'name': 'Germany', 'flag': '🇩🇪', 'code': 'DE'},
    {'name': 'France', 'flag': '🇫🇷', 'code': 'FR'},
    {'name': 'Italy', 'flag': '🇮🇹', 'code': 'IT'},
    {'name': 'Japan', 'flag': '🇯🇵', 'code': 'JP'},
    {'name': 'Brazil', 'flag': '🇧🇷', 'code': 'BR'},
  ];

  static const List<Map<String, String>> supportedLanguages = [
    {'name': 'English', 'native': 'English', 'flag': '🇬🇧'},
    {'name': 'Bengali', 'native': 'বাংলা', 'flag': '🇧🇩'},
    {'name': 'Hindi', 'native': 'हिन्दी', 'flag': '🇮🇳'},
    {'name': 'Arabic', 'native': 'العربية', 'flag': '🇸🇦'},
    {'name': 'Urdu', 'native': 'اردو', 'flag': '🇵🇰'},
    {'name': 'Spanish', 'native': 'Español', 'flag': '🇪🇸'},
    {'name': 'French', 'native': 'Français', 'flag': '🇫🇷'},
    {'name': 'Malay', 'native': 'Bahasa Melayu', 'flag': '🇲🇾'},
    {'name': 'Indonesian', 'native': 'Bahasa Indonesia', 'flag': '🇮🇩'},
  ];

  static const List<String> presetAvatars = [
    'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=200&q=80',
    'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?auto=format&fit=crop&w=200&q=80',
    'https://images.unsplash.com/photo-1580489944761-15a19d654956?auto=format&fit=crop&w=200&q=80',
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=200&q=80',
    'https://images.unsplash.com/photo-1628157582853-a796fa650a6a?auto=format&fit=crop&w=200&q=80',
    'https://images.unsplash.com/photo-1566492031773-4f4e44671857?auto=format&fit=crop&w=200&q=80',
  ];

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;

  late String _selectedCountry;
  late String _selectedCountryFlag;
  late String _selectedLanguage;
  late String _selectedGender;
  late int _selectedAge;
  late String _avatarUrl;

  bool _isUploading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final profileBloc = context.read<ProfileBloc>();
    final currentProfile = profileBloc.state.profile;

    _nameController = TextEditingController(text: currentProfile.nickname);
    _bioController = TextEditingController(text: currentProfile.bio);

    _selectedCountry = currentProfile.country.isNotEmpty ? currentProfile.country : 'Bangladesh';
    _selectedCountryFlag = currentProfile.countryFlag.isNotEmpty ? currentProfile.countryFlag : '🇧🇩';
    _selectedLanguage = currentProfile.language.isNotEmpty ? currentProfile.language : 'English';
    _selectedGender = currentProfile.gender.contains('♀') ? '♀ Female' : '♂ Male';
    _selectedAge = currentProfile.age > 0 ? currentProfile.age : 20;
    _avatarUrl = currentProfile.avatarUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadAvatar() async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (file == null) return;

      setState(() => _isUploading = true);
      final bytes = await file.readAsBytes();
      final ext = file.name.contains('.') ? file.name.split('.').last : 'jpg';
      final currentUid = AuthSessionManager.currentUserId ?? 'user_custom';

      final uploadedUrl = await R2StorageService.instance.uploadAvatar(
        bytes: bytes,
        userId: currentUid,
        extension: ext,
      );

      if (mounted) {
        setState(() {
          if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
            _avatarUrl = uploadedUrl;
          }
          _isUploading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _showCountryPickerDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF07241D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Select Country',
                      style: TextStyle(color: AppColors.goldCoin, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white12, height: 1),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: EditProfileSheet.supportedCountries.length,
                  separatorBuilder: (_, __) => const Divider(color: Colors.white10, height: 1),
                  itemBuilder: (_, index) {
                    final item = EditProfileSheet.supportedCountries[index];
                    final isSelected = item['name'] == _selectedCountry;
                    return ListTile(
                      leading: Text(item['flag'] ?? '', style: const TextStyle(fontSize: 24)),
                      title: Text(
                        item['name'] ?? '',
                        style: TextStyle(
                          color: isSelected ? AppColors.goldCoin : Colors.white,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle_rounded, color: AppColors.goldCoin)
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedCountry = item['name'] ?? 'Bangladesh';
                          _selectedCountryFlag = item['flag'] ?? '🇧🇩';
                        });
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLanguagePickerDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF07241D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Select App Language',
                      style: TextStyle(color: AppColors.goldCoin, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white12, height: 1),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: EditProfileSheet.supportedLanguages.length,
                  separatorBuilder: (_, __) => const Divider(color: Colors.white10, height: 1),
                  itemBuilder: (_, index) {
                    final item = EditProfileSheet.supportedLanguages[index];
                    final isSelected = item['name'] == _selectedLanguage;
                    return ListTile(
                      leading: Text(item['flag'] ?? '', style: const TextStyle(fontSize: 24)),
                      title: Text(
                        '${item['name']} (${item['native']})',
                        style: TextStyle(
                          color: isSelected ? AppColors.goldCoin : Colors.white,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle_rounded, color: AppColors.goldCoin)
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedLanguage = item['name'] ?? 'English';
                        });
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveProfile() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a display nickname'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final genderLabel = _selectedGender.contains('♀') ? '♀ $_selectedAge' : '♂ $_selectedAge';

    // 1. Dispatch event to ProfileBloc (updates state & remote Supabase)
    context.read<ProfileBloc>().add(
          UpdateProfileDetailsEvent(
            nickname: newName,
            avatarUrl: _avatarUrl.isNotEmpty ? _avatarUrl : null,
            country: _selectedCountry,
            countryFlag: _selectedCountryFlag,
            language: _selectedLanguage,
            bio: _bioController.text.trim(),
            gender: genderLabel,
            age: _selectedAge,
          ),
        );

    // 2. Persist locally in AuthSessionManager
    await AuthSessionManager.saveProfileDetails(
      name: newName,
      avatarUrl: _avatarUrl,
      country: _selectedCountry,
      countryFlag: _selectedCountryFlag,
      language: _selectedLanguage,
      bio: _bioController.text.trim(),
      gender: genderLabel,
      age: _selectedAge,
    );
    await AuthSessionManager.markProfileSetupCompleted(true);

    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.isInitialSetup
                      ? '🎉 Welcome! Your Royal Profile is ready.'
                      : '✅ Profile & personal info updated successfully!',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.gemEmerald,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF07241D),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: AppColors.goldCoin, width: 2),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white10)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.goldCoin.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.badge_rounded, color: AppColors.goldCoin, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.isInitialSetup ? 'Set Up Royal Profile' : 'Edit Profile & Info',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.isInitialSetup
                              ? 'Personal info, country & language'
                              : 'Manage your public identity',
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white60),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Avatar Picker Section
                  _buildAvatarSection(),
                  const SizedBox(height: 20),

                  // 2. Personal Info: Display Nickname
                  _buildSectionTitle('Display Nickname', Icons.person_rounded),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    maxLength: 25,
                    decoration: InputDecoration(
                      hintText: 'Enter your nickname...',
                      hintStyle: const TextStyle(color: Colors.white38),
                      prefixIcon: const Icon(Icons.edit_note_rounded, color: AppColors.goldCoin),
                      counterStyle: const TextStyle(color: Colors.white38, fontSize: 10),
                      filled: true,
                      fillColor: const Color(0xFF0F3E32),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.goldCoin, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 3. Country & Language Row Pickers
                  Row(
                    children: [
                      // Country Picker
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Country', Icons.public_rounded),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: _showCountryPickerDialog,
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F3E32),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.white12),
                                ),
                                child: Row(
                                  children: [
                                    Text(_selectedCountryFlag, style: const TextStyle(fontSize: 18)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _selectedCountry,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const Icon(Icons.arrow_drop_down, color: AppColors.goldCoin, size: 20),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Language Picker
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Language', Icons.language_rounded),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: _showLanguagePickerDialog,
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F3E32),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.white12),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.translate_rounded, color: AppColors.gemCyan, size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _selectedLanguage,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const Icon(Icons.arrow_drop_down, color: AppColors.goldCoin, size: 20),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // 4. Gender & Age Row
                  Row(
                    children: [
                      // Gender Selector
                      Expanded(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Gender', Icons.wc_rounded),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                _buildGenderChip('♂ Male', const Color(0xFF1976D2)),
                                const SizedBox(width: 8),
                                _buildGenderChip('♀ Female', const Color(0xFFE91E63)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Age Stepper
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Age', Icons.cake_rounded),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F3E32),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      if (_selectedAge > 18) setState(() => _selectedAge--);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.white10,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.remove, color: Colors.white70, size: 16),
                                    ),
                                  ),
                                  Text(
                                    '$_selectedAge yrs',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      if (_selectedAge < 80) setState(() => _selectedAge++);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.white10,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.add, color: Colors.white70, size: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // 5. Personal Bio / Status
                  _buildSectionTitle('Personal Bio / Status', Icons.format_quote_rounded),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _bioController,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    maxLines: 3,
                    maxLength: 120,
                    decoration: InputDecoration(
                      hintText: 'Share a bit about yourself (e.g. Voice host 🎤 | Gamer 🎮)...',
                      hintStyle: const TextStyle(color: Colors.white38),
                      counterStyle: const TextStyle(color: Colors.white38, fontSize: 10),
                      filled: true,
                      fillColor: const Color(0xFF0F3E32),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.goldCoin, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 6. Save Action Button
                  ElevatedButton(
                    onPressed: _isSaving ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gemEmerald,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                widget.isInitialSetup ? Icons.check_circle_rounded : Icons.save_rounded,
                                size: 18,
                                color: Colors.black,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.isInitialSetup ? 'Complete & Start Playing' : 'Save Profile Changes',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Column(
      children: [
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.goldCoin, width: 2.5),
                  image: _avatarUrl.isNotEmpty
                      ? DecorationImage(image: NetworkImage(_avatarUrl), fit: BoxFit.cover)
                      : null,
                  color: const Color(0xFF0F3E32),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.goldCoin.withValues(alpha: 0.25),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: _avatarUrl.isEmpty
                    ? const Center(child: RoyalBrandLogo(size: 54))
                    : null,
              ),
              if (_isUploading)
                Container(
                  width: 86,
                  height: 86,
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.goldCoin, strokeWidth: 2.5),
                  ),
                ),
              Positioned(
                bottom: 0,
                right: 0,
                child: InkWell(
                  onTap: _isUploading ? null : _pickAndUploadAvatar,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.gemEmerald,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 4)],
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.black, size: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Choose Royal Preset Avatar',
          style: TextStyle(color: Colors.white54, fontSize: 11),
        ),
        const SizedBox(height: 8),

        // Preset Avatars Row
        SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: EditProfileSheet.presetAvatars.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, index) {
              final url = EditProfileSheet.presetAvatars[index];
              final isSelected = _avatarUrl == url;
              return GestureDetector(
                onTap: () => setState(() => _avatarUrl = url),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.goldCoin : Colors.white24,
                      width: isSelected ? 2.5 : 1,
                    ),
                    image: DecorationImage(
                      image: NetworkImage(url),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.goldCoin, size: 14),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildGenderChip(String label, Color accentColor) {
    final isSelected = _selectedGender == label;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedGender = label),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? accentColor.withValues(alpha: 0.25) : const Color(0xFF0F3E32),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? accentColor : Colors.white12,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white60,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
