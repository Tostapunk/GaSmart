class Distributore {
  String nome;
  String brand;
  double lat;
  double lng;
  // int elevation;
  // int ritardo;
  // String indirizzo;
  // Comuni comune;
  // Provincie provincia;
  // Regioni regione;
  // DateTime lastIns;
  Map<String, double> prezzi;
  // TipiStrada strada;

  static Distributore fromJson(dynamic m) => Distributore(
      m["Nome"] as String,
      m["Brand"] as String,
      m["Latitudine"] as double,
      m["Longitudine"] as double,
      m["prezzi"] as Map<String, double>);

  Distributore(
    this.nome,
    this.brand,
    // this.comune,
    // this.elevation,
    // this.indirizzo,
    // this.lastIns,
    this.lat,
    this.lng,
    this.prezzi,
    // this.provincia,
    // this.regione,
    // this.ritardo,
    // this.strada
  );
}
