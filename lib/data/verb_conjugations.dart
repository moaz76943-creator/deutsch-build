// Compatibility/runtime facade. Editable German authoring sources live under content/german/.
import '../models/verb_conjugation.dart';
import 'generated/verb_conjugations_generated.dart';
export '../models/verb_conjugation.dart';
export 'generated/verb_conjugations_generated.dart';

const verbConjugations = generatedVerbConjugations;

// Legacy expansion symbols remain as empty compatibility views because the
// generated runtime pack already contains the complete verb corpus.
const v126VerbExpansion = <VerbConjugation>[];
const v126AdditionalVerbExpansion = <VerbConjugation>[];
const v128VerbExpansion = <VerbConjugation>[];
