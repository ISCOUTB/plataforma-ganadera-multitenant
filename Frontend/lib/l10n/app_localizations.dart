import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of S
/// returned by `S.of(context)`.
///
/// Applications need to include `S.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: S.localizationsDelegates,
///   supportedLocales: S.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the S.supportedLocales
/// property.
abstract class S {
  S(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S)!;
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appName.
  ///
  /// In es, this message translates to:
  /// **'FarmLink'**
  String get appName;

  /// No description provided for @appSlogan.
  ///
  /// In es, this message translates to:
  /// **'Gestión ganadera inteligente'**
  String get appSlogan;

  /// No description provided for @login.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get login;

  /// No description provided for @loginSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tus credenciales para continuar'**
  String get loginSubtitle;

  /// No description provided for @email.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get email;

  /// No description provided for @emailHint.
  ///
  /// In es, this message translates to:
  /// **'correo@ejemplo.com'**
  String get emailHint;

  /// No description provided for @emailInvalid.
  ///
  /// In es, this message translates to:
  /// **'Correo inválido'**
  String get emailInvalid;

  /// No description provided for @password.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get password;

  /// No description provided for @passwordHint.
  ///
  /// In es, this message translates to:
  /// **'••••••••'**
  String get passwordHint;

  /// No description provided for @passwordMin.
  ///
  /// In es, this message translates to:
  /// **'Mínimo 6 caracteres'**
  String get passwordMin;

  /// No description provided for @enter.
  ///
  /// In es, this message translates to:
  /// **'Entrar'**
  String get enter;

  /// No description provided for @noAccount.
  ///
  /// In es, this message translates to:
  /// **'¿No tienes cuenta? '**
  String get noAccount;

  /// No description provided for @register.
  ///
  /// In es, this message translates to:
  /// **'Registrarse'**
  String get register;

  /// No description provided for @registerTitle.
  ///
  /// In es, this message translates to:
  /// **'Crear cuenta'**
  String get registerTitle;

  /// No description provided for @fullName.
  ///
  /// In es, this message translates to:
  /// **'Nombre completo'**
  String get fullName;

  /// No description provided for @phone.
  ///
  /// In es, this message translates to:
  /// **'Teléfono (opcional)'**
  String get phone;

  /// No description provided for @tenantId.
  ///
  /// In es, this message translates to:
  /// **'Tenant ID (organización)'**
  String get tenantId;

  /// No description provided for @tenantHint.
  ///
  /// In es, this message translates to:
  /// **'tenant-a'**
  String get tenantHint;

  /// No description provided for @createAccount.
  ///
  /// In es, this message translates to:
  /// **'Crear cuenta'**
  String get createAccount;

  /// No description provided for @required.
  ///
  /// In es, this message translates to:
  /// **'Requerido'**
  String get required;

  /// No description provided for @splashLoading.
  ///
  /// In es, this message translates to:
  /// **'Cargando...'**
  String get splashLoading;

  /// No description provided for @home.
  ///
  /// In es, this message translates to:
  /// **'HOME'**
  String get home;

  /// No description provided for @inventory.
  ///
  /// In es, this message translates to:
  /// **'INVENTORY'**
  String get inventory;

  /// No description provided for @health.
  ///
  /// In es, this message translates to:
  /// **'HEALTH'**
  String get health;

  /// No description provided for @money.
  ///
  /// In es, this message translates to:
  /// **'MONEY'**
  String get money;

  /// No description provided for @settings.
  ///
  /// In es, this message translates to:
  /// **'SETTINGS'**
  String get settings;

  /// No description provided for @goodMorning.
  ///
  /// In es, this message translates to:
  /// **'Buenos días, {name}'**
  String goodMorning(String name);

  /// No description provided for @demography.
  ///
  /// In es, this message translates to:
  /// **'Demografía del hato'**
  String get demography;

  /// No description provided for @activeAnimals.
  ///
  /// In es, this message translates to:
  /// **'{count} activos'**
  String activeAnimals(int count);

  /// No description provided for @production.
  ///
  /// In es, this message translates to:
  /// **'Producción'**
  String get production;

  /// No description provided for @growth.
  ///
  /// In es, this message translates to:
  /// **'Crecimiento'**
  String get growth;

  /// No description provided for @dry.
  ///
  /// In es, this message translates to:
  /// **'Secas'**
  String get dry;

  /// No description provided for @landOccupancy.
  ///
  /// In es, this message translates to:
  /// **'Ocupación del terreno'**
  String get landOccupancy;

  /// No description provided for @hectaresOf.
  ///
  /// In es, this message translates to:
  /// **'de {total} ha totales'**
  String hectaresOf(int total);

  /// No description provided for @saturatedLand.
  ///
  /// In es, this message translates to:
  /// **'Terreno saturado'**
  String get saturatedLand;

  /// No description provided for @highUsage.
  ///
  /// In es, this message translates to:
  /// **'Uso alto'**
  String get highUsage;

  /// No description provided for @availableCapacity.
  ///
  /// In es, this message translates to:
  /// **'Capacidad disponible'**
  String get availableCapacity;

  /// No description provided for @criticalAlerts.
  ///
  /// In es, this message translates to:
  /// **'ALERTAS CRÍTICAS'**
  String get criticalAlerts;

  /// No description provided for @allGood.
  ///
  /// In es, this message translates to:
  /// **'¡Todo en orden!'**
  String get allGood;

  /// No description provided for @noAlertsMessage.
  ///
  /// In es, this message translates to:
  /// **'No hay alertas críticas. Comienza a registrar eventos de salud para llevar el historial de tu hato.'**
  String get noAlertsMessage;

  /// No description provided for @addMedicalRecord.
  ///
  /// In es, this message translates to:
  /// **'Añadir registro médico'**
  String get addMedicalRecord;

  /// No description provided for @urgent.
  ///
  /// In es, this message translates to:
  /// **'URGENTE'**
  String get urgent;

  /// No description provided for @recentMovements.
  ///
  /// In es, this message translates to:
  /// **'MOVIMIENTOS RECIENTES'**
  String get recentMovements;

  /// No description provided for @noMovementsYet.
  ///
  /// In es, this message translates to:
  /// **'Sin movimientos aún'**
  String get noMovementsYet;

  /// No description provided for @noMovementsMessage.
  ///
  /// In es, this message translates to:
  /// **'Cuando traslades animales entre potreros aparecerán aquí los 5 más recientes.'**
  String get noMovementsMessage;

  /// No description provided for @registerMovement.
  ///
  /// In es, this message translates to:
  /// **'Registrar movimiento'**
  String get registerMovement;

  /// No description provided for @showingCachedData.
  ///
  /// In es, this message translates to:
  /// **'Mostrando datos guardados · actualizando…'**
  String get showingCachedData;

  /// No description provided for @inventoryTitle.
  ///
  /// In es, this message translates to:
  /// **'Inventario'**
  String get inventoryTitle;

  /// No description provided for @inventorySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Animales, fincas y potreros'**
  String get inventorySubtitle;

  /// No description provided for @animals.
  ///
  /// In es, this message translates to:
  /// **'Animales'**
  String get animals;

  /// No description provided for @animalsDescription.
  ///
  /// In es, this message translates to:
  /// **'Listado, filtros, alta, edición, venta y costos por animal'**
  String get animalsDescription;

  /// No description provided for @farms.
  ///
  /// In es, this message translates to:
  /// **'Fincas'**
  String get farms;

  /// No description provided for @farmsDescription.
  ///
  /// In es, this message translates to:
  /// **'Predios, ubicaciones y propietarios'**
  String get farmsDescription;

  /// No description provided for @paddocks.
  ///
  /// In es, this message translates to:
  /// **'Potreros'**
  String get paddocks;

  /// No description provided for @paddocksDescription.
  ///
  /// In es, this message translates to:
  /// **'Capacidad, ocupación y rotación'**
  String get paddocksDescription;

  /// No description provided for @animalsTitle.
  ///
  /// In es, this message translates to:
  /// **'Animales'**
  String get animalsTitle;

  /// No description provided for @animalsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Inventario de bovinos'**
  String get animalsSubtitle;

  /// No description provided for @allFilter.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get allFilter;

  /// No description provided for @activeFilter.
  ///
  /// In es, this message translates to:
  /// **'Activos'**
  String get activeFilter;

  /// No description provided for @soldFilter.
  ///
  /// In es, this message translates to:
  /// **'Vendidos'**
  String get soldFilter;

  /// No description provided for @maleFilter.
  ///
  /// In es, this message translates to:
  /// **'Machos'**
  String get maleFilter;

  /// No description provided for @femaleFilter.
  ///
  /// In es, this message translates to:
  /// **'Hembras'**
  String get femaleFilter;

  /// No description provided for @noAnimals.
  ///
  /// In es, this message translates to:
  /// **'Sin animales'**
  String get noAnimals;

  /// No description provided for @createFirstAnimal.
  ///
  /// In es, this message translates to:
  /// **'Crea tu primer bovino con el +'**
  String get createFirstAnimal;

  /// No description provided for @male.
  ///
  /// In es, this message translates to:
  /// **'Macho'**
  String get male;

  /// No description provided for @female.
  ///
  /// In es, this message translates to:
  /// **'Hembra'**
  String get female;

  /// No description provided for @neuter.
  ///
  /// In es, this message translates to:
  /// **'Neutro'**
  String get neuter;

  /// No description provided for @active.
  ///
  /// In es, this message translates to:
  /// **'Activo'**
  String get active;

  /// No description provided for @sold.
  ///
  /// In es, this message translates to:
  /// **'Vendido'**
  String get sold;

  /// No description provided for @newAnimal.
  ///
  /// In es, this message translates to:
  /// **'Nuevo animal'**
  String get newAnimal;

  /// No description provided for @editAnimal.
  ///
  /// In es, this message translates to:
  /// **'Editar animal'**
  String get editAnimal;

  /// No description provided for @registerBovine.
  ///
  /// In es, this message translates to:
  /// **'Registra un nuevo bovino'**
  String get registerBovine;

  /// No description provided for @idNumber.
  ///
  /// In es, this message translates to:
  /// **'Número de identificación'**
  String get idNumber;

  /// No description provided for @breed.
  ///
  /// In es, this message translates to:
  /// **'Raza'**
  String get breed;

  /// No description provided for @gender.
  ///
  /// In es, this message translates to:
  /// **'Género'**
  String get gender;

  /// No description provided for @weight.
  ///
  /// In es, this message translates to:
  /// **'Peso (kg)'**
  String get weight;

  /// No description provided for @height.
  ///
  /// In es, this message translates to:
  /// **'Altura (m)'**
  String get height;

  /// No description provided for @birthDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha de nacimiento'**
  String get birthDate;

  /// No description provided for @farmId.
  ///
  /// In es, this message translates to:
  /// **'Finca (ID)'**
  String get farmId;

  /// No description provided for @paddockId.
  ///
  /// In es, this message translates to:
  /// **'ID de potrero'**
  String get paddockId;

  /// No description provided for @createAnimal.
  ///
  /// In es, this message translates to:
  /// **'Crear animal'**
  String get createAnimal;

  /// No description provided for @saveChanges.
  ///
  /// In es, this message translates to:
  /// **'Guardar cambios'**
  String get saveChanges;

  /// No description provided for @animalUpdated.
  ///
  /// In es, this message translates to:
  /// **'Animal actualizado'**
  String get animalUpdated;

  /// No description provided for @animalCreated.
  ///
  /// In es, this message translates to:
  /// **'Animal creado'**
  String get animalCreated;

  /// No description provided for @animalDeleted.
  ///
  /// In es, this message translates to:
  /// **'Animal eliminado'**
  String get animalDeleted;

  /// No description provided for @sellAnimal.
  ///
  /// In es, this message translates to:
  /// **'Vender animal'**
  String get sellAnimal;

  /// No description provided for @sellDescription.
  ///
  /// In es, this message translates to:
  /// **'Se creará automáticamente un movimiento de ingreso en finanzas'**
  String get sellDescription;

  /// No description provided for @salePrice.
  ///
  /// In es, this message translates to:
  /// **'Precio de venta'**
  String get salePrice;

  /// No description provided for @buyer.
  ///
  /// In es, this message translates to:
  /// **'Comprador'**
  String get buyer;

  /// No description provided for @saleDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha de venta'**
  String get saleDate;

  /// No description provided for @confirmSale.
  ///
  /// In es, this message translates to:
  /// **'Confirmar venta'**
  String get confirmSale;

  /// No description provided for @animalSold.
  ///
  /// In es, this message translates to:
  /// **'Animal vendido — registro financiero creado'**
  String get animalSold;

  /// No description provided for @accumulatedCosts.
  ///
  /// In es, this message translates to:
  /// **'COSTOS ACUMULADOS'**
  String get accumulatedCosts;

  /// No description provided for @healthCost.
  ///
  /// In es, this message translates to:
  /// **'Salud'**
  String get healthCost;

  /// No description provided for @feedingCost.
  ///
  /// In es, this message translates to:
  /// **'Alimentación'**
  String get feedingCost;

  /// No description provided for @totalCost.
  ///
  /// In es, this message translates to:
  /// **'Total'**
  String get totalCost;

  /// No description provided for @feedingHistory.
  ///
  /// In es, this message translates to:
  /// **'Historial de Alimentación'**
  String get feedingHistory;

  /// No description provided for @addFeeding.
  ///
  /// In es, this message translates to:
  /// **'Registrar alimentación'**
  String get addFeeding;

  /// No description provided for @selectFood.
  ///
  /// In es, this message translates to:
  /// **'Selecciona un alimento'**
  String get selectFood;

  /// No description provided for @amountKg.
  ///
  /// In es, this message translates to:
  /// **'Cantidad (kg)'**
  String get amountKg;

  /// No description provided for @feedingDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get feedingDate;

  /// No description provided for @feedingRegistered.
  ///
  /// In es, this message translates to:
  /// **'Alimentación registrada'**
  String get feedingRegistered;

  /// No description provided for @save.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get save;

  /// No description provided for @deleteAnimal.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar animal?'**
  String get deleteAnimal;

  /// No description provided for @deleteAnimalMessage.
  ///
  /// In es, this message translates to:
  /// **'Quedará marcado como eliminado y no aparecerá en los listados.'**
  String get deleteAnimalMessage;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get delete;

  /// No description provided for @farmsTitle.
  ///
  /// In es, this message translates to:
  /// **'Fincas'**
  String get farmsTitle;

  /// No description provided for @farmsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Gestiona tus predios'**
  String get farmsSubtitle;

  /// No description provided for @noFarms.
  ///
  /// In es, this message translates to:
  /// **'Sin fincas registradas'**
  String get noFarms;

  /// No description provided for @createFirstFarm.
  ///
  /// In es, this message translates to:
  /// **'Toca el + para crear tu primera finca.'**
  String get createFirstFarm;

  /// No description provided for @newFarm.
  ///
  /// In es, this message translates to:
  /// **'Nueva finca'**
  String get newFarm;

  /// No description provided for @editFarm.
  ///
  /// In es, this message translates to:
  /// **'Editar finca'**
  String get editFarm;

  /// No description provided for @createNewFarm.
  ///
  /// In es, this message translates to:
  /// **'Crea un nuevo predio'**
  String get createNewFarm;

  /// No description provided for @farmIdLabel.
  ///
  /// In es, this message translates to:
  /// **'ID de finca'**
  String get farmIdLabel;

  /// No description provided for @farmName.
  ///
  /// In es, this message translates to:
  /// **'Nombre de la finca'**
  String get farmName;

  /// No description provided for @location.
  ///
  /// In es, this message translates to:
  /// **'Ubicación'**
  String get location;

  /// No description provided for @owner.
  ///
  /// In es, this message translates to:
  /// **'Propietario'**
  String get owner;

  /// No description provided for @totalArea.
  ///
  /// In es, this message translates to:
  /// **'Área total (ha)'**
  String get totalArea;

  /// No description provided for @createFarm.
  ///
  /// In es, this message translates to:
  /// **'Crear finca'**
  String get createFarm;

  /// No description provided for @farmCreated.
  ///
  /// In es, this message translates to:
  /// **'Finca creada'**
  String get farmCreated;

  /// No description provided for @farmUpdated.
  ///
  /// In es, this message translates to:
  /// **'Finca actualizada'**
  String get farmUpdated;

  /// No description provided for @farmDeleted.
  ///
  /// In es, this message translates to:
  /// **'Finca eliminada'**
  String get farmDeleted;

  /// No description provided for @deleteFarm.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar finca?'**
  String get deleteFarm;

  /// No description provided for @deleteFarmMessage.
  ///
  /// In es, this message translates to:
  /// **'Se borrará la finca. Los datos asociados se mantendrán en histórico.'**
  String get deleteFarmMessage;

  /// No description provided for @registered.
  ///
  /// In es, this message translates to:
  /// **'Registrada'**
  String get registered;

  /// No description provided for @paddocksTitle.
  ///
  /// In es, this message translates to:
  /// **'Potreros'**
  String get paddocksTitle;

  /// No description provided for @paddocksSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Capacidad y rotaciones'**
  String get paddocksSubtitle;

  /// No description provided for @noPaddocks.
  ///
  /// In es, this message translates to:
  /// **'Sin potreros aún'**
  String get noPaddocks;

  /// No description provided for @createFirstPaddock.
  ///
  /// In es, this message translates to:
  /// **'Crea tu primer potrero con el botón +'**
  String get createFirstPaddock;

  /// No description provided for @newPaddock.
  ///
  /// In es, this message translates to:
  /// **'Nuevo potrero'**
  String get newPaddock;

  /// No description provided for @editPaddock.
  ///
  /// In es, this message translates to:
  /// **'Editar potrero'**
  String get editPaddock;

  /// No description provided for @configurePaddock.
  ///
  /// In es, this message translates to:
  /// **'Configura un nuevo potrero'**
  String get configurePaddock;

  /// No description provided for @paddockName.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get paddockName;

  /// No description provided for @capacity.
  ///
  /// In es, this message translates to:
  /// **'Capacidad de animales'**
  String get capacity;

  /// No description provided for @area.
  ///
  /// In es, this message translates to:
  /// **'Área (ha)'**
  String get area;

  /// No description provided for @status.
  ///
  /// In es, this message translates to:
  /// **'Estado'**
  String get status;

  /// No description provided for @statusActive.
  ///
  /// In es, this message translates to:
  /// **'Activo'**
  String get statusActive;

  /// No description provided for @statusRotation.
  ///
  /// In es, this message translates to:
  /// **'En rotación'**
  String get statusRotation;

  /// No description provided for @statusInactive.
  ///
  /// In es, this message translates to:
  /// **'Inactivo'**
  String get statusInactive;

  /// No description provided for @createPaddock.
  ///
  /// In es, this message translates to:
  /// **'Crear potrero'**
  String get createPaddock;

  /// No description provided for @paddockCreated.
  ///
  /// In es, this message translates to:
  /// **'Potrero creado'**
  String get paddockCreated;

  /// No description provided for @paddockUpdated.
  ///
  /// In es, this message translates to:
  /// **'Potrero actualizado'**
  String get paddockUpdated;

  /// No description provided for @paddockDeleted.
  ///
  /// In es, this message translates to:
  /// **'Potrero eliminado'**
  String get paddockDeleted;

  /// No description provided for @deletePaddock.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar potrero?'**
  String get deletePaddock;

  /// No description provided for @deletePaddockMessage.
  ///
  /// In es, this message translates to:
  /// **'El potrero quedará marcado como eliminado.'**
  String get deletePaddockMessage;

  /// No description provided for @occupancy.
  ///
  /// In es, this message translates to:
  /// **'OCUPACIÓN'**
  String get occupancy;

  /// No description provided for @healthTitle.
  ///
  /// In es, this message translates to:
  /// **'Salud'**
  String get healthTitle;

  /// No description provided for @healthSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Bienestar del hato'**
  String get healthSubtitle;

  /// No description provided for @healthRecords.
  ///
  /// In es, this message translates to:
  /// **'Registros de salud'**
  String get healthRecords;

  /// No description provided for @healthRecordsDescription.
  ///
  /// In es, this message translates to:
  /// **'Vacunas, vitaminas, desparasitaciones, enfermedades'**
  String get healthRecordsDescription;

  /// No description provided for @reproduction.
  ///
  /// In es, this message translates to:
  /// **'Reproducción'**
  String get reproduction;

  /// No description provided for @reproductionDescription.
  ///
  /// In es, this message translates to:
  /// **'Celos, montas, preñeces y partos'**
  String get reproductionDescription;

  /// No description provided for @alertCenter.
  ///
  /// In es, this message translates to:
  /// **'Centro de alertas'**
  String get alertCenter;

  /// No description provided for @alertCenterDescription.
  ///
  /// In es, this message translates to:
  /// **'Vista consolidada de todas las urgencias'**
  String get alertCenterDescription;

  /// No description provided for @healthListTitle.
  ///
  /// In es, this message translates to:
  /// **'Salud'**
  String get healthListTitle;

  /// No description provided for @healthListSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Vacunas, desparasitaciones y enfermedades'**
  String get healthListSubtitle;

  /// No description provided for @noHealthRecords.
  ///
  /// In es, this message translates to:
  /// **'Sin registros de salud'**
  String get noHealthRecords;

  /// No description provided for @registerHealthRecord.
  ///
  /// In es, this message translates to:
  /// **'Registra vacunas y tratamientos con el botón +'**
  String get registerHealthRecord;

  /// No description provided for @vaccination.
  ///
  /// In es, this message translates to:
  /// **'Vacunación'**
  String get vaccination;

  /// No description provided for @vitamins.
  ///
  /// In es, this message translates to:
  /// **'Vitaminas'**
  String get vitamins;

  /// No description provided for @deworming.
  ///
  /// In es, this message translates to:
  /// **'Desparasitación'**
  String get deworming;

  /// No description provided for @illness.
  ///
  /// In es, this message translates to:
  /// **'Enfermedad'**
  String get illness;

  /// No description provided for @newHealthRecord.
  ///
  /// In es, this message translates to:
  /// **'Nuevo registro de salud'**
  String get newHealthRecord;

  /// No description provided for @editHealthRecord.
  ///
  /// In es, this message translates to:
  /// **'Editar registro'**
  String get editHealthRecord;

  /// No description provided for @interventionType.
  ///
  /// In es, this message translates to:
  /// **'Tipo de intervención'**
  String get interventionType;

  /// No description provided for @appliedProduct.
  ///
  /// In es, this message translates to:
  /// **'Producto aplicado'**
  String get appliedProduct;

  /// No description provided for @dose.
  ///
  /// In es, this message translates to:
  /// **'Dosis'**
  String get dose;

  /// No description provided for @applicationDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha de aplicación'**
  String get applicationDate;

  /// No description provided for @nextApplication.
  ///
  /// In es, this message translates to:
  /// **'Próxima aplicación (opcional)'**
  String get nextApplication;

  /// No description provided for @notDefined.
  ///
  /// In es, this message translates to:
  /// **'Sin definir'**
  String get notDefined;

  /// No description provided for @cost.
  ///
  /// In es, this message translates to:
  /// **'Costo'**
  String get cost;

  /// No description provided for @animalId.
  ///
  /// In es, this message translates to:
  /// **'ID de animal'**
  String get animalId;

  /// No description provided for @createRecord.
  ///
  /// In es, this message translates to:
  /// **'Crear registro'**
  String get createRecord;

  /// No description provided for @recordCreated.
  ///
  /// In es, this message translates to:
  /// **'Registro creado'**
  String get recordCreated;

  /// No description provided for @recordUpdated.
  ///
  /// In es, this message translates to:
  /// **'Registro actualizado'**
  String get recordUpdated;

  /// No description provided for @recordDeleted.
  ///
  /// In es, this message translates to:
  /// **'Registro eliminado'**
  String get recordDeleted;

  /// No description provided for @deleteRecord.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar registro?'**
  String get deleteRecord;

  /// No description provided for @deleteRecordMessage.
  ///
  /// In es, this message translates to:
  /// **'Este registro sanitario quedará marcado como eliminado.'**
  String get deleteRecordMessage;

  /// No description provided for @reproductionTitle.
  ///
  /// In es, this message translates to:
  /// **'Reproducción'**
  String get reproductionTitle;

  /// No description provided for @reproductionSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Celos, montas y partos'**
  String get reproductionSubtitle;

  /// No description provided for @noReproductionEvents.
  ///
  /// In es, this message translates to:
  /// **'Sin eventos reproductivos'**
  String get noReproductionEvents;

  /// No description provided for @createFirstEvent.
  ///
  /// In es, this message translates to:
  /// **'Crea el primer evento con el +'**
  String get createFirstEvent;

  /// No description provided for @newReproEvent.
  ///
  /// In es, this message translates to:
  /// **'Nuevo evento reproductivo'**
  String get newReproEvent;

  /// No description provided for @editReproEvent.
  ///
  /// In es, this message translates to:
  /// **'Editar evento'**
  String get editReproEvent;

  /// No description provided for @eventId.
  ///
  /// In es, this message translates to:
  /// **'ID del evento'**
  String get eventId;

  /// No description provided for @reproMethod.
  ///
  /// In es, this message translates to:
  /// **'Método reproductivo'**
  String get reproMethod;

  /// No description provided for @inHeat.
  ///
  /// In es, this message translates to:
  /// **'En celo'**
  String get inHeat;

  /// No description provided for @pregnant.
  ///
  /// In es, this message translates to:
  /// **'Preñada'**
  String get pregnant;

  /// No description provided for @expectedOffspring.
  ///
  /// In es, this message translates to:
  /// **'Número de crías esperadas'**
  String get expectedOffspring;

  /// No description provided for @estimatedDueDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha estimada de parto'**
  String get estimatedDueDate;

  /// No description provided for @createEvent.
  ///
  /// In es, this message translates to:
  /// **'Crear evento'**
  String get createEvent;

  /// No description provided for @eventCreated.
  ///
  /// In es, this message translates to:
  /// **'Evento creado'**
  String get eventCreated;

  /// No description provided for @eventUpdated.
  ///
  /// In es, this message translates to:
  /// **'Evento actualizado'**
  String get eventUpdated;

  /// No description provided for @alertsTitle.
  ///
  /// In es, this message translates to:
  /// **'Alertas'**
  String get alertsTitle;

  /// No description provided for @alertsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Centro consolidado de urgencias'**
  String get alertsSubtitle;

  /// No description provided for @activeAlerts.
  ///
  /// In es, this message translates to:
  /// **'alertas activas'**
  String get activeAlerts;

  /// No description provided for @urgentNeedAttention.
  ///
  /// In es, this message translates to:
  /// **'{count} urgente(s) — requieren atención'**
  String urgentNeedAttention(int count);

  /// No description provided for @underControl.
  ///
  /// In es, this message translates to:
  /// **'Todo bajo control'**
  String get underControl;

  /// No description provided for @overdueHealth.
  ///
  /// In es, this message translates to:
  /// **'Salud vencida'**
  String get overdueHealth;

  /// No description provided for @upcomingHealth.
  ///
  /// In es, this message translates to:
  /// **'Salud próxima'**
  String get upcomingHealth;

  /// No description provided for @upcomingBirths.
  ///
  /// In es, this message translates to:
  /// **'Partos próximos'**
  String get upcomingBirths;

  /// No description provided for @inHeatLabel.
  ///
  /// In es, this message translates to:
  /// **'En celo'**
  String get inHeatLabel;

  /// No description provided for @prioritized.
  ///
  /// In es, this message translates to:
  /// **'PRIORIZADAS'**
  String get prioritized;

  /// No description provided for @highSeverity.
  ///
  /// In es, this message translates to:
  /// **'Alta'**
  String get highSeverity;

  /// No description provided for @mediumSeverity.
  ///
  /// In es, this message translates to:
  /// **'Media'**
  String get mediumSeverity;

  /// No description provided for @lowSeverity.
  ///
  /// In es, this message translates to:
  /// **'Baja'**
  String get lowSeverity;

  /// No description provided for @operationsTitle.
  ///
  /// In es, this message translates to:
  /// **'Operación'**
  String get operationsTitle;

  /// No description provided for @operationsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Finanzas, alimentos y traslados'**
  String get operationsSubtitle;

  /// No description provided for @finances.
  ///
  /// In es, this message translates to:
  /// **'Finanzas'**
  String get finances;

  /// No description provided for @financesDescription.
  ///
  /// In es, this message translates to:
  /// **'Ingresos, gastos y resumen'**
  String get financesDescription;

  /// No description provided for @food.
  ///
  /// In es, this message translates to:
  /// **'Alimentos'**
  String get food;

  /// No description provided for @foodDescription.
  ///
  /// In es, this message translates to:
  /// **'Inventario de alimentación del hato'**
  String get foodDescription;

  /// No description provided for @movements.
  ///
  /// In es, this message translates to:
  /// **'Movimientos'**
  String get movements;

  /// No description provided for @movementsDescription.
  ///
  /// In es, this message translates to:
  /// **'Traslados entre potreros'**
  String get movementsDescription;

  /// No description provided for @financesTitle.
  ///
  /// In es, this message translates to:
  /// **'Finanzas'**
  String get financesTitle;

  /// No description provided for @financesSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Ingresos y gastos'**
  String get financesSubtitle;

  /// No description provided for @noFinances.
  ///
  /// In es, this message translates to:
  /// **'Sin movimientos financieros'**
  String get noFinances;

  /// No description provided for @income.
  ///
  /// In es, this message translates to:
  /// **'Ingresos'**
  String get income;

  /// No description provided for @expenses.
  ///
  /// In es, this message translates to:
  /// **'Gastos'**
  String get expenses;

  /// No description provided for @balance.
  ///
  /// In es, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @incomeType.
  ///
  /// In es, this message translates to:
  /// **'Ingreso'**
  String get incomeType;

  /// No description provided for @expenseType.
  ///
  /// In es, this message translates to:
  /// **'Gasto'**
  String get expenseType;

  /// No description provided for @newTransaction.
  ///
  /// In es, this message translates to:
  /// **'Nuevo movimiento'**
  String get newTransaction;

  /// No description provided for @editTransaction.
  ///
  /// In es, this message translates to:
  /// **'Editar movimiento'**
  String get editTransaction;

  /// No description provided for @incomeOrExpense.
  ///
  /// In es, this message translates to:
  /// **'Ingreso o gasto'**
  String get incomeOrExpense;

  /// No description provided for @transactionId.
  ///
  /// In es, this message translates to:
  /// **'ID del movimiento'**
  String get transactionId;

  /// No description provided for @transactionType.
  ///
  /// In es, this message translates to:
  /// **'Tipo de movimiento'**
  String get transactionType;

  /// No description provided for @concept.
  ///
  /// In es, this message translates to:
  /// **'Concepto'**
  String get concept;

  /// No description provided for @category.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get category;

  /// No description provided for @amount.
  ///
  /// In es, this message translates to:
  /// **'Monto'**
  String get amount;

  /// No description provided for @date.
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get date;

  /// No description provided for @paymentMethod.
  ///
  /// In es, this message translates to:
  /// **'Método de pago'**
  String get paymentMethod;

  /// No description provided for @createTransaction.
  ///
  /// In es, this message translates to:
  /// **'Crear movimiento'**
  String get createTransaction;

  /// No description provided for @transactionCreated.
  ///
  /// In es, this message translates to:
  /// **'Movimiento creado'**
  String get transactionCreated;

  /// No description provided for @transactionUpdated.
  ///
  /// In es, this message translates to:
  /// **'Movimiento actualizado'**
  String get transactionUpdated;

  /// No description provided for @foodTitle.
  ///
  /// In es, this message translates to:
  /// **'Alimentos'**
  String get foodTitle;

  /// No description provided for @foodSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Inventario de alimentación'**
  String get foodSubtitle;

  /// No description provided for @noFood.
  ///
  /// In es, this message translates to:
  /// **'Sin alimentos registrados'**
  String get noFood;

  /// No description provided for @newFood.
  ///
  /// In es, this message translates to:
  /// **'Nuevo alimento'**
  String get newFood;

  /// No description provided for @editFood.
  ///
  /// In es, this message translates to:
  /// **'Editar alimento'**
  String get editFood;

  /// No description provided for @foodId.
  ///
  /// In es, this message translates to:
  /// **'ID del alimento'**
  String get foodId;

  /// No description provided for @foodType.
  ///
  /// In es, this message translates to:
  /// **'Tipo de alimento'**
  String get foodType;

  /// No description provided for @totalQuantity.
  ///
  /// In es, this message translates to:
  /// **'Cantidad total'**
  String get totalQuantity;

  /// No description provided for @frequency.
  ///
  /// In es, this message translates to:
  /// **'Frecuencia'**
  String get frequency;

  /// No description provided for @createFood.
  ///
  /// In es, this message translates to:
  /// **'Crear alimento'**
  String get createFood;

  /// No description provided for @foodCreated.
  ///
  /// In es, this message translates to:
  /// **'Alimento creado'**
  String get foodCreated;

  /// No description provided for @foodUpdated.
  ///
  /// In es, this message translates to:
  /// **'Alimento actualizado'**
  String get foodUpdated;

  /// No description provided for @movementsTitle.
  ///
  /// In es, this message translates to:
  /// **'Movimientos'**
  String get movementsTitle;

  /// No description provided for @movementsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Traslados entre potreros'**
  String get movementsSubtitle;

  /// No description provided for @noMovements.
  ///
  /// In es, this message translates to:
  /// **'Sin movimientos registrados'**
  String get noMovements;

  /// No description provided for @newMovement.
  ///
  /// In es, this message translates to:
  /// **'Nuevo movimiento'**
  String get newMovement;

  /// No description provided for @transferAnimal.
  ///
  /// In es, this message translates to:
  /// **'Traslada un animal entre potreros'**
  String get transferAnimal;

  /// No description provided for @originPaddock.
  ///
  /// In es, this message translates to:
  /// **'Potrero origen'**
  String get originPaddock;

  /// No description provided for @destinationPaddock.
  ///
  /// In es, this message translates to:
  /// **'Potrero destino'**
  String get destinationPaddock;

  /// No description provided for @transferDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha del traslado'**
  String get transferDate;

  /// No description provided for @reason.
  ///
  /// In es, this message translates to:
  /// **'Motivo'**
  String get reason;

  /// No description provided for @registerTransfer.
  ///
  /// In es, this message translates to:
  /// **'Registrar movimiento'**
  String get registerTransfer;

  /// No description provided for @movementRegistered.
  ///
  /// In es, this message translates to:
  /// **'Movimiento registrado'**
  String get movementRegistered;

  /// No description provided for @movementDetail.
  ///
  /// In es, this message translates to:
  /// **'Detalle del movimiento'**
  String get movementDetail;

  /// No description provided for @origin.
  ///
  /// In es, this message translates to:
  /// **'Origen'**
  String get origin;

  /// No description provided for @destination.
  ///
  /// In es, this message translates to:
  /// **'Destino'**
  String get destination;

  /// No description provided for @animal.
  ///
  /// In es, this message translates to:
  /// **'Animal'**
  String get animal;

  /// No description provided for @settingsTitle.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get settingsTitle;

  /// No description provided for @settingsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Tu cuenta y preferencias'**
  String get settingsSubtitle;

  /// No description provided for @organization.
  ///
  /// In es, this message translates to:
  /// **'ORGANIZACIÓN'**
  String get organization;

  /// No description provided for @tenantUsers.
  ///
  /// In es, this message translates to:
  /// **'Usuarios del tenant'**
  String get tenantUsers;

  /// No description provided for @account.
  ///
  /// In es, this message translates to:
  /// **'CUENTA'**
  String get account;

  /// No description provided for @changePassword.
  ///
  /// In es, this message translates to:
  /// **'Cambiar contraseña'**
  String get changePassword;

  /// No description provided for @notifications.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones'**
  String get notifications;

  /// No description provided for @language.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get language;

  /// No description provided for @spanish.
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get spanish;

  /// No description provided for @english.
  ///
  /// In es, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @about.
  ///
  /// In es, this message translates to:
  /// **'SOBRE'**
  String get about;

  /// No description provided for @version.
  ///
  /// In es, this message translates to:
  /// **'Versión'**
  String get version;

  /// No description provided for @termsAndPrivacy.
  ///
  /// In es, this message translates to:
  /// **'Términos y privacidad'**
  String get termsAndPrivacy;

  /// No description provided for @logout.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Cerrar sesión?'**
  String get logoutConfirm;

  /// No description provided for @logoutMessage.
  ///
  /// In es, this message translates to:
  /// **'Tendrás que volver a ingresar tus credenciales para entrar.'**
  String get logoutMessage;

  /// No description provided for @copyright.
  ///
  /// In es, this message translates to:
  /// **'FarmLink © 2026'**
  String get copyright;

  /// No description provided for @tenantUsersTitle.
  ///
  /// In es, this message translates to:
  /// **'Usuarios del tenant'**
  String get tenantUsersTitle;

  /// No description provided for @tenantUsersSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Miembros de tu organización'**
  String get tenantUsersSubtitle;

  /// No description provided for @addUser.
  ///
  /// In es, this message translates to:
  /// **'Agregar usuario'**
  String get addUser;

  /// No description provided for @editUser.
  ///
  /// In es, this message translates to:
  /// **'Editar usuario'**
  String get editUser;

  /// No description provided for @deleteUser.
  ///
  /// In es, this message translates to:
  /// **'Eliminar usuario'**
  String get deleteUser;

  /// No description provided for @confirmDelete.
  ///
  /// In es, this message translates to:
  /// **'¿Confirmar eliminación?'**
  String get confirmDelete;

  /// No description provided for @confirmDeleteUserMessage.
  ///
  /// In es, this message translates to:
  /// **'El usuario \"{name}\" será eliminado y no aparecerá en la lista.'**
  String confirmDeleteUserMessage(String name);

  /// No description provided for @userCreated.
  ///
  /// In es, this message translates to:
  /// **'Usuario creado'**
  String get userCreated;

  /// No description provided for @userUpdated.
  ///
  /// In es, this message translates to:
  /// **'Usuario actualizado'**
  String get userUpdated;

  /// No description provided for @userDeleted.
  ///
  /// In es, this message translates to:
  /// **'Usuario eliminado'**
  String get userDeleted;

  /// No description provided for @role.
  ///
  /// In es, this message translates to:
  /// **'Rol'**
  String get role;

  /// No description provided for @roleAdmin.
  ///
  /// In es, this message translates to:
  /// **'Administrador'**
  String get roleAdmin;

  /// No description provided for @rolePropietario.
  ///
  /// In es, this message translates to:
  /// **'Propietario'**
  String get rolePropietario;

  /// No description provided for @roleEmpleado.
  ///
  /// In es, this message translates to:
  /// **'Empleado'**
  String get roleEmpleado;

  /// No description provided for @quickCreate.
  ///
  /// In es, this message translates to:
  /// **'Creación rápida'**
  String get quickCreate;

  /// No description provided for @quickCreateSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Elige qué quieres registrar'**
  String get quickCreateSubtitle;

  /// No description provided for @newAnimalQuick.
  ///
  /// In es, this message translates to:
  /// **'Nuevo animal'**
  String get newAnimalQuick;

  /// No description provided for @newAnimalHint.
  ///
  /// In es, this message translates to:
  /// **'Registrar un bovino en el inventario'**
  String get newAnimalHint;

  /// No description provided for @newFarmQuick.
  ///
  /// In es, this message translates to:
  /// **'Nueva finca'**
  String get newFarmQuick;

  /// No description provided for @newFarmHint.
  ///
  /// In es, this message translates to:
  /// **'Dar de alta una finca o predio'**
  String get newFarmHint;

  /// No description provided for @newPaddockQuick.
  ///
  /// In es, this message translates to:
  /// **'Nuevo potrero'**
  String get newPaddockQuick;

  /// No description provided for @newPaddockHint.
  ///
  /// In es, this message translates to:
  /// **'Configurar un nuevo potrero'**
  String get newPaddockHint;

  /// No description provided for @newHealthQuick.
  ///
  /// In es, this message translates to:
  /// **'Registrar evento de salud'**
  String get newHealthQuick;

  /// No description provided for @newHealthHint.
  ///
  /// In es, this message translates to:
  /// **'Vacuna, desparasitación, enfermedad...'**
  String get newHealthHint;

  /// No description provided for @newFinanceQuick.
  ///
  /// In es, this message translates to:
  /// **'Registrar movimiento financiero'**
  String get newFinanceQuick;

  /// No description provided for @newFinanceHint.
  ///
  /// In es, this message translates to:
  /// **'Ingreso o gasto'**
  String get newFinanceHint;

  /// No description provided for @newTransferQuick.
  ///
  /// In es, this message translates to:
  /// **'Registrar traslado'**
  String get newTransferQuick;

  /// No description provided for @newTransferHint.
  ///
  /// In es, this message translates to:
  /// **'Mover animal entre potreros'**
  String get newTransferHint;

  /// No description provided for @retry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get retry;

  /// No description provided for @comingSoon.
  ///
  /// In es, this message translates to:
  /// **'Próximamente'**
  String get comingSoon;

  /// No description provided for @noDetail.
  ///
  /// In es, this message translates to:
  /// **'Sin detalle'**
  String get noDetail;

  /// No description provided for @noReason.
  ///
  /// In es, this message translates to:
  /// **'Sin motivo'**
  String get noReason;

  /// No description provided for @farm.
  ///
  /// In es, this message translates to:
  /// **'Finca'**
  String get farm;

  /// No description provided for @paddock.
  ///
  /// In es, this message translates to:
  /// **'Potrero'**
  String get paddock;
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return SEn();
    case 'es':
      return SEs();
  }

  throw FlutterError(
    'S.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
