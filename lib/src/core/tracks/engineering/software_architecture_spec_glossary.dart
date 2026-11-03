class SoftwareArchitectureSpecGlossary {
  final Map<String, String> terms = {'microservices': 'خدمات مصغرة', 'scalability': 'قابلية التوسع', 'latency': 'زمن الاستجابة'};
  String getTerm(String key) => terms[key] ?? key;
}
