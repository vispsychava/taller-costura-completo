import 'package:flutter/material.dart';
import '../models/order.dart';
import '../models/shelf.dart';
import 'add_shelf_screen.dart';

class ShelfCatalogScreen extends StatefulWidget {
  final List<Shelf> shelves;
  final List<Order> orders;
  final Function(String orderId) onNavigateToOrderDetail;
  final Function(List<Shelf>) onShelvesUpdated;

  const ShelfCatalogScreen({
    super.key,
    required this.shelves,
    required this.orders,
    required this.onNavigateToOrderDetail,
    required this.onShelvesUpdated,
  });

  @override
  State<ShelfCatalogScreen> createState() => _ShelfCatalogScreenState();
}

class _ShelfCatalogScreenState extends State<ShelfCatalogScreen> {
  late List<Shelf> _shelves;
  late List<Order> _orders;

  @override
  void initState() {
    super.initState();
    _shelves = List.from(widget.shelves);
    _orders = List.from(widget.orders);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateShelfCounts();
    });
  }

  @override
  void didUpdateWidget(ShelfCatalogScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.orders != oldWidget.orders || widget.shelves != oldWidget.shelves) {
      _shelves = List.from(widget.shelves);
      _orders = List.from(widget.orders);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateShelfCounts();
      });
    }
  }

  /// ✅ Actualizar el conteo de prendas en cada estante basado en los pedidos activos
  void _updateShelfCounts() {
    // Contar cuántos pedidos activos hay en cada estante
    final Map<String, int> shelfCounts = {};
    
    // Inicializar todos los estantes con 0
    for (var shelf in _shelves) {
      shelfCounts[shelf.id] = 0;
    }
    
    // Contar pedidos activos (no entregados) por estante
    for (var order in _orders) {
      if (order.status != "Entregado") {
        final shelfId = order.shelfAssignment;
        if (shelfCounts.containsKey(shelfId)) {
          shelfCounts[shelfId] = (shelfCounts[shelfId] ?? 0) + 1;
        }
      }
    }
    
    // Actualizar cada estante con su nuevo conteo y estado
    bool hasChanges = false;
    for (int i = 0; i < _shelves.length; i++) {
      final shelf = _shelves[i];
      final count = shelfCounts[shelf.id] ?? 0;
      
      // Solo actualizar si hay cambios
      if (shelf.garmentsCount != count) {
        hasChanges = true;
        _shelves[i] = Shelf(
          id: shelf.id,
          capacity: shelf.capacity,
          garmentsCount: count,
          status: _getStatusFromCount(count, shelf.capacity),
          lastActivity: count > 0 
              ? '${count} prenda${count > 1 ? 's' : ''} en almacenamiento'
              : 'Estante vacío',
        );
      }
    }
    
    // ✅ Solo notificar si hubo cambios
    if (hasChanges) {
      widget.onShelvesUpdated(_shelves);
    }
  }

  /// ✅ Calcular el estado del estante según el porcentaje de ocupación
  String _getStatusFromCount(int count, int capacity) {
    if (count == 0) return "Open";
    final percentage = count / capacity;
    if (percentage >= 1.0) return "Full";
    if (percentage >= 0.75) return "Near Full";
    return "Open";
  }

  void openShelf(Shelf shelf) {
    final activeOrders = _orders.where(
      (o) => o.shelfAssignment == shelf.id && o.status != "Entregado",
    ).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Container(
          height: MediaQuery.of(context).size.height * .75,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Estante ${shelf.id}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff102A43),
                        ),
                      ),
                      Text(
                        "${activeOrders.length} de ${shelf.capacity} prendas almacenadas",
                        style: const TextStyle(
                          color: Color(0xff64748B),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Expanded(
                child: activeOrders.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.layers,
                              size: 60,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Este estante está vacío",
                              style: TextStyle(
                                color: Color(0xff64748B),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: activeOrders.length,
                        itemBuilder: (context, index) {
                          final ord = activeOrders[index];
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              title: Text(
                                ord.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff102A43),
                                ),
                              ),
                              subtitle: Text(
                                "Cliente: ${ord.clientName}",
                                style: const TextStyle(
                                  color: Color(0xff64748B),
                                ),
                              ),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Color(0xff829AB1),
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                widget.onNavigateToOrderDetail(ord.id);
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addShelf(Shelf newShelf) {
    setState(() {
      _shelves.add(newShelf);
    });
    widget.onShelvesUpdated(_shelves);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Estante ${newShelf.id} creado correctamente'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Color statusColor(String status) {
    switch (status) {
      case "Open":
        return Colors.green;
      case "Near Full":
        return Colors.orange;
      case "Full":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _statChip(String text, Color textColor, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalShelves = _shelves.length;
    final availableCount = _shelves.where((s) => s.status == "Open").length;
    final nearCount = _shelves.where((s) => s.status == "Near Full").length;
    final fullCount = _shelves.where((s) => s.status == "Full").length;

    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xff6D3EFF),
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddShelfScreen(
                onAddShelf: _addShelf,
              ),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text(
          "Agregar Estante",
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            /// HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xffE5E7EB),
                  ),
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Organizador de Estantes",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff0F172A),
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Control de almacenamiento de prendas del taller",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xff94A3B8),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    /// RESUMEN
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _statChip(
                          "ESTANTES TOTALES: $totalShelves",
                          const Color(0xff6D3EFF),
                          const Color(0xffEEF2FF),
                        ),
                        _statChip(
                          "DISPONIBLES: $availableCount",
                          const Color(0xff15803D),
                          const Color(0xffDCFCE7),
                        ),
                        _statChip(
                          "CASI LLENOS: $nearCount",
                          const Color(0xffD97706),
                          const Color(0xffFEF3C7),
                        ),
                        _statChip(
                          "SATURADOS: $fullCount",
                          const Color(0xffDC2626),
                          const Color(0xffFEE2E2),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0xffE5E7EB),
                        ),
                      ),
                      child: const Text(
                        "💡 Puedes pulsar sobre cualquier estante del taller para visualizar las prendas asignadas.",
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xff64748B),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _shelves.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.05,
                      ),
                      itemBuilder: (context, index) {
                        final shelf = _shelves[index];
                        final usagePercent = shelf.capacity > 0 
                            ? shelf.garmentsCount / shelf.capacity 
                            : 0.0;

                        return InkWell(
                          onTap: () => openShelf(shelf),
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: const Color(0xffE5E7EB),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(.04),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      shelf.id,
                                      style: const TextStyle(
                                        fontSize: 42,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff0F172A),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: statusColor(shelf.status).withOpacity(.12),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: Text(
                                        shelf.status.toUpperCase(),
                                        style: TextStyle(
                                          color: statusColor(shelf.status),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 25),
                                Text(
                                  "Capacidad",
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const SizedBox(),
                                    Text(
                                      "${shelf.garmentsCount}/${shelf.capacity} prendas",
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff102A43),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: LinearProgressIndicator(
                                    value: usagePercent > 1.0 ? 1.0 : usagePercent,
                                    minHeight: 12,
                                    color: statusColor(shelf.status),
                                    backgroundColor: Colors.grey.shade200,
                                  ),
                                ),
                                const Spacer(),
                                Divider(
                                  color: Colors.grey.shade200,
                                ),
                                Text(
                                  shelf.lastActivity,
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}