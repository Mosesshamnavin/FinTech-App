import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:math_expressions/math_expressions.dart';

class CalculatorModal extends StatefulWidget {
  const CalculatorModal({super.key});

  @override
  State<CalculatorModal> createState() => _CalculatorModalState();
}

class _CalculatorModalState extends State<CalculatorModal> {
  String _expression = '';
  String _preview = '';
  bool _isEvaluated = false;

  void _onButtonPressed(String text) {
    HapticFeedback.lightImpact();
    setState(() {
      if (text == 'C') {
        _expression = '';
        _preview = '';
        _isEvaluated = false;
        return;
      }

      if (text == '⌫') {
        if (_isEvaluated) {
          _preview = '';
          _isEvaluated = false;
        } else if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
          _liveEvaluate();
        }
        return;
      }

      bool isOperator = ['÷', '×', '-', '+'].contains(text);

      if (text == '=') {
        if (_expression.isNotEmpty && !_isEvaluated) {
          String eval = _evaluate(_expression);
          if (eval != 'Error') {
             _preview = '$_expression =';
             _expression = eval;
             _isEvaluated = true;
          }
        }
        return;
      }

      if (_isEvaluated) {
        if (isOperator) {
          _expression = _expression + text;
          _preview = _evaluate(_expression);
        } else {
          _expression = text;
          _preview = '';
        }
        _isEvaluated = false;
        return;
      }

      // Handle normal input
      if (isOperator && _expression.isNotEmpty) {
        String lastChar = _expression[_expression.length - 1];
        if (['÷', '×', '-', '+'].contains(lastChar)) {
           _expression = _expression.substring(0, _expression.length - 1) + text;
        } else {
           _expression += text;
        }
      } else {
        _expression += text;
      }
      
      _liveEvaluate();
    });
  }

  void _liveEvaluate() {
    bool hasOperator = _expression.contains('+') || _expression.contains('-') || _expression.contains('×') || _expression.contains('÷');
    if (hasOperator) {
       String eval = _evaluate(_expression);
       _preview = eval == 'Error' ? '' : eval;
    } else {
       _preview = '';
    }
  }

  String _evaluate(String expr) {
    String parseExpr = expr.replaceAll('×', '*').replaceAll('÷', '/').replaceAll('%', '/100');
    if (parseExpr.endsWith('+') || parseExpr.endsWith('-') || parseExpr.endsWith('*') || parseExpr.endsWith('/')) {
       parseExpr = parseExpr.substring(0, parseExpr.length - 1);
    }
    if (parseExpr.isEmpty) return '';

    try {
      Parser p = Parser();
      Expression exp = p.parse(parseExpr);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);
      
      // Round to 2 decimal places
      eval = (eval * 100).roundToDouble() / 100;
      
      String evalString = eval.toString();
      if (evalString.endsWith('.0')) {
        evalString = evalString.substring(0, evalString.length - 2);
      }
      return evalString;
    } catch (e) {
      return 'Error';
    }
  }

  String _formatIndianNumber(String s) {
    if (s.isEmpty) return '';
    String res = '';
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      res = s[i] + res;
      count++;
      if (count == 3 && i != 0 && s[i - 1] != '-') {
        res = ',' + res;
      } else if (count > 3 && (count - 3) % 2 == 0 && i != 0 && s[i - 1] != '-') {
        res = ',' + res;
      }
    }
    return res;
  }

  String _formatExpressionDisplay(String expr) {
    if (expr.isEmpty) return '';
    
    final RegExp regex = RegExp(r'(\d+\.?\d*)|([÷×\-+%=\s]+)');
    final matches = regex.allMatches(expr);
    
    StringBuffer sb = StringBuffer();
    for (var match in matches) {
      String part = match.group(0)!;
      if (double.tryParse(part) != null) {
        if (part.contains('.')) {
           List<String> split = part.split('.');
           sb.write(_formatIndianNumber(split[0]));
           sb.write('.');
           sb.write(split[1]);
        } else {
           sb.write(_formatIndianNumber(part));
        }
      } else {
        sb.write(part);
      }
    }
    return sb.toString();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> buttons = [
      'C', '⌫', '%', '÷',
      '7', '8', '9', '×',
      '4', '5', '6', '-',
      '1', '2', '3', '+',
      '00', '0', '.', '=',
    ];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 350,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Display Screen
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              alignment: Alignment.bottomRight,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatExpressionDisplay(_preview),
                    style: const TextStyle(fontSize: 20, color: Colors.black54),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _expression.isEmpty ? '0' : _formatExpressionDisplay(_expression),
                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.black87),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Keypad
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 1.1,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: buttons.length,
                itemBuilder: (context, index) {
                  final text = buttons[index];
                  bool isOperator = ['÷', '×', '-', '+', '='].contains(text);
                  bool isAction = ['C', '⌫', '%'].contains(text);

                  return Material(
                    color: isOperator
                        ? Colors.lightBlue
                        : (isAction ? Colors.grey.shade300 : Colors.white),
                    borderRadius: BorderRadius.circular(8),
                    elevation: isAction || isOperator ? 0 : 2,
                    child: InkWell(
                      onTap: () => _onButtonPressed(text),
                      borderRadius: BorderRadius.circular(8),
                      child: Center(
                        child: Text(
                          text,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: isAction ? FontWeight.bold : FontWeight.w500,
                            color: isOperator
                                ? Colors.white
                                : (isAction ? Colors.black87 : Colors.black87),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
