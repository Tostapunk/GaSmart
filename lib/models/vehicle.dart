import 'enums.dart';

class Vehicle {
  int id;
  String marca;
  String modello;
  DateTime anno;
  // double co2;
  // double fuelCost;
  // int saveSpend;
  // int consumoAnnuale;
  // int combinedMPG; -> kmL  mpG / 2.352 = kmL
  bool editable;
  ClassiVeicolo classe;
  TipiCarburante carburante;

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "marca": marca,
      "modello": modello,
      "anno": anno.toString(),
      "editable": editable ? 1 : 0,
      "classe": classe.toString().replaceAll("ClassiVeicolo.", ""),
      "carburante": carburante.toString().replaceAll("TipiCarburante.", "")
    };
  }

  static Vehicle fromMap(Map<String, dynamic> m) {
    return Vehicle(
        m["id"] as int,
        m["marca"] as String,
        m["modello"] as String,
        DateTime.parse(m["anno"] as String),
        (m["editable"] as int) == 1 ? true : false,
        EnumConverter.tipoCarburanteFromStr(m["carburante"] as String),
        ClassiVeicolo.Test.fromString(m["classe"] as String));
  }

  Vehicle(
      this.id,
      this.marca,
      this.modello,
      this.anno,
      // this.co2,
      // this.fuelCost,
      // this.saveSpend,
      // this.consumoAnnuale,
      // this.combinedMPG,
      this.editable,
      this.carburante,
      this.classe);
}


// {
//   "id": int,
//   "marca": String,
//   "modello": String,
//   "anno": String,
//   "carburante": String<Diesel | Benzina | GPL ...>,
//   "classe": String<...>
// }