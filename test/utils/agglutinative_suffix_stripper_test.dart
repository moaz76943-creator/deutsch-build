import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/utils/agglutinative_suffix_stripper.dart';

void main() {
  const engine = AgglutinativeSuffixStripper();
  test('Turkish two-way cascade', () {
    final root=engine.decompose('evlerde',languageCode:'tr')
        .singleWhere((r)=>r.root=='ev');
    expect(root.suffixes,['de','ler']);
    expect(engine.decompose('evlar',languageCode:'tr')
        .any((r)=>r.root=='ev'),isFalse);
  });
  test('Turkish four-way harmony', () {
    expect(engine.decompose('arabayı',languageCode:'tr')
        .any((r)=>r.root=='araba'),isTrue);
    expect(engine.decompose('okulu',languageCode:'tr')
        .any((r)=>r.root=='okul'),isTrue);
  });
  test('Finnish and Hungarian front/back harmony', () {
    expect(engine.decompose('kylässä',languageCode:'fi')
        .any((r)=>r.root=='kylä'),isTrue);
    expect(engine.decompose('házakban',languageCode:'hu')
        .any((r)=>r.root=='ház'),isTrue);
  });
  test('exact lookup wins; otherwise verify candidates', () async {
    final calls=<String>[];
    final result=await engine.searchWithSuffixFallback('evlerde',
        languageCode:'tr',search:(word,language) async {
      calls.add(word);
      return word=='evlerde'?[<String,dynamic>{'surface':word}]:[];
    });
    expect(result,hasLength(1));
    expect(calls,['evlerde']);
    expect((await engine.resolveRoot('evlerde',languageCode:'tr',
        exists:(root,_) async =>root=='ev'))?.root,'ev');
    expect(await engine.resolveRoot('evlerde',languageCode:'tr',
        exists:(_,__) async=>false),isNull);
  });
  test('bounded, unsupported languages do not modify word', () {
    expect(engine.decompose('cats',languageCode:'en'),isEmpty);
    expect(()=>engine.decompose('evlerde',languageCode:'tr',depth:4),
        throwsRangeError);
  });
}
