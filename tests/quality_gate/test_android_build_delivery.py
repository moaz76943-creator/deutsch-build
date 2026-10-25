"""Build-policy and cloud-control regressions; external commands are isolated doubles."""
import json
import os
from pathlib import Path
import subprocess

import pytest

from security_topology import assert_active_build_delivery_boundaries

ROOT = Path(__file__).resolve().parents[2]
SHA = "a" * 40


def executable(path, source):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(source)
    path.chmod(0o755)


@pytest.mark.parametrize("available,status,report", [
    (1048575, 10, "minimum"), (1048576, 0, "WARN"),
    (2097152, 0, "WARN"), (3145728, 0, "OK"), (8388607, 0, "OK"),
])
def test_disk_policy_boundaries(tmp_path, available, status, report):
    binary = tmp_path / "bin/df"
    executable(binary, f"#!/bin/sh\nprintf 'Filesystem Blocks Used Available Capacity Mounted\\nfs 99999999 0 {available} 0 /\\n'\n")
    env = {**os.environ, "PATH": str(binary.parent) + os.pathsep + os.environ["PATH"]}
    proc = subprocess.run(["bash", str(ROOT / "scripts/check-disk-space.sh"), str(tmp_path)],
                          env=env, capture_output=True, text=True)
    assert proc.returncode == status, proc.stdout + proc.stderr
    assert report in proc.stdout + proc.stderr


@pytest.mark.parametrize("status,diagnostic,success", [
    (0, "", True), (1, "INFO|HINT|TEST|lib/a.dart|1|1|1|Info", True),
    (2, "WARNING|STATIC_WARNING|TEST|lib/a.dart|1|1|1|Warning", True),
    (0, "ERROR|COMPILE_TIME_ERROR|TEST|lib/a.dart|1|1|1|Error", False),
    (3, "ERROR|COMPILE_TIME_ERROR|TEST|lib/a.dart|1|1|1|Error", False),
    (1, "SDK crashed", False), (127, "Dart unavailable", False),
])
def test_dart_gate_distinguishes_errors_from_warnings_and_crashes(tmp_path, status, diagnostic, success):
    binary = tmp_path / "bin/dart"
    executable(binary, "#!/usr/bin/env python3\nimport os\nprint(os.environ['DIAGNOSTIC'])\nraise SystemExit(int(os.environ['ANALYZER_STATUS']))\n")
    env = {**os.environ, "PATH": str(binary.parent) + os.pathsep + os.environ["PATH"],
           "DIAGNOSTIC": diagnostic, "ANALYZER_STATUS": str(status)}
    proc = subprocess.run(["bash", str(ROOT / "scripts/check-dart-errors.sh")], env=env,
                          capture_output=True, text=True)
    assert (proc.returncode == 0) == success, proc.stdout + proc.stderr


@pytest.fixture
def worker_doubles(tmp_path):
    trace = tmp_path / "commands.jsonl"
    tools = tmp_path / "bin"
    executable(tools / "git", """#!/usr/bin/env python3
import json, os, sys
a=sys.argv[1:]
with open(os.environ['COMMAND_TRACE'],'a') as f: f.write(json.dumps(['git',*a])+'\n')
s=os.environ['SCENARIO']
if a[:2]==['remote','get-url']: print('https://github.com/sali97m-cpu/deutsch-bilarabi.git')
elif a and a[0]=='rev-parse': print(os.environ['SOURCE_SHA'])
elif a and a[0]=='ls-remote':
    if s=='ref-unavailable': raise SystemExit(128)
    if s=='new-branch': raise SystemExit(2)
    print('b'*40+' refs/heads/main')
elif a and a[0]=='merge-base' and s=='diverged': raise SystemExit(1)
elif a and a[0]=='push' and s=='push-failed': raise SystemExit(1)
""".replace("+'\n')", "+'\\n')"))
    executable(tools / "gh", """#!/usr/bin/env python3
import json, os, pathlib, sys
a=sys.argv[1:]
with open(os.environ['COMMAND_TRACE'],'a') as f: f.write(json.dumps(['gh',*a])+'\n')
s=os.environ['SCENARIO']; sha=os.environ['SOURCE_SHA']
def run(i,status,conclusion=None):
    return dict(databaseId=i,headSha=sha,status=status,conclusion=conclusion,url='https://github.com/sali97m-cpu/deutsch-bilarabi-worker/actions/runs/'+str(i))
if a[:2]==['variable','list']: print('false' if s=='disabled' else 'true')
elif a[:2]==['secret','list']:
    names=['RELEASE_KEYSTORE_BASE64','RELEASE_STORE_PASSWORD','RELEASE_KEY_ALIAS','RELEASE_KEY_PASSWORD','TELEGRAM_BOT_TOKEN','TELEGRAM_CHAT_ID']
    if s=='missing-telegram': names.remove('TELEGRAM_BOT_TOKEN')
    print('\n'.join(names))
elif a[:2]==['workflow','run']:
    if s=='dispatch-rejected': raise SystemExit(1)
elif a[:2]==['run','list']:
    count=pathlib.Path(os.environ['RUN_LIST_COUNT'])
    n=int(count.read_text())+1 if count.exists() else 1; count.write_text(str(n))
    if s=='status-unavailable' and n>1: raise SystemExit(1)
    if n==1: runs=[run(100,'queued' if s=='active' else 'completed','success')]
    elif s=='not-visible': runs=[]
    elif s in ('quota','build-failed'): runs=[run(101,'completed','failure')]
    elif s=='success': runs=[run(101,'completed','success')]
    else: runs=[run(101,'queued')]
    print(json.dumps(runs))
elif a and a[0]=='api':
    endpoint=next(x for x in a if x.startswith('repos/'))
    if endpoint.endswith('/annotations'): print('The job was not started because recent account payments have failed or your spending limit needs to be increased.' if s=='quota' else 'Compile failed')
    elif '/check-suites/' in endpoint: print('9')
    elif '/actions/runs/' in endpoint: print('5')
""".replace("+'\n')", "+'\\n')").replace("print('\n'.join", "print('\\n'.join"))
    env = {**os.environ, "PATH": str(tools) + os.pathsep + os.environ["PATH"],
           "COMMAND_TRACE": str(trace), "RUN_LIST_COUNT": str(tmp_path / "count"),
           "SOURCE_SHA": SHA, "BUILD_WORKER_STATUS_ATTEMPTS": "2", "BUILD_WORKER_STATUS_INTERVAL": "0"}
    return env, trace


@pytest.mark.parametrize("scenario,exit_code,dispatches,phrase", [
    ("success", 0, 1, "completed / success"),
    ("queued", 0, 1, "successful build is not yet confirmed"),
    ("active", 0, 0, "without duplicate dispatch"),
    ("quota", 2, 1, "compute is unavailable due to quota/billing"),
    ("build-failed", 2, 1, "Worker did not succeed"),
    ("dispatch-rejected", 1, 1, "Source export succeeded; cloud dispatch"),
    ("not-visible", 0, 1, "Cloud execution remains unverified"),
    ("status-unavailable", 0, 1, "Status API unavailable"),
    ("disabled", 1, 0, "BUILD_WORKER_ENABLED must be true"),
    ("missing-telegram", 1, 0, "missing worker secrets"),
    ("diverged", 1, 0, "Refusing to force-push"),
    ("ref-unavailable", 1, 0, "remote state is unknown"),
    ("push-failed", 1, 0, ""),
    ("new-branch", 0, 1, "Source export succeeded"),
])
def test_worker_export_and_bounded_dispatch(worker_doubles, scenario, exit_code, dispatches, phrase):
    env, trace = worker_doubles
    env["SCENARIO"] = scenario
    proc = subprocess.run(["bash", str(ROOT / "scripts/export_build_worker.sh")],
                          env=env, capture_output=True, text=True, timeout=15)
    assert proc.returncode == exit_code, proc.stdout + proc.stderr
    assert phrase in proc.stdout + proc.stderr
    commands = [json.loads(line) for line in trace.read_text().splitlines()]
    assert sum(command[:3] == ['gh','workflow','run'] for command in commands) == dispatches
    assert sum(command[:3] == ['gh','run','list'] for command in commands) <= 3
    if dispatches or scenario == "active":
        assert SHA in proc.stdout
        assert "deutsch-bilarabi-worker" in proc.stdout
    if scenario in ("quota", "queued", "active", "dispatch-rejected", "not-visible", "status-unavailable"):
        assert "./scripts/termux_release.sh" in proc.stdout + proc.stderr


def test_worker_yaml_preserves_control_plane_and_has_valid_shell_blocks(tmp_path):
    yaml = pytest.importorskip("yaml")
    workflow = yaml.safe_load((ROOT / ".github/workflows/worker_release_apk.yml").read_text())
    job = workflow['jobs']['build-release']
    assert workflow['concurrency']['cancel-in-progress'] is True
    assert 'BUILD_WORKER_RUNNER_LABELS' in job['runs-on']
    assert 'ubuntu-latest' in job['runs-on']
    for step in job['steps']:
        if 'uses' in step:
            import re
            assert re.fullmatch(r'[0-9a-f]{40}', step['uses'].split('@')[1])
        if 'run' in step:
            script = tmp_path / 'step.sh'
            script.write_text(step['run'])
            subprocess.run(['bash','-n',str(script)],check=True)
    names = {step['name'] for step in job['steps']}
    assert {'Notify Telegram on success','Notify Telegram on failure','Verify content ingestion engine'} <= names


def test_termux_release_rejects_other_hosts(tmp_path):
    env = os.environ.copy()
    env.pop('PREFIX', None)
    proc = subprocess.run(['bash',str(ROOT / 'scripts/termux_release.sh')],env=env,capture_output=True,text=True)
    assert proc.returncode != 0
    assert 'inside Termux' in proc.stderr


def test_release_manifest_strips_unwired_notification_and_storage_permissions():
    import xml.etree.ElementTree as ET
    manifest = ET.parse(ROOT / 'android/app/src/release/AndroidManifest.xml').getroot()
    android = '{http://schemas.android.com/apk/res/android}'
    tools = '{http://schemas.android.com/tools}'
    removed = {node.attrib[android+'name'] for node in manifest.findall('uses-permission')
               if node.attrib.get(tools+'node') == 'remove'}
    assert removed == {
        'android.permission.POST_NOTIFICATIONS',
        'android.permission.READ_EXTERNAL_STORAGE',
        'android.permission.WRITE_EXTERNAL_STORAGE',
        'android.permission.MANAGE_EXTERNAL_STORAGE',
        'android.permission.READ_MEDIA_IMAGES',
        'android.permission.READ_MEDIA_VIDEO',
        'android.permission.READ_MEDIA_AUDIO',
        'android.permission.READ_MEDIA_VISUAL_USER_SELECTED',
    }
    main = ET.parse(ROOT / 'android/app/src/main/AndroidManifest.xml').getroot()
    assert any(node.attrib.get(android+'name') == 'android.permission.RECORD_AUDIO'
               for node in main.findall('uses-permission'))


def test_phone_path_preserves_selected_jdk_and_dart_but_prefers_native_android_tools(tmp_path):
    prefix, sdk, flutter, jdk = [tmp_path / name for name in ('native', 'sdk', 'flutter', 'jdk')]
    for path in (prefix / 'bin/aapt', prefix / 'bin/aapt2',
                 sdk / 'build-tools/36.0.0/aapt', sdk / 'build-tools/36.0.0/aapt2',
                 flutter / 'bin/flutter', flutter / 'bin/cache/dart-sdk/bin/dart',
                 jdk / 'bin/java', prefix / 'bin/java', prefix / 'bin/dart'):
        executable(path, '#!/bin/sh\nexit 0\n')
    env = {**os.environ, 'PREFIX':str(prefix), 'ANDROID_SDK_ROOT':str(sdk),
           'ANDROID_BUILD_TOOLS_VERSION':'36.0.0', 'FLUTTER_ROOT':str(flutter),
           'JAVA_HOME':str(jdk), 'PATH':str(sdk / 'build-tools/36.0.0') + ':' + os.environ['PATH']}
    proc = subprocess.run(['bash', '-c',
        'source "$1"; is_termux() { return 0; }; configure_android_build_path; '
        'command -v java dart flutter aapt aapt2', 'fixture', str(ROOT / 'scripts/common.sh')],
        env=env, capture_output=True, text=True)
    assert proc.returncode == 0, proc.stdout + proc.stderr
    assert proc.stdout.splitlines() == [str(jdk/'bin/java'), str(flutter/'bin/cache/dart-sdk/bin/dart'),
        str(flutter/'bin/flutter'), str(prefix/'bin/aapt'), str(prefix/'bin/aapt2')]


@pytest.mark.parametrize('native_machine', [183, 62])
def test_native_aapt2_overrides_shadowing_sdk_and_rejects_wrong_elf_architecture(tmp_path, monkeypatch, native_machine):
    import importlib.util
    monkeypatch.syspath_prepend(str(ROOT / 'tool'))
    spec = importlib.util.spec_from_file_location('local_build_environment', ROOT / 'tool/local_build_environment.py')
    helper = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(helper)
    prefix = tmp_path / 'native'
    native, host = prefix / 'bin/aapt2', tmp_path / 'sdk/bin/aapt2'
    for binary, machine in ((native, native_machine), (host, 62)):
        executable(binary, '')
        binary.write_bytes(b'\x7fELF\x02\x01' + b'\x00' * 12 + machine.to_bytes(2, 'little'))
    monkeypatch.setenv('PATH', str(host.parent))
    if native_machine == 183:
        assert helper.native_aapt2(str(prefix)) == str(native)
    else:
        with pytest.raises(SystemExit, match='not ARM64'):
            helper.native_aapt2(str(prefix))


def test_termux_overrides_apply_to_real_gradle_without_rewriting_user_settings(tmp_path, monkeypatch, capsys):
    import importlib.util
    import shlex
    from types import SimpleNamespace
    monkeypatch.syspath_prepend(str(ROOT / 'tool'))
    spec = importlib.util.spec_from_file_location('local_build_environment', ROOT / 'tool/local_build_environment.py')
    helper = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(helper)
    project = tmp_path / 'fixture'
    project.mkdir()
    flutter = tmp_path / 'flutter sdk'
    android = tmp_path / 'android sdk'
    flutter.mkdir(); android.mkdir()
    home = tmp_path / 'gradle-user'
    home.mkdir()
    properties = home / 'gradle.properties'
    original = '# User settings\norg.gradle.parallel=true\norg.gradle.workers.max=8\n'
    properties.write_text(original)
    native = tmp_path / 'native tools/aapt2'
    executable(native, '#!/bin/sh\nexit 0\n')
    monkeypatch.setenv('GRADLE_USER_HOME', str(home))
    monkeypatch.setenv('PREFIX', '/data/data/com.termux/files/usr')
    monkeypatch.setenv('PATH', str(native.parent) + os.pathsep + os.environ['PATH'])
    monkeypatch.setattr(helper, 'ROOT', project)
    monkeypatch.setattr('sys.argv', ['local_build_environment.py', str(flutter), str(android)])
    with monkeypatch.context() as local:
        local.setattr(helper.os, 'uname', lambda: SimpleNamespace(machine='aarch64'))
        helper.main()
    exported = capsys.readouterr().out.strip()
    opts = shlex.split(exported.split('=',1)[1])[0]
    assert properties.read_text() == original
    assert (project / 'android/local.properties').exists()
    gradle = os.environ.get('LOCAL_SIGNING_GRADLE')
    if not gradle:
        pytest.skip('Set LOCAL_SIGNING_GRADLE to prove process-scoped Gradle options')
    (project / 'settings.gradle').write_text("rootProject.name='phone-resource-fixture'\n")
    (project / 'build.gradle').write_text("""
tasks.register('verifyPhonePolicy') {
  doLast {
    assert gradle.startParameter.maxWorkerCount == 1
    assert !gradle.startParameter.parallelProjectExecutionEnabled
    assert gradle.startParameter.buildCacheEnabled
    assert project.findProperty('kotlin.compiler.execution.strategy') == 'in-process'
    assert project.findProperty('android.aapt2FromMavenOverride') == System.getenv('EXPECTED_AAPT2')
    assert Runtime.getRuntime().maxMemory() <= 1100L * 1024 * 1024
    println 'PHONE POLICY PASS'
  }
}
""")
    env = {**os.environ, 'GRADLE_OPTS': opts, 'EXPECTED_AAPT2': str(native)}
    proc = subprocess.run([gradle, '--offline', '-p', str(project), 'verifyPhonePolicy'],
                          env=env, capture_output=True, text=True, timeout=120)
    assert proc.returncode == 0, proc.stdout + proc.stderr
    assert 'PHONE POLICY PASS' in proc.stdout
    assert properties.read_text() == original


@pytest.mark.parametrize('boundary', ['worker-private', 'worker-main', 'quality-cache'])
def test_security_audit_checks_active_workflow_boundaries(tmp_path, boundary):
    import shutil
    fixture = tmp_path / 'audit-project'
    fixture.mkdir()
    shutil.copytree(ROOT / '.github', fixture / '.github')

    assert_active_build_delivery_boundaries(fixture)

    name = 'quality_gate_ci.yml' if boundary == 'quality-cache' else 'worker_release_apk.yml'
    workflow = fixture / '.github/workflows' / name
    text = workflow.read_text()
    if boundary == 'worker-private':
        text = text.replace('github.event.repository.private == true', 'true')
    elif boundary == 'worker-main':
        text = text.replace("github.ref_name == 'main'", 'true')
    else:
        text = text.replace('cache: false', 'cache: true')
    workflow.write_text(text)

    with pytest.raises(AssertionError):
        assert_active_build_delivery_boundaries(fixture)


@pytest.mark.parametrize('mode', ['desktop', 'termux-placeholder', 'termux-native-source'])
def test_real_gradle_termux_packaging_keeps_native_payload_and_rejects_source_builds(tmp_path, mode):
    import shutil
    gradle = os.environ.get('LOCAL_SIGNING_GRADLE')
    if not gradle:
        pytest.skip('Set LOCAL_SIGNING_GRADLE to verify native packaging policy')
    fixture = tmp_path / 'gradle'
    fixture.mkdir()
    shutil.copy(ROOT / 'android/termux-packaging.gradle', fixture)
    placeholder = fixture / 'flutter/packages/flutter_tools/gradle/src/main/scripts/CMakeLists.txt'
    placeholder.parent.mkdir(parents=True)
    placeholder.write_text('# Flutter force-download placeholder\n')
    native = fixture / 'native/CMakeLists.txt'
    native.parent.mkdir()
    native.write_text('project(actual_native_source)\n')
    (fixture / 'settings.gradle').write_text("rootProject.name='native-packaging-policy'\n")
    (fixture / 'build.gradle').write_text("""
apply from: 'termux-packaging.gradle'
def cmake = new Expando(path: file(System.getenv('TEST_CMAKE')))
def jniLibs = new Expando(keepDebugSymbols: new HashSet())
def androidFixture = new Expando(externalNativeBuild: new Expando(cmake: cmake),
                                packaging: new Expando(jniLibs: jniLibs))
def changed = configureTermuxPackaging(androidFixture)
tasks.register('verifyPackagingPolicy') {
  doLast {
    if (System.getenv('TEST_MODE') == 'desktop') {
      assert !changed && cmake.path != null && jniLibs.keepDebugSymbols.empty
    } else {
      assert changed && cmake.path == null && jniLibs.keepDebugSymbols.contains('**/*.so')
    }
    println 'PACKAGING POLICY PASS'
  }
}
""")
    env = {**os.environ, 'GRADLE_USER_HOME': str(tmp_path/'cache'), 'TEST_MODE': mode,
           'TEST_CMAKE': str(native if mode == 'termux-native-source' else placeholder)}
    env.pop('PREFIX', None)
    if mode.startswith('termux'): env['PREFIX']='/data/data/com.termux/files/usr'
    proc = subprocess.run([gradle,'--no-daemon','--offline','-p',str(fixture),'verifyPackagingPolicy'],
                          env=env,capture_output=True,text=True,timeout=120)
    if mode == 'termux-native-source':
        assert proc.returncode != 0
        assert 'actual native CMake build' in proc.stderr
    else:
        assert proc.returncode == 0, proc.stdout+proc.stderr
        assert 'PACKAGING POLICY PASS' in proc.stdout


@pytest.mark.parametrize('digest', ['valid', 'wrong', 'missing'])
def test_native_flutter_local_package_requires_trusted_checksum(tmp_path, digest):
    import hashlib
    package = tmp_path/'disposable-native-host-package.deb'
    package.write_bytes(b'Disposable fixture; never installed by real dpkg')
    prefix = tmp_path/'prefix'
    sdk = prefix/'opt/flutter/bin'
    executable(sdk/'flutter', "#!/bin/sh\nprintf 'Flutter 3.44.9\\n'\n")
    executable(sdk/'dart', "#!/bin/sh\nprintf 'Dart SDK version: 3.12.2\\n'\n")
    hook = prefix/'share/flutter/post_install.sh'
    executable(hook, '#!/bin/sh\nexit 0\n')
    tools = tmp_path/'bin'
    install_marker = tmp_path/'installation-requested'
    download_marker = tmp_path/'unexpected-download'
    executable(tools/'dpkg', f"#!/bin/sh\ntouch '{install_marker}'\n")
    executable(tools/'curl', f"#!/bin/sh\ntouch '{download_marker}'\nexit 1\n")
    home = tmp_path/'home';home.mkdir()
    expected = hashlib.sha256(package.read_bytes()).hexdigest() if digest == 'valid' else ('0'*64 if digest == 'wrong' else '')
    env = {**os.environ,'HOME':str(home),'PREFIX':str(prefix),
           'FLUTTER_ROOT':str(tmp_path/'missing-sdk'),'TERMUX_FLUTTER_DEB_PATH':str(package),
           'TERMUX_FLUTTER_DEB_SHA256':expected,'PATH':str(tools)+os.pathsep+os.environ['PATH']}
    proc = subprocess.run(['bash','-c', 'source "$1"; ARCH=aarch64; setup_flutter',
                           'fixture',str(ROOT/'install_flutter.sh')],env=env,
                          capture_output=True,text=True,timeout=30)
    assert not download_marker.exists()
    assert install_marker.exists() == (digest == 'valid')
    assert (proc.returncode == 0) == (digest == 'valid'), proc.stdout+proc.stderr
