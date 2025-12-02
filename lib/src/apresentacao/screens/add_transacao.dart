import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../data/models/categoria_model.dart';
import '../../data/models/transacao_model.dart';
import '../../logica/blocs/categoria_bloc.dart';
import '../../logica/blocs/transacao_bloc.dart';
import '../../logica/events/transacao_event.dart';
import '../../logica/states/categoria_state.dart';


class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  // Uma chave global para identificar e controlar o form
  final _formKey = GlobalKey<FormState>();

  // Controladores para ler o texto dos campos de descrição e valor
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  //varieveis de estado para armazenar os valores selecionados pelo usuario
  Category? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  TransactionType _selectedType = TransactionType.despesa; // Começa como 'Despesa' por padrão.

  @override
  void dispose() {
   
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  // Função para mostrar o seletor de data.
  Future<void> _selectDate(BuildContext context) async {
  
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    //se o usuario escolheu uma data e n cancelou
    if (picked != null && picked != _selectedDate) {
      // avisa o flutter para reconstruir a tela e mostrar a nova data
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Função chamada quando o botão "Salvar" é pressionado.
  void _submitForm() {
    
    if (_formKey.currentState!.validate()) {
      //se o form for valido, cria um novo objeto 
      final newTransaction = Transaction(
        description: _descriptionController.text,
        amount: double.parse(_amountController.text.replaceAll(',', '.')),
        date: _selectedDate,
        categoryId: _selectedCategory!.id!,
        type: _selectedType,
      );

      
      context.read<TransactionBloc>().add(AddTransaction(newTransaction));

      
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Transação'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        // O widget `Form` que usa a `_formKey` para gerenciar o estado do formulário.
        child: Form(
          key: _formKey,
         
          child: ListView(
            children: [
              //botao para escolher despesa ou receita
              SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(
                    value: TransactionType.despesa,
                    label: Text('Despesa'),
                    icon: Icon(Icons.remove),
                  ),
                  ButtonSegment(
                    value: TransactionType.receita,
                    label: Text('Receita'),
                    icon: Icon(Icons.add),
                  ),
                ],
                selected: {_selectedType},
                onSelectionChanged: (newSelection) {
                  // Quando a seleção muda, atualiza a variável de estado
                  setState(() {
                    _selectedType = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 20),

              
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                ),
                // validação
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira uma descrição.';
                  }
                  return null; 
                },
              ),
              const SizedBox(height: 16),

              // Campo de texto para o valor
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Valor (R\$)',
                  border: OutlineInputBorder(),
                  prefixText: 'R\$ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira um valor.';
                  }
                  
                  if (double.tryParse(value.replaceAll(',', '.')) == null) {
                    return 'Por favor, insira um número válido.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Dropdown para selecionar a categoria.
          
              BlocBuilder<CategoryBloc, CategoryState>(
                builder: (context, state) {
                  
                  if (state is CategoryLoaded) {
                    return DropdownButtonFormField<Category>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Categoria',
                        border: OutlineInputBorder(),
                      ),
                      hint: const Text('Selecione uma categoria'),
                   
                      items: state.categories.map((Category category) {
                        return DropdownMenuItem<Category>(
                          value: category,
                          child: Text(category.name),
                        );
                      }).toList(),
                      onChanged: (Category? newValue) {
                        
                        setState(() {
                          _selectedCategory = newValue;
                        });
                      },
                      // Valida se o usuário selecionou alguma categoria.
                      validator: (value) => value == null ? 'Campo obrigatório' : null,
                    );
                  }
                 
                  return const Center(child: CircularProgressIndicator());
                },
              ),
              const SizedBox(height: 16),

              //  exibir e alterar a data
              Row(
                children: [
                  Expanded(
                    child: Text(
                     
                      'Data: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
                    ),
                  ),
                  TextButton(
                    onPressed: () => _selectDate(context),
                    child: const Text('Alterar'),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // botao submeter form
              ElevatedButton.icon(
                onPressed: _submitForm,
                icon: const Icon(Icons.save),
                label: const Text('Salvar'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}