import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../components/app_scaffold.dart';
import '../../services/api_service.dart';
import 'menu_estoque.dart';

// ← Sem import de main.dart ou AppBottomNav — o AdminShell cuida da nav

class EstoquePage extends StatefulWidget {
  final Usuario usuario;
  const EstoquePage({super.key, required this.usuario});

  @override
  State<EstoquePage> createState() => _EstoquePageState();
}

class _EstoquePageState extends State<EstoquePage> {
  List<EstoqueItem> _itens = [];
  List<ProdutoApi> _produtos = [];
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
      final results = await Future.wait([
        ApiService.getEstoque(),
        ApiService.getProdutos(),
      ]);
      setState(() {
        _itens    = results[0] as List<EstoqueItem>;
        _produtos = results[1] as List<ProdutoApi>;
        _loading  = false;
      });
    } catch (e) {
      setState(() { _erro = 'Erro ao carregar estoque'; _loading = false; });
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
      // SEM bottomNavigationBar — o AdminShell já gerencia
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryDeep,
        onPressed: _openOpcoes,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: AppTheme.primary,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Row(
              children: [
                _Tab(label: 'PRODUÇÃO', ativo: true, onTap: () {}),
                const SizedBox(width: 24),
                _Tab(
                  label: 'MATÉRIA PRIMA',
                  ativo: false,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => MateriaPrimaPage(onSalvo: _carregar)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _carregar,
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _erro != null
                      ? _ErroWidget(mensagem: _erro!, onRetry: _carregar)
                      : _itens.isEmpty
                          ? const _EmptyWidget()
                          : GridView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
                              itemCount: _itens.length,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.85,
                              ),
                              itemBuilder: (_, i) => ProdutoEstoqueCard(item: _itens[i]),
                            ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tab ───────────────────────────────────────────────────────

class _Tab extends StatelessWidget {
  final String label;
  final bool ativo;
  final VoidCallback onTap;

  const _Tab({required this.label, required this.ativo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: ativo ? FontWeight.bold : FontWeight.normal,
          color: ativo ? Colors.white : Colors.white70,
          decoration: ativo ? TextDecoration.underline : null,
          decorationColor: Colors.white,
        ),
      ),
    );
  }
}

// ── Card de produto no estoque ────────────────────────────────

class ProdutoEstoqueCard extends StatelessWidget {
  final EstoqueItem item;
  const ProdutoEstoqueCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final baixo = item.estaBaixo;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: baixo ? AppTheme.red.withOpacity(0.4) : Colors.transparent),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: baixo ? AppTheme.red.withOpacity(0.08) : AppTheme.background,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Center(
                child: Icon(Icons.inventory_2_outlined, size: 40, color: baixo ? AppTheme.red : AppTheme.primaryDeep),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.nome, style: AppTheme.cardTitleStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${item.quantidadeAtual} ${item.unidade}', style: AppTheme.cardSubtitleStyle),
                    if (baixo)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: AppTheme.red.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                        child: Text('Baixo', style: TextStyle(fontSize: 10, color: AppTheme.red, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widgets auxiliares ────────────────────────────────────────

class _ErroWidget extends StatelessWidget {
  final String mensagem;
  final VoidCallback onRetry;
  const _ErroWidget({required this.mensagem, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppTheme.red, size: 48),
            const SizedBox(height: 12),
            Text(mensagem, style: AppTheme.cardSubtitleStyle),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Tentar novamente')),
          ],
        ),
      ),
    );
  }
}

class _EmptyWidget extends StatelessWidget {
  const _EmptyWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory_2_outlined, color: AppTheme.textMuted, size: 48),
            const SizedBox(height: 12),
            Text('Nenhum item no estoque', style: AppTheme.cardSubtitleStyle),
          ],
        ),
      ),
    );
  }
}