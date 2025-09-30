class SalesReport {
  final DateTime date;
  final double totalSales;
  final int totalOrders;
  final double totalProfit;
  final Map<String, double> salesByCategory;
  final Map<String, int> topProducts;

  SalesReport({
    required this.date,
    required this.totalSales,
    required this.totalOrders,
    required this.totalProfit,
    required this.salesByCategory,
    required this.topProducts,
  });
}

class InventoryReport {
  final DateTime date;
  final int totalProducts;
  final int lowStockProducts;
  final int outOfStockProducts;
  final double totalInventoryValue;
  final List<Map<String, dynamic>> lowStockItems;

  InventoryReport({
    required this.date,
    required this.totalProducts,
    required this.lowStockProducts,
    required this.outOfStockProducts,
    required this.totalInventoryValue,
    required this.lowStockItems,
  });
}

class CustomerReport {
  final DateTime date;
  final int totalCustomers;
  final int activeCustomers;
  final double totalCreditBalance;
  final List<Map<String, dynamic>> topCustomers;

  CustomerReport({
    required this.date,
    required this.totalCustomers,
    required this.activeCustomers,
    required this.totalCreditBalance,
    required this.topCustomers,
  });
}
