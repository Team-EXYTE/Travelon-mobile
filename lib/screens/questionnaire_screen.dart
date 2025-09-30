import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  final List<String> questions = [
    "How enthusiastic are you about attending live music festivals or concerts?",
    "To what extent do you enjoy watching or participating in sporting events?",
    "How much do you enjoy exploring new restaurants and culinary experiences?",
    "How interested are you in visiting museums, art galleries, or historical sites?",
    "How much do you enjoy outdoor activities like hiking, camping, or visiting parks?",
    "How enthusiastic are you about experiencing a city's nightlife and social scene?",
    "To what extent are you interested in the latest technological innovations and gadgets?",
    "How important is it for your travel to include opportunities for professional networking?",
    "How much do you prioritize activities that promote wellness and relaxation (e.g., yoga)?",
    "How interested are you in attending workshops, lectures, or educational tours?",
  ];

  int currentQuestion = 0;
  final List<int> answers = List.filled(10, 0);
  String? predictionResult;

  Future<String?> sendAnswersAndGetPrediction(List<int> answers) async {
    final url = Uri.parse(
      'https://induwarar-interest-predictions.hf.space/predict',
    );
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'answers': answers}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return data['prediction'] as String?;
      }
    }
    return null;
  }

  void _next(int value) async {
    setState(() {
      answers[currentQuestion] = value;
    });
    if (currentQuestion < questions.length - 1) {
      setState(() {
        currentQuestion++;
      });
    } else {
      // Submit answers to API and get prediction
      final prediction = await sendAnswersAndGetPrediction(answers);
      setState(() {
        predictionResult = prediction;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double progress = (currentQuestion + 1) / questions.length;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Personalize Your Experience'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          image: DecorationImage(
            image: AssetImage('assets/quiz.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.65),
              BlendMode.lighten,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Fun icon/illustration above the card
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Icon(
                    Icons.emoji_objects_rounded,
                    color: Colors.grey[700],
                    size: 48,
                  ),
                ),
                // Progress bar
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[300],
                  color: Colors.black,
                  minHeight: 8,
                ),
                const SizedBox(height: 12),
                // Motivational subtitle
                Center(
                  child: Text(
                    progress < 1.0
                        ? 'You are ${((progress) * 100).round()}% done!'
                        : 'All done! Submitting...',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Rating scale explanation
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        '1 = Not at all',
                        style: TextStyle(fontSize: 15, color: Colors.black54,fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '3 = Neutral',
                        style: TextStyle(fontSize: 15, color: Colors.black54,fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '5 = Very much',
                        style: TextStyle(fontSize: 15, color: Colors.black54,fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                // Animated question card
                if (predictionResult == null) ...[
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder:
                        (child, anim) =>
                            FadeTransition(opacity: anim, child: child),
                    child: Card(
                      key: ValueKey(currentQuestion),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                        side: BorderSide(color: Colors.grey[300]!, width: 1.5),
                      ),
                      elevation: 18,
                      color: Colors.grey[100],
                      shadowColor: Colors.black12,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 36,
                          horizontal: 20,
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Question ${currentQuestion + 1} of ${questions.length}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              questions[currentQuestion],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Animated rating buttons (black, white, gray)
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder:
                        (child, anim) =>
                            ScaleTransition(scale: anim, child: child),
                    child: Row(
                      key: ValueKey(currentQuestion),
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (i) {
                        int rate = i + 1;
                        bool selected = answers[currentQuestion] == rate;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: GestureDetector(
                            onTap: () => _next(rate),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: selected ? 48 : 38,
                              height: selected ? 48 : 38,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: selected ? Colors.black : Colors.white,
                                boxShadow:
                                    selected
                                        ? [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                        : [],
                                border: Border.all(
                                  color:
                                      selected
                                          ? Colors.black
                                          : Colors.grey[400]!,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '$rate',
                                  style: TextStyle(
                                    fontSize: selected ? 22 : 16,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        selected ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 48),
                ] else ...[
                  // Show prediction result in a card
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                      side: BorderSide(color: Colors.grey[300]!, width: 1.5),
                    ),
                    elevation: 18,
                    color: Colors.grey[100],
                    shadowColor: Colors.black12,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 48,
                        horizontal: 24,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.celebration,
                            color: Colors.black87,
                            size: 48,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'We think that "$predictionResult" events are suitable for you!',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Explore and enjoy your personalized recommendations.',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
