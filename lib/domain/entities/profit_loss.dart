class ProfitLoss {
  final double totalRevenue;
  final double totalCost;
  final double grossProfit;
  final double grossMarginPercent;
  final int totalItemsSold;
  final int salesCount;
  final Map<int, ProductProfit> byProduct;

  const ProfitLoss({
    required this.totalRevenue,
    required this.totalCost,
    required this.grossProfit,
    required this.grossMarginPercent,
    required this.totalItemsSold,
    required this.salesCount,
    required this.byProduct,
  });
}

class ProductProfit {
  final int productId;
  final String? productName;
  final int quantity;
  final double revenue;
  final double cost;
  final double profit;

  const ProductProfit({
    required this.productId,
    this.productName,
    required this.quantity,
    required this.revenue,
    required this.cost,
    required this.profit,
  });
}
