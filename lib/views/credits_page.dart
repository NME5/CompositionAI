import 'package:flutter/material.dart';

class CreditsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Credits', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                        Text('About CompositionAI', style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  ),
                  // Container(
                  //   width: 48,
                  //   height: 48,
                  //   decoration: BoxDecoration(
                  //     gradient: LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)]),
                  //     borderRadius: BorderRadius.circular(16),
                  //   ),
                  //   child: Icon(Icons.info_outline, color: Colors.white),
                  // ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSection('Project Researcher',
                      [
                        _buildLongTeamMemberCard(
                          name: 'Timothy Juwono',
                          role: 'Researcher I',
                          description: 'Researched BLE communication protocols and explored AI methods, including Bayesian logistic regression for predictive analysis.',
                          gradientColors: [Color(0xFFFFECD2), Color(0xFFFCB69F)],
                        ),
                        SizedBox(height: 12),
                        _buildLongTeamMemberCard(
                          name: 'Lionel Winston Sengkey',
                          role: 'Researcher II',
                          description: 'Studied Type 2 Diabetes correlations to support prediction logic and recommendation design using Bayesian logistic regression.',
                          gradientColors: [Color(0xFFFFECD2), Color(0xFFFCB69F)],
                        ),
                      ]
                      ),

                      SizedBox(height: 24),

                      // Development Team
                      _buildSection(
                        'Development Team',
                        [
                          _buildLongTeamMemberCard(
                            name: 'Timothy Juwono',
                            role: 'Lead Developer',
                            description: 'Built the Flutter app, implemented one-way BLE communication to receive data from the scale, and integrated an on-device AI model for smart data processing and insights.',
                            gradientColors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                          ),
                          SizedBox(height: 12),
                          _buildLongTeamMemberCard(
                            name: 'Lionel Winston Sengkey',
                            role: 'UI/UX Designer',
                            description: 'Provided design direction throughout development, refined interface decisions, and delivered usability feedback to improve clarity, interaction flow, and overall user experience.',
                            gradientColors: [Color(0xFFFFECD2), Color(0xFFFCB69F)],
                          ),
                        ],
                      ),

                      SizedBox(height: 24),

                      // Technologies
                      _buildSection(
                        'Technologies',
                        [
                          _buildTechCard(
                            icon: Icons.code,
                            name: 'Flutter',
                            description: 'Cross-platform mobile development',
                          ),
                          SizedBox(height: 12),
                          _buildTechCard(
                            icon: Icons.storage,
                            name: 'Hive',
                            description: 'Lightweight Local database & storage',
                          ),
                          SizedBox(height: 12),
                          _buildTechCard(
                            icon: Icons.bluetooth,
                            name: 'Flutter Blue Plus',
                            description: 'Bluetooth connectivity',
                          ),
                        ],
                      ),

                      SizedBox(height: 24),

                      // Acknowledgments
                      _buildSection(
                        'Acknowledgments',
                        [
                          _buildAcknowledgmentCard(
                            title: 'Open Source Community',
                            description: 'Thanks to all the open source contributors and libraries that made this app possible.',
                          ),
                          SizedBox(height: 12),
                          _buildAcknowledgmentCard(
                            title: 'Health & Fitness Research',
                            description: 'Body composition calculations based on established medical research and standards.',
                          ),
                        ],
                      ),

                      SizedBox(height: 24),

                      // Footer
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Made with ❤️',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '© 2024 CompositionAI. All rights reserved.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildTeamMemberCard({
    required String name,
    required String role,
    required String description,
    List<Color>? gradientColors,
  }) {
    final colors = gradientColors ?? [Color(0xFFFFECD2), Color(0xFFFCB69F)];
    
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: colors),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.person, color: Colors.grey[800], size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(role, style: TextStyle(color: Color(0xFF667EEA), fontSize: 13, fontWeight: FontWeight.w500)),
                SizedBox(height: 4),
                Text(description, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLongTeamMemberCard({
    required String name,
    required String role,
    required String description,
    List<Color>? gradientColors,
  }) {
    final colors = gradientColors ?? [Color(0xFFFFECD2), Color(0xFFFCB69F)];
    
    return Container(
      padding: EdgeInsets.all(20),
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
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: colors),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.person, color: Colors.grey[800], size: 24),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text(role, style: TextStyle(color: Color(0xFF667EEA), fontSize: 13, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(color: Colors.grey[600], fontSize: 12, height: 1.4),
          ),
        ],
      ),
    );
  }


  Widget _buildTechCard({
    required IconData icon,
    required String name,
    required String description,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Color(0xFF667EEA).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Color(0xFF667EEA), size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                Text(description, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcknowledgmentCard({
    required String title,
    required String description,
  }) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.star, color: Colors.amber[600], size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                SizedBox(height: 4),
                Text(description, style: TextStyle(color: Colors.grey[600], fontSize: 12, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

