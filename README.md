# 📊 Dashboard Financeiro em Flutter

Este é um projeto de aplicativo de dashboard financeiro desenvolvido em Flutter. O objetivo é criar uma aplicação intuitiva e bonita para visualização de dados financeiros, com gráficos, filtros e funcionalidades de exportação, utilizando a arquitetura BLoC para um gerenciamento de estado robusto e escalável.

## ✨ Funcionalidades Implementadas

*   **CRUD de Transações**: Adicionar, visualizar e, futuramente, deletar transações financeiras.
*   **Categorias Padrão**: O aplicativo inicializa com um conjunto de categorias pré-definidas (Alimentação, Transporte, etc.), cada uma com um ícone e cor próprios.
*   **Dashboard Visual**:
    *   Cards de resumo para Receitas, Despesas e Saldo.
    *   Uma legenda clara que mostra as categorias de despesa e suas cores.
    *   Um gráfico de pizza (`PieChart`) que exibe a distribuição percentual das despesas.
*   **Filtro por Período**: Permite ao usuário selecionar um intervalo de datas para filtrar tanto a lista de transações quanto os dados do dashboard.
*   **Persistência Local**: Todos os dados são salvos localmente no dispositivo usando um banco de dados **SQFlite**.

## 🛠️ Arquitetura e Tecnologias

O projeto segue uma arquitetura limpa, dividida em três camadas principais: **Dados**, **Lógica** e **Apresentação**. Essa separação de responsabilidades torna o código mais organizado, testável e fácil de manter.

```
lib/
└── src/
    ├── data/         # Camada de Dados (Onde os dados vivem)
    │   ├── datasources/
    │   ├── models/
    │   └── repositories/
    ├── logic/        # Camada de Lógica (O cérebro do app)
    │   ├── blocs/
    │   ├── events/
    │   └── states/
    └── presentation/ # Camada de Apresentação (O que o usuário vê)
        ├── screens/
        └── widgets/
```

---

## 🔬 Análise Detalhada por Camada

### 1. Camada de Dados (`/data`)

Esta camada é a fundação do aplicativo. Sua única responsabilidade é gerenciar a origem dos dados, seja de um banco de dados local ou de uma API remota.

#### **Models (`/models`)**

Definem a estrutura dos nossos dados. São classes puras, sem lógica complexa.

*   `transaction_model.dart`: Define a classe `Transaction` e o `enum TransactionType`.
*   `category_model.dart`: Define a classe `Category`. Um detalhe importante aqui é o `getter` `colorValue`, que converte a string de cor hexadecimal (ex: `'#FF6347'`) armazenada no banco em um objeto `Color` que o Flutter pode usar. Isso centraliza a lógica de conversão em um único lugar.

    ```dart
    // trecho de category_model.dart
    class Category extends Equatable {
      final String color; // ex: '#FF6347'

      // ...

      Color get colorValue {
        final buffer = StringBuffer();
        if (color.length == 6 || color.length == 7) buffer.write('ff');
        buffer.write(color.replaceFirst('#', ''));
        return Color(int.parse(buffer.toString(), radix: 16));
      }
    }
    ```

#### **Datasources (`/datasources`)**

São as classes que interagem diretamente com a fonte de dados.

*   `local/database_helper.dart`: Usa o pacote `sqflite` para criar e gerenciar a conexão com o banco de dados local (`finance.db`). Ele utiliza o padrão Singleton para garantir que apenas uma instância do banco seja aberta durante o ciclo de vida do app. As tabelas `categories` e `transactions` são criadas aqui.

    ```dart
    // trecho de database_helper.dart
    Future<void> _createDB(Database db, int version) async {
      await db.execute('''
        CREATE TABLE categories(...)
      ''');
      await db.execute('''
        CREATE TABLE transactions(...)
      ''');
    }
    ```

*   `local_datasource.dart`: Implementa os métodos de CRUD (Create, Read, Update, Delete) que executam as queries SQL no banco de dados. É aqui que a lógica de filtragem por data é de fato executada na consulta SQL.

    ```dart
    // trecho de local_datasource.dart
    Future<List<Transaction>> getAllTransactions({DateTimeRange? dateRange}) async {
      // ...
      if (dateRange != null) {
        where = 'date >= ? AND date <= ?';
        whereArgs = [
          dateRange.start.toIso8601String(),
          dateRange.end.add(const Duration(days: 1)).toIso8601String(),
        ];
      }
      final maps = await db.query('transactions', where: where, whereArgs: whereArgs);
      // ...
    }
    ```

#### **Repositories (`/repositories`)**

Abstraem a fonte de dados. A camada de lógica (BLoC) se comunica com o repositório, sem precisar saber se os dados vêm de um banco local, de uma API ou de um cache.

*   `category_repository.dart`: Busca as categorias e, crucialmente, é responsável por popular o banco com um conjunto de categorias padrão na primeira vez que o aplicativo é executado.

    ```dart
    // trecho de category_repository.dart
    Future<void> _insertDefaultCategories() async {
      final defaultCategories = [
        Category(name: 'Alimentação', iconCodePoint: Icons.food_bank.codePoint, color: '#FF6347'),
        // ... outras categorias
      ];
      // ...
    }
    ```

*   `transaction_repository.dart`: Serve como um intermediário para as operações de transação, repassando as chamadas para o `LocalDataSource`.

### 2. Camada de Lógica (`/logic`)

O cérebro da aplicação, onde o estado é gerenciado usando o padrão BLoC (Business Logic Component).

*   **Events (`/events`)**: Classes que representam ações que a UI pode despachar para um BLoC. Exemplos: `LoadTransactions`, `AddTransaction`, `UpdateDateRange`.
*   **States (`/states`)**: Classes que definem os diferentes estados em que a UI pode estar. Exemplos: `TransactionLoading`, `TransactionLoaded`, `TransactionError`. A UI reage a essas mudanças de estado para se reconstruir.
*   **BLoCs (`/blocs`)**:
    *   `transaction_bloc.dart` e `category_bloc.dart`: Ouvem os `Events`, buscam dados do `Repository` correspondente, e emitem novos `States`. Eles são o coração da reatividade do app.
    *   `filter_bloc.dart`: Um BLoC mais simples que apenas armazena o estado do filtro de data (`DateTimeRange`), permitindo que o estado do filtro seja compartilhado e acessado por diferentes partes do app.

### 3. Camada de Apresentação (`/presentation`)

A interface com a qual o usuário interage. É uma camada "burra", ou seja, sua principal função é exibir o estado atual e despachar eventos com base na interação do usuário.

*   **Screens (`/screens`)**:
    *   `main.dart`: O ponto de entrada do aplicativo. É aqui que os `RepositoryProvider` e `BlocProvider` são injetados na árvore de widgets, disponibilizando os repositórios e BLoCs para todas as telas filhas.
    *   `home_screen.dart`: A tela principal. Usa um `DefaultTabController` para gerenciar as abas "Transações" e "Dashboard". Contém os botões na `AppBar` para despachar os eventos de filtro (`_selectDateRange`) e exportação (`_exportToCsv`).
    *   `add_transaction_screen.dart`: Um `StatefulWidget` com um formulário para adicionar novas transações. Ao salvar, despacha o evento `AddTransaction` para o `TransactionBloc`.
    *   `dashboard_view.dart`: O corpo da aba "Dashboard". Usa `BlocBuilder` para ouvir as mudanças de estado do `TransactionBloc` и `CategoryBloc`, recebendo os dados atualizados e passando-os para os widgets de UI, como os `SummaryCard` e o `CategoryPieChart`.

*   **Widgets (`/widgets`)**:
    *   `transaction_list_item.dart`: Um widget customizado para exibir uma única transação na lista, com formatação de data, moeda e o ícone/cor da categoria.
    *   `summary_card.dart`: Widget reutilizável para os cards de resumo no topo do dashboard.
    *   `category_pie_chart.dart`: Usa o pacote `fl_chart` para renderizar o gráfico de pizza. Ele recebe a lista de transações, processa os dados internamente (agrupando despesas por categoria) e gera as seções do gráfico.

    ```dart
    // trecho de category_pie_chart.dart
    List<PieChartSectionData> _prepareChartData() {
      // ... lógica para agrupar despesas por categoria
      return categoryExpenses.entries.map((entry) {
        // ...
        return PieChartSectionData(
          color: category.colorValue, // Usa o getter do modelo!
          value: amount,
          title: '${percentage.toStringAsFixed(1)}%',
          // ...
        );
      }).toList();
    }
    ```

---

## 🔗 Fluxo de Dados: Um Exemplo Completo

Para entender como as camadas se conectam, vamos seguir o fluxo de **Adicionar uma Nova Transação**:

1.  **Usuário**: Clica no `FloatingActionButton` (+) na `HomeScreen`.
2.  **UI (`HomeScreen`)**: O `Navigator` abre a `AddTransactionScreen`.
3.  **Usuário**: Preenche o formulário (descrição, valor, categoria) e clica em "Salvar".
4.  **UI (`AddTransactionScreen`)**: A função `_submitForm` é chamada. Ela valida o formulário, cria um objeto `Transaction` e despacha o evento para o BLoC:
    ```dart
    context.read<TransactionBloc>().add(AddTransaction(newTransaction));
    ```
5.  **BLoC (`TransactionBloc`)**: O `on<AddTransaction>` é ativado. Ele chama o método do repositório:
    ```dart
    await _transactionRepository.addTransaction(event.transaction);
    ```
6.  **Repositório (`TransactionRepository`)**: Repassa a chamada para a fonte de dados: `await localDataSource.insertTransaction(transaction)`.
7.  **DataSource (`LocalDataSource`)**: Executa a query `db.insert('transactions', transaction.toMap())`, salvando os dados no SQFlite.
8.  **BLoC (`TransactionBloc`)**: Após a inserção ser concluída com sucesso, o BLoC despacha um novo evento para si mesmo: `add(LoadTransactions())`.
9.  **BLoC (`TransactionBloc`)**: O `on<LoadTransactions>` é ativado, buscando a lista *atualizada* de transações do banco de dados (seguindo o mesmo fluxo: BLoC -> Repository -> DataSource).
10. **BLoC (`TransactionBloc`)**: Emite um novo estado `TransactionLoaded` contendo a nova lista de transações.
11. **UI (`HomeScreen` e `DashboardView`)**: Os `BlocBuilder`s em ambas as abas detectam o novo estado `TransactionLoaded`. Eles se reconstroem automaticamente, exibindo a nova transação na lista e atualizando os valores e o gráfico no dashboard.

