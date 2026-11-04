/// Task 1376: Distinguishes open clausal complements (xcomp) from closed (ccomp)
class ClausalComplementDistinguisher {
  String getComplementType(bool hasOvertSubject) => hasOvertSubject ? 'ccomp' : 'xcomp';
}
