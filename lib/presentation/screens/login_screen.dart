import 'package:echo_stock/presentation/core/ui_feedback.dart';
import 'package:echo_stock/presentation/cubit/auth/auth_cubit.dart';
import 'package:echo_stock/presentation/cubit/auth/auth_state.dart';
import 'package:echo_stock/presentation/widgets/custom_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isRegisterMode = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<AuthCubit>().clearFailure();

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final cubit = context.read<AuthCubit>();

    if (_isRegisterMode) {
      cubit.register(email: email, password: password);
    } else {
      cubit.login(email: email, password: password);
    }
  }

  void _switchToRegisterMode() {
    setState(() => _isRegisterMode = true);
    context.read<AuthCubit>().clearFailure();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listenWhen: (previous, current) =>
          current is AuthFailure && previous != current,
      listener: (context, state) {
        if (state is AuthFailure) {
          showAppSnackBar(
            context,
            message: state.message,
            backgroundColor: Colors.redAccent,
            action: state.suggestRegistration
                ? SnackBarAction(
                    label: 'Registrarme',
                    textColor: Colors.white,
                    onPressed: _switchToRegisterMode,
                  )
                : null,
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        final authFailure = state is AuthFailure ? state : null;

        return Scaffold(
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _isRegisterMode ? 'Crear cuenta' : 'Iniciar sesión',
                          style: Theme.of(context).textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        if (authFailure != null)
                          buildInlineErrorBanner(
                            message: authFailure.message,
                            onSecondaryAction: authFailure.suggestRegistration
                                ? _switchToRegisterMode
                                : null,
                            secondaryLabel: 'Crear cuenta nueva',
                          ),
                        CustomTextFormField(
                          controller: _emailController,
                          label: 'Correo',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Ingresa tu correo';
                            }
                            if (!value.contains('@')) {
                              return 'Correo inválido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        CustomTextFormField(
                          controller: _passwordController,
                          label: 'Contraseña',
                          prefixIcon: Icons.lock_outlined,
                          obscureText: _obscurePassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingresa tu contraseña';
                            }
                            if (_isRegisterMode && value.length < 6) {
                              return 'Mínimo 6 caracteres';
                            }
                            return null;
                          },
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            child: Text(
                              _obscurePassword ? 'Mostrar' : 'Ocultar',
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        FilledButton(
                          onPressed: isLoading ? null : _submit,
                          child: isLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  _isRegisterMode ? 'Registrarse' : 'Entrar',
                                ),
                        ),
                        TextButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  setState(() {
                                    _isRegisterMode = !_isRegisterMode;
                                  });
                                  context.read<AuthCubit>().clearFailure();
                                },
                          child: Text(
                            _isRegisterMode
                                ? '¿Ya tienes cuenta? Inicia sesión'
                                : '¿No tienes cuenta? Regístrate',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
