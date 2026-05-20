// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SEn extends S {
  SEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'FarmLink';

  @override
  String get appSlogan => 'Smart livestock management';

  @override
  String get login => 'Sign in';

  @override
  String get loginSubtitle => 'Enter your credentials to continue';

  @override
  String get email => 'Email';

  @override
  String get emailHint => 'email@example.com';

  @override
  String get emailInvalid => 'Invalid email';

  @override
  String get password => 'Password';

  @override
  String get passwordHint => '••••••••';

  @override
  String get passwordMin => 'Minimum 6 characters';

  @override
  String get enter => 'Sign in';

  @override
  String get noAccount => 'Don\'t have an account? ';

  @override
  String get register => 'Sign up';

  @override
  String get registerTitle => 'Create account';

  @override
  String get fullName => 'Full name';

  @override
  String get phone => 'Phone (optional)';

  @override
  String get tenantId => 'Tenant ID (organization)';

  @override
  String get tenantHint => 'tenant-a';

  @override
  String get createAccount => 'Create account';

  @override
  String get required => 'Required';

  @override
  String get splashLoading => 'Loading...';

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
    return 'Good morning, $name';
  }

  @override
  String get demography => 'Herd demography';

  @override
  String activeAnimals(int count) {
    return '$count active';
  }

  @override
  String get production => 'Production';

  @override
  String get growth => 'Growth';

  @override
  String get dry => 'Dry';

  @override
  String get landOccupancy => 'Land occupancy';

  @override
  String hectaresOf(int total) {
    return 'of $total ha total';
  }

  @override
  String get saturatedLand => 'Land saturated';

  @override
  String get highUsage => 'High usage';

  @override
  String get availableCapacity => 'Available capacity';

  @override
  String get criticalAlerts => 'CRITICAL ALERTS';

  @override
  String get allGood => 'All good!';

  @override
  String get noAlertsMessage =>
      'No critical alerts. Start recording health events to track your herd history.';

  @override
  String get addMedicalRecord => 'Add medical record';

  @override
  String get urgent => 'URGENT';

  @override
  String get recentMovements => 'RECENT MOVEMENTS';

  @override
  String get noMovementsYet => 'No movements yet';

  @override
  String get noMovementsMessage =>
      'When you transfer animals between paddocks, the 5 most recent will show here.';

  @override
  String get registerMovement => 'Register movement';

  @override
  String get showingCachedData => 'Showing saved data · updating…';

  @override
  String get inventoryTitle => 'Inventory';

  @override
  String get inventorySubtitle => 'Animals, farms and paddocks';

  @override
  String get animals => 'Animals';

  @override
  String get animalsDescription =>
      'List, filters, registration, editing, sale and costs per animal';

  @override
  String get farms => 'Farms';

  @override
  String get farmsDescription => 'Properties, locations and owners';

  @override
  String get paddocks => 'Paddocks';

  @override
  String get paddocksDescription => 'Capacity, occupancy and rotation';

  @override
  String get animalsTitle => 'Animals';

  @override
  String get animalsSubtitle => 'Bovine inventory';

  @override
  String get allFilter => 'All';

  @override
  String get activeFilter => 'Active';

  @override
  String get soldFilter => 'Sold';

  @override
  String get maleFilter => 'Males';

  @override
  String get femaleFilter => 'Females';

  @override
  String get noAnimals => 'No animals';

  @override
  String get createFirstAnimal => 'Create your first bovine with +';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get neuter => 'Neuter';

  @override
  String get active => 'Active';

  @override
  String get sold => 'Sold';

  @override
  String get newAnimal => 'New animal';

  @override
  String get editAnimal => 'Edit animal';

  @override
  String get registerBovine => 'Register a new bovine';

  @override
  String get idNumber => 'ID number';

  @override
  String get breed => 'Breed';

  @override
  String get gender => 'Gender';

  @override
  String get weight => 'Weight (kg)';

  @override
  String get height => 'Height (m)';

  @override
  String get birthDate => 'Date of birth';

  @override
  String get farmId => 'Farm (ID)';

  @override
  String get paddockId => 'Paddock ID';

  @override
  String get createAnimal => 'Create animal';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get animalUpdated => 'Animal updated';

  @override
  String get animalCreated => 'Animal created';

  @override
  String get animalDeleted => 'Animal deleted';

  @override
  String get sellAnimal => 'Sell animal';

  @override
  String get sellDescription =>
      'An income record will be automatically created in finances';

  @override
  String get salePrice => 'Sale price';

  @override
  String get buyer => 'Buyer';

  @override
  String get saleDate => 'Sale date';

  @override
  String get confirmSale => 'Confirm sale';

  @override
  String get animalSold => 'Animal sold — financial record created';

  @override
  String get accumulatedCosts => 'ACCUMULATED COSTS';

  @override
  String get healthCost => 'Health';

  @override
  String get feedingCost => 'Feeding';

  @override
  String get totalCost => 'Total';

  @override
  String get feedingHistory => 'Feeding history';

  @override
  String get addFeeding => 'Register feeding';

  @override
  String get selectFood => 'Select a food';

  @override
  String get amountKg => 'Amount (kg)';

  @override
  String get feedingDate => 'Date';

  @override
  String get feedingRegistered => 'Feeding registered';

  @override
  String get save => 'Save';

  @override
  String get deleteAnimal => 'Delete animal?';

  @override
  String get deleteAnimalMessage =>
      'It will be marked as deleted and won\'t appear in lists.';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get farmsTitle => 'Farms';

  @override
  String get farmsSubtitle => 'Manage your properties';

  @override
  String get noFarms => 'No farms registered';

  @override
  String get createFirstFarm => 'Tap + to create your first farm.';

  @override
  String get newFarm => 'New farm';

  @override
  String get editFarm => 'Edit farm';

  @override
  String get createNewFarm => 'Create a new property';

  @override
  String get farmIdLabel => 'Farm ID';

  @override
  String get farmName => 'Farm name';

  @override
  String get location => 'Location';

  @override
  String get owner => 'Owner';

  @override
  String get totalArea => 'Total area (ha)';

  @override
  String get createFarm => 'Create farm';

  @override
  String get farmCreated => 'Farm created';

  @override
  String get farmUpdated => 'Farm updated';

  @override
  String get farmDeleted => 'Farm deleted';

  @override
  String get deleteFarm => 'Delete farm?';

  @override
  String get deleteFarmMessage =>
      'The farm will be deleted. Associated data will be kept in history.';

  @override
  String get registered => 'Registered';

  @override
  String get paddocksTitle => 'Paddocks';

  @override
  String get paddocksSubtitle => 'Capacity and rotations';

  @override
  String get noPaddocks => 'No paddocks yet';

  @override
  String get createFirstPaddock => 'Create your first paddock with +';

  @override
  String get newPaddock => 'New paddock';

  @override
  String get editPaddock => 'Edit paddock';

  @override
  String get configurePaddock => 'Configure a new paddock';

  @override
  String get paddockName => 'Name';

  @override
  String get capacity => 'Animal capacity';

  @override
  String get area => 'Area (ha)';

  @override
  String get status => 'Status';

  @override
  String get statusActive => 'Active';

  @override
  String get statusRotation => 'In rotation';

  @override
  String get statusInactive => 'Inactive';

  @override
  String get createPaddock => 'Create paddock';

  @override
  String get paddockCreated => 'Paddock created';

  @override
  String get paddockUpdated => 'Paddock updated';

  @override
  String get paddockDeleted => 'Paddock deleted';

  @override
  String get deletePaddock => 'Delete paddock?';

  @override
  String get deletePaddockMessage => 'The paddock will be marked as deleted.';

  @override
  String get occupancy => 'OCCUPANCY';

  @override
  String get healthTitle => 'Health';

  @override
  String get healthSubtitle => 'Herd wellness';

  @override
  String get healthRecords => 'Health records';

  @override
  String get healthRecordsDescription =>
      'Vaccines, vitamins, deworming, diseases';

  @override
  String get reproduction => 'Reproduction';

  @override
  String get reproductionDescription =>
      'Heat cycles, breeding, pregnancies and births';

  @override
  String get alertCenter => 'Alert center';

  @override
  String get alertCenterDescription => 'Consolidated view of all urgencies';

  @override
  String get healthListTitle => 'Health';

  @override
  String get healthListSubtitle => 'Vaccines, deworming and diseases';

  @override
  String get noHealthRecords => 'No health records';

  @override
  String get registerHealthRecord => 'Record vaccines and treatments with +';

  @override
  String get vaccination => 'Vaccination';

  @override
  String get vitamins => 'Vitamins';

  @override
  String get deworming => 'Deworming';

  @override
  String get illness => 'Illness';

  @override
  String get newHealthRecord => 'New health record';

  @override
  String get editHealthRecord => 'Edit record';

  @override
  String get interventionType => 'Intervention type';

  @override
  String get appliedProduct => 'Applied product';

  @override
  String get dose => 'Dose';

  @override
  String get applicationDate => 'Application date';

  @override
  String get nextApplication => 'Next application (optional)';

  @override
  String get notDefined => 'Not defined';

  @override
  String get cost => 'Cost';

  @override
  String get animalId => 'Animal ID';

  @override
  String get createRecord => 'Create record';

  @override
  String get recordCreated => 'Record created';

  @override
  String get recordUpdated => 'Record updated';

  @override
  String get recordDeleted => 'Record deleted';

  @override
  String get deleteRecord => 'Delete record?';

  @override
  String get deleteRecordMessage =>
      'This health record will be marked as deleted.';

  @override
  String get reproductionTitle => 'Reproduction';

  @override
  String get reproductionSubtitle => 'Heat, breeding and births';

  @override
  String get noReproductionEvents => 'No reproductive events';

  @override
  String get createFirstEvent => 'Create the first event with +';

  @override
  String get newReproEvent => 'New reproductive event';

  @override
  String get editReproEvent => 'Edit event';

  @override
  String get eventId => 'Event ID';

  @override
  String get reproMethod => 'Reproductive method';

  @override
  String get inHeat => 'In heat';

  @override
  String get pregnant => 'Pregnant';

  @override
  String get expectedOffspring => 'Expected offspring count';

  @override
  String get estimatedDueDate => 'Estimated due date';

  @override
  String get createEvent => 'Create event';

  @override
  String get eventCreated => 'Event created';

  @override
  String get eventUpdated => 'Event updated';

  @override
  String get alertsTitle => 'Alerts';

  @override
  String get alertsSubtitle => 'Consolidated urgency center';

  @override
  String get activeAlerts => 'active alerts';

  @override
  String urgentNeedAttention(int count) {
    return '$count urgent — need attention';
  }

  @override
  String get underControl => 'Everything under control';

  @override
  String get overdueHealth => 'Overdue health';

  @override
  String get upcomingHealth => 'Upcoming health';

  @override
  String get upcomingBirths => 'Upcoming births';

  @override
  String get inHeatLabel => 'In heat';

  @override
  String get prioritized => 'PRIORITIZED';

  @override
  String get highSeverity => 'High';

  @override
  String get mediumSeverity => 'Medium';

  @override
  String get lowSeverity => 'Low';

  @override
  String get operationsTitle => 'Operations';

  @override
  String get operationsSubtitle => 'Finances, food and transfers';

  @override
  String get finances => 'Finances';

  @override
  String get financesDescription => 'Income, expenses and summary';

  @override
  String get food => 'Food';

  @override
  String get foodDescription => 'Herd feeding inventory';

  @override
  String get movements => 'Movements';

  @override
  String get movementsDescription => 'Transfers between paddocks';

  @override
  String get financesTitle => 'Finances';

  @override
  String get financesSubtitle => 'Income and expenses';

  @override
  String get noFinances => 'No financial transactions';

  @override
  String get income => 'Income';

  @override
  String get expenses => 'Expenses';

  @override
  String get balance => 'Balance';

  @override
  String get incomeType => 'Income';

  @override
  String get expenseType => 'Expense';

  @override
  String get newTransaction => 'New transaction';

  @override
  String get editTransaction => 'Edit transaction';

  @override
  String get incomeOrExpense => 'Income or expense';

  @override
  String get transactionId => 'Transaction ID';

  @override
  String get transactionType => 'Transaction type';

  @override
  String get concept => 'Concept';

  @override
  String get category => 'Category';

  @override
  String get amount => 'Amount';

  @override
  String get date => 'Date';

  @override
  String get paymentMethod => 'Payment method';

  @override
  String get createTransaction => 'Create transaction';

  @override
  String get transactionCreated => 'Transaction created';

  @override
  String get transactionUpdated => 'Transaction updated';

  @override
  String get foodTitle => 'Food';

  @override
  String get foodSubtitle => 'Feeding inventory';

  @override
  String get noFood => 'No food registered';

  @override
  String get newFood => 'New food';

  @override
  String get editFood => 'Edit food';

  @override
  String get foodId => 'Food ID';

  @override
  String get foodType => 'Food type';

  @override
  String get totalQuantity => 'Total quantity';

  @override
  String get frequency => 'Frequency';

  @override
  String get createFood => 'Create food';

  @override
  String get foodCreated => 'Food created';

  @override
  String get foodUpdated => 'Food updated';

  @override
  String get movementsTitle => 'Movements';

  @override
  String get movementsSubtitle => 'Transfers between paddocks';

  @override
  String get noMovements => 'No movements registered';

  @override
  String get newMovement => 'New movement';

  @override
  String get transferAnimal => 'Transfer an animal between paddocks';

  @override
  String get originPaddock => 'Origin paddock';

  @override
  String get destinationPaddock => 'Destination paddock';

  @override
  String get transferDate => 'Transfer date';

  @override
  String get reason => 'Reason';

  @override
  String get registerTransfer => 'Register transfer';

  @override
  String get movementRegistered => 'Movement registered';

  @override
  String get movementDetail => 'Movement detail';

  @override
  String get origin => 'Origin';

  @override
  String get destination => 'Destination';

  @override
  String get animal => 'Animal';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSubtitle => 'Your account and preferences';

  @override
  String get organization => 'ORGANIZATION';

  @override
  String get tenantUsers => 'Tenant users';

  @override
  String get account => 'ACCOUNT';

  @override
  String get changePassword => 'Change password';

  @override
  String get notifications => 'Notifications';

  @override
  String get language => 'Language';

  @override
  String get spanish => 'Español';

  @override
  String get english => 'English';

  @override
  String get about => 'ABOUT';

  @override
  String get version => 'Version';

  @override
  String get termsAndPrivacy => 'Terms and privacy';

  @override
  String get logout => 'Sign out';

  @override
  String get logoutConfirm => 'Sign out?';

  @override
  String get logoutMessage =>
      'You\'ll need to enter your credentials again to sign in.';

  @override
  String get copyright => 'FarmLink © 2026';

  @override
  String get tenantUsersTitle => 'Tenant users';

  @override
  String get tenantUsersSubtitle => 'Members of your organization';

  @override
  String get addUser => 'Add user';

  @override
  String get editUser => 'Edit user';

  @override
  String get deleteUser => 'Delete user';

  @override
  String get confirmDelete => 'Confirm delete?';

  @override
  String confirmDeleteUserMessage(String name) {
    return 'User \"$name\" will be removed and won\'t appear in the list.';
  }

  @override
  String get userCreated => 'User created';

  @override
  String get userUpdated => 'User updated';

  @override
  String get userDeleted => 'User deleted';

  @override
  String get role => 'Role';

  @override
  String get roleAdmin => 'Admin';

  @override
  String get rolePropietario => 'Owner';

  @override
  String get roleEmpleado => 'Employee';

  @override
  String get quickCreate => 'Quick create';

  @override
  String get quickCreateSubtitle => 'Choose what to register';

  @override
  String get newAnimalQuick => 'New animal';

  @override
  String get newAnimalHint => 'Register a bovine in the inventory';

  @override
  String get newFarmQuick => 'New farm';

  @override
  String get newFarmHint => 'Register a new farm or property';

  @override
  String get newPaddockQuick => 'New paddock';

  @override
  String get newPaddockHint => 'Configure a new paddock';

  @override
  String get newHealthQuick => 'Register health event';

  @override
  String get newHealthHint => 'Vaccine, deworming, illness...';

  @override
  String get newFinanceQuick => 'Register financial transaction';

  @override
  String get newFinanceHint => 'Income or expense';

  @override
  String get newTransferQuick => 'Register transfer';

  @override
  String get newTransferHint => 'Move animal between paddocks';

  @override
  String get retry => 'Retry';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get noDetail => 'No detail';

  @override
  String get noReason => 'No reason';

  @override
  String get farm => 'Farm';

  @override
  String get paddock => 'Paddock';
}
