import 'package:flutter/material.dart';

import '../models/viaje.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'mis_viajes_screen.dart';
import 'perfil_screen.dart';
import 'registrar_viaje_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState
    extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Viaje> _viajes = [];

  Future<void> _registrarViaje() async {
    final nuevoViaje = await Navigator.push<Viaje>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const RegistrarViajeScreen(),
      ),
    );

    if (nuevoViaje == null) {
      return;
    }

    setState(() {
      _viajes.add(nuevoViaje);
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Viaje registrado correctamente',
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _irAViajes() {
    setState(() {
      _selectedIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pantallas = [
      HomeScreen(
        cantidadViajes: _viajes.length,
        onRegistrarViaje: _registrarViaje,
        onVerViajes: _irAViajes,
      ),
      MisViajesScreen(
        viajes: _viajes,
        onRegistrarViaje: _registrarViaje,
      ),
      const PerfilScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: pantallas,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFE6EFFF),
        elevation: 4,
        height: 72,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
            ),
            selectedIcon: Icon(
              Icons.home_rounded,
              color: AppTheme.primary,
            ),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.flight_outlined,
            ),
            selectedIcon: Icon(
              Icons.flight_rounded,
              color: AppTheme.primary,
            ),
            label: 'Viajes',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.person_outline,
            ),
            selectedIcon: Icon(
              Icons.person_rounded,
              color: AppTheme.primary,
            ),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}