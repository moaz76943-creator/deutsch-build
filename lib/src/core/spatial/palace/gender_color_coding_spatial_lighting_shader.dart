/// Task 1612: Ambient lighting tinting room zones by grammatical gender
class GenderLightingShader {
  int getGenderColorRgb(String gender) => gender == 'Masc' ? 0x0000FF : (gender == 'Fem' ? 0xFF0000 : 0x00FF00);
}
