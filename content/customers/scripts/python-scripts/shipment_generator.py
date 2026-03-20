import hashlib
import secrets
import string
import random
import pandas as pd
from datetime import datetime


class ShipmentGenerator:

    def __init__(self):
        self.__now       = datetime.now()
        self.__shipment_id   = self.__generate_shipment_id()
        self.__tracking_code = self.__generate_tracking_code()

    def __generate_shipment_id(self) -> str:
        timestamp          = self.__now.strftime("%Y%m%d")
        secure_combination = ''.join(
            secrets.choice(string.ascii_uppercase + string.digits)
            for _ in range(8)
        )
        return f"SHP-{timestamp}-{secure_combination}"

    def __generate_tracking_code(self) -> str:
        raw = f"{self.__shipment_id}-{self.__now.isoformat()}"
        return hashlib.sha256(raw.encode()).hexdigest()[:12].upper()

    def generate(self) -> tuple:
        return (
            self.__now.strftime("%Y-%m-%d %H:%M:%S"),
            self.__shipment_id,
            self.__tracking_code,
        )

    @staticmethod
    def generate_dataframe(order_ids: list[str],
                           min_company: int = 1,
                           max_company: int = 10) -> pd.DataFrame:
        """
        Generate one shipment row per order_id.

        Args:
            order_ids   : list of existing order IDs from pay.orders
            min_company : minimum ship_company_id
            max_company : maximum ship_company_id

        Returns:
            pd.DataFrame with columns matching ship.shipment_orders
        """
        rows = []
        for order_id in order_ids:
            gen                  = ShipmentGenerator()
            created_at, shp_id, tracking = gen.generate()
            rows.append({
                "id"              : shp_id,
                "ship_company_id" : random.randint(min_company, max_company),
                "order_id"        : order_id,
                "tracking_code"   : tracking,
                "status"          : "pending",
                "shipped_at"      : None,
                "delivered_at"    : None,
                "created_at"      : created_at,
                "updated_at"      : created_at,
            })

        return pd.DataFrame(rows, columns=[
            "id", "ship_company_id", "order_id", "tracking_code",
            "status", "shipped_at", "delivered_at", "created_at", "updated_at",
        ])