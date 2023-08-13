// Import packages
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// typical main function that contains a line of code to run the app
void main() {
  // runApp function running an instance of the MyApp?
  runApp(MyApp());
}

// this is a class definition call MyApp which extends A StatelessWidget
// A widget that does not require mutable state.

// A stateless widget is a widget that describes part of the user interface
// by building a constellation of other widgets that describe the user interface
// more concretely.
class MyApp extends StatelessWidget {
  // calling the constructor function of the StatelessWidget?
  const MyApp({super.key});

  // The method overriding is a technique to achieve polymorphism.
  //Sometimes, we want a subclass object to give different results for the same
  // method when subclass object invokes it. This can be done by defining the same
  //method again in subclass.

  //The method has the same name, same arguments, and the same return type.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'My App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.tealAccent),
        ),
        home: MyHomePage(), // the starting point of your app
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  // the MyAppState class defines the app's...well...state.

  // The state class extends ChangeNotifier, which means that it can notify others
  // about its own changes. For example, if the current word pair changes, some widgets in the app need to know.

  // MyAppState defines the data the app needs to function.
  // Right now, it only contains a single variable with the current random word pair. You will add to this later.

  // The state is created and provided to the whole app using a ChangeNotifierProvider (see code above in MyApp)

  // This allows any widget in the app to get hold of the state.
  var current = WordPair.random();

  // ↓ Add this.
  void getNext() {
    current = WordPair.random();

    // notifyListeners()(a method of ChangeNotifier)that ensures that anyone watching MyAppState is notified.
    notifyListeners();
  }

  // ↓ You added a new property to MyAppState called favorites. This property is initialized with an empty list: [].
  // You also specified that the list can only ever contain word pairs: <WordPair>[]
  var favorites = <WordPair>[];

  // check to see if current wordpair is a favourite and adds/removes it depending on whether it's in the favourites list or not
  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }

    // updates the others (Widgets?) about the updated favourites list
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0; // ← Add this property.

  @override
  Widget build(BuildContext context) {
    Widget page;

    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(
        // LayoutBuilder's builder callback is called every time the constraints change.
        // - The user resizes the app's window
        // - The user rotates their phone from portrait mode to landscape mode, or back
        // - Some widget next to MyHomePage grows in size, making MyHomePage's constraints smaller
        builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            // The SafeArea ensures that its child is not obscured by a hardware notch or a status bar
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >=
                    600, // ← Show labels when width of screen is larger than 600 pixels.
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('Favorites'),
                  ),
                ],
                selectedIndex: selectedIndex, // ← Change to this.
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            // One way to think about Expanded widgets is that they are "greedy".
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>(); // ✔️
    final List<WordPair> favorites = appState.favorites;

    if (favorites.isEmpty) {
      // To be replaced with widget that displays required UI for no favourites yet
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return Column(
      children: <Widget>[
        SafeArea(
          child: Text(
            'You have ${favorites.length} favourite(s)!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(favorites[index].asPascalCase),
                );
              }),
        ),
      ],
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    // First, the code requests the app's current theme with Theme.of(context).
    final theme = Theme.of(context);

    // ↓ Add this.
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    // Note: Flutter uses Composition over Inheritance whenever it can. Here, instead of padding being an attribute of Text, it's a widget!
    // defines the card's color to be the same as the theme's colorScheme property
    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(pair.asLowerCase,
            style: style, semanticsLabel: "${pair.first} ${pair.second}"),
      ),
    );
  }
}
