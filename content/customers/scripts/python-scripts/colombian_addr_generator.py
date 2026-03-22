import re
import random
import pandas as pd


class ColombianAddressGenerator:

    _VIA = [
        ("CL", "Calle"), ("CR", "Carrera"), ("DG", "Diagonal"),
        ("TV", "Transversal"), ("AK", "Avenida Carrera"),
        ("AC", "Avenida Calle"), ("AUT", "Autopista"),
        ("CRT", "Carretera"), ("BLV", "Boulevard"), ("PW", "Park Way"),
    ]

    _COMPLEMENTOS = [
        ("AP", "Apartamento"), ("OF", "Oficina"), ("LC", "Local"),
        ("TO", "Torre"), ("BL", "Bloque"), ("P", "Piso"),
        ("CS", "Consultorio"), ("ED", "Edificio"), ("BG", "Bodega"),
        ("SUITE", "Suite"), ("PH", "Penthouse"), ("IN", "Interior"),
    ]

    _AGRUPACIONES = [
        ("CON", "Conjunto"), ("URB", "Urbanización"), ("CD", "Ciudadela"),
        ("BRR", "Barrio"), ("SEC", "Sector"), ("UR", "Unidad Residencial"),
        ("ET", "Etapa"),
    ]

    _AGR_NOMBRES = [
        "Los Pinos", "El Nogal", "La Reserva", "San Mateo", "Villa del Río",
        "El Jardín", "Las Palmas", "Santa Bárbara", "El Bosque",
        "Colinas del Norte", "La Pradera", "El Retiro", "Los Cerezos",
        "Villa Campestre", "Rincón del Lago",
    ]

    _COMENTARIOS = [
        "Casa con portón azul", "Timbre no funciona, llamar al llegar",
        "Entregar en portería", "Edificio esquinero",
        "Frente al parque principal", "Al lado de la droguería",
        "Segunda entrada del conjunto", "Dejar con el vigilante",
        "Casa color blanco con rejas negras", "Subir al segundo piso",
        "Cerca al semáforo", "Preguntar por el administrador",
    ]

    def __init__(self, sql_path: str = None, codes: list[str] = None):
        if sql_path:
            self.codes = self._load_codes(sql_path)
        elif codes:
            self.codes = codes
        else:
            raise ValueError("Provide sql_path or codes list.")

    @staticmethod
    def _load_codes(sql_path: str) -> list[str]:
        pattern = re.compile(r"\(\s*'(\d+)'\s*,\s*'[^']+'\s*,\s*'[^']+'\s*\)")
        with open(sql_path, "r", encoding="utf-8") as f:
            return pattern.findall(f.read())

    def _base_street(self) -> str:
        _, via   = random.choice(self._VIA)
        num      = random.randint(1, 150)
        letra    = random.choice(["", "A", "B", "C", ""])
        bis      = random.choice(["", " BIS"])
        cruce    = random.randint(1, 150)
        puerta   = random.randint(1, 99)
        return f"{via} {num}{letra}{bis} # {cruce} - {puerta}"

    def _complement(self) -> str:
        _, name = random.choice(self._COMPLEMENTOS)
        return f"{name} {random.randint(1, 50)}"

    def _agrupacion(self) -> str:
        _, name = random.choice(self._AGRUPACIONES)
        return f"{name} {random.choice(self._AGR_NOMBRES)}"

    def simple(self) -> tuple:
        return (random.choice(self.codes), self._base_street(), None, None)

    def with_complement(self) -> tuple:
        detail = self._complement()
        if random.random() < 0.6:
            detail += f", {self._agrupacion()}"
        return (random.choice(self.codes), self._base_street(), detail, None)

    def full(self) -> tuple:
        detail   = f"{self._complement()}, {self._agrupacion()}"
        comments = random.choice(self._COMENTARIOS)
        return (random.choice(self.codes), self._base_street(), detail, comments)

    def generate(self, n: int = 1) -> list[tuple]:
        return [random.choice([self.simple, self.with_complement, self.full])() for _ in range(n)]

    @staticmethod
    def to_insert(rows: list[tuple], table: str = "cs.addresses") -> str:
        def fmt(v): return f"'{v}'" if v else "NULL"
        vals = ",\n".join(
            f"    ({fmt(r[0])}, {fmt(r[1])}, {fmt(r[2])}, {fmt(r[3])})"
            for r in rows
        )
        return (
            f"INSERT INTO {table} "
            f"(municipality_code, street, detail, additional_comments)\nVALUES\n{vals};"
        )
    
    def enrich_dataframe(self, df: pd.DataFrame,
                     street_col: str = "street",
                     mun_col: str = "municipality_code") -> pd.DataFrame:
        """
        - street presente : agrega detail y additional_comments.
        - street nulo     : genera street completo + detail + additional_comments.
        El municipality_code se toma del DataFrame; si falta, se elige aleatorio.
        """

        df = df.copy()
        if mun_col not in df.columns:
            df[mun_col] = None
            
        for col in ("detail", "additional_comments"):
            if col not in df.columns:
                df[col] = None

        def _enrich_row(row):
            if mun_col in row.index and pd.notna(row[mun_col]):
                mun = row[mun_col]
            else:
                mun = random.choice(self.codes)
            mun  = row[mun_col] if pd.notna(row[mun_col]) else random.choice(self.codes)
            has_street = pd.notna(row[street_col]) and str(row[street_col]).strip() != ""

            if has_street:
                # Solo complementar
                row["detail"]               = self._complement()
                row["additional_comments"]  = random.choice(self._COMENTARIOS)
            else:
                # Generar todo
                row[street_col]             = self._base_street()
                row["detail"]               = f"{self._complement()}, {self._agrupacion()}"
                row["additional_comments"]  = random.choice(self._COMENTARIOS)

            row[mun_col] = mun
            return row

        return df.apply(_enrich_row, axis=1)