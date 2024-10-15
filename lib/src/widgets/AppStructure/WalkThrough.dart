import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_onboarding_slider/flutter_onboarding_slider.dart';
import 'package:lotengo/src/pages/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Para gestionar las preferencias

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      debugShowCheckedModeBanner: false,
      home: OnboardingScreen(),
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final Color kDarkBlueColor = const Color(0xFF053149);
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _loadOnboardingStatus();
  }

  Future<void> _loadOnboardingStatus() async {
    _prefs = await SharedPreferences.getInstance();
    bool? onboardingCompleted =
        _prefs?.getBool('onboarding_completed') ?? false;

    if (onboardingCompleted) {
      _navigateToHome();
    }
  }

  Future<void> _completeOnboarding() async {
    await _prefs?.setBool('onboarding_completed', true);
    _navigateToHome();
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      CupertinoPageRoute(
        builder: (context) => HomeScreen(), // Cambia la pantalla según necesidad
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return OnBoardingSlider(
      finishButtonText: 'Comenzar',
      onFinish: () {
        _completeOnboarding();
      },
      finishButtonStyle: FinishButtonStyle(
        backgroundColor: kDarkBlueColor,
      ),
      skipTextButton: Text(
        'Saltar',
        style: TextStyle(
          fontSize: 16,
          color: kDarkBlueColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: Text(
        '',
        style: TextStyle(
          fontSize: 16,
          color: kDarkBlueColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailingFunction: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => HomeScreen(),
          ),
        );
      },
      controllerColor: kDarkBlueColor,
      totalPage: 3,
      headerBackgroundColor: Colors.white,
      pageBackgroundColor: Colors.white,
      background: [
        Image.asset(
          'assets/data/images/logo.png',
          height: 400,
        ),
        Image.asset(
          'assets/data/images/logo.png',
          height: 400,
        ),
        Image.asset(
          'assets/data/images/logo.png',
          height: 400,
        ),
      ],
      speed: 1.8,
      pageBodies: [
        _buildPageContent(
          context,
          title: 'Registro y actualizaciones',
          description: 'Registra los resultados rápidamente, acorde al resultado oficial.',
        ),
        _buildPageContent(
          context,
          title: 'Búsqueda de Información',
          description: 'Obtén resultados instantáneos según los criterios de búsqueda.',
        ),
        _buildPageContent(
          context,
          title: 'Estadísticas',
          description: 'Analiza resultados estadísticos de forma organizada.',
        ),
      ],
    );
  }

  Widget _buildPageContent(BuildContext context, {required String title, required String description}) {
    return SingleChildScrollView( // Solución de desbordamiento
      child: Container(
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(
              height: 420, // Ajusta la altura aquí para pegar más el texto a la imagen
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: kDarkBlueColor,
                fontSize: 24.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(
              height: 10, // Reducir este valor para acercar el texto más al título
            ),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black26,
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
