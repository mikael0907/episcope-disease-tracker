//lib/screens/selfcare_tips_screen.dart



import 'package:flutter/material.dart';

class SelfCareTipsScreen extends StatelessWidget {
  final String disease;

  const SelfCareTipsScreen({super.key, required this.disease});

  @override
  Widget build(BuildContext context) {
    final tips = _getDiseaseSpecificTips(disease);

    return Scaffold(
      appBar: AppBar(title: Text('Self-Care Tips for $disease')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Managing $disease at Home',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            ..._buildTipSections(tips),
            const SizedBox(height: 24),
            _buildWhenToSeekHelp(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTipSections(Map<String, List<String>> tips) {
    return tips.entries.map((entry) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            entry.key,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...entry.value.map(
            (tip) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 4, right: 8),
                    child: Icon(Icons.circle, size: 8),
                  ),
                  Expanded(child: Text(tip)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      );
    }).toList();
  }

  Widget _buildWhenToSeekHelp() {
    return Card(
      color: Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '⚠️ When to Seek Medical Help',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.orange[800],
              ),
            ),
            const SizedBox(height: 8),
            const Text('Seek immediate medical attention if you experience:'),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning, size: 16, color: Colors.red),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('Difficulty breathing or shortness of breath'),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning, size: 16, color: Colors.red),
                  SizedBox(width: 8),
                  Expanded(child: Text('Persistent chest pain or pressure')),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning, size: 16, color: Colors.red),
                  SizedBox(width: 8),
                  Expanded(child: Text('Confusion or inability to wake up')),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning, size: 16, color: Colors.red),
                  SizedBox(width: 8),
                  Expanded(child: Text('Bluish lips or face')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, List<String>> _getDiseaseSpecificTips(String disease) {
    // Define comprehensive self-care tips for each disease
    final tipsDatabase = {
      'COVID-19': {
        'Rest and Hydration': [
          'Get plenty of rest to help your body fight the infection',
          'Drink fluids regularly (water, herbal teas, broth) to stay hydrated',
          'Avoid alcohol and caffeine as they can cause dehydration',
        ],
        'Symptom Management': [
          'Use over-the-counter medications like acetaminophen for fever and aches',
          'Use a humidifier or take hot showers to help with cough',
          'Gargle with warm salt water to soothe a sore throat',
        ],
        'Infection Control': [
          'Isolate yourself from others to prevent spreading the virus',
          'Wear a mask if you must be around others',
          'Wash hands frequently with soap and water',
        ],
      },
      'Influenza (Flu)': {
        'Comfort Measures': [
          'Rest as much as possible',
          'Drink clear fluids like water, broth, or electrolyte solutions',
          'Use a humidifier to ease congestion',
        ],
        'Medication': [
          'Take antiviral medications if prescribed by your doctor',
          'Use over-the-counter pain relievers for fever and body aches',
          'Consider cough suppressants if cough is severe',
        ],
      },
      'Dengue Fever': {
        'Hydration': [
          'Drink plenty of fluids (oral rehydration solutions recommended)',
          'Avoid aspirin and NSAIDs which can increase bleeding risk',
          'Use acetaminophen for pain and fever',
        ],
        'Monitoring': [
          'Watch for warning signs like severe abdominal pain or bleeding',
          'Get daily blood tests to monitor platelet count if advised',
          'Rest completely during the acute phase',
        ],
      },
      'Malaria': {
        'Medication': [
          'Complete the full course of antimalarial drugs as prescribed',
          'Take medications with food to reduce nausea',
        ],
        'Symptom Management': [
          'Use cool compresses to reduce fever',
          'Stay hydrated with clean, safe water',
          'Rest in a cool environment',
        ],
      },
      'Common Cold': {
        'Symptom Relief': [
          'Use saline nasal drops or spray to relieve congestion',
          'Gargle with salt water for sore throat',
          'Drink warm liquids like tea or soup',
        ],
        'Comfort': [
          'Get extra rest',
          'Use a humidifier in your room',
          'Consider over-the-counter cold medicines for symptom relief',
        ],
      },
      'Gastroenteritis': {
        'Diet': [
          'Start with clear liquids, then bland foods (BRAT diet: bananas, rice, applesauce, toast)',
          'Avoid dairy, fatty foods, and caffeine until recovered',
          'Eat small, frequent meals',
        ],
        'Hydration': [
          'Drink small amounts of clear fluids frequently',
          'Use oral rehydration solutions to replace electrolytes',
          'Watch for signs of dehydration (dry mouth, dizziness)',
        ],
      },
    };

    // Return tips for the specific disease or generic tips if disease not found
    return tipsDatabase[disease] ??
        {
          'General Self-Care': [
            'Get plenty of rest',
            'Stay hydrated by drinking fluids',
            'Use over-the-counter medications to relieve symptoms as needed',
            'Monitor your symptoms and seek medical help if they worsen',
          ],
          'Comfort Measures': [
            'Use a humidifier to ease breathing',
            'Gargle with warm salt water for throat irritation',
            'Apply warm or cold compresses for aches',
          ],
        };
  }
}
