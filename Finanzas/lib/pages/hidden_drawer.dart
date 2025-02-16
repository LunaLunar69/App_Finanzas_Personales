import 'package:minimallogin/pages/home_page.dart';
import 'package:minimallogin/pages/ingresos/Ingresos.dart';
import 'package:minimallogin/pages/settings_page.dart';
import 'package:minimallogin/pages/targetas/my_cards.dart';
import 'package:minimallogin/pages/transacciones/transactions.dart';
import 'package:minimallogin/pages/traspasos/transfers.dart';
import 'package:minimallogin/pages/activos/assetsPage.dart';
import 'package:flutter/material.dart';
import 'package:hidden_drawer_menu/hidden_drawer_menu.dart';

class HiddenDrawer extends StatefulWidget {
  const HiddenDrawer({super.key});

  @override
  State<HiddenDrawer> createState() => _HiddenDrawer();
}

class _HiddenDrawer extends State<HiddenDrawer> {
  List<ScreenHiddenDrawer> _pages = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _pages = [
      ScreenHiddenDrawer(
        ItemHiddenMenu(
          name: 'H O M E',
          baseStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
          selectedStyle:
              TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        const HomePage(),
      ),
      ScreenHiddenDrawer(
        ItemHiddenMenu(
          name: 'I N G R E S O S',
          baseStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
          selectedStyle:
              TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        const IngresoForm(),
      ),
      ScreenHiddenDrawer(
        ItemHiddenMenu(
          name: 'M I S   T A R J E T A S',
          baseStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
          selectedStyle:
              TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        CardListPage(),
      ),
      ScreenHiddenDrawer(
        ItemHiddenMenu(
          name: 'T R A N S A C C I O N E S',
          baseStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
          selectedStyle:
              TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        const TransactionsPage(),
      ),
      ScreenHiddenDrawer(
        ItemHiddenMenu(
          name: 'T R A S P A S O S',
          baseStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
          selectedStyle:
              TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        const TransfersPage(),
      ),
      ScreenHiddenDrawer(
        ItemHiddenMenu(
          name: 'A C T I V O S',
          baseStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
          selectedStyle:
              TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        AssetsPage(),
      ),
      ScreenHiddenDrawer(
        ItemHiddenMenu(
          name: 'C O N F I G U R A C I Ó N',
          baseStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
          selectedStyle:
              TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        const SettingsPage(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return HiddenDrawerMenu(
        screens: _pages,
        initPositionSelected: 0,
        backgroundColorMenu: Theme.of(context).colorScheme.surface);
  }
}
