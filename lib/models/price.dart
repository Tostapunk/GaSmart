import 'enums.dart';

class Price {
  String brand;
  DateTime date;
  int aggiornamento;
  String area;
  int north;
  int south;
  int east;
  int west;
  double min;
  double max;
  int num;
  double mean;
  double sd;
  Regioni regione;
  Provincie provincia;
  Comuni comune;

  Price(
      this.brand,
      this.date,
      this.aggiornamento,
      this.area,
      this.east,
      this.max,
      this.mean,
      this.min,
      this.north,
      this.num,
      this.sd,
      this.south,
      this.west,
      this.comune,
      this.provincia,
      this.regione);
}
