/// Task 1323: German noun plural & verb ending lemmatizer
class GermanSuffixLemmatizer {
  String lemmatize(String form) => form.endsWith('en') ? form.substring(0, form.length - 2) : form;
}
