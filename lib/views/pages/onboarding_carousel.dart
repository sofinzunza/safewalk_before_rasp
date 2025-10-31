import 'package:flutter/material.dart';
import 'package:safewalk/data/constants.dart';
import 'package:safewalk/views/pages/signin_page.dart';
import 'package:safewalk/views/widgets/nextbutton_widget.dart';
import 'package:safewalk/views/widgets/onboarding_page_content.dart';

class OnboardingCarousel extends StatefulWidget {
  const OnboardingCarousel({super.key});

  @override
  State<OnboardingCarousel> createState() => _OnboardingCarouselState();
}

class _OnboardingCarouselState extends State<OnboardingCarousel> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  final List<Map<String, String>> _slides = [
    {
      'title': 'Camina con confianza,\npaso a paso',
      'description':
          'SafeWalk se conecta con tu gorro inteligente Navicap para detectar obstáculos y avisarte de forma clara y accesible.',
      'bg': 'assets/images/S20.png',
      'img': 'assets/images/19.png',
    },
    {
      'title': 'Diseñado\npensando en ti',
      'description':
          'SafeWalk está optimizado para VoiceOver y TalkBack, ofreciendo alertas por voz, vibración y notificaciones simples.',
      'bg': 'assets/images/S21.png',
      'img': 'assets/images/4.png',
    },
    {
      'title': 'Nunca caminas solo',
      'description':
          'Configura tus contactos de\n'
          'emergencia en SafeWalk. Si tienes\n'
          'una emergencia, la app enviará\n'
          'una alerta para avisarles.',
      'bg': 'assets/images/S22.png',
      'img': 'assets/images/2.png',
    },
  ];

  void _next() {
    if (_currentIndex < _slides.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  void _finish() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) {
          return SigninPage();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _slides.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final slide = _slides[index];
                    return OnboardingPageContent(
                      title: slide['title']!,
                      description: slide['description']!,
                      bgImage: slide['bg']!,
                      fgImage: slide['img']!,
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slides.length,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: CircleAvatar(
                      radius: 5,
                      backgroundColor: index == _currentIndex
                          ? Colors.black
                          : Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 35),
              Row(
                mainAxisAlignment: _currentIndex < _slides.length - 1
                    ? MainAxisAlignment.spaceBetween
                    : MainAxisAlignment.center,
                children: [
                  if (_currentIndex < _slides.length - 1)
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return SigninPage();
                            },
                          ),
                        );
                      },
                      child: const Text(
                        'Omitir',
                        style: TextStyle(
                          color: KColors.tealChillon,
                          decoration: TextDecoration.underline,
                          fontSize: 15,
                          decorationColor: KColors.tealChillon,
                        ),
                      ),
                    )
                  else
                    const SizedBox.shrink(), // Para balancear visualmente

                  _currentIndex < _slides.length - 1
                      ? NextButton(text: 'Siguiente', onPressed: _next)
                      : Expanded(
                          child: Center(
                            child: SizedBox(
                              width: 250,
                              child: FilledButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return SigninPage();
                                      },
                                    ),
                                  );
                                },
                                style: FilledButton.styleFrom(
                                  backgroundColor: KColors.tealChillon,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(32),
                                  ),
                                ),
                                child: const Text(
                                  'Empezar ya',
                                  style: TextStyle(fontSize: 15),
                                ),
                              ),
                            ),
                          ),
                        ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
