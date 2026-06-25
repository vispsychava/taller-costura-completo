import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  final VoidCallback? onLogout; // Hacerlo opcional con ?

  const SettingsScreen({
    super.key,
    this.onLogout, // Ya no es required
  });

  void _showMessage(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '¡Configuración de "$label" disponible en la versión de producción!',
        ),
        backgroundColor: const Color(0xff6D3EFF),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Ajustes del Sistema",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xff102A43),
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// PERFIL
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
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
              child: Column(
                children: [
                  Stack(
                    children: [
                      const CircleAvatar(
                        radius: 45,
                        backgroundImage: NetworkImage(
                          "https://i.pravatar.cc/150?img=32",
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: Color(0xff6D3EFF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.verified,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Doña Tere",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff102A43),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Diseñadora de Alta Costura & Administradora",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xff64748B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xff6D3EFF).withOpacity(.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xff6D3EFF).withOpacity(.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.workspace_premium,
                              size: 16,
                              color: Color(0xff6D3EFF),
                            ),
                            SizedBox(width: 6),
                            Text(
                              "PREMIUM TAILOR",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xff6D3EFF),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.verified_user,
                              size: 16,
                              color: Color(0xff475569),
                            ),
                            SizedBox(width: 6),
                            Text(
                              "OWNER",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xff475569),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// OPCIONES
            Container(
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
              child: Column(
                children: [
                  _settingItem(
                    context,
                    icon: Icons.storefront,
                    title: "Datos de Taller",
                    subtitle: "Dirección corporativa, teléfonos públicos y logotipos",
                    onTap: () => _showMessage(
                      context,
                      "Datos de Taller",
                    ),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _settingItem(
                    context,
                    icon: Icons.lock,
                    title: "Contraseña y Seguridad",
                    subtitle: "Actualiza tus claves de acceso de administrador",
                    onTap: () => _showMessage(
                      context,
                      "Contraseña y Seguridad",
                    ),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _settingItem(
                    context,
                    icon: Icons.cloud_upload,
                    title: "Respaldo Automático",
                    subtitle: "Sincronización automática de órdenes en la nube",
                    onTap: () => _showMessage(
                      context,
                      "Respaldo Automático",
                    ),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _settingItem(
                    context,
                    icon: Icons.info_outline,
                    title: "Acerca de la Aplicación",
                    subtitle: "Versión 2.4.1",
                    onTap: () => _showMessage(
                      context,
                      "Acerca de la Aplicación",
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _settingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xff6D3EFF).withOpacity(.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          icon,
          color: const Color(0xff6D3EFF),
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: Color(0xff102A43),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xff64748B),
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Color(0xff829AB1),
      ),
      onTap: onTap,
    );
  }
}