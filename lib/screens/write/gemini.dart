import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class Gemini {
  Future<String> getGeminiResponse(String query) async {
    String apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

    final model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: apiKey,
    );
    try {
      final response = await model.generateContent([Content.text(query)]);
      return response.text ?? 'No response from Gemini.';
    } on GenerativeAIException catch (e) {
      if (e.message.contains('Candidate was blocked due to safety')) {
        return 'The response was blocked due to safety reasons. Please try rephrasing your prompt.';
      } else {
        return 'An error occurred while generating the response.';
      }
    } catch (e) {
      return 'An unexpected error occurred.';
    }
  }
}
