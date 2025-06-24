import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              _buildForm(),
              _buildButton(),
              _buildLinks(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Container();
  }

  Widget _buildFormField({
    required String label,
    required String title,
  }) {
    return TextField(
      
    );
  }

  Widget _buildHeader() {
    return Container(
      child: Column(
        children: [
          Image(image: AssetImage("assets/images/register-image.jpg")),
        ],
      ),
    );
  }

  Widget _buildButton() {
    return Container();
  }

  Widget _buildLinks() {
    return Container();
  }
}
