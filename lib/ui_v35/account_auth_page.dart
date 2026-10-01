import 'package:flutter/material.dart';

import '../models/account_session.dart';
import '../services/authentication.dart';
import '../services/auth_session_controller.dart';

/// Account/authentication UI boundary.
///
/// This page intentionally depends only on transient authentication state.
/// Learner data, subscriptions, credentials, and network transports remain
/// outside the presentation layer.
class AccountPage extends StatefulWidget {
  const AccountPage({super.key, required this.auth});

  final AuthSessionController auth;

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  bool _busy = false;
  bool _otpRequested = false;

  @override
  void initState() {
    super.initState();
    widget.auth.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    widget.auth.removeListener(_onAuthChanged);
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _onAuthChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _requestOtp() async {
    final email = _emailController.text.trim();
    if (!_validEmail(email)) {
      _showMessage('أدخل بريدًا إلكترونيًا صالحًا.');
      return;
    }
    await _runBusy(() => widget.auth.requestEmailOtp(email: email));
    if (mounted && widget.auth.lastFailure == null) {
      setState(() => _otpRequested = true);
      _showMessage('تم طلب رمز التحقق.');
    }
  }

  Future<void> _verifyOtp() async {
    final email = _emailController.text.trim();
    final otp = _otpController.text.trim();
    if (!_validEmail(email)) {
      _showMessage('أدخل بريدًا إلكترونيًا صالحًا.');
      return;
    }
    if (otp.isEmpty) {
      _showMessage('أدخل رمز التحقق.');
      return;
    }
    await _runBusy(
      () => widget.auth.signInWithEmailOtp(email: email, otp: otp),
    );
    if (mounted && widget.auth.session.isAuthenticated) {
      _otpController.clear();
      setState(() => _otpRequested = false);
    }
  }

  Future<void> _runBusy(Future<void> Function() operation) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await operation();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _renewSession() async {
    await _runBusy(widget.auth.renewSession);
  }

  Future<void> _signOut() async {
    await _runBusy(widget.auth.signOut);
  }

  bool _validEmail(String value) {
    return value.contains('@') &&
        value.indexOf('@') > 0 &&
        value.indexOf('@') < value.length - 1;
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.auth.session;
    return Scaffold(
      appBar: AppBar(title: const Text('الحساب')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          if (!widget.auth.isInitialized)
            const Card(
              child: ListTile(
                leading: CircularProgressIndicator(),
                title: Text('جارٍ التحقق من حالة الحساب...'),
              ),
            )
          else if (session.isAuthenticated)
            _authenticatedView(context, session)
          else
            _signInView(context),
          if (widget.auth.lastFailure != null) ...[
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('تعذر إتمام العملية'),
                subtitle: Text(_failureMessage(widget.auth.lastFailure!.code)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _authenticatedView(BuildContext context, AccountSession session) {
    final identity = session.identity!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.verified_user_outlined, size: 42),
            const SizedBox(height: 12),
            Text(
              'تم تسجيل الدخول',
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text('معرّف الحساب: ${identity.userId}'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _busy ? null : _renewSession,
                icon: const Icon(Icons.refresh),
                label: const Text('تجديد الجلسة'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _busy ? null : _signOut,
                icon: const Icon(Icons.logout),
                label: const Text('تسجيل الخروج'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _signInView(BuildContext context) {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تسجيل الدخول',
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                const Text(
                  'يمكنك متابعة التعلم بدون حساب. الحساب مخصص للميزات التي تحتاج هوية حساب لاحقًا.',
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textDirection: TextDirection.ltr,
                  autofillHints: const [AutofillHints.email],
                  decoration: const InputDecoration(
                    labelText: 'البريد الإلكتروني',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _busy ? null : _requestOtp,
                    icon: const Icon(Icons.mark_email_read_outlined),
                    label: const Text('إرسال رمز التحقق'),
                  ),
                ),
                if (_otpRequested) ...[
                  const SizedBox(height: 14),
                  TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    textDirection: TextDirection.ltr,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'رمز التحقق',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _busy ? null : _verifyOtp,
                      child: const Text('تأكيد وتسجيل الدخول'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _busy
                ? null
                : () => _runBusy(widget.auth.signInWithGoogle),
            icon: const Icon(Icons.g_mobiledata),
            label: const Text('المتابعة باستخدام Google'),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _busy
                ? null
                : () => _runBusy(widget.auth.signInWithApple),
            icon: const Icon(Icons.apple),
            label: const Text('المتابعة باستخدام Apple'),
          ),
        ),
      ],
    );
  }

  String _failureMessage(AuthenticationFailureCode code) {
    switch (code) {
      case AuthenticationFailureCode.cancelled:
        return 'تم إلغاء العملية.';
      case AuthenticationFailureCode.invalidCredential:
        return 'بيانات التحقق غير صالحة.';
      case AuthenticationFailureCode.expiredCredential:
        return 'انتهت صلاحية بيانات التحقق. أعد المحاولة.';
      case AuthenticationFailureCode.invalidSession:
        return 'انتهت صلاحية الجلسة. سجّل الدخول مرة أخرى.';
      case AuthenticationFailureCode.rateLimited:
        return 'تم تجاوز عدد المحاولات المسموح به. حاول لاحقًا.';
      case AuthenticationFailureCode.providerRejected:
        return 'رفض مزود تسجيل الدخول العملية.';
      case AuthenticationFailureCode.retryable:
        return 'تعذر إتمام العملية مؤقتًا. حاول مرة أخرى.';
      case AuthenticationFailureCode.unavailable:
        return 'خدمة تسجيل الدخول غير متاحة في هذه النسخة.';
    }
  }
}
