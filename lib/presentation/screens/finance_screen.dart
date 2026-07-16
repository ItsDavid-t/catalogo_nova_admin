import 'package:echo_stock/domain/core/filters/sale_filters.dart';
import 'package:echo_stock/domain/entities/alert_rule.dart';
import 'package:echo_stock/domain/entities/finance_insights.dart';
import 'package:echo_stock/domain/entities/profit_loss.dart';
import 'package:echo_stock/domain/entities/sale.dart';
import 'package:echo_stock/presentation/cubit/auth/auth_cubit.dart';
import 'package:echo_stock/presentation/cubit/product/product_cubit.dart';
import 'package:echo_stock/presentation/cubit/product/product_state.dart';
import 'package:echo_stock/presentation/cubit/sale/sale_cubit.dart';
import 'package:echo_stock/presentation/cubit/sale/sale_state.dart';
import 'package:echo_stock/presentation/screens/new_sale_screen.dart';
import 'package:echo_stock/presentation/widgets/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  SalesFilter _currentFilter = SalesFilter.month(DateTime.now());
  DateTimeRange? _customRange;
  List<FinanceInsights> _insights = [];
  List<AlertRule> _alerts = [];

  @override
  void initState() {
    super.initState();
    _loadFinances();
  }

  Future<void> _loadFinances() async {
    final shopId = context.read<AuthCubit>().currentSession?.userId;

    if (shopId == null) return;

    await context.read<ProductCubit>().loadProducts(shopId: shopId);
    if (!mounted) return;

    await context.read<SaleCubit>().loadSales(shopId, filter: _currentFilter);
  }

  Future<void> _calculateFinances(List<Sale> sales) async {
    final productState = context.read<ProductCubit>().state;

    if (productState is! ProductLoaded) return;

    final lookup = context.read<SaleCubit>().buildLookupFromProducts(
      productState.products,
    );

    final alerts = await context.read<SaleCubit>().evaluateAlertRules(
      productState.products,
      sales,
      productNames: lookup.names,
    );

    context.read<SaleCubit>().calculateFinanceForSales(
      sales,
      productCosts: lookup.costs,
      productNames: lookup.names,
    );

    final insights = await context.read<SaleCubit>().buildFinanceInsights(
      sales,
      productNames: lookup.names,
    );

    if (!mounted) return;
    setState(() {
      _insights = insights;
      _alerts = alerts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Finanzas'), elevation: 0),
      drawer: CustomDrawer(
        onRefresh: () => context.read<ProductCubit>().loadProducts(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NewSaleScreen()),
          );
        },
        icon: const Icon(Icons.point_of_sale),
        label: const Text('Nueva Venta'),
      ),
      body: BlocListener<SaleCubit, SaleState>(
        listener: (context, state) {
          if (state is SaleLoaded) {
            _calculateFinances(state.sales);
          }
        },
        child: BlocBuilder<SaleCubit, SaleState>(
          builder: (context, state) {
            if (state is SaleLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is SaleFailure) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 50,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${state.message}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _loadFinances,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            if (state is SaleFinanceLoaded) {
              if (state.profitLoss.salesCount == 0) {
                return _buildEmptyState(context);
              }
              return _buildFinanceContent(context, state.profitLoss);
            }
            return _buildEmptyState(context);
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadFinances,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFilterBar(),
            const SizedBox(height: 16),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.point_of_sale_outlined,
                    size: 56,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(height: 16),
                  const Text('Aún no hay ventas registradas'),
                  const SizedBox(height: 8),
                  Text(
                    'Registra tu primera venta para ver ganancias aquí',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NewSaleScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text('Registrar venta'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinanceContent(BuildContext context, ProfitLoss profitLoss) {
    return RefreshIndicator(
      onRefresh: _loadFinances,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFilterBar(),
            SizedBox(height: 16),
            _buildSummarySection(context, profitLoss),
            const SizedBox(height: 24),
            _buildMetricsGrid(context, profitLoss),
            const SizedBox(height: 24),

            const SizedBox(height: 24),
            if (_insights.isNotEmpty) ...[
              _buildInsightsSection(context),
              const SizedBox(height: 12),
              if (_alerts.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildAlertsSection(context),
              ],
            ],
            const SizedBox(height: 24),
            if (profitLoss.byProduct.isNotEmpty) ...[
              Text(
                'Ganancias por Producto',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildProductProfitList(context, profitLoss),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context, ProfitLoss profitLoss) {
    final isProfit = profitLoss.grossProfit >= 0;
    final profitColor = isProfit ? Colors.green : Colors.red;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ganancia Bruta',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                isProfit ? Icons.trending_up : Icons.trending_down,
                color: profitColor,
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                '\$${profitLoss.grossProfit.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryMetric(
                context,
                'Ingresos',
                '\$${profitLoss.totalRevenue.toStringAsFixed(2)}',
              ),
              _buildSummaryMetric(
                context,
                'Costos',
                '\$${profitLoss.totalCost.toStringAsFixed(2)}',
              ),
              _buildSummaryMetric(
                context,
                'Margen',
                '${profitLoss.grossMarginPercent.toStringAsFixed(1)}%',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryMetric(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.white70),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsGrid(BuildContext context, ProfitLoss profitLoss) {
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 1.2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildMetricCard(
          context,
          icon: Icons.shopping_cart_outlined,
          label: 'Ventas Realizadas',
          value: profitLoss.salesCount.toString(),
          color: Theme.of(context).colorScheme.primary,
        ),
        _buildMetricCard(
          context,
          icon: Icons.inventory_2_outlined,
          label: 'Productos Vendidos',
          value: profitLoss.totalItemsSold.toString(),
          color: Theme.of(context).colorScheme.secondary,
        ),
        _buildMetricCard(
          context,
          icon: Icons.attach_money,
          label: 'Ticket Promedio',
          value: '\$${profitLoss.averageTicket.toStringAsFixed(2)}',
          color: Colors.orange,
        ),

        _buildMetricCard(
          context,
          icon: Icons.trending_up,
          label: 'Ganancia por Venta',
          value: '\$${profitLoss.averageProfitPerSale.toStringAsFixed(2)}',
          color: Colors.green,
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductProfitList(BuildContext context, ProfitLoss profitLoss) {
    final sortedProducts = profitLoss.byProduct.values.toList()
      ..sort((a, b) => b.profit.compareTo(a.profit));

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedProducts.length,
      itemBuilder: (context, index) {
        final product = sortedProducts[index];
        final profitMargin = product.revenue > 0
            ? (product.profit / product.revenue) * 100
            : 0.0;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        product.productName ?? 'Producto #${product.productId}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: product.profit >= 0
                            ? Colors.green.withValues(alpha: 0.2)
                            : Colors.red.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '\$${product.profit.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: product.profit >= 0
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildProductStat(
                        'Vendido',
                        '${product.quantity}',
                        context,
                      ),
                    ),
                    Expanded(
                      child: _buildProductStat(
                        'Ingresos',
                        '\$${product.revenue.toStringAsFixed(2)}',
                        context,
                      ),
                    ),
                    Expanded(
                      child: _buildProductStat(
                        'Costos',
                        '\$${product.cost.toStringAsFixed(2)}',
                        context,
                      ),
                    ),
                    Expanded(
                      child: _buildProductStat(
                        'Margen',
                        '${profitMargin.toStringAsFixed(1)}%',
                        context,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductStat(String label, String value, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey, fontSize: 11),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildInsightsSection(BuildContext context) {
    final mostSold = _insights.isEmpty
        ? null
        : _insights.reduce((a, b) => b.quantity > a.quantity ? b : a);
    final mostProfitable = _insights.isEmpty
        ? null
        : _insights.reduce((a, b) => b.profit > a.profit ? b : a);
    final negativeProducts = _insights
        .where((insight) => insight.profit < 0)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Análisis',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildInsightCard(
              context,
              label: 'Más vendido',
              title: mostSold?.productName ?? 'Sin datos',
              value: mostSold != null ? '${mostSold.quantity} uds' : '-',
              color: Colors.blue,
            ),
            _buildInsightCard(
              context,
              label: 'Más rentable',
              title: mostProfitable?.productName ?? 'Sin datos',
              value: mostProfitable != null
                  ? '\$${mostProfitable.profit.toStringAsFixed(2)}'
                  : '-',
              color: Colors.green,
            ),
            _buildInsightCard(
              context,
              label: 'Margen negativo',
              title: negativeProducts.isEmpty
                  ? 'Ninguno'
                  : negativeProducts.first.productName,
              value: negativeProducts.isEmpty
                  ? '0'
                  : '${negativeProducts.length} productos',
              color: negativeProducts.isEmpty ? Colors.grey : Colors.red,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInsightCard(
    BuildContext context, {
    required String label,
    required String title,
    required String value,
    required Color color,
  }) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 2.3,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlertsSection(BuildContext context) {
    Color severityColor(AlertSeverity severity) {
      switch (severity) {
        case AlertSeverity.critical:
          return Colors.red;
        case AlertSeverity.warning:
          return Colors.orange;
        case AlertSeverity.info:
          return Colors.blue;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alertas',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Column(
          children: _alerts
              .map(
                (alert) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: _buildAlertTile(
                    context,
                    alert,
                    severityColor(alert.severity),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildAlertTile(BuildContext context, AlertRule alert, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(
            alert.severity == AlertSeverity.critical
                ? Icons.error
                : alert.severity == AlertSeverity.warning
                ? Icons.warning
                : Icons.info,
            color: color,
          ),
        ),
        title: Text(
          alert.title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(alert.message),
      ),
    );
  }

  Widget _filterChip(String label, SalesFilter filter) {
    final isSelected = _currentFilter.type == filter.type;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: ActionChip(
        label: Text(
          label,
          style: TextStyle(color: isSelected ? Colors.white : null),
        ),
        backgroundColor: isSelected ? Colors.blue : null,
        onPressed: () {
          setState(() {
            _currentFilter = filter;
          });
          _loadFinances();
        },
      ),
    );
  }

  Widget _buildCustomFilterChip() {
    final isSelected = _currentFilter.type == SalesTimeFilterType.custom;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: ActionChip(
        label: Text(
          'Personalizado',
          style: TextStyle(color: isSelected ? Colors.white : null),
        ),
        backgroundColor: isSelected ? Colors.blue : null,
        onPressed: () {
          _selectCustomRange(context);
        },
      ),
    );
  }

  Future<void> _selectCustomRange(BuildContext context) async {
    final now = DateTime.now();
    final initialRange =
        _customRange ??
        DateTimeRange(start: now.subtract(const Duration(days: 30)), end: now);

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 1, 1, 1),
      lastDate: now,
      initialDateRange: initialRange,
    );

    if (picked == null) return;

    setState(() {
      _customRange = picked;
      _currentFilter = SalesFilter.custom(
        DateTime(picked.start.year, picked.start.month, picked.start.day),
        DateTime(
          picked.end.year,
          picked.end.month,
          picked.end.day,
        ).add(const Duration(days: 1)),
      );
    });

    await _loadFinances();
  }

  Widget _buildFilterBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _filterChip("Hoy", SalesFilter.day(DateTime.now())),
          _filterChip("Mes", SalesFilter.month(DateTime.now())),
          _filterChip("Año", SalesFilter.year(DateTime.now())),
          _buildCustomFilterChip(),
        ],
      ),
    );
  }
}
