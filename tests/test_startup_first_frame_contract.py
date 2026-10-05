from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MAIN = (ROOT / "lib/main.dart").read_text(encoding="utf-8")


def test_no_project_work_runs_before_first_render():
    main_body = MAIN[
        MAIN.index("Future<void> main() async"):
        MAIN.index("Future<_ActivatedPhase3App> _activateProduction")
    ]
    run_app = main_body.index("runApp(const _RenderFirstBootstrapApp())")
    assert "registerProjectOpenSourceLicenses();" not in main_body[:run_app]


def test_license_registration_is_deferred_until_after_first_frame():
    init_state = MAIN[
        MAIN.index("void initState()", MAIN.index("_RenderFirstBootstrapAppState")):
        MAIN.index("Future<void> _bootstrap()", MAIN.index("_RenderFirstBootstrapAppState"))
    ]
    assert "addPostFrameCallback" in init_state
    assert "_registerProjectOpenSourceLicensesSafely();" in init_state


def test_framework_error_fallback_has_its_own_directionality():
    error_builder = MAIN[
        MAIN.index("ErrorWidget.builder"):
        MAIN.index(
            "WidgetsBinding.instance.platformDispatcher.onError",
            MAIN.index("ErrorWidget.builder"),
        )
    ]
    assert "Directionality(" in error_builder
    assert "textDirection: TextDirection.rtl" in error_builder


def test_loading_surface_is_explicit_not_spinner_only():
    loading = MAIN[
        MAIN.index("final class _RenderFirstLoading"):
        MAIN.index("final class _RenderFirstFailure")
    ]
    assert "جاري تجهيز التطبيق المحلي" in loading
    assert "CircularProgressIndicator" in loading


def test_binding_and_run_app_share_the_root_flutter_zone():
    main_body = MAIN[
        MAIN.index("Future<void> main() async"):
        MAIN.index("Future<_ActivatedPhase3App> _activateProduction")
    ]
    assert "WidgetsFlutterBinding.ensureInitialized();" in main_body
    assert "runZonedGuarded" not in main_body
    assert "platformDispatcher.onError" in main_body
