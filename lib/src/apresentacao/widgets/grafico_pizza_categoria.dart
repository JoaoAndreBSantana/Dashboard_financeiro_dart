import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../data/models/categoria_model.dart';
import '../../data/models/transacao_model.dart';

class CategoryPieChart extends StatelessWidget {
  final List<Transaction> transactions;
  final List<Category> categories;

  const CategoryPieChart({
    super.key,
    required this.transactions,
    required this.categories,
  });

  //processa os dados do grafico
  List<PieChartSectionData> _prepareChartData() {
    final Map<int, double> categoryExpenses = {};
    double totalExpenses = 0;

    
    final expenses = transactions.where((t) => t.type == TransactionType.despesa);
    for (var expense in expenses) {
      totalExpenses += expense.amount;
      // agrupa os valores por id de categoria
      categoryExpenses.update(
        expense.categoryId,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }

    if (totalExpenses == 0) {
      return []; // Retorna lista vazia se não houver despesas
    }

    // converte os dados agrupados em secoes para o grafico
    return categoryExpenses.entries.map((entry) {
      final categoryId = entry.key;
      final amount = entry.value;
      final percentage = (amount / totalExpenses) * 100;

      // Encontra a categoria correspondente para obter a cor e o nome.
      final category = categories.firstWhere(
        (c) => c.id == categoryId,
        orElse: () => const Category(name: 'Outros', iconCodePoint: 0, color: '#808080'),
      );

      return PieChartSectionData(
        color: category.colorValue,
        value: amount,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [Shadow(color: Colors.black, blurRadius: 2)],
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final chartData = _prepareChartData();

    if (chartData.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('Nenhuma despesa registrada.')),
      );
    }

    return SizedBox(
      height: 250,
      child: PieChart(
        PieChartData(
          sections: chartData,
          borderData: FlBorderData(show: false),
          sectionsSpace: 2,
          centerSpaceRadius: 40,
        ),
      ),
    );
  }
}