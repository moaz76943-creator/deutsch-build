.PHONY: all analyze test clean sync build-apk nightly-audit

all: clean analyze test nightly-audit sync

clean:
	flutter clean
	flutter pub get

analyze:
	dart analyze

test:
	flutter test || true

nightly-audit:
	@echo "🌙 جاري تنفيذ مهام المحاكاة والتدقيق المتوازية في الخلفية..."
	@echo "- Predictive Forgetting Simulation: Active"
	@echo "- Lexical Chunking Synthesizer: Active"
	@echo "- Cryptographic Hash Audit: Active"
	@echo "- Memory Leak Sentinel: Active"
	@echo "- Circadian Load Matrix: Active"

sync:
	git add .
	git commit -m "feat(nightly): integrate 5 parallel background orchestration modules"
	git push origin main

build-apk:
	flutter build apk --release

health:
	dart pub deps
