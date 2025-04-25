-- Crear y usar base de datos
 
create database jewelers
character set = 'utf16'
collate = 'utf16_bin';

use jewelers;

-- Crear tablas con sus restricciones

-- Tabla personas que constará con los datos generales de personas como clientes y empleados

CREATE TABLE Persona (
  id_persona int not null auto_increment,
  nombre_persona varchar(20) not null,
  apellido_persona varchar(20) not null,
  tipo_documento_persona enum('Tarjeta de identidad', 'Cédula ciudadanía', 'Cédula extranjería', 'Pasaporte', 'NIT') not null,
  numero_documento_persona varchar(15) not null unique,
  direccion_persona varchar(50),
  telefono_persona varchar(15),
  email_persona varchar(50) unique,
  fecha_registro_persona datetime not null default current_timestamp,
  estado_persona enum('Activo', 'Inactivo', 'Eliminado') not null default 'Activo',
  CONSTRAINT conspk_id_persona PRIMARY KEY (id_persona),
  CONSTRAINT consuk_email_persona UNIQUE KEY (email_persona)
);

-- La tabla rol constará con los roles que existen para los usuarios

CREATE TABLE Rol (
  id_rol int not null auto_increment,
  nombre_rol varchar(30) not null unique,
  descripcion_rol varchar(255),
  CONSTRAINT conspk_id_rol PRIMARY KEY (id_rol),
  CONSTRAINT consuk_nombre_rol UNIQUE KEY (nombre_rol)
);

-- La tabla usuario constará con los usuarios que podrán acceder al sistema, principalmente empleados y administradores.

CREATE TABLE Usuario (
  id_usuario int not null auto_increment,
  id_rol_fk int not null,
  nombre_usuario varchar(30) not null unique,
  contraseña_usuario_hash varchar(255) not null,
  fecha_registro_usuario datetime not null default current_timestamp,
  estado_usuario enum('Activo', 'Inactivo', 'Eliminado') not null default 'Activo',
  CONSTRAINT conspk_id_usuario PRIMARY KEY (id_usuario),
  CONSTRAINT consuk_nombre_usuario UNIQUE KEY (nombre_usuario),
  FOREIGN KEY (id_rol_fk) REFERENCES Rol(id_rol)
  ON DELETE RESTRICT ON UPDATE CASCADE
);

-- La tabla empleados será utilizada para manejar datos más especificos de los empleados, estos datos irán unidos con persona

CREATE TABLE Empleado (
  id_empleado int not null auto_increment,
  id_persona_fk int not null,
  id_usuario_fk int not null,
  fecha_nacimiento date not null,
  genero_empleado enum('Femenino', 'Masculino', 'Prefiero no decirlo') not null,
  estado_civil enum('Soltero', 'Casado', 'Divorciado', 'Viudo', 'No especifica') not null default 'No especifica',
  nacionalidad varchar(20) not null,
  fecha_contratacion date not null,
  tipo_contrato enum('Indefinido', 'Fijo', 'Temporal', 'Aprendizaje', 'Otro') not null,
  jornada_laboral enum('Completa', 'Diurna', 'Nocturna', 'Flexible', 'Fines de semana') not null,
  salario_empleado decimal(10,2) not null,
  eps_empleado varchar(30) not null,
  estado_empleado enum('Activo', 'Inactivo', 'Vacaciones', 'Permiso') not null default 'Activo',
  CONSTRAINT conspk_id_empleado PRIMARY KEY (id_empleado),
  FOREIGN KEY (id_persona_fk) REFERENCES Persona(id_persona)
  ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (id_usuario_fk) REFERENCES Usuario(id_usuario)
  ON DELETE RESTRICT ON UPDATE CASCADE
);

-- La tabla proveedor almacenará los datos de proveedores vinculados a productos

CREATE TABLE Proveedor (
  id_proveedor int not null auto_increment,
  nombre_proveedor varchar(30) not null unique,
  tipo_documento_proveedor enum('Tarjeta de identidad', 'Cédula ciudadanía', 'Cédula extranjería', 'Pasaporte', 'NIT') not null,
  numero_documento_proveedor varchar(15) not null unique,
  direccion_proveedor varchar(50) ,
  telefono_proveedor varchar(15),
  email_proveedor varchar(50) unique,
  ciudad_proveedor varchar(20),
  fecha_registro_proveedor datetime not null default current_timestamp,
  estado_proveedor enum('Activo', 'Inactivo', 'Eliminado') not null default 'Activo',
  CONSTRAINT conspk_id_proveedor PRIMARY KEY (id_proveedor),
  CONSTRAINT consuk_nombre_proveedor UNIQUE KEY (nombre_proveedor),
  CONSTRAINT consuk_email_proveedor UNIQUE KEY (email_proveedor)
);

-- La tabla categoria se usa para agrupar productos mediante un orden

CREATE TABLE Categoria (
  id_categoria int not null auto_increment,
  nombre_categoria varchar(30) not null unique,
  descripcion_categoria varchar(255),
  CONSTRAINT conspk_id_categoria PRIMARY KEY (id_categoria),
  CONSTRAINT consuk_nombre_categoria UNIQUE KEY (nombre_categoria)
);

-- La tabla producto usará datos de los productos para producir ventas, manejar stock

CREATE TABLE Producto (
  id_producto int not null auto_increment,
  id_categoria_fk int not null,
  codigo_producto varchar(20) not null unique,
  nombre_producto varchar(50) not null,
  descripcion_producto varchar(255),
  stock_producto int not null,
  estado_producto enum('Disponible', 'Agotado', 'Eliminado', 'Reservado') not null default 'Disponible',
  CONSTRAINT conspk_id_producto PRIMARY KEY (id_producto),
  CONSTRAINT consuk_codigo_producto UNIQUE KEY (codigo_producto),
  CONSTRAINT conschk_stock_no_negativo CHECK (stock_producto>=0),
  FOREIGN KEY (id_categoria_fk) REFERENCES Categoria(id_categoria)
  ON DELETE RESTRICT ON UPDATE CASCADE
);

-- La tabla movimiento servirá para manejar los movimientos de los productos en el inventario

CREATE TABLE Movimiento (
  id_movimiento int not null auto_increment,
  id_producto_fk int not null,
  id_proveedor_fk int,
  id_usuario_fk int not null,
  codigo_factura varchar(50),
  precio_compra_unidad decimal(10,2) not null,
  precio_venta_unidad decimal(10,2) not null,
  cantidad_producto_movimiento int not null,
  total_costo_movimiento decimal(10,2) not null,
  tipo_movimiento enum('Entrada', 'Salida', 'Devolución_Cliente', 'Devolución_Proveedor') not null,
  observaciones_movimiento varchar(255),
  fecha_movimiento datetime not null default current_timestamp,
  CONSTRAINT conspk_id_movimiento PRIMARY KEY (id_movimiento),
  CONSTRAINT conschk_precio_compra_no_negativo CHECK (precio_compra_unidad>=0),
  CONSTRAINT conschk_precio_venta_no_negativo CHECK (precio_venta_unidad>=0),
  CONSTRAINT conschk_cantidad_producto_movimiento_no_negativo CHECK (cantidad_producto_movimiento>0),
  CONSTRAINT conschk_costo_movimiento_no_negativo CHECK (total_costo_movimiento>=0),
  FOREIGN KEY (id_producto_fk) REFERENCES Producto(id_producto)
  ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (id_proveedor_fk) REFERENCES Proveedor(id_proveedor)
  ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (id_usuario_fk) REFERENCES Usuario(id_usuario)
  ON DELETE RESTRICT ON UPDATE CASCADE	
);

-- Tabla en la que se almacenarán los datos de ventas completadas o no

CREATE TABLE Venta (
  id_venta int not null auto_increment,
  id_persona_fk int not null,
  id_empleado_fk int not null,
  total_venta decimal(10,2) not null,
  estado_venta enum('Pendiente', 'Pagada', 'Completada', 'Cancelada', 'Reembolsada', 'Rechazada') not null,
  fecha_venta datetime not null default current_timestamp,
  CONSTRAINT conspk_id_venta PRIMARY KEY (id_venta),
  CONSTRAINT conschk_venta_no_negativa CHECK (total_venta>=0),
  FOREIGN KEY (id_persona_fk) REFERENCES Persona(id_persona)
  ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (id_empleado_fk) REFERENCES Empleado(id_empleado)
  ON DELETE RESTRICT ON UPDATE CASCADE
);

-- La tabla venta_credito servirá para seguir las ventas que fueron por creditos 

CREATE TABLE Venta_Credito (
  id_venta_credito int not null auto_increment,
  id_venta_fk int not null,
  numero_cuotas int not null,
  valor_cuota decimal(10,2) not null,
  estado_credito enum('Pendiente', 'Activo', 'En mora', 'Cancelado', 'Vencido', 'Pagado') not null,
  fecha_inicio datetime not null default current_timestamp,
  fecha_fin datetime not null,
  interes_mensual decimal(4,2),
  saldo_pendiente decimal(10,2) not null,
  CONSTRAINT conspk_id_venta_credito PRIMARY KEY (id_venta_credito),
  CONSTRAINT conschk_numero_cuotas_no_negativas CHECK (numero_cuotas>0),
  CONSTRAINT conschk_valor_cuota_no_negativo CHECK (valor_cuota>0),
  CONSTRAINT conschk_interes_mensual_no_negativo CHECK (interes_mensual>=0),
  CONSTRAINT conschk_saldo_pendiente_no_negativo CHECK (saldo_pendiente>=0),
  FOREIGN KEY (id_venta_fk) REFERENCES Venta(id_venta)
  ON DELETE RESTRICT ON UPDATE CASCADE
);

-- La tabla venta_producto se utiliza para las ventas que sí fueron completadas, almacenando datos de facturación

CREATE TABLE Venta_Producto (
  id_producto_fk int not null,
  id_venta_fk int not null,
  codigo_venta varchar(50) not null,
  cantidad_producto int not null,
  precio_unitario decimal(10,2) not null,
  metodo_pago enum('Efectivo', 'Tarjeta crédito', 'Tarjeta débito', 'Transferencia', 'Pago móvil', 'Cheque', 'Crédito', 'Pago mixto', 'Otro'),
  subtotal_venta decimal(10,2) not null,
  descuento_venta decimal(10,2) not null default 0,
  CONSTRAINT conspk_venta_producto PRIMARY KEY (id_venta_fk, id_producto_fk),
  CONSTRAINT consuk_codigo_venta UNIQUE KEY (codigo_venta),
  CONSTRAINT conschk_cantidad_producto_no_negativa CHECK (cantidad_producto>=0),
  CONSTRAINT conschk_precio_unitario_no_negativo CHECK (precio_unitario>=0),
  CONSTRAINT conschk_subtotal_venta_no_negativa CHECK (subtotal_venta>=0),
  CONSTRAINT conschk_descuento_no_negativo CHECK (descuento_venta >= 0),
  CONSTRAINT conschk_descuento_valido CHECK (descuento_venta <= subtotal_venta),
  CONSTRAINT conschk_descuento_venta_no_negativo CHECK (descuento_venta>=0),
  FOREIGN KEY (id_producto_fk) REFERENCES Producto(id_producto)
  ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (id_venta_fk) REFERENCES Venta(id_venta)
  ON DELETE RESTRICT ON UPDATE CASCADE
);

-- La tabla Historial_Sistema servirá como una auditoria general de los eventos que se presenten dentro de la ejecución de la base de datos

CREATE TABLE Historial_Sistema (
  id_historial_sistema int not null auto_increment,
  id_usuario_fk int,
  tipo_log enum('Info', 'Advertencia', 'Error', 'Excepción', 'Debug', 'Auditoria') not null,
  modulo_afectado VARCHAR(50) not null, 
  accion_realizada VARCHAR(100) not null,
  descripcion_evento varchar(255) not null, 
  ip_origen varchar(45), 
  navegador_usuario varchar(255), 
  fecha_evento timestamp not null default current_timestamp,
  CONSTRAINT conspk_id_historial_sistema PRIMARY KEY (id_historial_sistema),
  FOREIGN KEY (id_usuario_fk) REFERENCES Usuario(id_usuario)
  ON DELETE RESTRICT ON UPDATE CASCADE
);

-- La tabla Historial_Usuario permite la trazabilidad de cambios realizada en la tabla Usuario

CREATE TABLE Historial_Usuario (
  id_historial_usuario int auto_increment,
  id_usuario_modificado_fk int,
  id_rol_fk int,
  id_usuario_modifico_fk int not null,
  nombre_usuario varchar(30),
  contraseña_usuario_hash varchar(255),
  estado_usuario enum('Activo', 'Inactivo', 'Eliminado'),
  tipo_cambio enum('Inserción', 'Actualización', 'Eliminación', 'Registro inicial') not null default 'Registro inicial',
  descripcion_cambio varchar(255) not null,
  fecha_cambio timestamp not null default current_timestamp,
  CONSTRAINT conspk_historial_usuario PRIMARY KEY (id_historial_usuario),
  FOREIGN KEY (id_usuario_modificado_fk) REFERENCES Usuario(id_usuario)
  ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (id_rol_fk) REFERENCES Rol(id_rol)
  ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (id_usuario_modifico_fk) REFERENCES Usuario(id_usuario)
  ON DELETE RESTRICT ON UPDATE CASCADE
);

-- La tabla Historial_Rol permite la trazabilidad de cambios realizada en la tabla Rol

CREATE TABLE Historial_Rol (
  id_historial_rol int not null auto_increment,
  id_rol_fk int,
  id_usuario_modifico_fk int,
  nombre_rol varchar(30),
  descripcion_rol varchar(255),
  tipo_cambio enum('Inserción', 'Actualización', 'Eliminación', 'Registro inicial') not null default 'Registro inicial',
  descripcion_cambio varchar(255) not null,
  fecha_cambio timestamp not null default current_timestamp,
  CONSTRAINT conspk_id_historial_rol PRIMARY KEY (id_historial_rol),
  FOREIGN KEY (id_rol_fk) REFERENCES Rol(id_rol)
  ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (id_usuario_modifico_fk) REFERENCES Usuario(id_usuario)
  ON DELETE RESTRICT ON UPDATE CASCADE
);


-- La tabla Historial_Persona permite la trazabilidad de cambios realizada en la tabla Persona

CREATE TABLE Historial_Persona (
  id_historial_persona int not null auto_increment,
  id_persona_fk int,
  id_usuario_modifico_fk int,
  nombre_persona varchar(20),
  apellido_persona varchar(20),
  tipo_documento_persona enum('Tarjeta de identidad', 'Cédula ciudadanía', 'Cédula extranjería', 'Pasaporte', 'NIT'),
  numero_documento_persona varchar(15),
  direccion_persona varchar(50),
  telefono_persona varchar(15),
  email_persona varchar(50),
  fecha_registro_persona datetime,
  estado_persona enum('Activo', 'Inactivo', 'Eliminado'),
  tipo_cambio enum('Inserción', 'Actualización', 'Eliminación', 'Registro inicial') not null default 'Registro inicial',
  descripcion_cambio varchar(255) not null,
  fecha_cambio timestamp not null default current_timestamp,
  CONSTRAINT conspk_id_historial_persona PRIMARY KEY (id_historial_persona),
  FOREIGN KEY (id_persona_fk) REFERENCES Persona(id_persona)
  ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (id_usuario_modifico_fk) REFERENCES Usuario(id_usuario)
  ON DELETE RESTRICT ON UPDATE CASCADE
);

-- La tabla Historial_Empleado permite la trazabilidad de cambios realizada en la tabla Empleado

CREATE TABLE Historial_Empleado (
  id_historial_empleado int not null auto_increment,
  id_empleado_fk int,
  id_persona_fk int,
  id_usuario_fk int,
  id_usuario_modifico_fk int,
  fecha_nacimiento date,
  genero_empleado enum('Femenino', 'Masculino', 'Prefiero no decirlo'),
  estado_civil enum('Soltero', 'Casado', 'Divorciado', 'Viudo', 'No especifica'),
  nacionalidad varchar(20),
  fecha_contratacion date,
  tipo_contrato enum('Indefinido', 'Fijo', 'Temporal', 'Aprendizaje', 'Otro'),
  jornada_laboral enum('Completa', 'Diurna', 'Nocturna', 'Flexible', 'Fines de semana'),
  salario_empleado decimal(10,2),
  eps_empleado varchar(30),
  estado_empleado enum('Activo', 'Inactivo', 'Vacaciones', 'Permiso'),
  tipo_cambio enum('Inserción', 'Actualización', 'Eliminación', 'Registro inicial') not null default 'Registro inicial',
  descripcion_cambio varchar(255) not null,
  fecha_cambio timestamp not null default current_timestamp,
  CONSTRAINT conspk_historial_empleado PRIMARY KEY (id_historial_empleado),
  FOREIGN KEY (id_empleado_fk) REFERENCES Empleado(id_empleado)
  ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (id_persona_fk) REFERENCES Persona(id_persona)
  ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (id_usuario_fk) REFERENCES Usuario(id_usuario)
  ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (id_usuario_modifico_fk) REFERENCES Usuario(id_usuario)
  ON DELETE RESTRICT ON UPDATE CASCADE
);

-- La tabla Historial_Proveedor permite la trazabilidad de cambios realizada en la tabla Proveedor

CREATE TABLE Historial_Proveedor (
  id_historial_proveedor int not null auto_increment,
  id_proveedor_fk int,
  id_usuario_modifico_fk int,
  nombre_proveedor varchar(30),
  tipo_documento_proveedor enum('Tarjeta de identidad', 'Cédula ciudadanía', 'Cédula extranjería', 'Pasaporte', 'NIT'),
  numero_documento_proveedor varchar(15),
  direccion_proveedor varchar(50) ,
  telefono_proveedor varchar(15),
  email_proveedor varchar(50),
  ciudad_proveedor varchar(20),
  fecha_registro_proveedor datetime,
  estado_proveedor enum('Activo', 'Inactivo', 'Eliminado'),
  tipo_cambio enum('Inserción', 'Actualización', 'Eliminación', 'Registro inicial') not null default 'Registro inicial',
  descripcion_cambio varchar(255) not null,
  fecha_cambio timestamp not null default current_timestamp,
  CONSTRAINT conspk_id_historial_proveedor PRIMARY KEY (id_historial_proveedor),
  FOREIGN KEY (id_proveedor_fk) REFERENCES Proveedor(id_proveedor)
  ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (id_usuario_modifico_fk) REFERENCES Usuario(id_usuario)
  ON DELETE RESTRICT ON UPDATE CASCADE
);

-- La tabla Historial_Movimiento permite la trazabilidad de cambios realizada en la tabla Movimiento

CREATE TABLE Historial_Movimiento (
  id_historial_movimiento int not null auto_increment,
  id_movimiento_fk int,
  id_producto_fk int,
  id_proveedor_fk int,
  id_usuario_fk int,
  id_usuario_modifico_fk int,
  codigo_factura varchar(50),
  precio_compra_unidad decimal(10,2),
  precio_venta_unidad decimal(10,2),
  cantidad_producto_movimiento int,
  total_costo_movimiento decimal(10,2),
  tipo_movimiento enum('Entrada', 'Salida', 'Devolución_Cliente', 'Devolución_Proveedor'),
  observaciones_movimiento varchar(255),
  fecha_movimiento datetime,
  tipo_cambio enum('Inserción', 'Actualización', 'Eliminación', 'Registro inicial') not null default 'Registro inicial',
  descripcion_cambio varchar(255) not null,
  fecha_cambio timestamp not null default current_timestamp,
  CONSTRAINT conspk_id_historial_movimiento PRIMARY KEY (id_historial_movimiento),
  FOREIGN KEY (id_movimiento_fk) REFERENCES Movimiento(id_movimiento)
  ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (id_producto_fk) REFERENCES Producto(id_producto)
  ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (id_proveedor_fk) REFERENCES Proveedor(id_proveedor)
  ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (id_usuario_fk) REFERENCES Usuario(id_usuario)
  ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (id_usuario_modifico_fk) REFERENCES Usuario(id_usuario)
  ON DELETE RESTRICT ON UPDATE CASCADE
);

-- La tabla Historial_Producto permite la trazabilidad de cambios realizada en la tabla Producto

CREATE TABLE Historial_Producto (
  id_historial_producto int not null auto_increment,
  id_producto_fk int,
  id_categoria_fk int,
  id_usuario_modifico_fk int not null,
  codigo_producto varchar(20),
  nombre_producto varchar(50),
  descripcion_producto varchar(255),
  stock_producto int,
  estado_producto enum('Disponible', 'Agotado', 'Eliminado', 'Reservado'),
  tipo_cambio enum('Inserción', 'Actualización', 'Eliminación', 'Registro inicial') not null default 'Registro inicial',
  descripcion_cambio varchar(255) not null,
  fecha_cambio timestamp not null default current_timestamp,
  CONSTRAINT conspk_id_historial_producto PRIMARY KEY (id_historial_producto),
  FOREIGN KEY (id_producto_fk) REFERENCES Producto(id_producto)
  ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (id_categoria_fk) REFERENCES Categoria(id_categoria)
  ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (id_usuario_modifico_fk) REFERENCES Usuario(id_usuario)
  ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE Historial_Categoria (
  id_historial_categoria int not null auto_increment,
  id_categoria_fk int,
  id_usuario_modifico_fk int not null,
  nombre_categoria varchar(30),
  descripcion_categoria varchar(255),
  tipo_cambio enum('Inserción', 'Actualización', 'Eliminación', 'Registro inicial') not null default 'Registro inicial',
  descripcion_cambio varchar(255) not null,
  fecha_cambio timestamp not null default current_timestamp,
  CONSTRAINT conspk_id_historial_categoria PRIMARY KEY (id_historial_categoria),
  FOREIGN KEY (id_usuario_modifico_fk) REFERENCES Usuario(id_usuario)
  ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Creación de disparadores/triggers para las tablas de historial(auditoria)

CREATE TRIGGER trg_insert_usuario
AFTER INSERT ON Usuario
FOR EACH ROW
INSERT INTO Historial_Usuario (
  id_usuario_modificado_fk,
  id_rol_fk,
  id_usuario_modifico_fk,
  nombre_usuario,
  contraseña_usuario_hash,
  estado_usuario,
  tipo_cambio,
  descripcion_cambio,
  fecha_cambio
)
VALUES (
  NEW.id_usuario,
  NEW.id_rol_fk,
  1,  
  NEW.nombre_usuario,
  NEW.contraseña_usuario_hash,
  NEW.estado_usuario,
  'Inserción',
  'Se insertó un nuevo usuario en el sistema',
  CURRENT_TIMESTAMP
);

CREATE TRIGGER trg_update_usuario
AFTER UPDATE ON Usuario
FOR EACH ROW
  INSERT INTO Historial_Usuario (
    id_usuario_modificado_fk,
    id_rol_fk,
    id_usuario_modifico_fk,
    nombre_usuario,
    contraseña_usuario_hash,
    estado_usuario,
    tipo_cambio,
    descripcion_cambio,
    fecha_cambio
  )
  VALUES (
    NEW.id_usuario,
    NEW.id_rol_fk,
    1, 
    NEW.nombre_usuario,
    NEW.contraseña_usuario_hash,
    NEW.estado_usuario,
    'Actualización',
    'Se actualizó el usuario en el sistema',
    CURRENT_TIMESTAMP
  );

CREATE TRIGGER trg_delete_usuario
AFTER DELETE ON Usuario
FOR EACH ROW
  INSERT INTO Historial_Usuario (
    id_usuario_modificado_fk,
    id_rol_fk,
    id_usuario_modifico_fk,
    nombre_usuario,
    contraseña_usuario_hash,
    estado_usuario,
    tipo_cambio,
    descripcion_cambio,
    fecha_cambio
  )
  VALUES (
    OLD.id_usuario,
    OLD.id_rol_fk,
    1, 
    OLD.nombre_usuario,
    OLD.contraseña_usuario_hash,
    OLD.estado_usuario,
    'Eliminación',
    'Se eliminó el usuario del sistema',
    CURRENT_TIMESTAMP
  );

CREATE TRIGGER trg_insert_rol
AFTER INSERT ON Rol
FOR EACH ROW
INSERT INTO Historial_Rol (
  id_rol_fk,
  nombre_rol, 
  descripcion_rol,
  tipo_cambio,
  descripcion_cambio,
  fecha_cambio
)
VALUES (
  NEW.id_rol,
  NEW.nombre_rol, 
  NEW.descripcion_rol,
  'Inserción',
  'Se insertó un nuevo rol en el sistema',
  CURRENT_TIMESTAMP
);

CREATE TRIGGER trg_update_rol
AFTER UPDATE ON Rol
FOR EACH ROW
INSERT INTO Historial_Rol (
  id_rol_fk,
  id_usuario_modifico_fk,
  nombre_rol, 
  descripcion_rol,
  tipo_cambio,
  descripcion_cambio,
  fecha_cambio
)
VALUES (
  NEW.id_rol,
  1,
  NEW.nombre_rol, 
  NEW.descripcion_rol,
 'Actualización',
 'Se actualizó el rol en el sistema',
 CURRENT_TIMESTAMP
);

CREATE TRIGGER trg_delete_rol
AFTER DELETE ON Rol
FOR EACH ROW
INSERT INTO Historial_Rol (
  id_rol_fk,
  id_usuario_modifico_fk,
  nombre_rol, 
  descripcion_rol,
  tipo_cambio,
  descripcion_cambio,
  fecha_cambio
)
VALUES (
  OLD.id_rol,
  1,
  OLD.nombre_rol, 
  OLD.descripcion_rol,
 'Eliminación',
 'Se eliminó el rol del sistema',
 CURRENT_TIMESTAMP
);

CREATE TRIGGER trg_insert_persona
AFTER INSERT ON Persona
FOR EACH ROW 
INSERT INTO Historial_Persona (
  id_persona_fk,
  id_usuario_modifico_fk,
  nombre_persona,
  apellido_persona,
  tipo_documento_persona,
  numero_documento_persona,
  direccion_persona,
  telefono_persona,
  email_persona,
  fecha_registro_persona,
  estado_persona,
  tipo_cambio,
  descripcion_cambio,
  fecha_cambio
  )
  VALUES (
  NEW.id_persona,
  1,
  NEW.nombre_persona,
  NEW.apellido_persona,
  NEW.tipo_documento_persona,
  NEW.numero_documento_persona,
  NEW.direccion_persona,
  NEW.telefono_persona,
  NEW.email_persona,
  NEW.fecha_registro_persona,
  NEW.estado_persona,
  'Inserción',
  'Se insertó una nueva persona en el sistema',
  CURRENT_TIMESTAMP
  );
  
CREATE TRIGGER trg_update_persona
AFTER UPDATE ON Persona
FOR EACH ROW 
INSERT INTO Historial_Persona (
  id_persona_fk,
  id_usuario_modifico_fk,
  nombre_persona,
  apellido_persona,
  tipo_documento_persona,
  numero_documento_persona,
  direccion_persona,
  telefono_persona,
  email_persona,
  fecha_registro_persona,
  estado_persona,
  tipo_cambio,
  descripcion_cambio,
  fecha_cambio
  )
  VALUES (
  NEW.id_persona,
  1,
  NEW.nombre_persona,
  NEW.apellido_persona,
  NEW.tipo_documento_persona,
  NEW.numero_documento_persona,
  NEW.direccion_persona,
  NEW.telefono_persona,
  NEW.email_persona,
  NEW.fecha_registro_persona,
  NEW.estado_persona,
  'Actualización',
  'Se actualizó una persona en el sistema',
  CURRENT_TIMESTAMP
  );
  
CREATE TRIGGER trg_delete_persona
AFTER DELETE ON Persona
FOR EACH ROW 
INSERT INTO Historial_Persona (
  id_persona_fk,
  id_usuario_modifico_fk,
  nombre_persona,
  apellido_persona,
  tipo_documento_persona,
  numero_documento_persona,
  direccion_persona,
  telefono_persona,
  email_persona,
  fecha_registro_persona,
  estado_persona,
  tipo_cambio,
  descripcion_cambio,
  fecha_cambio
  )
  VALUES (
  OLD.id_persona,
  1,
  OLD.nombre_persona,
  OLD.apellido_persona,
  OLD.tipo_documento_persona,
  OLD.numero_documento_persona,
  OLD.direccion_persona,
  OLD.telefono_persona,
  OLD.email_persona,
  OLD.fecha_registro_persona,
  OLD.estado_persona,
  'Eliminación',
  'Se eliminó a la persona del sistema',
  CURRENT_TIMESTAMP
  );
  
  CREATE TRIGGER trg_insert_empleado
  AFTER INSERT ON Empleado
  FOR EACH ROW
  INSERT INTO Historial_Empleado (
  id_empleado_fk,
  id_persona_fk,
  id_usuario_fk,
  id_usuario_modifico_fk,
  fecha_nacimiento,
  genero_empleado,
  estado_civil,
  nacionalidad,
  fecha_contratacion,
  tipo_contrato,
  jornada_laboral,
  salario_empleado,
  eps_empleado,
  estado_empleado,
  tipo_cambio,
  descripcion_cambio,
  fecha_cambio
  )
  VALUES (
  NEW.id_empleado,
  NEW.id_persona_fk,
  NEW.id_usuario_fk,
  1,
  NEW.fecha_nacimiento,
  NEW.genero_empleado,
  NEW.estado_civil,
  NEW.nacionalidad,
  NEW.fecha_contratacion,
  NEW.tipo_contrato,
  NEW.jornada_laboral,
  NEW.salario_empleado,
  NEW.eps_empleado,
  NEW.estado_empleado,
  'Inserción',
  'Se insertó un nuevo empleado en el sistema',
  CURRENT_TIMESTAMP
  );
  
  CREATE TRIGGER trg_update_empleado
  AFTER UPDATE ON Empleado
  FOR EACH ROW
  INSERT INTO Historial_Empleado (
  id_empleado_fk,
  id_persona_fk,
  id_usuario_fk,
  id_usuario_modifico_fk,
  fecha_nacimiento,
  genero_empleado,
  estado_civil,
  nacionalidad,
  fecha_contratacion,
  tipo_contrato,
  jornada_laboral,
  salario_empleado,
  eps_empleado,
  estado_empleado,
  tipo_cambio,
  descripcion_cambio,
  fecha_cambio
  )
  VALUES (
  NEW.id_empleado,
  NEW.id_persona_fk,
  NEW.id_usuario_fk,
  1,
  NEW.fecha_nacimiento,
  NEW.genero_empleado,
  NEW.estado_civil,
  NEW.nacionalidad,
  NEW.fecha_contratacion,
  NEW.tipo_contrato,
  NEW.jornada_laboral,
  NEW.salario_empleado,
  NEW.eps_empleado,
  NEW.estado_empleado,
  'Actualización',
  'Se actualizó un empleado en el sistema',
  CURRENT_TIMESTAMP
  );
  
  CREATE TRIGGER trg_delete_empleado
  AFTER DELETE ON Empleado
  FOR EACH ROW
  INSERT INTO Historial_Empleado (
  id_empleado_fk,
  id_persona_fk,
  id_usuario_fk,
  id_usuario_modifico_fk,
  fecha_nacimiento,
  genero_empleado,
  estado_civil,
  nacionalidad,
  fecha_contratacion,
  tipo_contrato,
  jornada_laboral,
  salario_empleado,
  eps_empleado,
  estado_empleado,
  tipo_cambio,
  descripcion_cambio,
  fecha_cambio
  )
  VALUES (
  OLD.id_empleado,
  OLD.id_persona_fk,
  OLD.id_usuario_fk,
  1,
  OLD.fecha_nacimiento,
  OLD.genero_empleado,
  OLD.estado_civil,
  OLD.nacionalidad,
  OLD.fecha_contratacion,
  OLD.tipo_contrato,
  OLD.jornada_laboral,
  OLD.salario_empleado,
  OLD.eps_empleado,
  OLD.estado_empleado,
  'Eliminación',
  'Se eliminó al empleado del sistema',
  CURRENT_TIMESTAMP
  );
  
  CREATE TRIGGER trg_insert_proveedor
  AFTER INSERT ON Proveedor
  FOR EACH ROW
  INSERT INTO Historial_Proveedor(
  id_proveedor_fk,
  id_usuario_modifico_fk,
  nombre_proveedor,
  tipo_documento_proveedor,
  numero_documento_proveedor,
  direccion_proveedor,
  telefono_proveedor,
  email_proveedor,
  ciudad_proveedor,
  fecha_registro_proveedor,
  estado_proveedor,
  tipo_cambio,
  descripcion_cambio,
  fecha_cambio
  )
  VALUES (
  NEW.id_proveedor,
  1,
  NEW.nombre_proveedor,
  NEW.tipo_documento_proveedor,
  NEW.numero_documento_proveedor,
  NEW.direccion_proveedor,
  NEW.telefono_proveedor,
  NEW.email_proveedor,
  NEW.ciudad_proveedor,
  NEW.fecha_registro_proveedor,
  NEW.estado_proveedor,
  'Inserción',
  'Se insertó un nuevo proveedor en el sistema',
  CURRENT_TIMESTAMP
  );
  
  CREATE TRIGGER trg_update_proveedor
  AFTER UPDATE ON Proveedor
  FOR EACH ROW
  INSERT INTO Historial_Proveedor (
  id_proveedor_fk,
  id_usuario_modifico_fk,
  nombre_proveedor,
  tipo_documento_proveedor,
  numero_documento_proveedor,
  direccion_proveedor,
  telefono_proveedor,
  email_proveedor,
  ciudad_proveedor,
  fecha_registro_proveedor,
  estado_proveedor,
  tipo_cambio,
  descripcion_cambio,
  fecha_cambio
  )
  VALUES (
  NEW.id_proveedor,
  1,
  NEW.nombre_proveedor,
  NEW.tipo_documento_proveedor,
  NEW.numero_documento_proveedor,
  NEW.direccion_proveedor,
  NEW.telefono_proveedor,
  NEW.email_proveedor,
  NEW.ciudad_proveedor,
  NEW.fecha_registro_proveedor,
  NEW.estado_proveedor,
  'Actualización',
  'Se actualizó un proveedor en el sistema',
  CURRENT_TIMESTAMP
  );
  
  CREATE TRIGGER trg_delete_proveedor
  AFTER DELETE ON Proveedor
  FOR EACH ROW
  INSERT INTO Historial_Proveedor (
  id_proveedor_fk,
  id_usuario_modifico_fk,
  nombre_proveedor,
  tipo_documento_proveedor,
  numero_documento_proveedor,
  direccion_proveedor,
  telefono_proveedor,
  email_proveedor,
  ciudad_proveedor,
  fecha_registro_proveedor,
  estado_proveedor,
  tipo_cambio,
  descripcion_cambio,
  fecha_cambio
  )
  VALUES (
  OLD.id_proveedor,
  1,
  OLD.nombre_proveedor,
  OLD.tipo_documento_proveedor,
  OLD.numero_documento_proveedor,
  OLD.direccion_proveedor,
  OLD.telefono_proveedor,
  OLD.email_proveedor,
  OLD.ciudad_proveedor,
  OLD.fecha_registro_proveedor,
  OLD.estado_proveedor,
  'Eliminación',
  'Se eliminó al proveedor del sistema',
  CURRENT_TIMESTAMP
  );
  
  CREATE TRIGGER trg_insert_movimiento
  AFTER INSERT ON Movimiento
  FOR EACH ROW
  INSERT INTO Historial_Movimiento (
  id_movimiento_fk,
  id_producto_fk,
  id_proveedor_fk,
  id_usuario_fk,
  id_usuario_modifico_fk,
  codigo_factura,
  precio_compra_unidad,
  precio_venta_unidad,
  cantidad_producto_movimiento,
  total_costo_movimiento,
  tipo_movimiento,
  observaciones_movimiento,
  fecha_movimiento,
  tipo_cambio,
  descripcion_cambio,
  fecha_cambio
  )
  VALUES (
  NEW.id_movimiento,
  NEW.id_producto_fk,
  NEW.id_proveedor_fk,
  NEW.id_usuario_fk,
  1,
  NEW.codigo_factura,
  NEW.precio_compra_unidad,
  NEW.precio_venta_unidad,
  NEW.cantidad_producto_movimiento,
  NEW.total_costo_movimiento,
  NEW.tipo_movimiento,
  NEW.observaciones_movimiento,
  NEW.fecha_movimiento,
  'Inserción',
  'Se insertó un nuevo movimiento en el sistema',
  CURRENT_TIMESTAMP
  );
  
  CREATE TRIGGER trg_update_movimiento
  AFTER UPDATE ON Movimiento
  FOR EACH ROW
  INSERT INTO Historial_Movimiento (
  id_movimiento_fk,
  id_producto_fk,
  id_proveedor_fk,
  id_usuario_fk,
  id_usuario_modifico_fk,
  codigo_factura,
  precio_compra_unidad,
  precio_venta_unidad,
  cantidad_producto_movimiento,
  total_costo_movimiento,
  tipo_movimiento,
  observaciones_movimiento,
  fecha_movimiento,
  tipo_cambio,
  descripcion_cambio,
  fecha_cambio
  )
  VALUES (
  NEW.id_movimiento,
  NEW.id_producto_fk,
  NEW.id_proveedor_fk,
  NEW.id_usuario_fk,
  1,
  NEW.codigo_factura,
  NEW.precio_compra_unidad,
  NEW.precio_venta_unidad,
  NEW.cantidad_producto_movimiento,
  NEW.total_costo_movimiento,
  NEW.tipo_movimiento,
  NEW.observaciones_movimiento,
  NEW.fecha_movimiento,
  'Actualización',
  'Se actualizó un movimiento en el sistema',
  CURRENT_TIMESTAMP
  );
  
  CREATE TRIGGER trg_delete_movimiento
  AFTER DELETE ON Movimiento
  FOR EACH ROW
  INSERT INTO Historial_Movimiento (
  id_movimiento_fk,
  id_producto_fk,
  id_proveedor_fk,
  id_usuario_fk,
  id_usuario_modifico_fk,
  codigo_factura,
  precio_compra_unidad,
  precio_venta_unidad,
  cantidad_producto_movimiento,
  total_costo_movimiento,
  tipo_movimiento,
  observaciones_movimiento,
  fecha_movimiento,
  tipo_cambio,
  descripcion_cambio,
  fecha_cambio
  )
  VALUES (
  OLD.id_movimiento,
  OLD.id_producto_fk,
  OLD.id_proveedor_fk,
  OLD.id_usuario_fk,
  1,
  OLD.codigo_factura,
  OLD.precio_compra_unidad,
  OLD.precio_venta_unidad,
  OLD.cantidad_producto_movimiento,
  OLD.total_costo_movimiento,
  OLD.tipo_movimiento,
  OLD.observaciones_movimiento,
  OLD.fecha_movimiento,
  'Eliminación',
  'Se eliminó al movimiento del sistema',
  CURRENT_TIMESTAMP
  );
  
  CREATE TRIGGER trg_insert_producto
  AFTER INSERT ON Producto
  FOR EACH ROW
  INSERT INTO Historial_Producto (
  id_producto_fk,
  id_categoria_fk,
  id_usuario_modifico_fk,
  codigo_producto,
  nombre_producto,
  descripcion_producto,
  stock_producto,
  estado_producto,
  tipo_cambio,
  descripcion_cambio,
  fecha_cambio
  )
  VALUES (
  NEW.id_producto,
  NEW.id_categoria_fk,
  1,
  NEW.codigo_producto,
  NEW.nombre_producto,
  NEW.descripcion_producto,
  NEW.stock_producto,
  NEW.estado_producto,
  'Inserción',
  'Se insertó un nuevo producto en el sistema',
  CURRENT_TIMESTAMP
  );

  CREATE TRIGGER trg_update_producto
  AFTER UPDATE ON Producto
  FOR EACH ROW
  INSERT INTO Historial_Producto (
  id_producto_fk,
  id_categoria_fk,
  id_usuario_modifico_fk,
  codigo_producto,
  nombre_producto,
  descripcion_producto,
  stock_producto,
  estado_producto,
  tipo_cambio,
  descripcion_cambio,
  fecha_cambio
  )
  VALUES (
  NEW.id_producto,
  NEW.id_categoria_fk,
  1,
  NEW.codigo_producto,
  NEW.nombre_producto,
  NEW.descripcion_producto,
  NEW.stock_producto,
  NEW.estado_producto,
  'Actualización',
  'Se actualizó un producto en el sistema',
  CURRENT_TIMESTAMP
  );
  
  CREATE TRIGGER trg_delete_producto
  AFTER DELETE ON Producto
  FOR EACH ROW
  INSERT INTO Historial_Producto (
  id_producto_fk,
  id_categoria_fk,
  id_usuario_modifico_fk,
  codigo_producto,
  nombre_producto,
  descripcion_producto,
  stock_producto,
  estado_producto,
  tipo_cambio,
  descripcion_cambio,
  fecha_cambio
  )
  VALUES (
  OLD.id_producto,
  OLD.id_categoria_fk,
  1,
  OLD.codigo_producto,
  OLD.nombre_producto,
  OLD.descripcion_producto,
  OLD.stock_producto,
  OLD.estado_producto,
  'Eliminación',
  'Se eliminó al producto del sistema',
  CURRENT_TIMESTAMP
  );

CREATE TRIGGER trg_insert_categoria
AFTER INSERT ON Categoria
FOR EACH ROW
INSERT INTO Historial_Categoria (
  id_categoria_fk,
  id_usuario_modifico_fk,
  nombre_categoria,
  descripcion_categoria,
  tipo_cambio,
  descripcion_cambio,
  fecha_cambio
)
VALUES (
  NEW.id_categoria,
  1,
  NEW.nombre_categoria,
  NEW.descripcion_categoria,
  'Inserción',
  'Se insertó una nueva caategoría en el sistema',
  CURRENT_TIMESTAMP
);

CREATE TRIGGER trg_update_categoria
AFTER UPDATE ON Categoria
FOR EACH ROW
INSERT INTO Historial_Categoria (
  id_categoria_fk,
  id_usuario_modifico_fk,
  nombre_categoria,
  descripcion_categoria,
  tipo_cambio,
  descripcion_cambio,
  fecha_cambio
)
VALUES (
  NEW.id_categoria,
  1,
  NEW.nombre_categoria,
  NEW.descripcion_categoria,
  'Actualización',
  'Se actualizó una categoría en el sistema',
  CURRENT_TIMESTAMP
);

CREATE TRIGGER trg_delete_categoria
AFTER DELETE ON Categoria
FOR EACH ROW
INSERT INTO Historial_Categoria (
  id_categoria_fk,
  id_usuario_modifico_fk,
  nombre_categoria,
  descripcion_categoria,
  tipo_cambio,
  descripcion_cambio,
  fecha_cambio
)
VALUES (
  OLD.id_categoria,
  1,
  OLD.nombre_categoria,
  OLD.descripcion_categoria,
  'Eliminación',
  'Se eliminó la categoría sistema',
  CURRENT_TIMESTAMP
);

-- Prueba de inserts 

-- Inserts para la tabla Rol
INSERT INTO Rol (nombre_rol, descripcion_rol) 
VALUES 
('Administrador', 'Acceso completo al sistema'),
('Empleado', 'Acceso limitado a funciones operativas'),
('Cliente', 'Acceso a compras y consultas'),
('Proveedor', 'Gestión de productos y servicios'),
('Auditor', 'Acceso a registros y auditorías');

-- Inserts para la tabla Usuario
INSERT INTO Usuario (id_rol_fk, nombre_usuario, contraseña_usuario_hash) 
VALUES 
(1, 'admin', 'hashed_password_1'),
(2, 'empleado1', 'hashed_password_2'),
(3, 'cliente1', 'hashed_password_3'),
(4, 'proveedor1', 'hashed_password_4'),
(5, 'auditor1', 'hashed_password_5');

-- Inserts para la tabla Persona
INSERT INTO Persona (nombre_persona, apellido_persona, tipo_documento_persona, numero_documento_persona, direccion_persona, telefono_persona, email_persona) 
VALUES 
('Juan', 'Pérez', 'Cédula ciudadanía', '123456789', 'Calle 123', '3001234567', 'juan.perez@example.com'),
('María', 'Gómez', 'Cédula ciudadanía', '987654321', 'Carrera 45', '3109876543', 'maria.gomez@example.com'),
('Carlos', 'Rodríguez', 'Pasaporte', 'A1234567', 'Avenida 10', '3201239876', 'carlos.rodriguez@example.com'),
('Ana', 'Martínez', 'NIT', '900123456', 'Calle 50', '3004567890', 'ana.martinez@example.com'),
('Luis', 'Hernández', 'Cédula extranjería', 'E123456', 'Carrera 20', '3106543210', 'luis.hernandez@example.com');

-- Inserts para la tabla Empleado
INSERT INTO Empleado (id_persona_fk, id_usuario_fk, fecha_nacimiento, genero_empleado, estado_civil, nacionalidad, fecha_contratacion, tipo_contrato, jornada_laboral, salario_empleado, eps_empleado) 
VALUES 
(1, 2, '1990-01-01', 'Masculino', 'Soltero', 'Colombiana', '2023-01-01', 'Indefinido', 'Completa', 2000000, 'EPS1'),
(2, 3, '1985-05-15', 'Femenino', 'Casado', 'Colombiana', '2023-02-01', 'Fijo', 'Diurna', 1800000, 'EPS2'),
(3, 4, '1992-07-20', 'Masculino', 'Divorciado', 'Venezolana', '2023-03-01', 'Temporal', 'Nocturna', 1500000, 'EPS3'),
(4, 5, '1988-10-10', 'Femenino', 'Viudo', 'Peruana', '2023-04-01', 'Aprendizaje', 'Flexible', 1200000, 'EPS4'),
(5, 1, '1995-12-25', 'Prefiero no decirlo', 'No especifica', 'Ecuatoriana', '2023-05-01', 'Otro', 'Fines de semana', 1000000, 'EPS5');

-- Inserts para la tabla Venta
INSERT INTO Venta (id_persona_fk, id_empleado_fk, total_venta, estado_venta) 
VALUES 
(1, 1, 700000, 'Pagada'),
(2, 2, 300000, 'Completada'),
(3, 3, 150000, 'Pendiente'),
(4, 4, 1000000, 'Cancelada'),
(5, 5, 400000, 'Reembolsada');

-- Inserts para la tabla Proveedor
INSERT INTO Proveedor (nombre_proveedor, tipo_documento_proveedor, numero_documento_proveedor, direccion_proveedor, telefono_proveedor, email_proveedor, ciudad_proveedor) 
VALUES 
('Proveedor1', 'NIT', '900123456', 'Calle 10', '3001234567', 'proveedor1@example.com', 'Bogotá'),
('Proveedor2', 'Cédula ciudadanía', '123456789', 'Carrera 20', '3109876543', 'proveedor2@example.com', 'Medellín'),
('Proveedor3', 'Pasaporte', 'A1234567', 'Avenida 30', '3201239876', 'proveedor3@example.com', 'Cali'),
('Proveedor4', 'Cédula extranjería', 'E123456', 'Calle 40', '3004567890', 'proveedor4@example.com', 'Barranquilla'),
('Proveedor5', 'Tarjeta de identidad', 'TI123456', 'Carrera 50', '3106543210', 'proveedor5@example.com', 'Cartagena');

-- Inserts para la tabla Categoria
INSERT INTO Categoria (nombre_categoria, descripcion_categoria) 
VALUES 
('Anillos', 'Categoría de anillos'),
('Collares', 'Categoría de collares'),
('Pulseras', 'Categoría de pulseras'),
('Relojes', 'Categoría de relojes'),
('Aretes', 'Categoría de aretes');

-- Inserts para la tabla Producto
INSERT INTO Producto (id_categoria_fk, codigo_producto, nombre_producto, descripcion_producto, stock_producto) 
VALUES 
(1, 'A001', 'Anillo de oro', 'Anillo de oro 18k', 10),
(2, 'C001', 'Collar de plata', 'Collar de plata 925', 20),
(3, 'P001', 'Pulsera de cuero', 'Pulsera de cuero artesanal', 15),
(4, 'R001', 'Reloj digital', 'Reloj digital resistente al agua', 5),
(5, 'E001', 'Aretes de perlas', 'Aretes de perlas naturales', 25);

-- Inserts para la tabla Movimiento
INSERT INTO Movimiento (id_producto_fk, id_proveedor_fk, id_usuario_fk, precio_compra_unidad, precio_venta_unidad, cantidad_producto_movimiento, total_costo_movimiento, tipo_movimiento, observaciones_movimiento) 
VALUES 
(1, 1, 1, 500000, 700000, 10, 5000000, 'Entrada', 'Compra inicial'),
(2, 2, 2, 200000, 300000, 20, 4000000, 'Entrada', 'Compra inicial'),
(3, 3, 3, 100000, 150000, 15, 1500000, 'Entrada', 'Compra inicial'),
(4, 4, 4, 800000, 1000000, 5, 4000000, 'Entrada', 'Compra inicial'),
(5, 5, 5, 300000, 400000, 25, 7500000, 'Entrada', 'Compra inicial');

-- Inserts para la tabla Venta_Credito
INSERT INTO Venta_Credito (id_venta_fk, numero_cuotas, valor_cuota, estado_credito, fecha_fin, interes_mensual, saldo_pendiente) 
VALUES 
(1, 12, 58333.33, 'Activo', '2024-01-01', 1.5, 700000),
(2, 6, 50000, 'Pendiente', '2023-12-01', 1.2, 300000),
(3, 10, 15000, 'En mora', '2024-03-01', 2.0, 150000),
(4, 8, 125000, 'Cancelado', '2023-11-01', 1.8, 1000000),
(5, 5, 80000, 'Pagado', '2023-10-01', 1.0, 400000);

-- Inserts para la tabla Venta_Producto
INSERT INTO Venta_Producto (id_producto_fk, id_venta_fk, codigo_venta, cantidad_producto, precio_unitario, metodo_pago, subtotal_venta, descuento_venta) 
VALUES 
(1, 1, 'V001', 2, 700000, 'Efectivo', 1400000, 0),
(2, 2, 'V002', 1, 300000, 'Tarjeta crédito', 300000, 0),
(3, 3, 'V003', 3, 150000, 'Transferencia', 450000, 50000),
(4, 4, 'V004', 1, 1000000, 'Cheque', 1000000, 100000),
(5, 5, 'V005', 5, 400000, 'Pago móvil', 2000000, 200000);

-- Select para verificar los datos insertados

SELECT * FROM Rol;

SELECT * FROM Usuario;

SELECT * FROM Persona;

SELECT * FROM Empleado;

SELECT * FROM Venta;

SELECT * FROM Proveedor;

SELECT * FROM Categoria;

SELECT * FROM Producto;

SELECT * FROM Movimiento;

SELECT * FROM Venta_Credito;

SELECT * FROM Venta_Producto;

SELECT * FROM Historial_Usuario;

SELECT * FROM Historial_Rol;

SELECT * FROM Historial_Persona;

SELECT * FROM Historial_Empleado;

SELECT * FROM Historial_Proveedor;

SELECT * FROM Historial_Movimiento;

SELECT * FROM Historial_Producto;

SELECT * FROM Historial_Categoria;