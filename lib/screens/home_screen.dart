import 'package:ailoitte_assessment/models/drink.dart';
import 'package:ailoitte_assessment/repositories/drinks_repository.dart';
import 'package:ailoitte_assessment/screens/drink_details_screen.dart';
import 'package:ailoitte_assessment/utils/helpers.dart';
import 'package:ailoitte_assessment/widgets/custom_loader.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  static const id = 'HomeScreen';

  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Drink>? _drinks;
  bool _isLoading = false;

  final TextEditingController searchController = TextEditingController();

  void _updateDrinks(String? q) async {
    setState(() => _isLoading = true);
    try {
      _drinks = await DrinksRepository.getDrinks(searchQuery: q);
    } catch (_) {
      showSnackBar('Something went wrong!');
    }
    setState(() => _isLoading = false);
  }

  @override
  void initState() {
    _updateDrinks(null);
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: DoubleBackToCloseApp(
          snackBar: const SnackBar(
            content: Text('Tap the back button again to exit the app!'),
          ),
          child: ListView(
            padding: const EdgeInsets.all(10),
            children: [
              TextField(
                controller: searchController,
                onSubmitted: (_) {
                  final searchQuery = searchController.text;
                  if (isNullOrBlank(searchQuery)) {
                    return showSnackBar('Please enter a valid search term!');
                  }
                  _updateDrinks(searchQuery);
                },
                decoration: InputDecoration(
                  hintText: 'Search for drinks...',
                  suffix: IconButton(
                    onPressed: () {
                      final q = searchController.text;
                      if (!isNullOrBlank(q)) _updateDrinks(null);
                      searchController.clear();
                      FocusScope.of(context).unfocus();
                    },
                    icon: const Icon(Icons.clear),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                child: const Text(
                  'Search',
                  style: TextStyle(fontSize: 20),
                ),
                onPressed: () async {
                  final searchQuery = searchController.text;
                  if (isNullOrBlank(searchQuery)) {
                    return showSnackBar('Please enter a valid search term!');
                  }
                  _updateDrinks(searchQuery);
                },
              ),
              const SizedBox(height: 25),
              if (_isLoading)
                const CustomLoader()
              else if (_drinks == null)
                const Center(
                  child: Text(
                    'No drinks found!',
                    style: TextStyle(fontSize: 22),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) => _DrinkCard(
                    drink: _drinks![index],
                  ),
                  itemCount: _drinks!.length,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrinkCard extends StatelessWidget {
  final Drink drink;

  const _DrinkCard({
    Key? key,
    required this.drink,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(drink.strDrink),
      subtitle: Text(drink.idDrink),
      onTap: () => Navigator.pushNamed(
        context,
        DrinkDetailsScreen.id,
        arguments: drink,
      ),
    );
  }
}
