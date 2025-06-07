import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  // Ganti dengan Hugging Face API token Anda
  final String _apiToken = dotenv.env['HUGGINGFACE_TOKEN'] ?? '';
  final String _apiUrl = dotenv.env['API_URL'] ?? '';

  Future<String> generateRecipe(String ingredients, String recipeType) async {
    if (ingredients.trim().isEmpty) {
      throw Exception('Masukkan bahan-bahan terlebih dahulu!');
    }

    // Map recipe types to descriptions
    Map<String, String> typeDescriptions = {
      'breakfast': 'a healthy and energizing breakfast',
      'lunch': 'a balanced and filling lunch',
      'dinner': 'a satisfying and nutritious dinner',
      'snack': 'a light and tasty snack',
      'dessert': 'a sweet and delicious dessert',
      'appetizer': 'a flavorful appetizer or starter',
      'beverage': 'a refreshing beverage or drink',
      'salad': 'a fresh and healthy salad'
    };

    String typeDescription = typeDescriptions[recipeType] ?? 'a delicious meal';

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Authorization': 'Bearer $_apiToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'provider': "hyperbolic",
          'model': "deepseek-ai/DeepSeek-R1",
          'messages': [
            {
              'role': 'system',
              'content': '''
                You are a helpful and consistent cooking assistant. You will be given a list of available ingredients with their quantities, and a specific recipe type.
                Create a single-serving recipe that matches the requested type using reasonable amounts of the provided ingredients. Only use what is necessary to prepare one serving for the specified recipe type. You may add a few complementary ingredients if needed (such as salt, oil, spices, or basic seasonings), but the focus should remain on the provided ingredients.
          
                Make sure the recipe is appropriate for the requested type:
                - Breakfast: Should be energizing, light to moderate portions, suitable for morning consumption
                - Lunch: Should be balanced, filling but not too heavy, nutritious
                - Dinner: Can be more substantial, satisfying, and complete
                - Snack: Should be light, quick to prepare, portion-controlled
                - Dessert: Should be sweet, indulgent, appropriate portion size for dessert
                - Appetizer: Should be small portions, flavorful, suitable as starter
                - Beverage: Should be drinkable, refreshing, appropriate liquid consistency
                - Salad: Should be fresh, healthy, with good mix of textures and flavors
          
                Return the recipe strictly in the following JSON format:
          
                {
                  "name": "<Recipe Title appropriate for the type>",
                  "description": "<A short and appealing sentence describing the recipe>",
                  "ingredients": [
                    {
                      "name": "<Ingredient name>",
                      "quantity": <quantity as number>,
                      "unit": "<unit>"
                    },
                    ...
                  ],
                  "steps": [
                    "<Step 1>",
                    "<Step 2>",
                    ...
                  ]
                }
              '''
            },
            {
              'role': 'user',
              'content': "I have the following ingredients available (each item includes quantity, unit, and name): ${ingredients}. Please create a $typeDescription recipe using only reasonable amounts of these ingredients to serve 1 portion. The recipe should be appropriate for ${recipeType}. You don't have to use all the ingredients. You may add basic complementary ingredients (salt, oil, spices) if needed, but focus mainly on the ones I provided."
            }
          ],
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is Map &&
            data.containsKey('choices') &&
            data['choices'] is List &&
            data['choices'].isNotEmpty) {

          final choice = data['choices'][0];
          if (choice is Map &&
              choice.containsKey('message') &&
              choice['message'] is Map &&
              choice['message'].containsKey('content')) {

            return choice['message']['content'] ?? 'Tidak ada resep yang dihasilkan';
          } else {
            throw Exception('Format message tidak valid: $choice');
          }
        } else {
          throw Exception('Format response tidak valid: $data');
        }
      } else if (response.statusCode == 503) {
        throw Exception('Model sedang loading, coba lagi dalam beberapa detik...');
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network Error: $e');
    }
  }

  Future<String> generateRecipeWithoutType(String ingredients) async {
    return generateRecipe(ingredients, 'lunch');
  }
}