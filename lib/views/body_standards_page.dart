import 'package:flutter/material.dart';

class BodyStandardsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Body Standards & References',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: 24 + MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Research References',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Body composition calculations are based on peer-reviewed research papers. Below are the key references and formulas used in this application.',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            SizedBox(height: 32),

            // Reference 1: Janssen - Skeletal Muscle Mass
            _buildReferenceCard(
              title: 'Skeletal Muscle Mass Estimation',
              authors: 'Janssen I. et al., 2000',
              description: 'Estimation of skeletal muscle mass by bioelectrical impedance analysis',
              equation: 'SM (kg) = 0.401 × (H²/R) + 3.825 × sex − 0.071 × age + 5.102',
              equationDetails: 'Where: H = height (cm), R = impedance (Ω), sex: men=1, women=0',
              journal: 'Journal of Applied Physiology',
            ),

            SizedBox(height: 16),

            // Reference 2: Lukaski - TBW and FFM
            _buildReferenceCard(
              title: 'Total Body Water & Fat-Free Mass Prediction',
              authors: 'Lukaski HC et al., 1986 / Kushner & Lukaski',
              description: 'Foundational equations linking impedance index (H²/R) to TBW and FFM. Provides explicit regression coefficients for weight/height/sex models.',
              equation: 'TBW/FFM = a × (H²/R) + b × weight + c × sex + d',
              equationDetails: 'Regression coefficients vary by population and measurement protocol',
              journal: 'American Journal of Clinical Nutrition',
            ),

            SizedBox(height: 16),

            // Reference 3: Deurenberg - Body Fat Percentage
            _buildReferenceCard(
              title: 'Body Fat Percentage Prediction',
              authors: 'Deurenberg P.',
              description: 'Body-fat/FFM prediction formulas using anthropometry and bioelectrical impedance. Multiple validation studies available.',
              equation: 'Body Fat % = f(weight, height, age, sex, impedance)',
              equationDetails: 'Multiple validated equations available for different populations',
              journal: 'Asia Pacific Journal of Clinical Nutrition',
            ),

            SizedBox(height: 16),

            // Reference 4: Kang - Visceral Fat Area
            _buildReferenceCard(
              title: 'Visceral Fat Area Determination',
              authors: 'Kang SH et al., 2015',
              description: 'BIA-derived visceral fat area (VFA) prediction equation validated against CT/MRI reference standards.',
              equation: 'VFA = g(impedance, weight, height, age, sex)',
              equationDetails: 'Validated against computed tomography and magnetic resonance imaging',
              journal: 'International Journal of Medical Sciences',
            ),

            SizedBox(height: 16),

            // Reference 5: Hoffmann - Visceral Fat via BIA
            _buildReferenceCard(
              title: 'Visceral Fat Quantification via BIA',
              authors: 'Hoffmann J. et al., 2023',
              description: 'Newer model proposing explicit regression equations for visceral adipose tissue (VAT) estimation using BIA and simple anthropometric measures.',
              equation: 'VAT = h(BIA parameters, anthropometry)',
              equationDetails: 'Includes explicit formula coefficients and validation data',
              journal: 'Published in PMC',
            ),

            SizedBox(height: 16),

            // Reference 6: Beaudart - Systematic Review
            _buildReferenceCard(
              title: 'Systematic Review: Muscle Mass BIA Equations',
              authors: 'Beaudart C. et al., 2019',
              description: 'Comprehensive systematic review listing and comparing multiple skeletal muscle mass BIA equations. Contains many explicit formulas for different populations.',
              equation: 'Multiple validated SMM equations',
              equationDetails: 'Compares equations across different age groups, ethnicities, and clinical populations',
              journal: 'Ageing Muscle Research',
            ),

            SizedBox(height: 32),

            // Additional Notes Section
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFFF0F4FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Color(0xFF667EEA).withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Color(0xFF667EEA), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Note',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF667EEA),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    'The formulas implemented in this application are based on these research papers. Different calculation methods may use different equations from these references. You can switch between calculation methods in Profile Settings.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildReferenceCard({
    required String title,
    required String authors,
    required String description,
    required String equation,
    required String equationDetails,
    required String journal,
  }) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF667EEA),
            ),
          ),
          SizedBox(height: 8),
          Text(
            authors,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Formula:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  equation,
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'monospace',
                    color: Colors.grey[900],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (equationDetails.isNotEmpty) ...[
                  SizedBox(height: 8),
                  Text(
                    equationDetails,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.article, size: 14, color: Colors.grey[600]),
              SizedBox(width: 6),
              Text(
                journal,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

