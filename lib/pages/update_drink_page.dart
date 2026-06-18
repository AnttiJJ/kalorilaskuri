import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kalorilaskuri/db/firestore_util.dart';
import 'package:kalorilaskuri/db/food.dart';

class UpdateDrinkPage extends StatefulWidget {
  final Food food;

  const UpdateDrinkPage({super.key, required this.food});

  @override
  State<UpdateDrinkPage> createState() => _UpdateDrinkPageState();
}

class _UpdateDrinkPageState extends State<UpdateDrinkPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _calWeightController = TextEditingController();
  final _calPieceController = TextEditingController();

  bool _emptyCals = false;
  bool _hasWeightCal = false;
  bool _hasPieceCal = false;

  @override
  void initState() {
    // TextFields
    _nameController.text = widget.food.name;
    _calWeightController.text = widget.food.caloriesPer100g != null
        ? widget.food.caloriesPer100g.toString()
        : '';
    _calPieceController.text = widget.food.caloriesPerPiece != null
        ? widget.food.caloriesPerPiece.toString()
        : '';

    // Checkboxes and Switch
    _hasWeightCal = widget.food.caloriesPer100g != null;
    _hasPieceCal = widget.food.caloriesPerPiece != null;
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _calWeightController.dispose();
    _calPieceController.dispose();
    super.dispose();
  }

  Future<void> updateFood() async {
    final String name = _nameController.text;
    final int? weightCal = _hasWeightCal
        ? int.parse(_calWeightController.text)
        : null;
    final int? pieceCal = _hasPieceCal
        ? int.parse(_calPieceController.text)
        : null;

    if (weightCal == null && pieceCal == null) {
      setState(() {
        _emptyCals = true;
      });
      return;
    }

    Food food = Food(
      name: name,
      type: 'Juoma',
      caloriesPer100g: weightCal,
      caloriesPerPiece: pieceCal,
      caloriesPerSize: null,
    );

    try {
      FirestoreUtil firestoreUtil = FirestoreUtil();
      await firestoreUtil.updateFood(food);
    } catch (e) {
      print(e);
      return;
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Muokkaa juomaa'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  enabled: false,
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Aterian nimi'),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Anna juoman nimi';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 40),
                Text('Kalorit', style: TextStyle(fontSize: 24)),
                if (_emptyCals)
                  Text(
                    'Kaikki kalorit eivät voi olla tyhjiä',
                    style: TextStyle(color: Colors.red),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: CheckboxListTile(
                        title: const Text('Paino'),
                        value: _hasWeightCal,
                        onChanged: (value) {
                          setState(() {
                            _hasWeightCal = value ?? false;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        enabled: _hasWeightCal,
                        controller: _calWeightController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(
                          labelText: 'kcal/100g',
                        ),
                        validator: (value) {
                          if (!_hasWeightCal) {
                            return null;
                          }

                          if (value == null || value.isEmpty) {
                            return 'Anna kalorit per 100g';
                          }

                          final number = int.tryParse(value);

                          if (number == null || number <= 0) {
                            return 'Anna kalorit positiivisena lukuna';
                          }

                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: CheckboxListTile(
                        title: const Text('Määrä'),
                        value: _hasPieceCal,
                        onChanged: (value) {
                          setState(() {
                            _hasPieceCal = value ?? false;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        enabled: _hasPieceCal,
                        controller: _calPieceController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(
                          labelText: 'kcal/kpl',
                        ),
                        validator: (value) {
                          if (!_hasPieceCal) {
                            return null;
                          }

                          if (value == null || value.isEmpty) {
                            return 'Anna kalorit per kappale';
                          }

                          final number = int.tryParse(value);

                          if (number == null || number <= 0) {
                            return 'Anna kalorit positiivisena lukuna';
                          }

                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      updateFood();
                    }
                  },
                  child: const Text('Tallenna'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
