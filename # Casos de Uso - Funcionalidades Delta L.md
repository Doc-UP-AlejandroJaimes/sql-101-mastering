# Casos de Uso - Funcionalidades Delta Lake

##  **APPEND** - `save_files_to_s3(mode="append")`
**Qué hace:** Agrega nuevos registros sin borrar los existentes.

**Cuándo usarlo:**
- Cargas incrementales diarias de nuevos clientes
- Logs o eventos que solo crecen (nunca se actualizan)
- Datos históricos que se acumulan

**Ejemplo real:**
```python
# Cada día llegan 1000 nuevos clientes del CRM
# No quieres borrar los 100,000 clientes anteriores
s3_handler.save_files_to_s3(df_nuevos_clientes, path, format="delta", mode="append")
```

---

##  **UPDATE** - `update_delta_data()`
**Qué hace:** Actualiza campos específicos de registros que cumplan una condición.

**Cuándo usarlo:**
- Corregir errores en datos (emails mal escritos, teléfonos incorrectos)
- Cambios masivos de estado (activar/desactivar usuarios)
- Actualizar campos calculados o derivados

**Ejemplo real:**
```python
# El área de compliance detectó 500 emails con dominio inválido
# Necesitas marcarlos como "pendiente_validación"
s3_handler.update_delta_data(
    path, 
    condition="email LIKE '%@tempmail.com'",
    update_values={"status": "pendiente_validacion", "requires_review": "true"}
)
```

**Ventaja vs recrear tabla:** Actualiza solo los registros necesarios en segundos, no reescribe toda la tabla.

---

##  **MERGE (UPSERT)** - `merge_delta_data()`
**Qué hace:** Si el registro existe (por clave), lo actualiza. Si no existe, lo inserta.

**Cuándo usarlo:**
- **CDC (Change Data Capture):** Sincronizar cambios de bases transaccionales
- Actualizaciones de sistemas origen donde no sabes qué cambió
- Mantener tablas maestras actualizadas (clientes, productos, empleados)

**Ejemplo real:**
```python
# Cada hora recibes un dump de la tabla de clientes de Oracle
# Algunos clientes son nuevos, otros actualizaron su dirección/email
# MERGE hace todo en una operación:
s3_handler.merge_delta_data(
    df_desde_oracle,
    path,
    merge_keys=["customer_id"]  # Busca por ID, actualiza si existe, inserta si no
)
```

**Ventaja:** Una sola operación en vez de dos (DELETE + INSERT). Atómico y eficiente.

---

##  **DELETE** - `delete_delta_data()`
**Qué hace:** Elimina registros que cumplan una condición específica.

**Cuándo usarlo:**
- **GDPR / Privacidad:** Eliminar datos de clientes que solicitaron "derecho al olvido"
- Depuración de datos (eliminar registros de prueba)
- Retención de datos (eliminar logs mayores a 90 días)
- Corrección de errores (eliminar duplicados)

**Ejemplo real:**
```python
# Un cliente solicita eliminación de sus datos por GDPR
s3_handler.delete_delta_data(
    path,
    condition="customer_id = 12345"
)

# Política de retención: eliminar logs mayores a 90 días
s3_handler.delete_delta_data(
    path,
    condition="fecha < '2024-08-01'"
)
```

**Ventaja:** Sin Delta Lake tendrías que reescribir TODA la tabla excluyendo esos registros.

---

##  **HISTORY** - `get_delta_history()`
**Qué hace:** Muestra el historial de todas las operaciones realizadas en la tabla (auditoría completa).

**Cuándo usarlo:**
- **Auditoría:** Demostrar quién modificó qué y cuándo
- **Debugging:** Investigar por qué los datos cambiaron
- **Compliance:** Trazabilidad para reguladores (SOX, GDPR)
- **Rollback:** Identificar la versión correcta antes de un error

**Ejemplo real:**
```python
# Reportan que los datos están "raros" desde ayer
# Ver qué operaciones se ejecutaron en las últimas 24 horas
history = s3_handler.get_delta_history(path, limit=50)
history.filter("timestamp > '2025-11-12'").show()

# Output:
# version | timestamp           | operation | user       | numRecords
# 45      | 2025-11-13 02:00:00 | DELETE    | etl_job_1  | -5000 (borró 5000 registros!)
# 44      | 2025-11-12 23:00:00 | MERGE     | etl_job_2  | 10000
```

**Ventaja:** Trazabilidad completa sin logging externo. Cada cambio queda registrado automáticamente.

---

##  **OPTIMIZE** - `optimize_delta_table()`
**Qué hace:** Compacta archivos pequeños en archivos más grandes para mejorar rendimiento de lectura.

**Cuándo usarlo:**
- Después de muchas operaciones APPEND pequeñas (ej: 100 inserts de 10 registros)
- Tablas con miles de archivos pequeños (< 1MB)
- Queries lentas por exceso de archivos
- **Programar mensualmente o semanalmente**

**Ejemplo real:**
```python
# Tu tabla tiene 10,000 archivos de 100KB cada uno (1GB total)
# Las queries leen 10,000 archivos = lento + caro
s3_handler.optimize_delta_table(path)
# Ahora: 10 archivos de 100MB cada uno = rápido + barato

# RECOMENDACIÓN: Ejecutar en job mensual de mantenimiento
if datetime.now().day == 1:  # Primer día del mes
    s3_handler.optimize_delta_table(path)
```

**Ventaja:** Queries hasta 10x más rápidas. Reduce costos de S3 (menos requests).

---

##  **VACUUM** - `vacuum_delta_table()`
**Qué hace:** Elimina físicamente archivos antiguos que ya no son necesarios (libera espacio en S3).

**Cuándo usarlo:**
- **Ahorrar costos de almacenamiento S3**
- Después de acumular muchas versiones (30+ versiones)
- **IMPORTANTE:** Solo cuando ya no necesites time travel histórico

**Ejemplo real:**
```python
# Tu tabla ocupa 500GB en S3
# Pero 400GB son versiones antiguas que nadie consulta
# Vacuum elimina versiones mayores a 7 días
s3_handler.vacuum_delta_table(path, retention_hours=168)  # 7 días
# Ahora: 100GB (ahorro de $320/año en S3 Standard)

# RECOMENDACIÓN: Ejecutar trimestralmente
# CUIDADO: No podrás hacer time travel más allá de 7 días
```

**Ventaja:** Reduce costos de S3 hasta 80%. Mantén solo versiones necesarias.

---

## Resumen Visual de Casos de Uso

| Operación | Caso de Uso Principal | Frecuencia Recomendada |
|-----------|----------------------|------------------------|
| **APPEND** | Cargas incrementales diarias | Diario/Horario |
| **UPDATE** | Correcciones puntuales | Ocasional (según necesidad) |
| **MERGE** | Sincronización CDC | Horario/Diario |
| **DELETE** | GDPR, retención de datos | Ocasional (compliance) |
| **HISTORY** | Auditoría, debugging | Cuando sea necesario |
| **OPTIMIZE** | Mejorar performance | Mensual |
| **VACUUM** | Reducir costos S3 | Trimestral |

---