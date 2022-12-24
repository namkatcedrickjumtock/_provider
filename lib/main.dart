import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import "package:uuid/uuid.dart";

void main(List<String> args) {
  runApp(
    ChangeNotifierProvider(
      create: ((context) => BreadhCrumbProvider()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const Home(),
        routes: {
          '/new': (context) => const NewBradCrumbsWiget(),
        },
      ),
    ),
  );
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Provider"),
      ),
      body: Column(
        children: [
          Consumer<BreadhCrumbProvider>(
            builder: (context, value, child) {
              return BreadCrumbsWidgets(breadCrumbs: value.items);
            },
          ),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, "/new");
            },
            child: const Text("Add new bread Crumb"),
          ),
          TextButton(
            onPressed: () {
              // recomended to use context.Read insdie callbacks fnx since it' sjut communicates with the provider
              context.read<BreadhCrumbProvider>().reset();
            },
            child: const Text("Reset"),
          )
        ],
      ),
    );
  }
}

// typedef OnBreadCrumbTaped = void Function(BreadCrumb);

class NewBradCrumbsWiget extends StatefulWidget {
  const NewBradCrumbsWiget({super.key});

  @override
  State<NewBradCrumbsWiget> createState() => _NewBradCrumbsWigetState();
}

class _NewBradCrumbsWigetState extends State<NewBradCrumbsWiget> {
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Bread Crumb"),
      ),
      body: Column(
        children: [
          TextField(
            controller: _controller,
            decoration:
                const InputDecoration(hintText: "Enter a new Brad Crumb here"),
          ),
          TextButton(
            onPressed: () {
              final text = _controller.text;
              if (text.isNotEmpty) {
                final breadCrumb = BreadCrumb(name: text, isActive: false);
                context.read<BreadhCrumbProvider>().add(breadCrumb);
                Navigator.of(context).pop();
              }
            },
            child: const Text("Add"),
          )
        ],
      ),
    );
  }
}

// bread crumb component
class BreadCrumb {
  bool isActive;
  final String name;
  final String uuid;

  void activate() {
    isActive = true;
  }

  BreadCrumb({required this.name, required this.isActive})
      : uuid = const Uuid().v4();

  // tell apart diff bread crumbs
  @override
  bool operator ==(covariant BreadCrumb other) => uuid == other.uuid;

  @override
  int get hashCode => uuid.hashCode;

  String get title => name + (isActive ? '>' : "");
}

// breadcurmb provider
class BreadhCrumbProvider extends ChangeNotifier {
  final List<BreadCrumb> _items = [];

  // creating a read only list view
  UnmodifiableListView<BreadCrumb> get items => UnmodifiableListView(_items);

  void add(BreadCrumb breadCrumb) {
    for (final items in _items) {
      items.activate();
    }
    _items.add(breadCrumb);
    notifyListeners();
  }

// clear breadCurmb array
  void reset() {
    _items.clear();
    notifyListeners();
  }
}

class BreadCrumbsWidgets extends StatelessWidget {
  final UnmodifiableListView<BreadCrumb> breadCrumbs;
  const BreadCrumbsWidgets({super.key, required this.breadCrumbs});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: breadCrumbs.map(
        (breadCrumb) {
          return Text(
            breadCrumb.title,
            style: TextStyle(
                color: breadCrumb.isActive ? Colors.blue : Colors.black),
          );
        },
      ).toList(),
    );
  }
}
