import 'package:flutter/material.dart';
import '../models/order.dart';
import 'new_order_screen.dart';
import '../models/shelf.dart';
import 'order_detail_screen.dart';

class OrdersView extends StatefulWidget {
  final List<Order> orders;
  final Function(String screen, [String? orderId]) onNavigate;
  final String? initialFilter;
  final List<Shelf> shelves;
  final Function(Map<String, dynamic>) onSaveOrder;
  final VoidCallback onRefresh;

  const OrdersView({
    super.key,
    required this.orders,
    required this.onNavigate,
    this.initialFilter,
    this.shelves = const [],
    required this.onSaveOrder,
    required this.onRefresh,
  });

  @override
  State<OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends State<OrdersView> {
  String searchQuery = '';
  late String selectedStatusFilter;
  late List<Order> _localOrders;
  int _refreshCounter = 0;

  @override
  void initState() {
    super.initState();
    selectedStatusFilter = widget.initialFilter ?? 'Todos';
    _localOrders = List.from(widget.orders);
  }

  @override
  void didUpdateWidget(OrdersView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.orders != oldWidget.orders) {
      setState(() {
        _localOrders = List.from(widget.orders);
        _refreshCounter++;
      });
    }
  }

  List<Order> get filteredOrders {
    return _localOrders.where((order) {
      final matchQuery =
          order.clientName.toLowerCase().contains(searchQuery.toLowerCase()) ||
          order.id.toLowerCase().contains(searchQuery.toLowerCase()) ||
          order.title.toLowerCase().contains(searchQuery.toLowerCase());

      if (selectedStatusFilter == 'Todos') {
        return matchQuery;
      }

      return matchQuery && order.status == selectedStatusFilter;
    }).toList();
  }

  void showToast(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  Color statusColor(String status) {
    switch (status) {
      case 'En proceso':
        return const Color(0xFF8B5CF6);
      case 'Terminado':
        return const Color(0xFF10B981);
      case 'Entregado':
        return const Color(0xFF3B82F6);
      case 'Atrasado':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  String statusIcon(String status) {
    switch (status) {
      case 'En proceso':
        return '⏳';
      case 'Terminado':
        return '✅';
      case 'Entregado':
        return '📦';
      case 'Atrasado':
        return '⚠️';
      default:
        return '📋';
    }
  }

  @override
  Widget build(BuildContext context) {
    final chips = [
      {'label': 'Todos', 'count': _localOrders.length},
      {
        'label': 'En proceso',
        'count': _localOrders.where((o) => o.status == 'En proceso').length,
      },
      {
        'label': 'Terminado',
        'count': _localOrders.where((o) => o.status == 'Terminado').length,
      },
      {
        'label': 'Atrasado',
        'count': _localOrders.where((o) => o.status == 'Atrasado').length,
      },
      {
        'label': 'Entregado',
        'count': _localOrders.where((o) => o.status == 'Entregado').length,
      },
    ];

    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 900 ? 4 : 2; // 4 en pantallas grandes, 2 en pequeñas

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          "Pedidos",
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Color(0xFF475569),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// HEADER
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Buscar cliente o pedido...",
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                        ),
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  height: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF6366F1),
                        Color(0xFF8B5CF6),
                      ],
                    ),
                  ),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      showToast("¡Exportación CSV iniciada!");
                    },
                    icon: const Icon(Icons.download),
                    label: const Text(
                      "Exportar",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            /// TÍTULO
            const Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Lista de Órdenes",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF102A43),
                    ),
                  ),
                  Text(
                    "Administra las fichas técnicas y estados de entrega",
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            /// FILTROS
            SizedBox(
              height: 45,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: chips.length,
                itemBuilder: (context, index) {
                  final chip = chips[index];
                  final isSelected = selectedStatusFilter == chip['label'];
                  final count = chip['count'] as int;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      selected: isSelected,
                      label: Text(
                        "${chip['label']} $count",
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 14,
                          color: isSelected ? Colors.white : const Color(0xFF475569),
                        ),
                      ),
                      selectedColor: const Color(0xFF6D3EFF),
                      backgroundColor: Colors.white,
                      side: BorderSide(
                        color: isSelected ? const Color(0xFF6D3EFF) : Colors.grey.shade300,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      onSelected: (_) {
                        setState(() {
                          selectedStatusFilter = chip['label'] as String;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),

            /// GRID - 4 columnas en pantallas grandes
            Expanded(
              child: GridView.builder(
                key: ValueKey('$_refreshCounter-${_localOrders.length}'),
                itemCount: filteredOrders.length + 1,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.75, // Más compacto
                ),
                itemBuilder: (context, index) {
                  /// TARJETA NUEVA ORDEN - Más pequeña
                  if (index == filteredOrders.length) {
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => NewOrderScreen(
                              shelves: widget.shelves,
                              onSaveOrder: widget.onSaveOrder,
                            ),
                          ),
                        ).then((_) {
                          widget.onRefresh();
                        });
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 2,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6D3EFF).withOpacity(.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Color(0xFF6D3EFF),
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Nueva Orden",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color(0xFF102A43),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Registrar cliente",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final order = filteredOrders[index];
                  final isAtrasado = order.status == 'Atrasado';
                  final isPaid = order.balanceDue == 0;
                  final isEnProceso = order.status == 'En proceso';

                  /// TARJETA DE PEDIDO - Más pequeña y compacta
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrderDetailScreen(
                            order: order,
                            onOrderUpdated: (updatedOrder) {
                              setState(() {
                                final index = _localOrders.indexWhere((o) => o.id == updatedOrder.id);
                                if (index != -1) {
                                  _localOrders[index] = updatedOrder;
                                }
                                _refreshCounter++;
                              });
                              widget.onSaveOrder(updatedOrder.toJson());
                              widget.onRefresh();
                            },
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.05),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// HEADER - Más compacto
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor(order.status).withOpacity(.08),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  order.id,
                                  style: const TextStyle(
                                    color: Color(0xFF102A43),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor(order.status),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        statusIcon(order.status),
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        order.status.toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 8,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          /// CONTENIDO - Más compacto
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    order.clientName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Color(0xFF102A43),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    order.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.person_outline,
                                              size: 12,
                                              color: Color(0xFF64748B),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              order.size,
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: Color(0xFF64748B),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Container(
                                              width: 2,
                                              height: 2,
                                              decoration: const BoxDecoration(
                                                color: Color(0xFF64748B),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            const Icon(
                                              Icons.shelves,
                                              size: 12,
                                              color: Color(0xFF64748B),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              order.shelfAssignment,
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: Color(0xFF64748B),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.calendar_today,
                                              size: 12,
                                              color: Color(0xFF64748B),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              isAtrasado
                                                  ? "Vencido: ${order.expectedDeliveryDate}"
                                                  : "Entrega: ${order.expectedDeliveryDate}",
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: isAtrasado
                                                    ? Colors.red
                                                    : const Color(0xFF64748B),
                                                fontWeight: isAtrasado
                                                    ? FontWeight.w600
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isPaid
                                              ? Colors.green.withOpacity(.12)
                                              : Colors.orange.withOpacity(.12),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          isPaid
                                              ? "Pagado"
                                              : "\$${order.balanceDue}",
                                          style: TextStyle(
                                            color: isPaid ? Colors.green : Colors.orange,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                      if (isAtrasado)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.red.withOpacity(.12),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Text(
                                            "Vencido",
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 9,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          /// FOOTER - Más compacto
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (order.status == 'Terminado') {
                                        showToast(
                                          "Notificación enviada a ${order.clientName}",
                                        );
                                      } else {
                                        widget.onNavigate(
                                          'status_management',
                                          order.id,
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isEnProceso
                                          ? const Color(0xFF8B5CF6)
                                          : order.status == 'Atrasado'
                                              ? Colors.red
                                              : const Color(0xFF10B981),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 6,
                                      ),
                                      minimumSize: const Size(0, 30),
                                    ),
                                    child: Text(
                                      order.status == 'Terminado'
                                          ? 'Notificar'
                                          : isAtrasado
                                              ? 'Prioridad'
                                              : 'Actualizar',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}