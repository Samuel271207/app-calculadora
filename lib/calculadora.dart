import 'dart:math';
import 'package:expressions/expressions.dart';
import 'package:flutter/material.dart';

class Calculadora extends StatefulWidget {
  const Calculadora({super.key});

  @override
  State<Calculadora> createState() => _CalculadoraState();
}

class _CalculadoraState extends State<Calculadora> {
  final String _limpar = 'Limpar';
  String _expressao = '';
  String _resultado = '';

  void _pressionarBotao(String valor) {
    setState(() {
      if (valor == _limpar) {
        _expressao = '';
        _resultado = '';
      } else if (valor == '=') {
        _calcularResultado();
      } else if (valor == '⌫') {
        if (_expressao.isNotEmpty) {
          _expressao = _expressao.substring(0, _expressao.length - 1);
        }
      } else {
        _expressao += valor;
      }
    });
  }

  void _calcularResultado() {
    try {
      setState(() {
        _resultado = _avaliarExpressao(_expressao).toString();
      });
    } catch (e) {
      setState(() {
        _resultado = 'Erro: $e';  // Exibe erro específico
      });
    }
  }

  double _avaliarExpressao(String expressao) {
    // Substituindo operadores customizados
    expressao = expressao.replaceAll('x', '*').replaceAll('÷', '/');

    // Resolver operações de potência manualmente
    expressao = expressao.replaceAllMapped(
      RegExp(r'(\d+(?:\.\d+)?)\^(\d+(?:\.\d+)?)'),
      (match) => pow(double.parse(match[1]!), double.parse(match[2]!)).toString(),
    );
    
    final parsedExpression = Expression.parse(expressao);
    final evaluator = const ExpressionEvaluator();
    try {
      final result = evaluator.eval(parsedExpression, {
        'sin': (num x) => sin(x * pi / 180),  // Trigonometria em graus
        'cos': (num x) => cos(x * pi / 180),
        'tan': (num x) => tan(x * pi / 180),
        'log': (num x) => log(x) / log(10),  // Logaritmo de base 10
        'ln': log,  // Logaritmo natural
        'sqrt': sqrt,
        'exp': exp,
      });
      return result.toDouble();
    } catch (e) {
      throw 'Erro na avaliação da expressão';  // Mensagem de erro caso falhe
    }
  }

  Widget _botao(String valor) {
    return ElevatedButton(
      onPressed: () => _pressionarBotao(valor),
      child: Text(valor, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Text(_expressao, style: const TextStyle(fontSize: 24)),
        ),
        Expanded(
          child: Text(_resultado, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          flex: 3,
          child: GridView.count(
            crossAxisCount: 4,
            childAspectRatio: 2,
            children: [
              _botao('7'), _botao('8'), _botao('9'), _botao('÷'),
              _botao('4'), _botao('5'), _botao('6'), _botao('x'),
              _botao('1'), _botao('2'), _botao('3'), _botao('-'),
              _botao('0'), _botao('.'), _botao('='), _botao('+'),
              _botao('sin('), _botao('cos('), _botao('tan('), _botao('log('),
              _botao('ln('), _botao('sqrt('), _botao('exp('), _botao('^'), _botao('⌫'),
              _botao('('), _botao(')'), _botao(_limpar),
            ],
          ),
        ),
      ],
    );
  }
}
