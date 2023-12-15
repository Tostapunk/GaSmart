enum ClassiVeicolo { Test }

extension ExtClassiVeicolo on ClassiVeicolo {
  ClassiVeicolo fromString(String s) {
    return ClassiVeicolo.Test;
  }
}

enum TipiCarburante { Benzina, Diesel, GPL, None }

enum TipiStrada { Provinciale, Autostrada }

enum Regioni { Veneto, Friuli }

enum Provincie { TV }

enum Comuni { Conegliano }

class EnumConverter {
  static TipiCarburante tipoCarburanteFromStr(String val) {
    switch (val) {
      case "Benzina":
        return TipiCarburante.Benzina;
      case "Diesel":
        return TipiCarburante.Diesel;
      case "GPL":
        return TipiCarburante.GPL;
      default:
        return TipiCarburante.None;
    }
  }

  static String stringFromTipoCarburante(TipiCarburante val) {
    switch (val) {
      case TipiCarburante.Benzina:
        return "Benzina";
      case TipiCarburante.Diesel:
        return "Diesel";
      case TipiCarburante.GPL:
        return "GPL";
      default:
        return "None";
    }
  }
}
