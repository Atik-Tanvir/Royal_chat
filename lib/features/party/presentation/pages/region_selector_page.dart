import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class RegionSelectorPage extends StatefulWidget {
  final String selectedRegion;
  final ValueChanged<String>? onSelectRegion;

  const RegionSelectorPage({
    super.key,
    this.selectedRegion = 'All',
    this.onSelectRegion,
  });

  @override
  State<RegionSelectorPage> createState() => _RegionSelectorPageState();
}

class _RegionSelectorPageState extends State<RegionSelectorPage> {
  final List<Map<String, String>> _recommended = [
    {'name': 'All', 'flag': '🌐'},
    {'name': 'Bangladesh', 'flag': '🇧🇩'},
    {'name': 'Saudi Arabia', 'flag': '🇸🇦'},
    {'name': 'United Arab Emirates', 'flag': '🇦🇪'},
    {'name': 'Qatar', 'flag': '🇶🇦'},
    {'name': 'Kuwait', 'flag': '🇰🇼'},
    {'name': 'India', 'flag': '🇮🇳'},
    {'name': 'Pakistan', 'flag': '🇵🇰'},
    {'name': 'Philippines', 'flag': '🇵🇭'},
    {'name': 'Indonesia', 'flag': '🇮🇩'},
    {'name': 'Malaysia', 'flag': '🇲🇾'},
  ];

  final Map<String, List<Map<String, String>>> _alphabetical = {
    'A': [
      {'name': 'Abkhazia', 'flag': '🌐'},
      {'name': 'Afghanistan', 'flag': '🇦🇫'},
      {'name': 'Albania', 'flag': '🇦🇱'},
      {'name': 'Algeria', 'flag': '🇩🇿'},
      {'name': 'American Samoa', 'flag': '🇦🇸'},
      {'name': 'Andorra', 'flag': '🇦🇩'},
      {'name': 'Angola', 'flag': '🇦🇴'},
      {'name': 'Anguilla', 'flag': '🇦🇮'},
      {'name': 'Antigua and Barbuda', 'flag': '🇦🇬'},
      {'name': 'Argentina', 'flag': '🇦🇷'},
      {'name': 'Armenia', 'flag': '🇦🇲'},
      {'name': 'Aruba', 'flag': '🇦🇼'},
      {'name': 'Australia', 'flag': '🇦🇺'},
      {'name': 'Austria', 'flag': '🇦🇹'},
      {'name': 'Azerbaijan', 'flag': '🇦🇿'},
    ],
    'B': [
      {'name': 'Bahamas', 'flag': '🇧🇸'},
      {'name': 'Bahrain', 'flag': '🇧🇭'},
      {'name': 'Bangladesh', 'flag': '🇧🇩'},
      {'name': 'Barbados', 'flag': '🇧🇧'},
      {'name': 'Belarus', 'flag': '🇧🇾'},
      {'name': 'Belgium', 'flag': '🇧🇪'},
      {'name': 'Belize', 'flag': '🇧🇿'},
      {'name': 'Benin', 'flag': '🇧🇯'},
      {'name': 'Bermuda', 'flag': '🇧🇲'},
      {'name': 'Bhutan', 'flag': '🇧🇹'},
      {'name': 'Bolivia', 'flag': '🇧🇴'},
      {'name': 'Brazil', 'flag': '🇧🇷'},
    ],
    'C': [
      {'name': 'Cambodia', 'flag': '🇰🇭'},
      {'name': 'Cameroon', 'flag': '🇨🇲'},
      {'name': 'Canada', 'flag': '🇨🇦'},
      {'name': 'Chile', 'flag': '🇨🇱'},
      {'name': 'China', 'flag': '🇨🇳'},
      {'name': 'Colombia', 'flag': '🇨🇴'},
    ],
    'D': [
      {'name': 'Denmark', 'flag': '🇩🇰'},
      {'name': 'Djibouti', 'flag': '🇩🇯'},
      {'name': 'Dominican Republic', 'flag': '🇩🇴'},
    ],
    'E': [
      {'name': 'Egypt', 'flag': '🇪🇬'},
      {'name': 'Ecuador', 'flag': '🇪🇨'},
      {'name': 'Ethiopia', 'flag': '🇪🇹'},
    ],
    'F': [
      {'name': 'Finland', 'flag': '🇫🇮'},
      {'name': 'France', 'flag': '🇫🇷'},
    ],
    'G': [
      {'name': 'Germany', 'flag': '🇩🇪'},
      {'name': 'Ghana', 'flag': '🇬🇭'},
      {'name': 'Greece', 'flag': '🇬🇷'},
    ],
    'H': [
      {'name': 'Hong Kong', 'flag': '🇭🇰'},
      {'name': 'Hungary', 'flag': '🇭🇺'},
    ],
    'I': [
      {'name': 'India', 'flag': '🇮🇳'},
      {'name': 'Indonesia', 'flag': '🇮🇩'},
      {'name': 'Iraq', 'flag': '🇮🇶'},
      {'name': 'Ireland', 'flag': '🇮🇪'},
      {'name': 'Italy', 'flag': '🇮🇹'},
    ],
    'J': [
      {'name': 'Japan', 'flag': '🇯🇵'},
      {'name': 'Jordan', 'flag': '🇯🇴'},
    ],
    'K': [
      {'name': 'Kazakhstan', 'flag': '🇰🇿'},
      {'name': 'Kenya', 'flag': '🇰🇪'},
      {'name': 'Kuwait', 'flag': '🇰🇼'},
    ],
    'L': [
      {'name': 'Lebanon', 'flag': '🇱🇧'},
      {'name': 'Libya', 'flag': '🇱🇾'},
    ],
    'M': [
      {'name': 'Malaysia', 'flag': '🇲🇾'},
      {'name': 'Maldives', 'flag': '🇲🇻'},
      {'name': 'Mexico', 'flag': '🇲🇽'},
      {'name': 'Morocco', 'flag': '🇲🇦'},
    ],
    'N': [
      {'name': 'Nepal', 'flag': '🇳🇵'},
      {'name': 'Netherlands', 'flag': '🇳🇱'},
      {'name': 'New Zealand', 'flag': '🇳🇿'},
      {'name': 'Nigeria', 'flag': '🇳🇬'},
    ],
    'O': [
      {'name': 'Oman', 'flag': '🇴🇲'},
    ],
    'P': [
      {'name': 'Pakistan', 'flag': '🇵🇰'},
      {'name': 'Palestine', 'flag': '🇵🇸'},
      {'name': 'Philippines', 'flag': '🇵🇭'},
      {'name': 'Poland', 'flag': '🇵🇱'},
      {'name': 'Portugal', 'flag': '🇵🇹'},
    ],
    'Q': [
      {'name': 'Qatar', 'flag': '🇶🇦'},
    ],
    'R': [
      {'name': 'Romania', 'flag': '🇷🇴'},
      {'name': 'Russia', 'flag': '🇷🇺'},
    ],
    'S': [
      {'name': 'Saudi Arabia', 'flag': '🇸🇦'},
      {'name': 'Singapore', 'flag': '🇸🇬'},
      {'name': 'South Africa', 'flag': '🇿🇦'},
      {'name': 'South Korea', 'flag': '🇰🇷'},
      {'name': 'Spain', 'flag': '🇪🇸'},
      {'name': 'Sri Lanka', 'flag': '🇱🇰'},
    ],
    'T': [
      {'name': 'Thailand', 'flag': '🇹🇭'},
      {'name': 'Tunisia', 'flag': '🇹🇳'},
      {'name': 'Turkey', 'flag': '🇹🇷'},
    ],
    'U': [
      {'name': 'Ukraine', 'flag': '🇺🇦'},
      {'name': 'United Arab Emirates', 'flag': '🇦🇪'},
      {'name': 'United Kingdom', 'flag': '🇬🇧'},
      {'name': 'United States', 'flag': '🇺🇸'},
    ],
    'V': [
      {'name': 'Vietnam', 'flag': '🇻🇳'},
    ],
    'Y': [
      {'name': 'Yemen', 'flag': '🇾🇪'},
    ],
    'Z': [
      {'name': 'Zimbabwe', 'flag': '🇿🇼'},
    ]
  };

  void _chooseRegion(String name) {
    widget.onSelectRegion?.call(name);
    Navigator.pop(context, name);
  }

  @override
  Widget build(BuildContext context) {
    final letters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.gemEmerald, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Region',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 36, 32),
            children: [
              // Recommend Header
              const Text(
                'Recommend',
                style: TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              // Recommend Pills
              Wrap(
                spacing: 8,
                runSpacing: 10,
                children: _recommended.map((c) => _buildCountryPill(c['name']!, c['flag']!)).toList(),
              ),
              const SizedBox(height: 24),

              // Alphabetical Sections
              ..._alphabetical.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 10,
                      children: entry.value
                          .map((c) => _buildCountryPill(c['name']!, c['flag']!))
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              }),
            ],
          ),

          // A-Z Quick Index Bar on Right
          Positioned(
            right: 6,
            top: 20,
            bottom: 20,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: letters.map((l) {
                return Text(
                  l,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountryPill(String name, String flag) {
    final isSelected = widget.selectedRegion == name;

    return GestureDetector(
      onTap: () => _chooseRegion(name),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F7F2) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.gemEmerald : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(flag, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(
              name,
              style: TextStyle(
                color: isSelected ? AppColors.gemEmerald : const Color(0xFF334155),
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
