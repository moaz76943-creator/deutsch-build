import 'package:flutter/material.dart';

import '../design_system/design_system.dart';
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: AppDirectionalText(
          message,
          languageCode: 'ar',
          style: AppTypography.body,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.auth.session;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: AppDirectionalText(
            'الملف الشخصي والحساب',
            languageCode: 'ar',
            style: AppTypography.title,
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(18),
          children: <Widget>[
            _profileSummary(session),
            const SizedBox(height: 12),
            if (!widget.auth.isInitialized)
              AppGlassCard(
                glowColor: AppColors.primary,
                child: Row(
                  children: <Widget>[
                    const CircularProgressIndicator(),
                    const SizedBox(width: 14),
                    Expanded(
                      child: AppDirectionalText(
                        'جارٍ التحقق من حالة الحساب...',
                        languageCode: 'ar',
                        style: AppTypography.body,
                      ),
                    ),
                  ],
                ),
              )
            else if (session.isAuthenticated)
              _authenticatedView(context, session)
            else
              _signInView(context),
            if (widget.auth.lastFailure != null) ...<Widget>[
              const SizedBox(height: 12),
              AppGlassCard(
                glowColor: Theme.of(context).colorScheme.error,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          AppDirectionalText(
                            'تعذر إتمام العملية',
                            languageCode: 'ar',
                            style: AppTypography.title,
                          ),
                          const SizedBox(height: 4),
                          AppDirectionalText(
                            _failureMessage(
                              widget.auth.lastFailure!.code,
                            ),
                            languageCode: 'ar',
                            style: AppTypography.body,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _profileSummary(AccountSession session) {
    final authenticated = session.isAuthenticated;
    return AppGlassCard(
      glowColor: authenticated ? AppColors.mastery : AppColors.primary,
      child: Row(
        children: <Widget>[
          Icon(
            authenticated
                ? Icons.verified_user_outlined
                : Icons.person_outline_rounded,
            size: 42,
            color: authenticated ? AppColors.mastery : AppColors.primary,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                AppDirectionalText(
                  authenticated ? 'ملفك الشخصي' : 'التعلم بدون حساب',
                  languageCode: 'ar',
                  style: AppTypography.title,
                ),
                const SizedBox(height: 4),
                AppDirectionalText(
                  authenticated
                      ? 'حالة الحساب متصلة بالهوية فقط؛ '
                          'بيانات التعلم المحلية مستقلة.'
                      : 'يمكنك متابعة التعلم محليًا. '
                          'الحساب اختياري للميزات التي تحتاج هوية.',
                  languageCode: 'ar',
                  style: AppTypography.body,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _authenticatedView(
    BuildContext context,
    AccountSession session,
  ) {
    final identity = session.identity!;
    return AppGlassCard(
      glowColor: AppColors.mastery,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AppDirectionalText(
            'تم تسجيل الدخول',
            languageCode: 'ar',
            style: AppTypography.title,
          ),
          const SizedBox(height: 8),
          AppDirectionalText(
            'معرّف الحساب',
            languageCode: 'ar',
            style: AppTypography.label,
          ),
          const SizedBox(height: 3),
          AppDirectionalText(
            identity.userId,
            languageCode: 'en',
            style: AppTypography.body.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _busy ? null : _renewSession,
            icon: const Icon(Icons.refresh),
            label: AppDirectionalText(
              'تجديد الجلسة',
              languageCode: 'ar',
              style: AppTypography.label,
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _busy ? null : _signOut,
            icon: const Icon(Icons.logout),
            label: AppDirectionalText(
              'تسجيل الخروج',
              languageCode: 'ar',
              style: AppTypography.label,
            ),
          ),
        ],
      ),
    );
  }

  Widget _signInView(BuildContext context) {
    return Column(
      children: <Widget>[
        AppGlassCard(
          glowColor: AppColors.primary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              AppDirectionalText(
                'تسجيل الدخول',
                languageCode: 'ar',
                style: AppTypography.title,
              ),
              const SizedBox(height: 8),
              AppDirectionalText(
                'يمكنك متابعة التعلم بدون حساب. الحساب مخصص للميزات '
                'التي تحتاج هوية حساب لاحقًا.',
                languageCode: 'ar',
                style: AppTypography.body,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textDirection: TextDirection.ltr,
                style: AppTypography.body,
                autofillHints: const <String>[AutofillHints.email],
                decoration: InputDecoration(
                  label: AppDirectionalText(
                    'البريد الإلكتروني',
                    languageCode: 'ar',
                    style: AppTypography.label,
                  ),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: _busy ? null : _requestOtp,
                icon: const Icon(Icons.mark_email_read_outlined),
                label: AppDirectionalText(
                  'إرسال رمز التحقق',
                  languageCode: 'ar',
                  style: AppTypography.label,
                ),
              ),
              if (_otpRequested) ...<Widget>[
                const SizedBox(height: 14),
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  textDirection: TextDirection.ltr,
                  style: AppTypography.body,
                  obscureText: true,
                  decoration: InputDecoration(
                    label: AppDirectionalText(
                      'رمز التحقق',
                      languageCode: 'ar',
                      style: AppTypography.label,
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                FilledButton(
                  onPressed: _busy ? null : _verifyOtp,
                  child: AppDirectionalText(
                    'تأكيد وتسجيل الدخول',
                    languageCode: 'ar',
                    style: AppTypography.label,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        AppGlassCard(
          opacity: .12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              AppDirectionalText(
                'خيارات الهوية',
                languageCode: 'ar',
                style: AppTypography.title,
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed:
                    _busy ? null : () => _runBusy(widget.auth.signInWithGoogle),
                icon: const Icon(Icons.g_mobiledata),
                label: AppDirectionalText(
                  'المتابعة باستخدام Google',
                  languageCode: 'ar',
                  style: AppTypography.label,
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed:
                    _busy ? null : () => _runBusy(widget.auth.signInWithApple),
                icon: const Icon(Icons.apple),
                label: AppDirectionalText(
                  'المتابعة باستخدام Apple',
                  languageCode: 'ar',
                  style: AppTypography.label,
                ),
              ),
            ],
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
