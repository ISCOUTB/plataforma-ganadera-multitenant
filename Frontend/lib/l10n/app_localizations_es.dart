// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class SEs extends S {
  SEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'FarmLink';

  @override
  String get appSlogan => 'Gestión ganadera inteligente';

  @override
  String get login => 'Iniciar sesión';

  @override
  String get loginSubtitle => 'Ingresa tus credenciales para continuar';

  @override
  String get email => 'Correo electrónico';

  @override
  String get emailHint => 'correo@ejemplo.com';

  @override
  String get emailInvalid => 'Correo inválido';

  @override
  String get password => 'Contraseña';

  @override
  String get passwordHint => '••••••••';

  @override
  String get passwordMin => 'Mínimo 6 caracteres';

  @override
  String get enter => 'Entrar';

  @override
  String get noAccount => '¿No tienes cuenta? ';

  @override
  String get register => 'Registrarse';

  @override
  String get registerTitle => 'Crear cuenta';

  @override
  String get fullName => 'Nombre completo';

  @override
  String get phone => 'Teléfono (opcional)';

  @override
  String get tenantId => 'Tenant ID (organización)';

  @override
  String get tenantHint => 'tenant-a';

  @override
  String get createAccount => 'Crear cuenta';

  @override
  String get required => 'Requerido';

  @override
  String get splashLoading => 'Cargando...';

  @override
  String get home => 'HOME';

  @override
  String get inventory => 'INVENTORY';

  @override
  String get health => 'HEALTH';

  @override
  String get money => 'MONEY';

  @override
  String get settings => 'SETTINGS';

  @override
  String goodMorning(String name) {
    return 'Buenos días, $name';
  }

  @override
  String get demography => 'Demografía del hato';

  @override
  String activeAnimals(int count) {
    return '$count activos';
  }

  @override
  String get production => 'Producción';

  @override
  String get growth => 'Crecimiento';

  @override
  String get dry => 'Secas';

  @override
  String get landOccupancy => 'Ocupación del terreno';

  @override
  String hectaresOf(int total) {
    return 'de $total ha totales';
  }

  @override
  String get saturatedLand => 'Terreno saturado';

  @override
  String get highUsage => 'Uso alto';

  @override
  String get availableCapacity => 'Capacidad disponible';

  @override
  String get criticalAlerts => 'ALERTAS CRÍTICAS';

  @override
  String get allGood => '¡Todo en orden!';

  @override
  String get noAlertsMessage =>
      'No hay alertas críticas. Comienza a registrar eventos de salud para llevar el historial de tu hato.';

  @override
  String get addMedicalRecord => 'Añadir registro médico';

  @override
  String get urgent => 'URGENTE';

  @override
  String get recentMovements => 'MOVIMIENTOS RECIENTES';

  @override
  String get noMovementsYet => 'Sin movimientos aún';

  @override
  String get noMovementsMessage =>
      'Cuando traslades animales entre potreros aparecerán aquí los 5 más recientes.';

  @override
  String get registerMovement => 'Registrar movimiento';

  @override
  String get showingCachedData => 'Mostrando datos guardados · actualizando…';

  @override
  String get inventoryTitle => 'Inventario';

  @override
  String get inventorySubtitle => 'Animales, fincas y potreros';

  @override
  String get animals => 'Animales';

  @override
  String get animalsDescription =>
      'Listado, filtros, alta, edición, venta y costos por animal';

  @override
  String get farms => 'Fincas';

  @override
  String get farmsDescription => 'Predios, ubicaciones y propietarios';

  @override
  String get paddocks => 'Potreros';

  @override
  String get paddocksDescription => 'Capacidad, ocupación y rotación';

  @override
  String get animalsTitle => 'Animales';

  @override
  String get animalsSubtitle => 'Inventario de bovinos';

  @override
  String get allFilter => 'Todos';

  @override
  String get activeFilter => 'Activos';

  @override
  String get soldFilter => 'Vendidos';

  @override
  String get maleFilter => 'Machos';

  @override
  String get femaleFilter => 'Hembras';

  @override
  String get noAnimals => 'Sin animales';

  @override
  String get createFirstAnimal => 'Crea tu primer bovino con el +';

  @override
  String get male => 'Macho';

  @override
  String get female => 'Hembra';

  @override
  String get neuter => 'Neutro';

  @override
  String get active => 'Activo';

  @override
  String get sold => 'Vendido';

  @override
  String get newAnimal => 'Nuevo animal';

  @override
  String get editAnimal => 'Editar animal';

  @override
  String get registerBovine => 'Registra un nuevo bovino';

  @override
  String get idNumber => 'Número de identificación';

  @override
  String get breed => 'Raza';

  @override
  String get gender => 'Género';

  @override
  String get weight => 'Peso (kg)';

  @override
  String get height => 'Altura (m)';

  @override
  String get birthDate => 'Fecha de nacimiento';

  @override
  String get farmId => 'Finca (ID)';

  @override
  String get paddockId => 'ID de potrero';

  @override
  String get createAnimal => 'Crear animal';

  @override
  String get saveChanges => 'Guardar cambios';

  @override
  String get animalUpdated => 'Animal actualizado';

  @override
  String get animalCreated => 'Animal creado';

  @override
  String get animalDeleted => 'Animal eliminado';

  @override
  String get sellAnimal => 'Vender animal';

  @override
  String get sellDescription =>
      'Se creará automáticamente un movimiento de ingreso en finanzas';

  @override
  String get salePrice => 'Precio de venta';

  @override
  String get buyer => 'Comprador';

  @override
  String get saleDate => 'Fecha de venta';

  @override
  String get confirmSale => 'Confirmar venta';

  @override
  String get animalSold => 'Animal vendido — registro financiero creado';

  @override
  String get accumulatedCosts => 'COSTOS ACUMULADOS';

  @override
  String get healthCost => 'Salud';

  @override
  String get feedingCost => 'Alimentación';

  @override
  String get totalCost => 'Total';

  @override
  String get feedingHistory => 'Historial de Alimentación';

  @override
  String get addFeeding => 'Registrar alimentación';

  @override
  String get selectFood => 'Selecciona un alimento';

  @override
  String get amountKg => 'Cantidad (kg)';

  @override
  String get feedingDate => 'Fecha';

  @override
  String get feedingRegistered => 'Alimentación registrada';

  @override
  String get save => 'Guardar';

  @override
  String get deleteAnimal => '¿Eliminar animal?';

  @override
  String get deleteAnimalMessage =>
      'Quedará marcado como eliminado y no aparecerá en los listados.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get farmsTitle => 'Fincas';

  @override
  String get farmsSubtitle => 'Gestiona tus predios';

  @override
  String get noFarms => 'Sin fincas registradas';

  @override
  String get createFirstFarm => 'Toca el + para crear tu primera finca.';

  @override
  String get newFarm => 'Nueva finca';

  @override
  String get editFarm => 'Editar finca';

  @override
  String get createNewFarm => 'Crea un nuevo predio';

  @override
  String get farmIdLabel => 'ID de finca';

  @override
  String get farmName => 'Nombre de la finca';

  @override
  String get location => 'Ubicación';

  @override
  String get owner => 'Propietario';

  @override
  String get totalArea => 'Área total (ha)';

  @override
  String get createFarm => 'Crear finca';

  @override
  String get farmCreated => 'Finca creada';

  @override
  String get farmUpdated => 'Finca actualizada';

  @override
  String get farmDeleted => 'Finca eliminada';

  @override
  String get deleteFarm => '¿Eliminar finca?';

  @override
  String get deleteFarmMessage =>
      'Se borrará la finca. Los datos asociados se mantendrán en histórico.';

  @override
  String get registered => 'Registrada';

  @override
  String get paddocksTitle => 'Potreros';

  @override
  String get paddocksSubtitle => 'Capacidad y rotaciones';

  @override
  String get noPaddocks => 'Sin potreros aún';

  @override
  String get createFirstPaddock => 'Crea tu primer potrero con el botón +';

  @override
  String get newPaddock => 'Nuevo potrero';

  @override
  String get editPaddock => 'Editar potrero';

  @override
  String get configurePaddock => 'Configura un nuevo potrero';

  @override
  String get paddockName => 'Nombre';

  @override
  String get capacity => 'Capacidad de animales';

  @override
  String get area => 'Área (ha)';

  @override
  String get status => 'Estado';

  @override
  String get statusActive => 'Activo';

  @override
  String get statusRotation => 'En rotación';

  @override
  String get statusInactive => 'Inactivo';

  @override
  String get createPaddock => 'Crear potrero';

  @override
  String get paddockCreated => 'Potrero creado';

  @override
  String get paddockUpdated => 'Potrero actualizado';

  @override
  String get paddockDeleted => 'Potrero eliminado';

  @override
  String get deletePaddock => '¿Eliminar potrero?';

  @override
  String get deletePaddockMessage =>
      'El potrero quedará marcado como eliminado.';

  @override
  String get occupancy => 'OCUPACIÓN';

  @override
  String get healthTitle => 'Salud';

  @override
  String get healthSubtitle => 'Bienestar del hato';

  @override
  String get healthRecords => 'Registros de salud';

  @override
  String get healthRecordsDescription =>
      'Vacunas, vitaminas, desparasitaciones, enfermedades';

  @override
  String get reproduction => 'Reproducción';

  @override
  String get reproductionDescription => 'Celos, montas, preñeces y partos';

  @override
  String get alertCenter => 'Centro de alertas';

  @override
  String get alertCenterDescription =>
      'Vista consolidada de todas las urgencias';

  @override
  String get healthListTitle => 'Salud';

  @override
  String get healthListSubtitle => 'Vacunas, desparasitaciones y enfermedades';

  @override
  String get noHealthRecords => 'Sin registros de salud';

  @override
  String get registerHealthRecord =>
      'Registra vacunas y tratamientos con el botón +';

  @override
  String get vaccination => 'Vacunación';

  @override
  String get vitamins => 'Vitaminas';

  @override
  String get deworming => 'Desparasitación';

  @override
  String get illness => 'Enfermedad';

  @override
  String get newHealthRecord => 'Nuevo registro de salud';

  @override
  String get editHealthRecord => 'Editar registro';

  @override
  String get interventionType => 'Tipo de intervención';

  @override
  String get appliedProduct => 'Producto aplicado';

  @override
  String get dose => 'Dosis';

  @override
  String get applicationDate => 'Fecha de aplicación';

  @override
  String get nextApplication => 'Próxima aplicación (opcional)';

  @override
  String get notDefined => 'Sin definir';

  @override
  String get cost => 'Costo';

  @override
  String get animalId => 'ID de animal';

  @override
  String get createRecord => 'Crear registro';

  @override
  String get recordCreated => 'Registro creado';

  @override
  String get recordUpdated => 'Registro actualizado';

  @override
  String get recordDeleted => 'Registro eliminado';

  @override
  String get deleteRecord => '¿Eliminar registro?';

  @override
  String get deleteRecordMessage =>
      'Este registro sanitario quedará marcado como eliminado.';

  @override
  String get reproductionTitle => 'Reproducción';

  @override
  String get reproductionSubtitle => 'Celos, montas y partos';

  @override
  String get noReproductionEvents => 'Sin eventos reproductivos';

  @override
  String get createFirstEvent => 'Crea el primer evento con el +';

  @override
  String get newReproEvent => 'Nuevo evento reproductivo';

  @override
  String get editReproEvent => 'Editar evento';

  @override
  String get eventId => 'ID del evento';

  @override
  String get reproMethod => 'Método reproductivo';

  @override
  String get inHeat => 'En celo';

  @override
  String get pregnant => 'Preñada';

  @override
  String get expectedOffspring => 'Número de crías esperadas';

  @override
  String get estimatedDueDate => 'Fecha estimada de parto';

  @override
  String get createEvent => 'Crear evento';

  @override
  String get eventCreated => 'Evento creado';

  @override
  String get eventUpdated => 'Evento actualizado';

  @override
  String get alertsTitle => 'Alertas';

  @override
  String get alertsSubtitle => 'Centro consolidado de urgencias';

  @override
  String get activeAlerts => 'alertas activas';

  @override
  String urgentNeedAttention(int count) {
    return '$count urgente(s) — requieren atención';
  }

  @override
  String get underControl => 'Todo bajo control';

  @override
  String get overdueHealth => 'Salud vencida';

  @override
  String get upcomingHealth => 'Salud próxima';

  @override
  String get upcomingBirths => 'Partos próximos';

  @override
  String get inHeatLabel => 'En celo';

  @override
  String get prioritized => 'PRIORIZADAS';

  @override
  String get highSeverity => 'Alta';

  @override
  String get mediumSeverity => 'Media';

  @override
  String get lowSeverity => 'Baja';

  @override
  String get operationsTitle => 'Operación';

  @override
  String get operationsSubtitle => 'Finanzas, alimentos y traslados';

  @override
  String get finances => 'Finanzas';

  @override
  String get financesDescription => 'Ingresos, gastos y resumen';

  @override
  String get food => 'Alimentos';

  @override
  String get foodDescription => 'Inventario de alimentación del hato';

  @override
  String get movements => 'Movimientos';

  @override
  String get movementsDescription => 'Traslados entre potreros';

  @override
  String get financesTitle => 'Finanzas';

  @override
  String get financesSubtitle => 'Ingresos y gastos';

  @override
  String get noFinances => 'Sin movimientos financieros';

  @override
  String get income => 'Ingresos';

  @override
  String get expenses => 'Gastos';

  @override
  String get balance => 'Balance';

  @override
  String get incomeType => 'Ingreso';

  @override
  String get expenseType => 'Gasto';

  @override
  String get newTransaction => 'Nuevo movimiento';

  @override
  String get editTransaction => 'Editar movimiento';

  @override
  String get incomeOrExpense => 'Ingreso o gasto';

  @override
  String get transactionId => 'ID del movimiento';

  @override
  String get transactionType => 'Tipo de movimiento';

  @override
  String get concept => 'Concepto';

  @override
  String get category => 'Categoría';

  @override
  String get amount => 'Monto';

  @override
  String get date => 'Fecha';

  @override
  String get paymentMethod => 'Método de pago';

  @override
  String get createTransaction => 'Crear movimiento';

  @override
  String get transactionCreated => 'Movimiento creado';

  @override
  String get transactionUpdated => 'Movimiento actualizado';

  @override
  String get foodTitle => 'Alimentos';

  @override
  String get foodSubtitle => 'Inventario de alimentación';

  @override
  String get noFood => 'Sin alimentos registrados';

  @override
  String get newFood => 'Nuevo alimento';

  @override
  String get editFood => 'Editar alimento';

  @override
  String get foodId => 'ID del alimento';

  @override
  String get foodType => 'Tipo de alimento';

  @override
  String get totalQuantity => 'Cantidad total';

  @override
  String get frequency => 'Frecuencia';

  @override
  String get createFood => 'Crear alimento';

  @override
  String get foodCreated => 'Alimento creado';

  @override
  String get foodUpdated => 'Alimento actualizado';

  @override
  String get movementsTitle => 'Movimientos';

  @override
  String get movementsSubtitle => 'Traslados entre potreros';

  @override
  String get noMovements => 'Sin movimientos registrados';

  @override
  String get newMovement => 'Nuevo movimiento';

  @override
  String get transferAnimal => 'Traslada un animal entre potreros';

  @override
  String get originPaddock => 'Potrero origen';

  @override
  String get destinationPaddock => 'Potrero destino';

  @override
  String get transferDate => 'Fecha del traslado';

  @override
  String get reason => 'Motivo';

  @override
  String get registerTransfer => 'Registrar movimiento';

  @override
  String get movementRegistered => 'Movimiento registrado';

  @override
  String get movementDetail => 'Detalle del movimiento';

  @override
  String get origin => 'Origen';

  @override
  String get destination => 'Destino';

  @override
  String get animal => 'Animal';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsSubtitle => 'Tu cuenta y preferencias';

  @override
  String get organization => 'ORGANIZACIÓN';

  @override
  String get tenantUsers => 'Usuarios del tenant';

  @override
  String get account => 'CUENTA';

  @override
  String get changePassword => 'Cambiar contraseña';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get language => 'Idioma';

  @override
  String get spanish => 'Español';

  @override
  String get english => 'English';

  @override
  String get about => 'SOBRE';

  @override
  String get version => 'Versión';

  @override
  String get termsAndPrivacy => 'Términos y privacidad';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get logoutConfirm => '¿Cerrar sesión?';

  @override
  String get logoutMessage =>
      'Tendrás que volver a ingresar tus credenciales para entrar.';

  @override
  String get copyright => 'FarmLink © 2026';

  @override
  String get tenantUsersTitle => 'Usuarios del tenant';

  @override
  String get tenantUsersSubtitle => 'Miembros de tu organización';

  @override
  String get addUser => 'Agregar usuario';

  @override
  String get editUser => 'Editar usuario';

  @override
  String get deleteUser => 'Eliminar usuario';

  @override
  String get confirmDelete => '¿Confirmar eliminación?';

  @override
  String confirmDeleteUserMessage(String name) {
    return 'El usuario \"$name\" será eliminado y no aparecerá en la lista.';
  }

  @override
  String get userCreated => 'Usuario creado';

  @override
  String get userUpdated => 'Usuario actualizado';

  @override
  String get userDeleted => 'Usuario eliminado';

  @override
  String get role => 'Rol';

  @override
  String get roleAdmin => 'Administrador';

  @override
  String get rolePropietario => 'Propietario';

  @override
  String get roleEmpleado => 'Empleado';

  @override
  String get quickCreate => 'Creación rápida';

  @override
  String get quickCreateSubtitle => 'Elige qué quieres registrar';

  @override
  String get newAnimalQuick => 'Nuevo animal';

  @override
  String get newAnimalHint => 'Registrar un bovino en el inventario';

  @override
  String get newFarmQuick => 'Nueva finca';

  @override
  String get newFarmHint => 'Dar de alta una finca o predio';

  @override
  String get newPaddockQuick => 'Nuevo potrero';

  @override
  String get newPaddockHint => 'Configurar un nuevo potrero';

  @override
  String get newHealthQuick => 'Registrar evento de salud';

  @override
  String get newHealthHint => 'Vacuna, desparasitación, enfermedad...';

  @override
  String get newFinanceQuick => 'Registrar movimiento financiero';

  @override
  String get newFinanceHint => 'Ingreso o gasto';

  @override
  String get newTransferQuick => 'Registrar traslado';

  @override
  String get newTransferHint => 'Mover animal entre potreros';

  @override
  String get retry => 'Reintentar';

  @override
  String get comingSoon => 'Próximamente';

  @override
  String get noDetail => 'Sin detalle';

  @override
  String get noReason => 'Sin motivo';

  @override
  String get farm => 'Finca';

  @override
  String get paddock => 'Potrero';
}
