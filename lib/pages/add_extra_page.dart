import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kalorilaskuri/db/firestore_util.dart';
import 'package:kalorilaskuri/db/food.dart';

class AddExtraPage extends StatefulWidget {
  const AddExtraPage({super.key});

  @override
  State<AddExtraPage> createState() => _AddExtraPageState();
}

class _AddExtraPageState extends State<AddExtraPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _calWeightController = TextEditingController();
  final _calPieceController = TextEditingController();
  final _calSmallController = TextEditingController();
  final _calNormalController = TextEditingController();
  final _calLargeController = TextEditingController();

  bool _emptyCals = false;
  bool _hasWeightCal = false;
  bool _hasPieceCal = false;
  bool _hasSizeCal = false;
  bool _hasSizeSmall = false;
  bool _hasSizeNormal = false;
  bool _hasSizeLarge = false;

  @override
  void dispose() {
    _nameController.dispose();
    _calWeightController.dispose();
    _calPieceController.dispose();
    _calSmallController.dispose();
    _calNormalController.dispose();
    _calLargeController.dispose();
    super.dispose();
  }

  Future<void> saveExtra() async {
    final String name = _nameController.text;
    final int? weightCal = _hasWeightCal
        ? int.parse(_calWeightController.text)
        : null;
    final int? pieceCal = _hasPieceCal
        ? int.parse(_calPieceController.text)
        : null;

    Map<String, int?>? sizeCal;

    if (_hasSizeCal) {
      final int? smallCal = _hasSizeSmall
          ? int.parse(_calSmallController.text)
          : null;
      final int? normalCal = _hasSizeNormal
          ? int.parse(_calNormalController.text)
          : null;
      final int? largeCal = _hasSizeLarge
          ? int.parse(_calLargeController.text)
          : null;

      if (smallCal != null || normalCal != null || largeCal != null) {
        sizeCal = {'Pieni': smallCal, 'Normaali': normalCal, 'Iso': largeCal};
      }
    }

    if (weightCal == null && pieceCal == null && sizeCal == null) {
      setState(() {
        _emptyCals = true;
      });
      return;
    }

    Food food = Food(
      name: name,
      type: 'Lisuke',
      caloriesPer100g: weightCal,
      caloriesPerPiece: pieceCal,
      caloriesPerSize: sizeCal,
    );

    try {
      FirestoreUtil firestoreUtil = FirestoreUtil();
      firestoreUtil.addFood(food);
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
        title: Text('Uusi lisuke'),
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
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Lisukkeen nimi',
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Anna lisukkeen nimi';
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
                SizedBox(height: 20),
                Container(
                  decoration: _hasSizeCal
                      ? BoxDecoration(border: Border.all())
                      : null,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Center(
                              child: Text(
                                'Annoskoko',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Switch(
                              value: _hasSizeCal,
                              onChanged: (value) {
                                setState(() {
                                  _hasSizeCal = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),

                      if (_hasSizeCal)
                        Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: CheckboxListTile(
                                    title: Text('Pieni'),
                                    value: _hasSizeSmall,
                                    onChanged: (value) {
                                      setState(() {
                                        _hasSizeSmall = value ?? false;
                                      });
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: TextFormField(
                                    enabled: _hasSizeSmall,
                                    controller: _calSmallController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    decoration: const InputDecoration(
                                      labelText: 'kcal/annos',
                                    ),
                                    validator: (value) {
                                      if (!_hasSizeSmall) {
                                        return null;
                                      }

                                      if (value == null || value.isEmpty) {
                                        return 'Anna pienen annoksen kalorit';
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
                            Row(
                              children: [
                                Expanded(
                                  child: CheckboxListTile(
                                    title: Text('Normaali'),
                                    value: _hasSizeNormal,
                                    onChanged: (value) {
                                      setState(() {
                                        _hasSizeNormal = value ?? false;
                                      });
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: TextFormField(
                                    enabled: _hasSizeNormal,
                                    controller: _calNormalController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    decoration: const InputDecoration(
                                      labelText: 'kcal/annos',
                                    ),
                                    validator: (value) {
                                      if (!_hasSizeNormal) {
                                        return null;
                                      }

                                      if (value == null || value.isEmpty) {
                                        return 'Anna normaalin annoksen kalorit';
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
                            Row(
                              children: [
                                Expanded(
                                  child: CheckboxListTile(
                                    title: Text('Iso'),
                                    value: _hasSizeLarge,
                                    onChanged: (value) {
                                      setState(() {
                                        _hasSizeLarge = value ?? false;
                                      });
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: TextFormField(
                                    enabled: _hasSizeLarge,
                                    controller: _calLargeController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    decoration: const InputDecoration(
                                      labelText: 'kcal/annos',
                                    ),
                                    validator: (value) {
                                      if (!_hasSizeLarge) {
                                        return null;
                                      }

                                      if (value == null || value.isEmpty) {
                                        return 'Anna ison annoksen kalorit';
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
                          ],
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      saveExtra();
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
