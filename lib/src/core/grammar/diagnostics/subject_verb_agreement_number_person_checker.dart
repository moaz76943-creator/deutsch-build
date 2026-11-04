/// Task 1341: Subject-verb agreement error detector (singular/plural, person)
class SubjectVerbAgreementChecker {
  bool hasAgreementError(String subjectNumber, String verbNumber) => subjectNumber != verbNumber;
}
