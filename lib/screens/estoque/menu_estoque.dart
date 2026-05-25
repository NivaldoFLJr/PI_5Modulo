import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../components/app_scaffold.dart';
import '../../services/api_service.dart';
import '../../services/api_client.dart';

class MateriaPrimaPage extends StatefulWidget {
  final VoidCallback? onSalvo;
  const MateriaPrimaPage({super.key, this.onSalvo});

  @override
  State<MateriaPrimaPage> createState() => _MateriaPrimaPageState();
}

class _MateriaPrimaPageState extends State<MateriaPrimaPage> {
  List<EstoqueItem> _itens = [];
  bool _loading = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    try {
      setState(() { _loading = true; _erro = null; });
      final itens = await ApiService.getEstoque();
      setState(() { _itens = itens; _loading = false; });
    } catch (e) {
      setState(() { _erro = 'Erro ao carregar'; _loading = false; });
    }
  }

  void _openOpcoes() {
    final pageContext = context;
    showModalBottomSheet(
      context: pageContext,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => OpcoesAdicionarSheet(
        onNovoProduto: () {
          Navigator.pop(sheetContext);
          Future.delayed(const Duration(milliseconds: 300), () {
            showModalBottomSheet(
              context: pageContext,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (_) => AdicionarProdutoSheet(onSalvo: _carregar),
            );
          });
        },
        onProdutoExistente: () => Navigator.pop(sheetContext),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: AppTheme.primary,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return AppScaffold(
      title: 'Estoque',
      currentIndex: 1,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: AppTheme.primary,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text(
                    'PRODUÇÃO',
                    style: TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                ),
                const SizedBox(width: 24),
                const Text(
                  'MATÉRIA PRIMA',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Stack(
              children: [
                RefreshIndicator(
                  onRefresh: _carregar,
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : _erro != null
                          ? Center(child: Text(_erro!))
                          : _itens.isEmpty
                              ? const Center(
                                  child: Text('Nenhum item no estoque'))
                              : GridView.builder(
                                  padding: const EdgeInsets.fromLTRB(
                                      16, 16, 16, 110),
                                  itemCount: _itens.length,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 0.85,
                                  ),
                                  itemBuilder: (_, i) => _MateriaPrimaCard(
                                      item: _itens[i]),
                                ),
                ),
                Positioned(
                  left: 16,
                  bottom: 24,
                  child: FloatingActionButton(
                    heroTag: 'fabMateriaPrima',
                    backgroundColor: AppTheme.primaryDeep,
                    onPressed: _openOpcoes,
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MateriaPrimaCard extends StatelessWidget {
  final EstoqueItem item;

  const _MateriaPrimaCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.science_outlined,
              size: 36, color: AppTheme.primaryDeep),
          const SizedBox(height: 8),
          Text(item.nome,
              style: AppTheme.cardTitleStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text('${item.quantidadeAtual} ${item.unidade}',
              style: AppTheme.cardSubtitleStyle),
        ],
      ),
    );
  }
}

class OpcoesAdicionarSheet extends StatelessWidget {
  final VoidCallback onNovoProduto;
  final VoidCallback onProdutoExistente;

  const OpcoesAdicionarSheet({
    super.key,
    required this.onNovoProduto,
    required this.onProdutoExistente,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: const [
              Icon(Icons.settings, size: 16, color: Colors.black54),
              SizedBox(width: 6),
              Text(
                'OPÇÕES ADICIONAR',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onNovoProduto,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryDeep,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22)),
              ),
              child: const Text('NOVO PRODUTO',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onProdutoExistente,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryDeep,
                side: BorderSide(color: AppTheme.primaryDeep),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22)),
              ),
              child: const Text('PRODUTO EXISTENTE',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class AdicionarProdutoSheet extends StatefulWidget {
  final VoidCallback onSalvo;

  const AdicionarProdutoSheet({super.key, required this.onSalvo});

  @override
  State<AdicionarProdutoSheet> createState() => _AdicionarProdutoSheetState();
}

class _AdicionarProdutoSheetState extends State<AdicionarProdutoSheet> {
  final _nomeController       = TextEditingController();
  final _unidadeController    = TextEditingController();
  final _precoVendaController = TextEditingController();
  final _precoCustoController = TextEditingController();
  final _quantidadeController = TextEditingController();
  bool _salvando = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _unidadeController.dispose();
    _precoVendaController.dispose();
    _precoCustoController.dispose();
    _quantidadeController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    final nome       = _nomeController.text.trim();
    final unidade    = _unidadeController.text.trim();
    final precoVenda = double.tryParse(_precoVendaController.text.trim());
    final precoCusto = double.tryParse(_precoCustoController.text.trim());
    final quantidade = int.tryParse(_quantidadeController.text.trim());

    if (nome.isEmpty || unidade.isEmpty ||
        precoVenda == null || precoCusto == null || quantidade == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos corretamente')),
      );
      return;
    }

    setState(() => _salvando = true);

    try {
      final result = await ApiClient.post('/produtos', {
        'nome':        nome,
        'unidade':     unidade,
        'preco_venda': precoVenda,
        'preco_custo': precoCusto,
        'quantidade':  quantidade,
        'icone':       'basket',
        'categoria':   'salgado',
      });

      await ApiClient.post('/estoque', {
        'produto_id':       result['id'],
        'quantidade_atual': quantidade,
        'quantidade_minima': 10,
      });

      if (!mounted) return;
      Navigator.pop(context);
      widget.onSalvo();
    } catch (e) {
      setState(() => _salvando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao salvar produto')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ADICIONAR NOVO PRODUTO', style: AppTheme.sectionTitleStyle),
            const SizedBox(height: 16),
            _StyledTextField(controller: _nomeController,       hint: 'Nome do produto'),
            const SizedBox(height: 10),
            _StyledTextField(controller: _unidadeController,    hint: 'Unidade (ex: 100 un)'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _StyledTextField(
                    controller: _precoVendaController,
                    hint: 'Preço de venda',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StyledTextField(
                    controller: _precoCustoController,
                    hint: 'Preço de custo',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _StyledTextField(
              controller: _quantidadeController,
              hint: 'Quantidade inicial',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _salvando ? null : _salvar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryDeep,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _salvando
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('SALVAR',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType keyboardType;

  const _StyledTextField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 12, color: Colors.grey[500]),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: AppTheme.primaryDeep, width: 1.5),
        ),
      ),
    );
  }
}