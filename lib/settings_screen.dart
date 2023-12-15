import 'package:GaSmart/models/enums.dart';
import 'package:GaSmart/models/vehicle.dart';
import 'package:GaSmart/utils/db.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

const List<String> carburanti = <String>['Diesel', 'Benzina', 'GPL'];
// Vehicle v1 = Vehicle(1, 'BMW', 'M3', DateTime.now(), true,
//     TipiCarburante.Benzina, ClassiVeicolo.Test);
// Vehicle v2 = Vehicle(1, 'Ford', 'EcoSport', DateTime.now(), false,
//     TipiCarburante.Diesel, ClassiVeicolo.Test);

class _SettingsScreenState extends State<SettingsScreen> {
  List<Vehicle> veicoli = <Vehicle>[];
  String selectedVeicolo = "";
  bool risparmio = false;
  bool inquinamento = true;
  int raggio = 20;

  Future<void> _loadSettings() async {
    // await DB.deleteDatabase();
    var st = (await DB.getSettings())[0];
    await _loadVeicoli();
    setState(() {
      selectedVeicolo = st["veicolo"].toString();
      risparmio = (st["risparmio"] as int) == 1 ? true : false;
      inquinamento = (st["inquinamento"] as int) == 1 ? true : false;
      raggio = st["raggio"] as int;
    });
  }

  Future<void> _loadVeicoli() async {
    List<Map<String, dynamic>> v = await DB.getVehicles();
    setState(() => veicoli = v.map((e) => Vehicle.fromMap(e)).toList());
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 20, 16.0, 0),
                child: Text(
                  'Settings',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 20, 16.0, 0),
                  child: DropdownMenu<String>(
                    width: MediaQuery.of(context).size.width - 32,
                    inputDecorationTheme:
                        const InputDecorationTheme(filled: true),
                    initialSelection: selectedVeicolo,
                    onSelected: (value) {
                      setState(() {
                        selectedVeicolo = value!;
                      });
                    },
                    requestFocusOnTap: true,
                    dropdownMenuEntries:
                        veicoli.map<DropdownMenuEntry<String>>((value) {
                      return DropdownMenuEntry<String>(
                          value: value.id.toString(),
                          label: "${value.marca} ${value.modello}",
                          trailingIcon: value.editable
                              ? Row(children: [
                                  IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        if (value.id.toString() ==
                                            selectedVeicolo) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                                  content:
                                                      Text("Cannot do this")));
                                          return;
                                        }
                                        DB
                                            .deleteVehicle(value.id)
                                            .then((value) async {
                                          await _loadSettings();
                                        });
                                      }),
                                  IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () {
                                        GestureBinding.instance
                                            .handlePointerEvent(
                                          const PointerDownEvent(
                                              position: Offset(10, 10)),
                                        );
                                        openFullscreenDialog(
                                                context,
                                                true,
                                                veicoli
                                                    .firstWhere((element) =>
                                                        element.id == value.id)
                                                    .toMap())
                                            .then((value) async {
                                          await _loadSettings();
                                        });
                                      })
                                ])
                              : null);
                    }).toList(),
                  )),
            ),
            SliverToBoxAdapter(
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 20, 16.0, 0),
                  child: Row(
                    children: [
                      Switch(
                        value: risparmio,
                        onChanged: (value) {
                          setState(() {
                            risparmio = value;
                          });
                        },
                      ),
                      const Padding(
                          padding: EdgeInsets.fromLTRB(16.0, 20, 16.0, 0)),
                      Text(
                        'Massimizza risparmio',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  )),
            ),
            SliverToBoxAdapter(
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 20, 16.0, 0),
                  child: Row(
                    children: [
                      Switch(
                        value: inquinamento,
                        onChanged: (value) {
                          setState(() {
                            inquinamento = value;
                          });
                        },
                      ),
                      const Padding(
                          padding: EdgeInsets.fromLTRB(16.0, 20, 16.0, 0)),
                      Text(
                        'Minimizza inquinamento',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  )),
            ),
            SliverToBoxAdapter(
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 20, 16.0, 0),
                  child: Column(
                    children: [
                      Text(
                        'Raggio distributori (Km)',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      SizedBox(
                        height: 50,
                        child: Slider(
                          value: raggio.toDouble(),
                          max: 50,
                          min: 5,
                          divisions: 9,
                          label: raggio.round().toString(),
                          onChanged: (value) {
                            setState(() {
                              raggio = value.toInt();
                            });
                          },
                        ),
                      ),
                    ],
                  )),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 20, 16.0, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () =>
                          openFullscreenDialog(context, false, null)
                              .then((value) async {
                        await _loadVeicoli();
                      }),
                      icon: const Icon(Icons.add),
                      label: const Text('Crea'),
                    ),
                    FilledButton(
                      onPressed: () async {
                        if (selectedVeicolo == "") {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text("Devi selezionare un veicolo")));
                          return;
                        }
                        await DB.updateSettings({
                          "id": 1,
                          "veicolo": int.parse(selectedVeicolo),
                          "risparmio": risparmio ? 1 : 0,
                          "inquinamento": inquinamento ? 1 : 0,
                          "raggio": raggio
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text("Impostazioni salvate con successo"),
                                backgroundColor: Colors.lightGreen));
                      },
                      child: const Text('Salva'),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

Future<void> openFullscreenDialog(
    BuildContext context, bool update, Map<String, dynamic>? newV) {
  Map<String, dynamic> x = newV ??
      {
        "marca": "",
        "modello": "",
        "carburante":
            EnumConverter.stringFromTipoCarburante(TipiCarburante.values.first),
        "classe": ClassiVeicolo.values.first
            .toString()
            .replaceAll("ClassiVeicolo.", ""),
        "anno": DateTime.now().toString(),
        "editable": 1
      };
  TextEditingController textController1 = TextEditingController();
  TextEditingController textController2 = TextEditingController();
  textController1.text = x["marca"] as String;
  textController2.text = x["modello"] as String;

  Future<String> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.parse(x["anno"].toString()),
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != DateTime.parse(x["anno"].toString())) {
      x["anno"] = picked.toString();
    }
    return picked.toString();
  }

  return showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
            return Dialog.fullscreen(
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Scaffold(
                    appBar: AppBar(
                      title: const Text('Crea veicolo'),
                      centerTitle: false,
                      leading: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      actions: [
                        TextButton(
                          child: const Text('Close'),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    body: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                            child: TextField(
                              onChanged: (val) => setState(
                                  () => x["marca"] = textController1.text),
                              controller: textController1,
                              decoration: InputDecoration(
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () => textController1.clear(),
                                ),
                                labelText: 'Marca',
                                filled: true,
                              ),
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                            child: SizedBox(
                              child: TextField(
                                onChanged: (val) => setState(
                                    () => x["modello"] = textController2.text),
                                controller: textController2,
                                decoration: InputDecoration(
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () => textController2.clear(),
                                  ),
                                  labelText: 'Modello',
                                  filled: true,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                              child: DropdownMenu<String>(
                                helperText: "Tipo carburante",
                                width: MediaQuery.of(context).size.width - 40,
                                inputDecorationTheme:
                                    const InputDecorationTheme(filled: true),
                                initialSelection: x["carburante"].toString(),
                                onSelected: (value) => setState(
                                    () => x["carburante"] = value.toString()),
                                dropdownMenuEntries: TipiCarburante.values
                                    .map((e) =>
                                        EnumConverter.stringFromTipoCarburante(
                                            e))
                                    .map<DropdownMenuEntry<String>>((value) {
                                  return DropdownMenuEntry<String>(
                                      value: value, label: value);
                                }).toList(),
                              )),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                              child: DropdownMenu<String>(
                                helperText: "Classe veicolo",
                                width: MediaQuery.of(context).size.width - 40,
                                inputDecorationTheme:
                                    const InputDecorationTheme(filled: true),
                                initialSelection: x["classe"].toString(),
                                onSelected: (value) => setState(
                                    () => x["classe"] = value.toString()),
                                dropdownMenuEntries: ClassiVeicolo.values
                                    .map((e) => e
                                        .toString()
                                        .replaceAll("ClassiVeicolo.", ""))
                                    .map<DropdownMenuEntry<String>>((value) {
                                  return DropdownMenuEntry<String>(
                                      value: value.toString(),
                                      label: value.toString());
                                }).toList(),
                              )),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                            child: TextField(
                                readOnly: true,
                                controller: TextEditingController(
                                    text:
                                        "${DateTime.parse(x["anno"].toString()).day}/${DateTime.parse(x["anno"].toString()).month}/${DateTime.parse(x["anno"].toString()).year}"),
                                decoration: InputDecoration(
                                  suffixIcon: IconButton(
                                      icon: const Icon(Icons.calendar_month),
                                      onPressed: () async {
                                        var d = await selectDate(context);
                                        setState(() => x["anno"] = d);
                                      }),
                                  helperText: 'data',
                                  filled: true,
                                )),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                FilledButton(
                                  onPressed: () {
                                    if (!update) {
                                      DB.insertVehicleMap(x);
                                    } else {
                                      DB.updateVehicleMap(x);
                                    }
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Salva'),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          }));
}
