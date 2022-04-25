import '../hive/models/field.hive.dart';

List<HiveLisoField> templateMedicalRecordFields() {
  return [
    HiveLisoField(
      identifier: 'date',
      type: LisoFieldType.date.name,
      data: {
        'label': 'Date',
      },
    ),
    HiveLisoField(
      identifier: 'location',
      type: LisoFieldType.textField.name,
      data: {
        'label': 'Location',
      },
    ),
    HiveLisoField(
      identifier: 'healthcare_professional',
      type: LisoFieldType.textField.name,
      data: {
        'label': 'Healthcare Professional',
      },
    ),
    HiveLisoField(
      identifier: 'patient',
      type: LisoFieldType.textField.name,
      data: {
        'label': 'Patient',
      },
    ),
    HiveLisoField(
      identifier: 'visit_reason',
      type: LisoFieldType.textField.name,
      data: {
        'label': 'Reason for visit',
      },
    ),
    HiveLisoField(
      type: LisoFieldType.section.name,
      data: {'value': 'Medication'},
    ),
    HiveLisoField(
      identifier: 'medication',
      type: LisoFieldType.textField.name,
      data: {
        'label': 'Medication',
      },
    ),
    HiveLisoField(
      identifier: 'dosage',
      type: LisoFieldType.textField.name,
      data: {
        'label': 'Dosage',
      },
    ),
    HiveLisoField(
      identifier: 'medical_notes',
      type: LisoFieldType.textField.name,
      data: {
        'label': 'Medical Notes',
      },
    ),
    HiveLisoField(
      type: LisoFieldType.section.name,
      data: {'value': 'Others'},
    ),
    HiveLisoField(
      identifier: 'note',
      type: LisoFieldType.textArea.name,
      data: {
        'label': 'Notes',
      },
    ),
  ];
}
