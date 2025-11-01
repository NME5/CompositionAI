import 'package:flutter/material.dart';
import '../viewmodels/profile_view_model.dart';
import '../services/data_service.dart';

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
    _viewModel = ProfileViewModel();
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
              // Header
              Padding(
                padding: EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Profile', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('Personal settings & preferences', style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Color(0xFFFFECD2), Color(0xFFFCB69F)]),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(Icons.person, color: Colors.grey[800]),
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // User Info
                      Container(
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 80, height: 80,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)]),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Icon(Icons.person, color: Colors.white, size: 40),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(profile.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                      Text(profile.membershipType, style: TextStyle(color: Colors.grey[600])),
                                      SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.amber[100],
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text('⭐ Gold', style: TextStyle(color: Colors.amber[700], fontSize: 10)),
                                          ),
                                          SizedBox(width: 8),
                                          Text('Member since ${profile.memberSince.year}', style: TextStyle(color: Colors.grey[600], fontSize: 10)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildProfileStat('127', 'Measurements'),
                                _buildProfileStat('89', 'Days Active'),
                                _buildProfileStat('15', 'Goals Achieved'),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24),
                      
                      // Personal Info
                      _buildInfoSection('Personal Information', [
                        _buildInfoRow('Age', '${profile.age} years'),
                        _buildInfoRow('Height', '${profile.height.toStringAsFixed(0)} cm'),
                        _buildInfoRow('Weight', '${profile.weight} kg'),
                        _buildInfoRow('Activity Level', profile.activityLevel),
                      ]),
                      SizedBox(height: 24),
                      
                      // Settings
                      _buildInfoSection('Settings', [
                        _buildSettingRow('Units', _viewModel.selectedUnit, 'Change'),
                        _buildToggleRow('Notifications', 'Daily reminders enabled', _viewModel.notificationsEnabled),
                        _buildToggleRow('Data Sync', 'Auto-sync with cloud', _viewModel.dataSyncEnabled),
                      ]),
                      SizedBox(height: 24),
                      
                      // Support
                      _buildInfoSection('Support & Info', [
                        _buildActionRow('Help Center'),
                        _buildActionRow('Privacy Policy'),
                        _buildActionRow('Terms of Service'),
                        _buildActionRow('Sign Out', color: Colors.red),
                      ]),
                      SizedBox(height: 100),
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

  Widget _buildProfileStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 10)),
      ],
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
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

  Widget _buildActionRow(String title, {Color? color}) {
    return InkWell(
      onTap: () {},
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

