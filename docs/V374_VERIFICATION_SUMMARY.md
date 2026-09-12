# V374 Verification Summary

- Version: 3.3.0+123
- Full Python regression: 629 passed
- Fast content run: LOW risk; content_quality, compiler_parity, targeted selected; accessibility, architecture, full_regression, integration, privacy, security explicitly skipped as unaffected.
- Fast second run: same three checks served from dependency-aware cache.
- Release verification wrapper (non-Flutter environment): full regression, content quality, security, privacy, accessibility, architecture, compiler parity all PASS.
- `compileall`: PASS.
- Flutter/Android build: not executed because Flutter toolchain is unavailable in this environment; `scripts/check-release.sh` fails closed with exit 2 when the toolchain is absent.
- Existing language-ready architecture gate remains a separate open item: V370 gate reports 47 findings. V374 does not suppress or reinterpret those findings.
