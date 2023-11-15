import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            primary: Colors.indigo,
            onPrimary: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ),
      ),
      home: CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _input = '';
  String _output = '';
  List<String> _history = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculatrice Flutter'),
      ),
      body: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.indigo, width: 2.0),
          borderRadius: BorderRadius.circular(10.0),
        ),
        margin: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: Colors.indigo, width: 2.0)),
                ),
                alignment: Alignment.bottomRight,
                padding: EdgeInsets.all(16.0),
                child: Text(
                  _input,
                  style: TextStyle(fontSize: 24.0),
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: Colors.indigo, width: 2.0)),
                ),
                alignment: Alignment.bottomRight,
                padding: EdgeInsets.all(16.0),
                child: Text(
                  _output,
                  style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildButton('C'),
                _buildButton('('),
                _buildButton(')'),
                _buildButton('÷'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildButton('7'),
                _buildButton('8'),
                _buildButton('9'),
                _buildButton('*'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildButton('4'),
                _buildButton('5'),
                _buildButton('6'),
                _buildButton('-'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildButton('1'),
                _buildButton('2'),
                _buildButton('3'),
                _buildButton('+'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildButton('0'),
                _buildButton('.'),
                _buildButton('Del'),
                _buildButton('='),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildHistoryButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String buttonText) {
    return ElevatedButton(
      onPressed: () {
        _onButtonPressed(buttonText);
      },
      child: Text(
        buttonText,
        style: TextStyle(fontSize: 20.0),
      ),
    );
  }

  Widget _buildHistoryButton() {
    return ElevatedButton(
      onPressed: () {
        _showHistory();
      },
      child: Text(
        'Historique',
        style: TextStyle(fontSize: 16.0),
      ),
    );
  }

  bool _isNumeric(String str) {
    if (str == null || str.isEmpty) {
      return false;
    }
    return double.tryParse(str) != null;
  }

  void _onButtonPressed(String buttonText) {
    setState(() {
      if (buttonText == 'C') {
        _clear();
      } else if (buttonText == '=') {
        _calculate();
      } else if (buttonText == 'Del') {
        _delete();
      } else {
        // Ajouter '*' si la chaîne se termine par '(' et le bouton est un nombre
        if (_input.isNotEmpty &&
            (_input.substring(_input.length - 1) == '(' ||
                _input.substring(_input.length - 1) == ')' ||
                _isNumeric(_input.substring(_input.length - 1))) &&
            _isNumeric(buttonText)) {
          _input += '*$buttonText';
        } else if (_input.isNotEmpty &&
            (_input.substring(_input.length - 1) == '(' ||
                _input.substring(_input.length - 1) == ')' ||
                _isNumeric(_input.substring(_input.length - 1))) &&
            buttonText == '÷') {
          _input += '/'; // Ajouter '/' si la chaîne se termine par un nombre
        } else {
          _input += buttonText;
        }
      }
    });
  }

  void _clear() {
    _input = '';
    _output = '';
  }

  void _delete() {
    setState(() {
      if (_input.isNotEmpty) {
        _input = _input.substring(0, _input.length - 1);
      }
    });
  }

  void _calculate() {
    try {
      Parser p = Parser();
      Expression exp = p.parse(_input);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);
      _output = eval.toString();
      _history.add('$_input = $_output');
    } catch (e) {
      _output = 'Erreur';
    }
  }

  void _showHistory() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Historique'),
          content: Container(
            width: double.maxFinite,
            height: 200.0, // Ajustez la hauteur selon vos besoins
            child: ListView.builder(
              itemCount: _history.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_history[index]),
                );
              },
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Fermer'),
            ),
            ElevatedButton(
              onPressed: () {
                _showClearHistoryConfirmation();
              },
              child: Text('Effacer l\'historique'),
            ),
          ],
        );
      },
    );
  }

  void _showClearHistoryConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Êtes-vous sûr de vouloir effacer l\'historique?'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                _clearHistory();
                Navigator.of(context)
                    .pop(); // Ferme la boîte de dialogue de confirmation
                Navigator.of(context)
                    .pop(); // Ferme la boîte de dialogue de l'historique
              },
              child: Text('Confirmer'),
            ),
          ],
        );
      },
    );
  }

  void _clearHistory() {
    setState(() {
      _history.clear();
    });
  }
}
