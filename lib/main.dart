import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

Future<void> main() async {

  await Hive.initFlutter();
  await Hive.openBox('storage');

  Get.lazyPut<RecipeController>(() => RecipeController());

  runApp(
    GetMaterialApp(
      home: RecipeWidget(),
      initialRoute: "/",
      getPages: [
        GetPage(name: "/", page: () => HomeScreen()),
        GetPage(name: "/addrecipe", page: () => AddRecipeScreen()),
        GetPage(name: "/articles", page: () => ArticlesScreen()),
        GetPage(name: "/account", page: () => AccountScreen()),
        GetPage(name: "/account/:secretId", page: () => SecretScreen()),
      ],
      ),
  );
}

class RecipeController {
  final storage = Hive.box('storage');

  RxList recipes;

  RecipeController() : recipes = [].obs {
    recipes.value = storage.get('recipes') ?? [];
  }

  void addRecipe(String name, String ingredients) {
    recipes.add({'name': name, 'ingredients': ingredients});
    storage.put('recipes', recipes);
  }

  int get count => recipes.length;
}

class RecipeWidget extends StatefulWidget {
  @override
  State<RecipeWidget> createState() => _RecipeState();
}

class _RecipeState extends State<RecipeWidget> {
  int _selectedIndex = 0;

  final _screens = [
    HomeScreen(),
    ArticlesScreen(),
  ];

  void _change(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Recipes", style: TextStyle(color: Color.fromARGB(255, 48, 52, 76))),
        backgroundColor: Color(0xFFd9dbf1),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () => Get.toNamed("/account"),
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _change,
        backgroundColor: Color(0xFFd9dbf1),
        selectedItemColor: Color.fromARGB(255, 48, 52, 76), 
        unselectedItemColor: Color(0xFF7d84b2),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: "Articles",
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final controller = Get.find<RecipeController>();

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    int count;
    if (width < 640) {
      count = 1;
    } else if (width < 768) {
      count = 2;
    } else {
      count = 3;
    }

    return Center(
      child: Column(
        children: [
          SizedBox(height: 10),
          Obx(() => Text("Total recipes: ${controller.count}")),
          SizedBox(height: 10),
          Expanded(
            child: Obx(
              () => GridView.count(
                crossAxisCount: count,
                padding: EdgeInsets.all(10),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: controller.recipes.map((recipe) {
                  final name = recipe['name'];
                  final ingredients = recipe['ingredients'];

                  return Card(
                    color: Color(0xffffdab9),
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          children: [
                            Text("$name",
                              style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16, color: Color.fromARGB(255, 93, 41, 41),
                              ),
                            ),
                            SizedBox(height: 5),
                            Text("$ingredients",
                              style: TextStyle(color: Color.fromARGB(255, 93, 41, 41),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          SizedBox(height: 10),
          ElevatedButton(
              onPressed: () => Get.toNamed("/addrecipe"),
              child: Text("Add recipe"),
            ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}

class ArticlesScreen extends StatelessWidget {
  final articles = ["Healthy sweet potato brownies", "Pumpkin pie", "Oreo cheesecake", "Blueberry muffins"];

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    int crossAxisCount = 1; 
    if (screenWidth >= 600) crossAxisCount = 2;
    if (screenWidth >= 900) crossAxisCount = 3;

    final articleCards = articles
        .map(
          (article) => Card(
            color: Color(0xffffdab9),
            child: Center(
              child: Text(
                "$article",
                style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 93, 41, 41),
                ),
              ),
            ),
          ),
        )
        .toList();

    return Center(
      child: Column(
        children: [
          SizedBox(height: 10),
          Text("Ideas from community"),
          SizedBox(height: 10),
          Expanded(
            child: GridView.count(
              crossAxisCount: crossAxisCount,
              padding: EdgeInsets.all(10),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: articleCards,
            ),
          ),
        ],
      ),
    );
  }
}

class AddRecipeScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormBuilderState>();
  final recipeController = Get.find<RecipeController>();

  void _submit() {
    if (_formKey.currentState!.saveAndValidate()) {
      recipeController.addRecipe(
        _formKey.currentState!.value['name'],
        _formKey.currentState!.value['ingredients'],
      );
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add recipe", style: TextStyle(color: Color.fromARGB(255, 48, 52, 76))),
        backgroundColor: Color(0xFFd9dbf1),
        ),
      body: Center(
        child: SizedBox(
          width: 400, 
          child: FormBuilder(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min, 
              children: [
                FormBuilderTextField(
                  name: 'name',
                  decoration: InputDecoration(
                    labelText: "Recipe name",
                  ),
                  autovalidateMode: AutovalidateMode.always,
                  validator: FormBuilderValidators.required(),
                ),
                SizedBox(height: 10),
                FormBuilderTextField(
                  name: 'ingredients',
                  decoration: InputDecoration(
                    labelText: "Ingredients",
                  ),
                  autovalidateMode: AutovalidateMode.always,
                  validator: FormBuilderValidators.required(),
                  maxLines: 3,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submit,
                  child: Text("Save"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AccountScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Account", style: TextStyle(color: Color.fromARGB(255, 48, 52, 76))),
        backgroundColor: Color(0xFFd9dbf1),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              color: Color(0xffffdab9),
              margin: EdgeInsets.all(20),
              child: ListTile(
                leading: Icon(Icons.contact_phone, color: Color.fromARGB(255, 93, 41, 41)),
                title: Text(
                  "Jane Doe",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color.fromARGB(255, 93, 41, 41),
                  ),
                ),
                subtitle: Text(
                  "+358 50 123 1234",
                  style: TextStyle(color: Color.fromARGB(255, 93, 41, 41)),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Get.toNamed("/account/love"),
              child: Text("Show cooking secret 1"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Get.toNamed("/account/salt"),
              child: Text("Show cooking secret 2"),
            ),
          ],
        ),
      ),
    );
  }
}

class SecretScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final secretId = Get.parameters["secretId"];
    return Scaffold(
      appBar: AppBar(
        title: Text("Secret", style: TextStyle(color: Color.fromARGB(255, 48, 52, 76))),
        backgroundColor: Color(0xFFd9dbf1),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Get.back(),
          child: Text("The secret ingredient was $secretId"),
        ),
      ),
    );
  }
}