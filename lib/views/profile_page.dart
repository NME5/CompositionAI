import 'package:flutter/material.dart';
import '../viewmodels/profile_view_model.dart';
import '../services/data_service.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/dialogs.dart';
import 'credits_page.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late ProfileViewModel _viewModel;
  final DataService _dataService = DataService();

  @override
  void initState() {
    super.initState();
    // Initialize view model with data from service using UserProfile model
    final profile = _dataService.getUserProfile();
    _viewModel = ProfileViewModel(userProfile: profile);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = _dataService.getUserProfile();

    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, child) {
        return SafeArea(
          child: Column(
            children: [  
              Expanded(
                child: SingleChildScrollView(
          child: Column(
            children: [
                  // User Info
                  Padding(
                        padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(18),
                                  child: Image.asset(
                                    'assets/img/credits/timothy_juwono.jpg',
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        profile.name,
                                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        'Glad to see you back',
                                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                            
                      SizedBox(height: 24),
                      
                      // Personal Info
                      _buildInfoSection('Personal Information', [
                              _buildInfoRow('Gender', _viewModel.gender, onEdit: () => _editGender(context)),
                              _buildInfoRow('Age', '${_viewModel.age} years', onEdit: () => _editAge(context)),
                              _buildInfoRow('Height', '${_viewModel.height.toStringAsFixed(0)} cm', onEdit: () => _editHeight(context)),
                              _buildInfoRow('Activity Level', _viewModel.activityLevel, onEdit: () => _editActivityLevel(context)),
                      ]),
                      
                      SizedBox(height: 24),
                      
                      // Settings
                      _buildInfoSection('Settings', [
                        _buildSettingRow('Units', _viewModel.selectedUnit, 'Change'),
                        _buildToggleRow('Notifications', 'Daily reminders enabled', _viewModel.notificationsEnabled),
                        _buildToggleRow('Research Calculation', 'Measurement for body Composition', _viewModel.dataSyncEnabled),
                      ]),
                      SizedBox(height: 24),
                      
                      // Support
                      _buildInfoSection('Support & Info', [
                        _buildActionRow('Help Center'),
                        _buildActionRow('Privacy Policy'),
                        _buildActionRow('Body Standards'),
                        _buildActionRow('Credits', onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => CreditsPage()),
                          );
                        }),
                        _buildActionRow('Sign Out', color: Colors.red),
                      ]),
                      SizedBox(height: 100),
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
      },
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  

  void _editAge(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final scrollController = FixedExtentScrollController(initialItem: _viewModel.age - 1);
          int selectedAge = _viewModel.age;
          
          return Container(
            height: MediaQuery.of(context).size.height * 0.6,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // Header
                Padding(
                  padding: EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                      Text('Select Your Age', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(width: 48),
                    ],
                  ),
                ),
                Divider(color: Colors.grey[200], height: 1),
                SizedBox(height: 24),
                // Scrollable picker with fixed unit
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Scrollable numbers
                      SizedBox(
                        width: 120,
                        child: ListWheelScrollView.useDelegate(
                          itemExtent: 50,
                          diameterRatio: 1.5,
                          controller: scrollController,
                          physics: FixedExtentScrollPhysics(),
                          onSelectedItemChanged: (index) {
                            setState(() {
                              selectedAge = index + 1;
                            });
                            _viewModel.updateAge(selectedAge);
                          },
                          childDelegate: ListWheelChildBuilderDelegate(
                            builder: (context, index) {
                              final age = index + 1;
                              final isSelected = age == selectedAge;
                              return Container(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  '$age',
                                  style: TextStyle(
                                    fontSize: isSelected ? 22 : 18,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? Color(0xFF667EEA) : Colors.grey[600],
                                  ),
                                ),
                              );
                            },
                            childCount: 150,
                          ),
                        ),
                      ),
                      // Fixed unit text
                      Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Text(
                          'years',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF667EEA),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Save button
                Padding(
                  padding: EdgeInsets.all(24),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await _dataService.saveUserProfile(_viewModel.userProfile); //save ke hive
                        if (mounted) Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF667EEA),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      child: Text('Save', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _editHeight(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final currentHeight = _viewModel.height.round();
          final initialIndex = (currentHeight - 50).clamp(0, 200);
          final scrollController = FixedExtentScrollController(initialItem: initialIndex);
          int selectedHeight = currentHeight;
          
          return Container(
            height: MediaQuery.of(context).size.height * 0.6,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // Header
                Padding(
                  padding: EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                      Text('Select Your Height', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(width: 48),
                    ],
                  ),
                ),
                Divider(color: Colors.grey[200], height: 1),
                SizedBox(height: 24),
                // Scrollable picker with fixed unit
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Scrollable numbers
                      SizedBox(
                        width: 120,
                        child: ListWheelScrollView.useDelegate(
                          itemExtent: 50,
                          diameterRatio: 1.5,
                          controller: scrollController,
                          physics: FixedExtentScrollPhysics(),
                          onSelectedItemChanged: (index) {
                            setState(() {
                              selectedHeight = 50 + index;
                            });
                            _viewModel.updateHeight(selectedHeight.toDouble());
                          },
                          childDelegate: ListWheelChildBuilderDelegate(
                            builder: (context, index) {
                              final height = 50 + index;
                              final isSelected = height == selectedHeight;
                              return Container(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  '$height',
                                  style: TextStyle(
                                    fontSize: isSelected ? 22 : 18,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? Color(0xFF667EEA) : Colors.grey[600],
                                  ),
                                ),
                              );
                            },
                            childCount: 201, // 50 to 250 in 1 cm steps
                          ),
                        ),
                      ),
                      // Fixed unit text
                      Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Text(
                          'cm',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF667EEA),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Save button
                Padding(
                  padding: EdgeInsets.all(24),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await _dataService.saveUserProfile(_viewModel.userProfile); //save ke hive
                        if (mounted) Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF667EEA),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      child: Text('Save', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _editGender(BuildContext context) {
    final genders = ['Male', 'Female'];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                  Text('Select Your Gender', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(width: 48),
                ],
              ),
            ),
            Divider(color: Colors.grey[200], height: 1),
            SizedBox(height: 24),
            // Gender options
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 24),
                itemCount: genders.length,
                itemBuilder: (context, index) {
                  final gender = genders[index];
                  final isSelected = gender == _viewModel.gender;
                  return InkWell(
                    onTap: () async {
                      _viewModel.updateGender(gender);
                      await _dataService.saveUserProfile(_viewModel.userProfile); // save ke hive
                      if (mounted) Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      margin: EdgeInsets.only(bottom: 12),
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isSelected ? Color(0xFF667EEA).withOpacity(0.1) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected ? Border.all(color: Color(0xFF667EEA), width: 2) : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(gender, style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Color(0xFF667EEA) : Colors.black87,
                          )),
                          if (isSelected)
                            Icon(Icons.check_circle, color: Color(0xFF667EEA)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editActivityLevel(BuildContext context) {
    final activityLevels = ['Sedentary', 'Lightly Active', 'Moderately Active', 'Very Active', 'Extra Active'];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                  Text('Select Your Activity Level', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(width: 48),
                ],
              ),
            ),
            Divider(color: Colors.grey[200], height: 1),
            SizedBox(height: 24),
            // Activity level options
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 24),
                itemCount: activityLevels.length,
                itemBuilder: (context, index) {
                  final level = activityLevels[index];
                  final isSelected = level == _viewModel.activityLevel;
                  return InkWell(
                    onTap: () async {
                      _viewModel.updateActivityLevel(level);
                      await _dataService.saveUserProfile(_viewModel.userProfile); // save ke hive
                      if (mounted) Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      margin: EdgeInsets.only(bottom: 12),
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isSelected ? Color(0xFF667EEA).withOpacity(0.1) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected ? Border.all(color: Color(0xFF667EEA), width: 2) : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(level, style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Color(0xFF667EEA) : Colors.black87,
                          )),
                          if (isSelected)
                            Icon(Icons.check_circle, color: Color(0xFF667EEA)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildInfoRow(String label, String value, {VoidCallback? onEdit}) {
    if (onEdit != null) {
      return InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              )),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.grey[500],
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } else {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
        ],
      ),
    );
    }
  }

  Widget _buildSettingRow(String title, String subtitle, String action) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
              Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          ),
          TextButton(
            onPressed: () {},
            child: Text(action, style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow(String title, String subtitle, bool value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
              Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          ),
          Switch(
            value: value,
            onChanged: (newValue) => _viewModel.toggleNotifications(newValue),
            activeColor: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(String title, {Color? color, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.w500, color: color)),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}

