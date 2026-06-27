import 'package:flutter/material.dart';
import '../models/reminder.dart';
import '../models/order.dart';
import 'new_order_screen.dart';
import '../models/shelf.dart';
import 'order_detail_screen.dart';
import '../services/notification_service.dart';

class RemindersScreen extends StatefulWidget {
  final List<Reminder> reminders;
  final List<Order> orders;
  final Function(String, String) onAddReminder;
  final Function(String) onCheckReminder;
  final List<Shelf> shelves;
  final Function(Map<String, dynamic>) onSaveOrder;

  const RemindersScreen({
    super.key,
    required this.reminders,
    required this.orders,
    required this.onAddReminder,
    required this.onCheckReminder,
    this.shelves = const [],
    required this.onSaveOrder,
  });

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  bool showAddForm = false;
  final _notificationService = NotificationService();

  final TextEditingController taskController = TextEditingController();
  final TextEditingController clientController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  DateTime? _selectedDate;

  String _getMonthName(int month) {
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return months[month - 1];
  }

  String _formatDate(DateTime date) {
    const weekdays = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    return '${weekdays[date.weekday - 1]}, ${date.day} de ${_getMonthName(date.month)}';
  }

  String _formatDateShort(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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

  /// ✅ Convertir pedidos a recordatorios para mostrarlos juntos
  List<Reminder> _getAllReminders() {
    final List<Reminder> allItems = [];
    
    // Agregar recordatorios existentes
    allItems.addAll(widget.reminders);
    
    // ✅ Agregar pedidos como recordatorios (solo si no están entregados)
    for (var order in widget.orders) {
      if (order.status != "Entregado") {
        // Verificar si ya existe un recordatorio para este pedido
        final exists = widget.reminders.any((r) => 
          r.title == order.title && r.clientName == order.clientName
        );
        
        if (!exists) {
          final deliveryDate = _parseDate(order.expectedDeliveryDate);
          
          allItems.add(Reminder(
            id: 'order-${order.id}',
            title: '📦 ${order.title}',
            clientName: order.clientName,
            time: 'Pedido #${order.id}',
            deadlineText: order.expectedDeliveryDate,
            dateTime: deliveryDate,
            isCompleted: false,
          ));
        }
      }
    }
    
    // Ordenar por fecha
    allItems.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    
    return allItems;
  }

  void submitReminder() {
    if (taskController.text.trim().isEmpty ||
        clientController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona una fecha'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    widget.onAddReminder(
      taskController.text,
      clientController.text,
    );

     if (_selectedDate != null) {
    final newReminder = Reminder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: taskController.text,
      clientName: clientController.text,
      time: timeController.text,
      deadlineText: dateController.text,
      dateTime: _selectedDate!,
    );
    _notificationService.scheduleReminderNotification(newReminder);
  }


    taskController.clear();
    clientController.clear();
    timeController.clear();
    dateController.clear();
    _selectedDate = null;

    setState(() {
      showAddForm = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Recordatorio creado con éxito!'),
        backgroundColor: Colors.green,
      ),
    );
  }

    void _navigateToNewOrder() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NewOrderScreen(
            shelves: widget.shelves,
            onSaveOrder: (order) {
              widget.onSaveOrder(order);

              // Programa notificación 1 día antes de la entrega
              final reminder = Reminder(
                id: 'order-${order['id']}',
                title: order['title'] ?? '',
                clientName: order['clientName'] ?? '',
                time: '',
                deadlineText: order['expectedDeliveryDate'] ?? '',
                dateTime: DateTime.tryParse(order['expectedDeliveryDate'] ?? '') 
                    ?? DateTime.now().add(const Duration(days: 7)),
              );
              _notificationService.scheduleReminderNotification(reminder);
            },
          ),
        ),
      );
    }

  /// ✅ Navegar a OrderDetailScreen desde un pedido
  void _navigateToOrderDetail(String orderId) {
    final order = widget.orders.firstWhere(
      (o) => o.id == orderId,
      orElse: () => widget.orders.first,
    );
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderDetailScreen(
          order: order,
          onOrderUpdated: (updatedOrder) {
            widget.onSaveOrder(updatedOrder.toJson());
          },
        ),
      ),
    );
  }

  Color _getColorForDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) return Colors.red;
    if (dateOnly == tomorrow) return Colors.orange;
    return const Color(0xff6D3EFF);
  }

  @override
  Widget build(BuildContext context) {
    final allItems = _getAllReminders();
    
    // Separar completados y no completados
    final activeItems = allItems.where((r) => !r.isCompleted).toList();
    final completedItems = allItems.where((r) => r.isCompleted).toList();

    // Agrupar por fecha
    final Map<String, List<Reminder>> groupedReminders = {};
    for (var reminder in activeItems) {
      final dateKey = _formatDateShort(reminder.dateTime);
      if (!groupedReminders.containsKey(dateKey)) {
        groupedReminders[dateKey] = [];
      }
      groupedReminders[dateKey]!.add(reminder);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Próximas Entregas',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xff102A43),
                fontSize: 22,
              ),
            ),
            Text(
              'Gestiona tu agenda de costura',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xff64748B),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: FloatingActionButton.small(
              onPressed: () {
                setState(() {
                  showAddForm = !showAddForm;
                  if (!showAddForm) {
                    taskController.clear();
                    clientController.clear();
                    timeController.clear();
                    dateController.clear();
                    _selectedDate = null;
                  }
                });
              },
              backgroundColor: const Color(0xff6D3EFF),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// FORMULARIO PARA AGREGAR
            if (showAddForm)
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Nuevo Recordatorio',
                          style: TextStyle(
                            color: Color(0xff6D3EFF),
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: taskController,
                        decoration: const InputDecoration(
                          labelText: 'Descripción',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.task),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: clientController,
                        decoration: const InputDecoration(
                          labelText: 'Cliente',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: timeController,
                        decoration: const InputDecoration(
                          labelText: 'Hora (ej: 16:00)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.access_time),
                        ),
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (date != null) {
                            setState(() {
                              _selectedDate = date;
                              dateController.text = _formatDate(date);
                            });
                          }
                        },
                        child: IgnorePointer(
                          child: TextField(
                            controller: dateController,
                            decoration: const InputDecoration(
                              labelText: 'Fecha de Entrega',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.calendar_today),
                              suffixIcon: Icon(Icons.arrow_drop_down),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                              onPressed: () {
                                setState(() {
                                  showAddForm = false;
                                  taskController.clear();
                                  clientController.clear();
                                  timeController.clear();
                                  dateController.clear();
                                  _selectedDate = null;
                                });
                              },
                              child: const Text('Cancelar'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff6D3EFF),
                                foregroundColor: Colors.white,
                              ),
                              onPressed: submitReminder,
                              child: const Text('Añadir'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            if (showAddForm) const SizedBox(height: 20),

            /// SIN RECORDATORIOS NI PEDIDOS
            if (activeItems.isEmpty && completedItems.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 80),
                child: Column(
                  children: const [
                    Icon(
                      Icons.inbox,
                      size: 70,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 15),
                    Text(
                      'No hay entregas pendientes',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xff102A43),
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '¡Buen trabajo!',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

            /// GRUPOS DE RECORDATORIOS + PEDIDOS
            if (activeItems.isNotEmpty)
              Column(
                children: [
                  for (var entry in groupedReminders.entries)
                    buildGroup(
                      _formatDate(entry.value.first.dateTime),
                      entry.value,
                      _getColorForDate(entry.value.first.dateTime),
                    ),
                ],
              ),

            /// COMPLETADOS
            if (completedItems.isNotEmpty)
              buildGroup(
                "Completados ✓",
                completedItems.toList(),
                Colors.green,
              ),
          ],
        ),
      ),
    );
  }

  Widget buildGroup(
    String title,
    List<Reminder> reminders,
    Color color,
  ) {
    if (reminders.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: const Color(0xff102A43),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  reminders.length.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        ...reminders.map(
          (r) {
            // ✅ Verificar si es un pedido (tiene el prefijo 📦)
            final isOrder = r.title.contains('📦');
            
            return InkWell(
              onTap: () {
                if (isOrder) {
                  // ✅ Si es un pedido, extraer el ID y navegar
                  final orderId = r.id.replaceFirst('order-', '');
                  _navigateToOrderDetail(orderId);
                } else {
                  // ✅ Si es un recordatorio normal, marcar como completado
                  if (!r.isCompleted) {
                    widget.onCheckReminder(r.id);
                  }
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: r.isCompleted ? Colors.green.shade200 : Colors.grey.shade100,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: r.isCompleted 
                            ? Colors.green.withValues(alpha: .12) 
                            : color.withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        r.isCompleted ? Icons.check : 
                          (r.title.contains('📦') ? Icons.shopping_bag : Icons.event_note),
                        color: r.isCompleted ? Colors.green : color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              decoration: r.isCompleted ? TextDecoration.lineThrough : null,
                              color: r.isCompleted ? Colors.grey : const Color(0xff102A43),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Cliente: ${r.clientName}',
                            style: TextStyle(
                              fontSize: 14,
                              color: r.isCompleted ? Colors.grey.shade500 : const Color(0xff64748B),
                            ),
                          ),
                          Row(
                            children: [
                              if (r.time.isNotEmpty)
                                Text(
                                  r.time,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: r.isCompleted ? Colors.grey.shade400 : const Color(0xff829AB1),
                                  ),
                                ),
                              if (r.time.isNotEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 6),
                                  child: Text(
                                    '•',
                                    style: TextStyle(
                                      color: Color(0xff829AB1),
                                    ),
                                  ),
                                ),
                              Text(
                                _formatDateShort(r.dateTime),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: r.isCompleted ? Colors.grey.shade400 : const Color(0xff829AB1),
                                ),
                              ),
                              if (isOrder && !r.isCompleted)
                                const Padding(
                                  padding: EdgeInsets.only(left: 8),
                                  child: Icon(
                                    Icons.chevron_right,
                                    size: 16,
                                    color: Color(0xff829AB1),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (!r.isCompleted && !isOrder)
                      InkWell(
                        onTap: () {
                          widget.onCheckReminder(r.id);
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: .08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.check_circle_outline,
                            color: Colors.green,
                            size: 28,
                          ),
                        ),
                      ),
                    if (r.isCompleted)
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 28,
                      ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}