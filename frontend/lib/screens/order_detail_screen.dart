import 'package:flutter/material.dart';
import '../models/order.dart';
import '../models/activity_item.dart';

class OrderDetailScreen extends StatefulWidget {
  final Order order;
  final Function(Order) onOrderUpdated;

  const OrderDetailScreen({
    super.key,
    required this.order,
    required this.onOrderUpdated,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late double paymentAmount;
  late String selectedStatus;
  late Order _currentOrder;

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
    paymentAmount = widget.order.balanceDue;
    selectedStatus = widget.order.status;
  }

  void _showPaymentModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Registrar Pago',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Color(0xff102A43),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Cliente: ${_currentOrder.clientName}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Monto a pagar',
                  hintText: '\$0.00',
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                onChanged: (value) {
                  paymentAmount =
                      double.tryParse(value) ?? _currentOrder.balanceDue;
                },
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xff6D3EFF).withOpacity(.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Saldo pendiente:',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Color(0xff102A43),
                      ),
                    ),
                    Text(
                      '\$${_currentOrder.balanceDue.toStringAsFixed(2)} MXN',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xff6D3EFF),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _registerPayment(paymentAmount);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff6D3EFF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Confirmar Pago'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _registerPayment(double amount) {
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ El monto debe ser mayor a 0'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (amount > _currentOrder.balanceDue) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ El monto no puede ser mayor al saldo pendiente'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // ✅ CORREGIDO: Convertir el resultado de clamp a double
    final newBalance = (_currentOrder.balanceDue - amount).clamp(0.0, double.infinity).toDouble();

    // Crear actividad
    final newActivity = ActivityItem(
      id: 'act-${DateTime.now().millisecondsSinceEpoch}',
      action: 'Pago registrado',
      description: 'Pago de \$${amount.toStringAsFixed(2)} registrado',
      date: DateTime.now(),
      userId: 'sistema',
    );

    // Actualizar orden
    final updatedOrder = Order(
      id: _currentOrder.id,
      clientName: _currentOrder.clientName,
      clientPhone: _currentOrder.clientPhone,
      clientEmail: _currentOrder.clientEmail,
      clientAvatar: _currentOrder.clientAvatar,
      title: _currentOrder.title,
      description: _currentOrder.description,
      type: _currentOrder.type,
      size: _currentOrder.size,
      status: _currentOrder.status,
      statusDate: _currentOrder.statusDate,
      expectedDeliveryDate: _currentOrder.expectedDeliveryDate,
      totalAmount: _currentOrder.totalAmount,
      advancePaid: _currentOrder.advancePaid + amount,
      balanceDue: newBalance,
      shelfAssignment: _currentOrder.shelfAssignment,
      measurements: _currentOrder.measurements,
      progressNotes: _currentOrder.progressNotes,
      activityHistory: [..._currentOrder.activityHistory, newActivity],
      priority: _currentOrder.priority,
    );

    setState(() {
      _currentOrder = updatedOrder;
    });

    // Notificar al Dashboard
    widget.onOrderUpdated(updatedOrder);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Pago registrado: \$${amount.toStringAsFixed(2)}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showStatusModal() {
    final statuses = ['Sin empezar', 'En proceso', 'Terminado', 'Entregado', 'Atrasado'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Actualizar Estado',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Color(0xff102A43),
                ),
              ),
              const SizedBox(height: 16),
              ...statuses.map((status) {
                final isSelected = _currentOrder.status == status;
                return ListTile(
                  leading: Radio<String>(
                    value: status,
                    groupValue: _currentOrder.status,
                    activeColor: const Color(0xff6D3EFF),
                    onChanged: (value) {
                      if (value != null) {
                        _updateStatus(value);
                        Navigator.pop(context);
                      }
                    },
                  ),
                  title: Text(
                    status,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? const Color(0xff6D3EFF) : const Color(0xff102A43),
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: Color(0xff6D3EFF))
                      : null,
                );
              }).toList(),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _updateStatus(String newStatus) {
    if (newStatus == _currentOrder.status) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ℹ️ El estado ya es ese'),
          backgroundColor: Colors.blue,
        ),
      );
      return;
    }

    // Crear actividad
    final newActivity = ActivityItem(
      id: 'act-${DateTime.now().millisecondsSinceEpoch}',
      action: 'Estado actualizado',
      description: 'Estado cambiado de "${_currentOrder.status}" a "$newStatus"',
      date: DateTime.now(),
      userId: 'sistema',
    );

    // Actualizar orden
    final updatedOrder = Order(
      id: _currentOrder.id,
      clientName: _currentOrder.clientName,
      clientPhone: _currentOrder.clientPhone,
      clientEmail: _currentOrder.clientEmail,
      clientAvatar: _currentOrder.clientAvatar,
      title: _currentOrder.title,
      description: _currentOrder.description,
      type: _currentOrder.type,
      size: _currentOrder.size,
      status: newStatus,
      statusDate: DateTime.now().toIso8601String(),
      expectedDeliveryDate: _currentOrder.expectedDeliveryDate,
      totalAmount: _currentOrder.totalAmount,
      advancePaid: _currentOrder.advancePaid,
      balanceDue: _currentOrder.balanceDue,
      shelfAssignment: _currentOrder.shelfAssignment,
      measurements: _currentOrder.measurements,
      progressNotes: _currentOrder.progressNotes,
      activityHistory: [..._currentOrder.activityHistory, newActivity],
      priority: _currentOrder.priority,
    );

    setState(() {
      _currentOrder = updatedOrder;
    });

    // Notificar al Dashboard
    widget.onOrderUpdated(updatedOrder);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Estado actualizado a: $newStatus'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showHistoryModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Historial de Actividad',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Color(0xff102A43),
                ),
              ),
              const SizedBox(height: 16),
              if (_currentOrder.activityHistory.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      Icon(Icons.history, size: 50, color: Colors.grey),
                      SizedBox(height: 12),
                      Text(
                        'No hay actividad registrada',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _currentOrder.activityHistory.length,
                  itemBuilder: (context, index) {
                    final h = _currentOrder.activityHistory[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xff6D3EFF).withOpacity(.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              h.action == 'Pago registrado' ? Icons.attach_money : Icons.sync,
                              color: const Color(0xff6D3EFF),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  h.action,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xff102A43),
                                  ),
                                ),
                                Text(
                                  h.description,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  '${h.date.day}/${h.date.month}/${h.date.year} ${h.date.hour.toString().padLeft(2, '0')}:${h.date.minute.toString().padLeft(2, '0')}',
                                  style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff6D3EFF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Cerrar'),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget infoCard({
    required String title,
    required Widget child,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xff6D3EFF).withOpacity(.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xff6D3EFF), size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff102A43),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = _currentOrder;
    final isPaid = order.balanceDue == 0;

    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Ficha Técnica',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Color(0xff102A43),
          ),
        ),
        centerTitle: false,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isPaid ? null : _showPaymentModal,
                  icon: Icon(
                    isPaid ? Icons.check_circle : Icons.attach_money,
                    color: Colors.white,
                  ),
                  label: Text(
                    isPaid ? "Cobro Completado" : "Registrar Pago",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isPaid ? Colors.green : const Color(0xff6D3EFF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showStatusModal,
                  icon: const Icon(Icons.sync),
                  label: const Text(
                    "Estado",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// CABECERA
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status).withOpacity(.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      order.status.toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(order.status),
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    order.id,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff102A43),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Color(0xff829AB1),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Entrega: ${order.expectedDeliveryDate}",
                        style: const TextStyle(
                          color: Color(0xff64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            /// CLIENTE
            infoCard(
              title: "Información del Cliente",
              icon: Icons.person_outline,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(order.clientAvatar),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.clientName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xff102A43),
                          ),
                        ),
                        Text(
                          order.clientPhone,
                          style: const TextStyle(
                            color: Color(0xff64748B),
                          ),
                        ),
                        Text(
                          order.clientEmail,
                          style: const TextStyle(
                            color: Color(0xff64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            /// PRENDA
            infoCard(
              title: "Detalles de la Prenda",
              icon: Icons.checkroom,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xff102A43),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order.description,
                    style: const TextStyle(
                      color: Color(0xff64748B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Talla: ${order.size}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Color(0xff64748B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            /// FINANZAS
            infoCard(
              title: "Acuerdo Financiero",
              icon: Icons.payments_outlined,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _financeItem("Total", "\$${order.totalAmount}"),
                  _financeItem("Anticipo", "\$${order.advancePaid}"),
                  _financeItem(
                    "Saldo",
                    "\$${order.balanceDue}",
                    color: order.balanceDue > 0 ? Colors.orange : Colors.green,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            /// MEDIDAS
            infoCard(
              title: "Mediciones",
              icon: Icons.straighten,
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.2,
                children: [
                  _measureItem("Busto", order.measurements.bust.toString()),
                  _measureItem("Cintura", order.measurements.waist.toString()),
                  _measureItem("Cadera", order.measurements.hip.toString()),
                  _measureItem("Largo", order.measurements.length.toString()),
                ],
              ),
            ),
            const SizedBox(height: 16),

            /// HISTORIAL
            infoCard(
              title: "Actividad Reciente",
              icon: Icons.history,
              child: order.activityHistory.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        children: [
                          Icon(
                            Icons.inbox,
                            size: 40,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 8),
                          Text(
                            "No hay actividad registrada",
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: order.activityHistory.length > 3 ? 3 : order.activityHistory.length,
                      itemBuilder: (context, index) {
                        final h = order.activityHistory[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: const Color(0xff6D3EFF).withOpacity(.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  h.action == 'Pago registrado' ? Icons.attach_money : Icons.sync,
                                  color: const Color(0xff6D3EFF),
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      h.action,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: Color(0xff102A43),
                                      ),
                                    ),
                                    Text(
                                      h.description,
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${h.date.day}/${h.date.month}',
                                style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),

            /// BOTÓN VER HISTORIAL COMPLETO
            if (order.activityHistory.length > 3)
              Center(
                child: TextButton(
                  onPressed: _showHistoryModal,
                  child: const Text(
                    "Ver historial completo →",
                    style: TextStyle(
                      color: Color(0xff6D3EFF),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Sin empezar':
        return Colors.grey;
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

  Widget _financeItem(String label, String value, {Color color = Colors.black}) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xff829AB1),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _measureItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xff829AB1),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Color(0xff102A43),
            ),
          ),
        ],
      ),
    );
  }
}