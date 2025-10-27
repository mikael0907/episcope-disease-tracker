//lib/models/disease_cases_model.dart



import 'dart:ui';

class DiseaseCases {
  final String disease;
  final int cases;
  final Color color;

  const DiseaseCases(this.disease, this.cases, this.color);
}

class DailyCases {
  final DateTime date;
  final int count;

  const DailyCases(this.date, this.count);
}

class DiseaseReports {
  final String diseases;
  final num listingPercentage;
  final String? text;

  const DiseaseReports(this.diseases, this.listingPercentage, [this.text]);
}

class CaseTrend {
  final DateTime date;
  final int newReports;
  final String period;

  const CaseTrend(this.date, this.newReports, this.period);
}
