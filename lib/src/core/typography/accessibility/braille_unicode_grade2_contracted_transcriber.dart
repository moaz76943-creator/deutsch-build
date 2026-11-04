/// Task 1296: Unicode Braille Grade 1 & 2 transcription engine
class BrailleTranscriber {
  String toBraille(String text) => text.split('').map((c) => '\u2800').join('');
}
