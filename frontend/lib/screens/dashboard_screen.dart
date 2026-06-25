import 'package:flutter/material.dart';
import '../models/order.dart';
import '../models/reminder.dart';
import 'new_order_screen.dart';
import '../models/shelf.dart';
import 'orders_screen.dart';
import 'shelf_catalog_screen.dart';
import 'settings_screen.dart';
import 'reminders_screen.dart';
import 'order_detail_screen.dart'; // ✅ IMPORTAR OrderDetailScreen
import '../models/measurements.dart';
import '../models/progress_note.dart';
import '../models/activity_item.dart';

class DashboardScreen extends StatefulWidget {
  final List<Order> orders;
  final List<Reminder> reminders;
  final List<Shelf> shelves;

  const DashboardScreen({
    super.key,
    required this.orders,
    required this.reminders,
    required this.shelves,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int notificationsCount = 3;
  late List<Order> _orders;
  late List<Shelf> _shelves;
  
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _showSuggestions = false;
  List<Order> _suggestions = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _orders = List.from(widget.orders);
    _shelves = List.from(widget.shelves);
    _updateShelvesFromOrders();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
        _searchQuery = '';
      });
      return;
    }

    setState(() {
      _searchQuery = query;
      _suggestions = _orders.where((order) {
        return order.clientName.toLowerCase().contains(query) ||
            order.id.toLowerCase().contains(query) ||
            order.title.toLowerCase().contains(query);
      }).toList();
      _showSuggestions = true;
    });
  }

  void _performSearch() {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return;

    final results = _orders.where((order) {
      return order.clientName.toLowerCase().contains(query) ||
          order.id.toLowerCase().contains(query) ||
          order.title.toLowerCase().contains(query);
    }).toList();

    setState(() {
      _showSuggestions = false;
      _searchController.text = '';
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrdersView(
          orders: results.isEmpty ? _orders : results,
          onNavigate: (screen, [orderId]) {
            print("Pantalla: $screen");
            if (orderId != null) {
              print("Pedido: $orderId");
            }
          },
          initialFilter: 'Todos',
          shelves: _shelves,
          onSaveOrder: _saveOrder,
          onRefresh: () {
            setState(() {
              _orders = List.from(_orders);
              _updateShelvesFromOrders();
            });
          },
        ),
      ),
    );
  }

  void _selectSuggestion(Order order) {
    setState(() {
      _showSuggestions = false;
      _searchController.text = '';
      _suggestions = [];
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrdersView(
          orders: _orders,
          onNavigate: (screen, [orderId]) {
            print("Pantalla: $screen");
            if (orderId != null) {
              print("Pedido: $orderId");
            }
          },
          initialFilter: 'Todos',
          shelves: _shelves,
          onSaveOrder: _saveOrder,
          onRefresh: () {
            setState(() {
              _orders = List.from(_orders);
              _updateShelvesFromOrders();
            });
          },
        ),
      ),
    );
  }

  List<MapEntry<String, dynamic>> get upcomingEvents {
    List<MapEntry<String, dynamic>> events = [];
    
    for (var reminder in widget.reminders) {
      if (!reminder.isCompleted) {
        events.add(MapEntry('reminder', reminder));
      }
    }
    
    for (var order in _orders) {
      if (order.status != "Entregado") {
        events.add(MapEntry('order', order));
      }
    }
    
    events.sort((a, b) {
      DateTime dateA;
      DateTime dateB;
      
      if (a.key == 'reminder') {
        dateA = (a.value as Reminder).dateTime;
      } else {
        dateA = _parseDate((a.value as Order).expectedDeliveryDate);
      }
      
      if (b.key == 'reminder') {
        dateB = (b.value as Reminder).dateTime;
      } else {
        dateB = _parseDate((b.value as Order).expectedDeliveryDate);
      }
      
      return dateA.compareTo(dateB);
    });
    
    return events.take(3).toList();
  }

  DateTime _parseDate(String dateStr) {
    try {
      final parts = dateStr.split('/');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
    } catch (e) {}
    return DateTime.now().add(const Duration(days: 7));
  }

  String _getStatusFromCount(int count, int capacity) {
    if (count == 0) return "Open";
    final percentage = count / capacity;
    if (percentage >= 1.0) return "Full";
    if (percentage >= 0.75) return "Near Full";
    return "Open";
  }

  void _updateShelvesFromOrders() {
    final Map<String, int> shelfCounts = {};
    for (var shelf in _shelves) {
      shelfCounts[shelf.id] = 0;
    }
    for (var order in _orders) {
      if (order.status != "Entregado") {
        final shelfId = order.shelfAssignment;
        if (shelfCounts.containsKey(shelfId)) {
          shelfCounts[shelfId] = (shelfCounts[shelfId] ?? 0) + 1;
        }
      }
    }
    
    for (int i = 0; i < _shelves.length; i++) {
      final shelf = _shelves[i];
      final count = shelfCounts[shelf.id] ?? 0;
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

  void _saveOrder(Map<String, dynamic> orderData) {
    setState(() {
      final existingIndex = _orders.indexWhere((o) => o.id == orderData['id']);
      
      List<ProgressNote> progressNotes = [];
      if (orderData['progressNotes'] != null) {
        progressNotes = (orderData['progressNotes'] as List)
            .map((e) => ProgressNote(
                  id: e['id'] ?? '',
                  note: e['note'] ?? '',
                  date: DateTime.parse(e['date'] ?? DateTime.now().toIso8601String()),
                  author: e['author'] ?? '',
                ))
            .toList();
      }

      List<ActivityItem> activityHistory = [];
      if (orderData['activityHistory'] != null) {
        activityHistory = (orderData['activityHistory'] as List)
            .map((e) => ActivityItem(
                  id: e['id'] ?? '',
                  action: e['action'] ?? '',
                  description: e['description'] ?? '',
                  date: DateTime.parse(e['date'] ?? DateTime.now().toIso8601String()),
                  userId: e['userId'] ?? '',
                ))
            .toList();
      }

      Measurements measurements;
      if (orderData['measurements'] != null) {
        measurements = Measurements.fromJson(orderData['measurements']);
      } else {
        measurements = Measurements.empty();
      }
      
      if (existingIndex != -1) {
        final updatedOrder = Order(
          id: orderData['id'],
          clientName: orderData['clientName'],
          clientPhone: orderData['clientPhone'] ?? '',
          clientEmail: orderData['clientEmail'] ?? '',
          clientAvatar: orderData['clientAvatar'] ?? '',
          title: orderData['title'],
          description: orderData['description'] ?? '',
          type: orderData['type'] ?? orderData['garmentType'] ?? 'vestido',
          size: orderData['size'],
          status: orderData['status'],
          statusDate: orderData['statusDate'] ?? DateTime.now().toIso8601String(),
          expectedDeliveryDate: orderData['expectedDeliveryDate'],
          totalAmount: orderData['totalAmount'] ?? 0,
          advancePaid: orderData['advancePaid'] ?? 0,
          balanceDue: orderData['balanceDue'] ?? 0,
          shelfAssignment: orderData['shelfAssignment'],
          measurements: measurements,
          progressNotes: progressNotes,
          activityHistory: activityHistory,
          priority: orderData['priority'] ?? 'Media',
        );
        _orders[existingIndex] = updatedOrder;
      } else {
        final newOrder = Order(
          id: orderData['id'],
          clientName: orderData['clientName'],
          clientPhone: orderData['clientPhone'] ?? '',
          clientEmail: orderData['clientEmail'] ?? '',
          clientAvatar: orderData['clientAvatar'] ?? '',
          title: orderData['title'],
          description: orderData['description'] ?? '',
          type: orderData['type'] ?? orderData['garmentType'] ?? 'vestido',
          size: orderData['size'],
          status: orderData['status'],
          statusDate: orderData['statusDate'] ?? DateTime.now().toIso8601String(),
          expectedDeliveryDate: orderData['expectedDeliveryDate'],
          totalAmount: orderData['totalAmount'] ?? 0,
          advancePaid: orderData['advancePaid'] ?? 0,
          balanceDue: orderData['balanceDue'] ?? 0,
          shelfAssignment: orderData['shelfAssignment'],
          measurements: measurements,
          progressNotes: progressNotes,
          activityHistory: activityHistory,
          priority: orderData['priority'] ?? 'Media',
        );
        _orders.add(newOrder);
      }
      
      _updateShelvesFromOrders();
    });
  }

  void _updateShelves(List<Shelf> updatedShelves) {
    setState(() {
      _shelves = updatedShelves;
    });
  }

  void _navigateToOrdersWithFilter(String filter) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrdersView(
          orders: _orders,
          onNavigate: (screen, [orderId]) {
            print("Pantalla: $screen");
            if (orderId != null) {
              print("Pedido: $orderId");
            }
          },
          initialFilter: filter,
          shelves: _shelves,
          onSaveOrder: _saveOrder,
          onRefresh: () {
            setState(() {
              _orders = List.from(_orders);
              _updateShelvesFromOrders();
            });
          },
        ),
      ),
    );
  }

  void _navigateToReminders() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RemindersScreen(
          reminders: widget.reminders,
          orders: _orders,
          onAddReminder: (title, client) {
            print("Agregar recordatorio: $title - $client");
          },
          onCheckReminder: (id) {
            print("Completar recordatorio: $id");
          },
          shelves: _shelves,
          onSaveOrder: _saveOrder,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount = _orders
        .where((o) => o.status == 'Sin empezar')
        .length;

    final processCount = _orders
        .where((o) => o.status == 'En proceso')
        .length;

    final finishedCount = _orders
        .where((o) => o.status == 'Terminado')
        .length;

    final deliveredCount = _orders
        .where((o) => o.status == 'Entregado')
        .length;

    final events = upcomingEvents;

    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NewOrderScreen(
                shelves: _shelves,
                onSaveOrder: _saveOrder,
              ),
            ),
          );
        },
        backgroundColor: const Color(0xff6D3EFF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Buenos días, Doña Tere",
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: Color(0xff102A43),
                        ),
                      ),
                      Text(
                        "¡Lista para un día creativo en el taller!",
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xff64748B),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications_none, size: 28),
                            onPressed: () {},
                          ),
                          Positioned(
                            right: 10,
                            top: 10,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Color(0xff8B5CF6),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.settings_outlined, size: 28),
                        color: const Color(0xff64748B),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SettingsScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              /// BARRA DE BÚSQUEDA
              Container(
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
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      decoration: InputDecoration(
                        hintText: "Buscar cliente o pedido...",
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xff829AB1),
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 20),
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                    _suggestions = [];
                                    _showSuggestions = false;
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      onSubmitted: (_) => _performSearch(),
                    ),
                    
                    if (_showSuggestions && _suggestions.isNotEmpty)
                      Container(
                        constraints: const BoxConstraints(
                          maxHeight: 200,
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                          itemCount: _suggestions.length > 5 ? 5 : _suggestions.length,
                          itemBuilder: (context, index) {
                            final order = _suggestions[index];
                            return ListTile(
                              dense: true,
                              leading: const Icon(
                                Icons.receipt_long,
                                size: 18,
                                color: Color(0xff6D3EFF),
                              ),
                              title: Text(
                                order.clientName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xff102A43),
                                ),
                              ),
                              subtitle: Text(
                                '${order.id} • ${order.title}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              trailing: Chip(
                                label: Text(
                                  order.status,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                backgroundColor: statusColor(order.status).withOpacity(.12),
                                labelStyle: TextStyle(
                                  color: statusColor(order.status),
                                ),
                              ),
                              onTap: () => _selectSuggestion(order),
                            );
                          },
                        ),
                      ),
                    
                    if (_showSuggestions && _suggestions.isEmpty && _searchQuery.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 20,
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 40,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No se encontraron pedidos para "$_searchQuery"',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            TextButton(
                              onPressed: _performSearch,
                              child: const Text(
                                'Ver todos los resultados',
                                style: TextStyle(
                                  color: Color(0xff6D3EFF),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              /// MÉTRICAS
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _metricCard(
                    "Pendientes",
                    pendingCount.toString(),
                    Icons.access_time,
                    const Color(0xff6366F1),
                    () => _navigateToOrdersWithFilter('Sin empezar'),
                  ),
                  _metricCard(
                    "En Proceso",
                    processCount.toString(),
                    Icons.trending_up,
                    const Color(0xffF59E0B),
                    () => _navigateToOrdersWithFilter('En proceso'),
                  ),
                  _metricCard(
                    "Terminados",
                    finishedCount.toString(),
                    Icons.check_circle,
                    const Color(0xff10B981),
                    () => _navigateToOrdersWithFilter('Terminado'),
                  ),
                  _metricCard(
                    "Entregados",
                    deliveredCount.toString(),
                    Icons.local_shipping,
                    const Color(0xff3B82F6),
                    () => _navigateToOrdersWithFilter('Entregado'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              /// PANEL DE CONTROL
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.05),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Panel de Control",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff102A43),
                        ),
                      ),
                      const SizedBox(height: 20),

                      GridView.count(
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        children: [
                          _actionButton(
                            "Nuevo Pedido",
                            Icons.add,
                            const Color(0xff6D3EFF),
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => NewOrderScreen(
                                    shelves: _shelves,
                                    onSaveOrder: _saveOrder,
                                  ),
                                ),
                              );
                            },
                            true,
                          ),
                          _actionButton(
                            "Ver Pedidos",
                            Icons.list_alt,
                            const Color(0xff475569),
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => OrdersView(
                                    orders: _orders,
                                    onNavigate: (screen, [orderId]) {
                                      print("Pantalla: $screen");
                                      if (orderId != null) {
                                        print("Pedido: $orderId");
                                      }
                                    },
                                    shelves: _shelves,
                                    onSaveOrder: _saveOrder,
                                    onRefresh: () {
                                      setState(() {
                                        _orders = List.from(_orders);
                                        _updateShelvesFromOrders();
                                      });
                                    },
                                  ),
                                ),
                              );
                            },
                            false,
                          ),
                          _actionButton(
                            "Estantes Taller",
                            Icons.grid_view,
                            const Color(0xff6D3EFF),
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ShelfCatalogScreen(
                                    shelves: _shelves,
                                    orders: _orders,
                                    onNavigateToOrderDetail: (orderId) {
                                      print("Abrir pedido: $orderId");
                                    },
                                    onShelvesUpdated: _updateShelves,
                                  ),
                                ),
                              );
                            },
                            false,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              /// PRÓXIMOS RECORDATORIOS
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.04),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Próximos Recordatorios",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff102A43),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    if (events.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            "No hay recordatorios pendientes",
                            style: TextStyle(
                              color: Color(0xff829AB1),
                            ),
                          ),
                        ),
                      )
                    else
                      ...events.map((entry) {
                        if (entry.key == 'reminder') {
                          final reminder = entry.value as Reminder;
                          return _reminderCard(reminder);
                        } else {
                          final order = entry.value as Order;
                          return _orderCard(order);
                        }
                      }),
                    
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: _navigateToReminders,
                        child: const Text(
                          "Ver Calendario Completo →",
                          style: TextStyle(
                            color: Color(0xff6D3EFF),
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
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

  Widget _metricCard(
    String title,
    String value,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: MediaQuery.of(context).size.width / 2 - 24,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.04),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: color.withOpacity(.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    color: Colors.blueGrey.shade300,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff102A43),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(
    String text,
    IconData icon,
    Color color,
    VoidCallback onTap,
    bool isPrimary,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: isPrimary
              ? const LinearGradient(
                  colors: [
                    Color(0xff6D3EFF),
                    Color(0xff4F2FFF),
                  ],
                )
              : null,
          color: isPrimary ? null : Colors.white,
          border: Border.all(
            color: isPrimary ? Colors.transparent : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.04),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: isPrimary ? Colors.white : color,
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isPrimary
                      ? Colors.white
                      : const Color(0xff23395B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _reminderCard(Reminder reminder) {
    final today = DateTime.now();
    final isToday = reminder.dateTime.year == today.year &&
        reminder.dateTime.month == today.month &&
        reminder.dateTime.day == today.day;
    
    final tomorrow = today.add(const Duration(days: 1));
    final isTomorrow = reminder.dateTime.year == tomorrow.year &&
        reminder.dateTime.month == tomorrow.month &&
        reminder.dateTime.day == tomorrow.day;

    String displayText = reminder.deadlineText;
    Color deadlineColor = const Color(0xff6D3EFF);

    if (isToday) {
      displayText = "HOY";
      deadlineColor = const Color(0xffEF4444);
    } else if (isTomorrow) {
      displayText = "MAÑANA";
      deadlineColor = const Color(0xffF59E0B);
    } else {
      final day = reminder.dateTime.day.toString();
      final month = reminder.dateTime.month.toString();
      displayText = "$day/$month";
      deadlineColor = const Color(0xff6D3EFF);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isToday 
            ? Colors.red.shade50 
            : isTomorrow 
                ? Colors.orange.shade50 
                : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isToday 
              ? Colors.red.shade200 
              : isTomorrow 
                  ? Colors.orange.shade200 
                  : Colors.grey.shade200,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xff102A43),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Cliente: ${reminder.clientName} • ${reminder.time}",
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xff64748B),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: deadlineColor.withOpacity(.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              displayText,
              style: TextStyle(
                color: deadlineColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ Tarjeta para mostrar pedidos en el Dashboard
  Widget _orderCard(Order order) {
    final deliveryDate = _parseDate(order.expectedDeliveryDate);
    final today = DateTime.now();
    final isToday = deliveryDate.year == today.year &&
        deliveryDate.month == today.month &&
        deliveryDate.day == today.day;
    
    final tomorrow = today.add(const Duration(days: 1));
    final isTomorrow = deliveryDate.year == tomorrow.year &&
        deliveryDate.month == tomorrow.month &&
        deliveryDate.day == tomorrow.day;

    String displayText = order.expectedDeliveryDate;
    Color deadlineColor = const Color(0xff6D3EFF);

    if (isToday) {
      displayText = "HOY";
      deadlineColor = const Color(0xffEF4444);
    } else if (isTomorrow) {
      displayText = "MAÑANA";
      deadlineColor = const Color(0xffF59E0B);
    } else {
      displayText = order.expectedDeliveryDate;
      deadlineColor = const Color(0xff6D3EFF);
    }

    return InkWell(
      onTap: () {
        // ✅ Navegar a OrderDetailScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OrderDetailScreen(
              order: order,
              onOrderUpdated: (updatedOrder) {
                _saveOrder(updatedOrder.toJson());
              },
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isToday 
              ? Colors.red.shade50 
              : isTomorrow 
                  ? Colors.orange.shade50 
                  : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isToday 
                ? Colors.red.shade200 
                : isTomorrow 
                    ? Colors.orange.shade200 
                    : Colors.grey.shade200,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.shopping_bag,
                        size: 16,
                        color: Color(0xff6D3EFF),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        order.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xff102A43),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Cliente: ${order.clientName}",
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xff64748B),
                    ),
                  ),
                  Text(
                    "Estante: ${order.shelfAssignment}",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: deadlineColor.withOpacity(.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                displayText,
                style: TextStyle(
                  color: deadlineColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}