import 'package:flutter/material.dart';
import '../models/shelf.dart';

class NewOrderScreen extends StatefulWidget {
  final List<Shelf> shelves;
  final Function(Map<String, dynamic>) onSaveOrder;

  const NewOrderScreen({
    super.key,
    required this.shelves,
    required this.onSaveOrder,
  });

  @override
  State<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen> {
  final _formKey = GlobalKey<FormState>();

  final clientNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final sizeController = TextEditingController();
  final descriptionController = TextEditingController();
  
  final TextEditingController bustController = TextEditingController();
  final TextEditingController waistController = TextEditingController();
  final TextEditingController hipController = TextEditingController();
  final TextEditingController lengthController = TextEditingController();

  String? shelfAssignment;
  String garmentType = "vestido";
  String priority = "Media";
  DateTime deliveryDate = DateTime.now();

  double totalAmount = 0;
  double advancePaid = 0;
  double balanceDue = 0;

  bool _showMeasurements = false;

  List<Shelf> get _availableShelves {
    return widget.shelves.where((shelf) {
      return shelf.status != "Full";
    }).toList();
  }

  /// ✅ Obtener las medidas según el tipo de prenda
  List<Map<String, dynamic>> get _measurementFields {
    switch (garmentType) {
      case 'vestido':
        return [
          {'label': 'Busto', 'controller': bustController},
          {'label': 'Cintura', 'controller': waistController},
          {'label': 'Cadera', 'controller': hipController},
          {'label': 'Largo', 'controller': lengthController},
        ];
      case 'pantalon':
        return [
          {'label': 'Cintura', 'controller': waistController},
          {'label': 'Cadera', 'controller': hipController},
          {'label': 'Largo', 'controller': lengthController},
        ];
      case 'falda':
        return [
          {'label': 'Cintura', 'controller': waistController},
          {'label': 'Cadera', 'controller': hipController},
          {'label': 'Largo', 'controller': lengthController},
        ];
      case 'saco':
        return [
          {'label': 'Cintura', 'controller': waistController},
          {'label': 'Cadera', 'controller': hipController},
          {'label': 'Largo', 'controller': lengthController},
        ];
      case 'ajuste':
        return [
          {'label': 'Busto', 'controller': bustController},
          {'label': 'Cintura', 'controller': waistController},
          {'label': 'Cadera', 'controller': hipController},
          {'label': 'Largo', 'controller': lengthController},
        ];
      default:
        return [
          {'label': 'Busto', 'controller': bustController},
          {'label': 'Cintura', 'controller': waistController},
          {'label': 'Cadera', 'controller': hipController},
          {'label': 'Largo', 'controller': lengthController},
        ];
    }
  }

  @override
  void initState() {
    super.initState();
    if (_availableShelves.isNotEmpty) {
      shelfAssignment = _availableShelves.first.id;
    }
  }

  void calculateBalance() {
    setState(() {
      balanceDue = (totalAmount - advancePaid);
      if (balanceDue < 0) balanceDue = 0;
    });
  }

  InputDecoration _input(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: Colors.grey.shade600,
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.grey.shade200,
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xff6D3EFF),
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
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
          )
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
                child: Icon(
                  icon,
                  color: const Color(0xff6D3EFF),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff102A43),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final availableShelves = _availableShelves;
    final measurementFields = _measurementFields;

    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Text(
          "Registrar Nuevo Pedido",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Color(0xff102A43),
          ),
        ),
        centerTitle: false,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              /// INFORMACIÓN DEL CLIENTE
              _sectionCard(
                title: "Información del Cliente",
                icon: Icons.person_outline,
                child: Column(
                  children: [
                    TextFormField(
                      controller: clientNameController,
                      decoration: _input("Nombre Completo"),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xff102A43),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Campo obligatorio";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: phoneController,
                            decoration: _input("Teléfono"),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xff102A43),
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: emailController,
                            decoration: _input("Correo Electrónico"),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xff102A43),
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              /// UBICACIÓN EN TALLER
              _sectionCard(
                title: "Ubicación en Taller",
                icon: Icons.location_on_outlined,
                child: Column(
                  children: [
                    if (availableShelves.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.red.shade200,
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.warning, color: Colors.red),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "No hay estantes disponibles. Todos los estantes están llenos.",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      DropdownButtonFormField<String>(
                        value: shelfAssignment,
                        decoration: _input("Asignación de Estante"),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xff102A43),
                        ),
                        items: availableShelves.map((shelf) {
                          final remaining = shelf.capacity - shelf.garmentsCount;
                          return DropdownMenuItem(
                            value: shelf.id,
                            child: Text(
                              "Estante ${shelf.id} (${shelf.garmentsCount}/${shelf.capacity}) - ${remaining} espacios disponibles",
                              style: const TextStyle(
                                fontSize: 15,
                                color: Color(0xff102A43),
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            shelfAssignment = value!;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Selecciona un estante";
                          }
                          return null;
                        },
                      ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Prioridad del Trabajo",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _priorityOption("Baja", Icons.arrow_downward),
                            const SizedBox(width: 16),
                            _priorityOption("Media", Icons.remove),
                            const SizedBox(width: 16),
                            _priorityOption("Alta", Icons.arrow_upward),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              /// DETALLES DE LA PRENDA
              _sectionCard(
                title: "Detalles de la Prenda",
                icon: Icons.checkroom,
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: garmentType,
                      decoration: _input("Tipo de Prenda"),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xff102A43),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: "vestido",
                          child: Text("Vestido de Noche / Gala"),
                        ),
                        DropdownMenuItem(
                          value: "pantalon",
                          child: Text("Pantalón"),
                        ),
                        DropdownMenuItem(
                          value: "saco",
                          child: Text("Saco"),
                        ),
                        DropdownMenuItem(
                          value: "falda",
                          child: Text("Falda"),
                        ),
                        DropdownMenuItem(
                          value: "ajuste",
                          child: Text("Ajuste"),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          garmentType = value!;
                          bustController.clear();
                          waistController.clear();
                          hipController.clear();
                          lengthController.clear();
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    /// ✅ BOTÓN PARA MOSTRAR/OCULTAR MEDIDAS - MÁS COMPACTO
                    InkWell(
                      onTap: () {
                        setState(() {
                          _showMeasurements = !_showMeasurements;
                        });
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: _showMeasurements
                              ? const Color(0xff6D3EFF).withOpacity(.08)
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _showMeasurements
                                ? const Color(0xff6D3EFF)
                                : Colors.grey.shade200,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.straighten,
                                  color: _showMeasurements
                                      ? const Color(0xff6D3EFF)
                                      : Colors.grey.shade600,
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  _showMeasurements ? "Ocultar Mediciones" : "Agregar Mediciones",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: _showMeasurements
                                        ? const Color(0xff6D3EFF)
                                        : Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                            Icon(
                              _showMeasurements
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              color: _showMeasurements
                                  ? const Color(0xff6D3EFF)
                                  : Colors.grey.shade600,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),

                    /// ✅ CAMPOS DE MEDIDAS - MÁS COMPACTOS (en filas)
                    if (_showMeasurements)
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.grey.shade200,
                          ),
                        ),
                        child: Column(
                          children: [
                            /// ✅ PRIMERA FILA (2 columnas)
                            if (measurementFields.length >= 2)
                              Row(
                                children: [
                                  Expanded(
                                    child: _compactMeasureField(
                                      measurementFields[0]['label'],
                                      measurementFields[0]['controller'],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _compactMeasureField(
                                      measurementFields[1]['label'],
                                      measurementFields[1]['controller'],
                                    ),
                                  ),
                                ],
                              ),
                            
                            /// ✅ SEGUNDA FILA (si hay más de 2)
                            if (measurementFields.length >= 4)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _compactMeasureField(
                                        measurementFields[2]['label'],
                                        measurementFields[2]['controller'],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _compactMeasureField(
                                        measurementFields[3]['label'],
                                        measurementFields[3]['controller'],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            
                            /// ✅ SI SON 3 (Pantalón, Falda, Saco)
                            if (measurementFields.length == 3)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _compactMeasureField(
                                        measurementFields[2]['label'],
                                        measurementFields[2]['controller'],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Container(), // Espacio vacío
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 16),
                    TextFormField(
                      controller: descriptionController,
                      maxLines: 4,
                      decoration: _input(
                        "Descripción de la Modificación / Trabajo",
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xff102A43),
                      ),
                      minLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: sizeController,
                      decoration: _input("Talla / Medidas Clave"),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xff102A43),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              /// ACUERDO FINANCIERO Y ENTREGA
              _sectionCard(
                title: "Acuerdo Financiero y Entrega",
                icon: Icons.payments_outlined,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: deliveryDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365),
                                ),
                              );
                              if (date != null) {
                                setState(() {
                                  deliveryDate = date;
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Fecha de Entrega",
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "${deliveryDate.day}/${deliveryDate.month}/${deliveryDate.year}",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xff102A43),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.calendar_today,
                                        color: Colors.grey.shade600,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Divider(height: 1),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    "Costo Total",
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      hintText: "\$0.00",
                                      hintStyle: TextStyle(
                                        color: Colors.grey.shade400,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide.none,
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                    ),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Color(0xff102A43),
                                    ),
                                    onChanged: (value) {
                                      totalAmount = double.tryParse(value) ?? 0;
                                      calculateBalance();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    "Anticipo / Depósito",
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      hintText: "\$0.00",
                                      hintStyle: TextStyle(
                                        color: Colors.grey.shade400,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide.none,
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                    ),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Color(0xff102A43),
                                    ),
                                    onChanged: (value) {
                                      advancePaid = double.tryParse(value) ?? 0;
                                      calculateBalance();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Saldo Remanente",
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  "\$ ${balanceDue.toStringAsFixed(2)} MXN",
                                  style: const TextStyle(
                                    color: Color(0xff6D3EFF),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: Colors.grey.shade300,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                      ),
                      child: const Text(
                        "Cancelar",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff64748B),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff6D3EFF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                      ),
                      onPressed: () {
                        if (!_formKey.currentState!.validate()) {
                          return;
                        }

                        if (shelfAssignment == null || shelfAssignment!.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("⚠️ Selecciona un estante"),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                        final selectedShelf = widget.shelves.firstWhere(
                          (s) => s.id == shelfAssignment,
                          orElse: () => Shelf(id: '', capacity: 0, garmentsCount: 0, status: '', lastActivity: ''),
                        );
                        
                        if (selectedShelf.status == "Full" || selectedShelf.garmentsCount >= selectedShelf.capacity) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("⚠️ Este estante ya está lleno, selecciona otro"),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                        final timestamp = DateTime.now().millisecondsSinceEpoch;
                        final id = 'ORD-${timestamp.toString().substring(7)}';

                        final measurements = {
                          'bust': double.tryParse(bustController.text.trim()) ?? 0,
                          'waist': double.tryParse(waistController.text.trim()) ?? 0,
                          'hip': double.tryParse(hipController.text.trim()) ?? 0,
                          'length': double.tryParse(lengthController.text.trim()) ?? 0,
                        };

                        final newOrder = {
                          'id': id,
                          'clientName': clientNameController.text.trim(),
                          'clientPhone': phoneController.text.trim(),
                          'clientEmail': emailController.text.trim(),
                          'clientAvatar': 'https://i.pravatar.cc/150?img=${timestamp % 70}',
                          'shelfAssignment': shelfAssignment!,
                          'priority': priority,
                          'garmentType': garmentType,
                          'title': '${garmentType == 'vestido' ? 'Vestido' : garmentType == 'pantalon' ? 'Pantalón' : garmentType == 'saco' ? 'Saco' : garmentType == 'falda' ? 'Falda' : 'Ajuste'} - ${clientNameController.text.trim()}',
                          'size': sizeController.text.trim(),
                          'description': descriptionController.text.trim(),
                          'deliveryDate': '${deliveryDate.day}/${deliveryDate.month}/${deliveryDate.year}',
                          'expectedDeliveryDate': '${deliveryDate.day}/${deliveryDate.month}/${deliveryDate.year}',
                          'totalAmount': totalAmount,
                          'advancePaid': advancePaid,
                          'balanceDue': balanceDue,
                          'status': 'Sin empezar',
                          'statusDate': DateTime.now().toIso8601String(),
                          'progressNotes': [],
                          'activityHistory': [],
                          'measurements': measurements,
                        };

                        widget.onSaveOrder(newOrder);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("✅ Pedido guardado correctamente"),
                            backgroundColor: Colors.green,
                          ),
                        );

                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Guardar Pedido",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  /// ✅ CAMPO DE MEDIDA COMPACTO
  Widget _compactMeasureField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w500,
          fontSize: 11,
        ),
        hintText: 'cm',
        hintStyle: TextStyle(
          color: Colors.grey.shade400,
          fontSize: 11,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Colors.grey.shade200,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Color(0xff6D3EFF),
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 8,
        ),
        isDense: true,
      ),
      style: const TextStyle(
        fontSize: 13,
        color: Color(0xff102A43),
      ),
    );
  }

  Widget _priorityOption(String label, IconData icon) {
    final isSelected = priority == label;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            priority = label;
          });
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 4,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xff6D3EFF).withOpacity(.1)
                : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? const Color(0xff6D3EFF)
                  : Colors.grey.shade200,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? const Color(0xff6D3EFF)
                    : Colors.grey.shade500,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? const Color(0xff6D3EFF)
                      : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}