import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone_flutter/resources/auth_methods.dart';
import 'package:instagram_clone_flutter/responsive/mobile_screen_layout.dart';
import 'package:instagram_clone_flutter/responsive/responsive_layout.dart';
import 'package:instagram_clone_flutter/responsive/web_screen_layout.dart';
import 'package:instagram_clone_flutter/screens/login_screen.dart';
import 'package:instagram_clone_flutter/utils/colors.dart';
import 'package:instagram_clone_flutter/utils/utils.dart';
import 'package:instagram_clone_flutter/widgets/text_field_input.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  bool _isLoading = false;
  Uint8List? _image;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
  }

  void signUpUser() async {
    if (formKey.currentState!.validate()) {
      // set loading to true

      if (_image != null) {
        setState(() {
          _isLoading = true;
        });
        String res = await AuthMethods().signUpUser(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            username: _usernameController.text.trim(),
            bio: _bioController.text.trim(),
            file: _image!);
        // if string returned is sucess, user has been created
        if (res == "success") {
          setState(() {
            _isLoading = false;
          });
          // navigate to the home screen
          if (!mounted) return;
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const ResponsiveLayout(
                  mobileScreenLayout: MobileScreenLayout(),
                  webScreenLayout: WebScreenLayout(),
                ),
              ),
              (route) => false);
        } else {
          setState(() {
            _isLoading = false;
          });
          // show the error
          if (!mounted) return;
          showSnackBar(context, res);
        }
      } else {
        showSnackBar(context, 'Please Upload Profile Picture');
      }
    }

    // signup user using our authmethodds
  }

  selectImage() async {
    Uint8List im = await pickImage(ImageSource.gallery);
    // set state because we need to display the image we selected on the circle avatar
    setState(() {
      _image = im;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Picsgram',
                          style: GoogleFonts.lobster(
                            fontSize: 70,
                          )),
                      const SizedBox(
                        height: 30,
                      ),
                      Stack(
                        children: [
                          _image != null
                              ? CircleAvatar(
                                  radius: 64,
                                  backgroundImage: MemoryImage(_image!),
                                  backgroundColor: Colors.red,
                                )
                              : const CircleAvatar(
                                  radius: 64,
                                  backgroundImage: NetworkImage(
                                      'https://i.stack.imgur.com/l60Hf.png'),
                                  backgroundColor: Colors.red,
                                ),
                          Positioned(
                            bottom: -10,
                            left: 80,
                            child: IconButton(
                              onPressed: selectImage,
                              icon: const Icon(Icons.add_a_photo),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      TextFieldInput(
                        hintText: 'Enter your username',
                        textInputType: TextInputType.text,
                        textEditingController: _usernameController,
                        validator: (value) {
                          value = value.toString().trim().toLowerCase();
                          if (value.length < 3) {
                            return 'Username should be greater than 3 characters';
                          } else {
                            return null;
                          }
                        },
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      TextFieldInput(
                        hintText: 'Enter your email',
                        textInputType: TextInputType.emailAddress,
                        textEditingController: _emailController,
                        validator: (email) {
                          if (!RegExp(
                                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                              .hasMatch(email!)) {
                            return "Invalid Email";
                          } else {
                            return null;
                          }
                        },
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      TextFieldInput(
                        hintText: 'Enter your password',
                        textInputType: TextInputType.text,
                        textEditingController: _passwordController,
                        isPass: true,
                        validator: (input) {
                          if (input!.length < 6) {
                            return 'Passwords should be more than 5 characters';
                          } else {
                            return null;
                          }
                        },
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      TextFieldInput(
                        hintText: 'Enter your bio',
                        textInputType: TextInputType.text,
                        textEditingController: _bioController,
                        validator: (input) {
                          if (input!.isEmpty) {
                            return 'Please Enter Bio';
                          } else {
                            return null;
                          }
                        },
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      ElevatedButton(
                        onPressed: signUpUser,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 50),
                          primary: blueColor,
                        ),
                        child: !_isLoading
                            ? const Text(
                                'Sign up',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              )
                            : const CircularProgressIndicator(
                                color: primaryColor,
                              ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: const Text(
                              'Already have an account?',
                            ),
                          ),
                          TextButton(
                            
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
