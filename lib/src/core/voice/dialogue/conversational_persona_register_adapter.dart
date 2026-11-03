/// Task 1163: Sociolinguistic register adapter (Formal vs Informal)
enum SpeechRegister { formal, informal, academic }
class PersonaRegisterAdapter {
  SpeechRegister activeRegister = SpeechRegister.formal;
  void setRegister(SpeechRegister reg) => activeRegister = reg;
}
