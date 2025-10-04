import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Paleta baseada no Figma
const Color kDarkBlue = Color(0xFF0B0B5B);
const Color kStrongBlue = Color(0xFF3000FF);
const Color kGrayButton = Color(0xFFD9D9D9);
const Color kDarkGrayText = Color(0xFF333333);

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _emailField = TextEditingController();
  final _senhaField = TextEditingController();
  final _confSenhaField = TextEditingController();
  final _authController = FirebaseAuth.instance;

  bool _senhaOculta = true;
  bool _confSenhaOculta = true;

  void _registrar() async {
    final email = _emailField.text.trim();
    final senha = _senhaField.text;
    final confSenha = _confSenhaField.text;

    if (email.isEmpty || senha.isEmpty || confSenha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Preencha todos os campos")),
      );
      return;
    }

    if (senha != confSenha) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("As senhas não coincidem")),
      );
      return;
    }

    try {
      await _authController.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String mensagemErro;
      switch (e.code) {
        case 'email-already-in-use':
          mensagemErro = 'Este email já está em uso.';
          break;
        case 'invalid-email':
          mensagemErro = 'Email inválido.';
          break;
        case 'weak-password':
          mensagemErro = 'A senha é muito fraca.';
          break;
        default:
          mensagemErro = 'Erro: ${e.message}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensagemErro)),
      );
    }
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    bool isPassword = false,
    bool isObscured = false,
    VoidCallback? toggleVisibility,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: kGrayButton,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        obscureText: isObscured,
        style: const TextStyle(color: kDarkGrayText),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: kDarkGrayText),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isObscured ? Icons.visibility : Icons.visibility_off,
                    color: kDarkGrayText,
                  ),
                  onPressed: toggleVisibility,
                )
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDarkBlue,
      appBar: AppBar(
        backgroundColor: kStrongBlue,
        elevation: 0,
        toolbarHeight: 20,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: kStrongBlue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                "Fazer Cadastro",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 30),
            _buildInputField(controller: _emailField, hint: "Email"),
            _buildInputField(
              controller: _senhaField,
              hint: "Senha",
              isPassword: true,
              isObscured: _senhaOculta,
              toggleVisibility: () {
                setState(() {
                  _senhaOculta = !_senhaOculta;
                });
              },
            ),
            _buildInputField(
              controller: _confSenhaField,
              hint: "Confirmar Senha",
              isPassword: true,
              isObscured: _confSenhaOculta,
              toggleVisibility: () {
                setState(() {
                  _confSenhaOculta = !_confSenhaOculta;
                });
              },
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _registrar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kGrayButton,
                  foregroundColor: kDarkGrayText,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text("Cadastrar"),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: kStrongBlue,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Icon(Icons.arrow_back, color: Colors.white),
              Icon(Icons.home, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
