import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:myapp/core/task_filter.dart';

class AppTranslations {
  final Locale locale;
  const AppTranslations(this.locale);

  static const supportedLocales = [
    Locale('en', ''),
    Locale('fil', ''),
    Locale('es', ''),
    Locale('fr', ''),
  ];

  static const List<LocalizationsDelegate<dynamic>> delegates = [
    AppTranslationsLocalizationsDelegate(),
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static const _languageNames = {
    'English': 'English',
    'Filipino': 'Filipino',
    'Spanish': 'Español',
    'French': 'Français',
  };

  static Locale localeFor(String language) {
    const codes = {
      'English': 'en',
      'Filipino': 'fil',
      'Spanish': 'es',
      'French': 'fr',
    };
    final code = codes[language];
    return code == null ? const Locale('en') : Locale(code);
  }

  static String languageNameOf(String name) => _languageNames[name] ?? name;

  static AppTranslations of(BuildContext context) {
    return Localizations.of<AppTranslations>(context, AppTranslations)!;
  }

  Map<String, String> get _strings {
    switch (locale.languageCode) {
      case 'fil':
        return _filipino;
      case 'es':
        return _spanish;
      case 'fr':
        return _french;
      default:
        return _english;
    }
  }

  String get appTitle => t('appTitle');
  String get welcome => t('welcome');
  String get welcomeSubtitle => t('welcomeSubtitle');
  String get username => t('username');
  String get password => t('password');
  String get login => t('login');
  String get forgotPassword => t('forgotPassword');
  String get fillAllFields => t('fillAllFields');
  String get invalidCredentials => t('invalidCredentials');
  String get forgotPasswordTitle => t('forgotPasswordTitle');
  String get resetPasswordHeader => t('resetPasswordHeader');
  String get resetPasswordSubtitle => t('resetPasswordSubtitle');
  String get newPassword => t('newPassword');
  String get confirmPassword => t('confirmPassword');
  String get min6Chars => t('min6Chars');
  String get resetPassword => t('resetPassword');
  String get usernameRequired => t('usernameRequired');
  String get unknownUsername => t('unknownUsername');
  String get passwordRequired => t('passwordRequired');
  String get useAtLeast6 => t('useAtLeast6');
  String get confirmYourPassword => t('confirmYourPassword');
  String get passwordsDoNotMatch => t('passwordsDoNotMatch');
  String get passwordResetSuccess => t('passwordResetSuccess');
  String get dashboard => t('dashboard');
  String get myTasks => t('myTasks');
  String get enterNewTask => t('enterNewTask');
  String get toDo => t('toDo');
  String get completed => t('completed');
  String get noTasksYet => t('noTasksYet');
  String get newTask => t('newTask');
  String get editTask => t('editTask');
  String get taskTitle => t('taskTitle');
  String get descriptionOptional => t('descriptionOptional');
  String get addTask => t('addTask');
  String get saveChanges => t('saveChanges');
  String get pending => t('pending');
  String get description => t('description');
  String get created => t('created');
  String get noDescription => t('noDescription');
  String get markDone => t('markDone');
  String get markPending => t('markPending');
  String get delete => t('delete');
  String get save => t('save');
  String get profile => t('profile');
  String get changeProfilePicture => t('changeProfilePicture');
  String get profileUpdated => t('profileUpdated');
  String get fullName => t('fullName');
  String get email => t('email');
  String get phone => t('phone');
  String get location => t('location');
  String get editProfile => t('editProfile');
  String get galleryError => t('galleryError');
  String get emailRequired => t('emailRequired');
  String get validEmail => t('validEmail');
  String get phoneRequired => t('phoneRequired');
  String get locationRequired => t('locationRequired');
  String get fullNameRequired => t('fullNameRequired');
  String get settings => t('settings');
  String get general => t('general');
  String get language => t('language');
  String get darkMode => t('darkMode');
  String get notifications => t('notifications');
  String get on => t('on');
  String get off => t('off');
  String get enabled => t('enabled');
  String get disabled => t('disabled');
  String get account => t('account');
  String get changePassword => t('changePassword');
  String get privacy => t('privacy');
  String get about => t('about');
  String get version => t('version');
  String get selectLanguage => t('selectLanguage');
  String get privacyBody => t('privacyBody');
  String get aboutDesc => t('aboutDesc');
  String get builtWithFlutter => t('builtWithFlutter');
  String get passwordUpdated => t('passwordUpdated');
  String get updatePassword => t('updatePassword');
  String get logout => t('logout');
  String get changePasswordTitle => t('changePasswordTitle');
  String get currentPassword => t('currentPassword');
  String get currentPasswordIncorrect => t('currentPasswordIncorrect');
  String get ok => t('ok');
  String get cancel => t('cancel');
  String get logoutConfirm => t('logoutConfirm');
  String get notifTaskAdded => t('notifTaskAdded');
  String get notifTaskCompleted => t('notifTaskCompleted');
  String get undo => t('undo');
  String get deleteTaskTitle => t('deleteTaskTitle');
  String get deleteTaskConfirm => t('deleteTaskConfirm');
  String get taskAdded => t('taskAdded');
  String get taskUpdated => t('taskUpdated');
  String get taskCompleted => t('taskCompleted');
  String get taskPending => t('taskPending');
  String get taskDeleted => t('taskDeleted');
  String get searchTasks => t('searchTasks');
  String get noResults => t('noResults');
  String get progress => t('progress');
  String get totalTasks => t('totalTasks');
  String get createAccount => t('createAccount');
  String get createAccountSubtitle => t('createAccountSubtitle');
  String get noAccount => t('noAccount');
  String get alreadyHaveAccount => t('alreadyHaveAccount');
  String get usernameTaken => t('usernameTaken');
  String get usernameTooShort => t('usernameTooShort');
  String get usernameInvalid => t('usernameInvalid');
  String get accountCreated => t('accountCreated');
  String get optional => t('optional');
  String get dueDate => t('dueDate');
  String get noDueDate => t('noDueDate');
  String get setDueDate => t('setDueDate');
  String get notifTaskDue => t('notifTaskDue');
  String get overdue => t('overdue');
  String get priority => t('priority');
  String get priorityLow => t('low');
  String get priorityMedium => t('medium');
  String get priorityHigh => t('high');
  String get category => t('category');
  String get categoryOptional => t('categoryOptional');
  String get today => t('today');
  String get clearFilter => t('clearFilter');
  String get noCompletedTasks => t('noCompletedTasks');
  String get noOverdueTasks => t('noOverdueTasks');
  String get noTodayTasks => t('noTodayTasks');

  String filterLabel(TaskFilter filter) => switch (filter) {
        TaskFilter.completed => completed,
        TaskFilter.overdue => overdue,
        TaskFilter.today => today,
      };

  String priorityLabel(String priority) => switch (priority) {
        'low' => priorityLow,
        'high' => priorityHigh,
        _ => priorityMedium,
      };

  String t(String key) => _strings[key] ?? _english[key] ?? key;

  static const _english = <String, String>{
    'appTitle': 'TaskManager',
    'welcome': 'TaskManager',
    'welcomeSubtitle': 'Login to access your dashboard',
    'username': 'Username',
    'password': 'Password',
    'login': 'Login',
    'forgotPassword': 'Forgot Password?',
    'fillAllFields': 'Please fill in all fields',
    'invalidCredentials': 'Invalid username or password',
    'forgotPasswordTitle': 'Forgot Password',
    'resetPasswordHeader': 'Reset your password',
    'resetPasswordSubtitle':
        'Enter your username and set a new password.',
    'newPassword': 'New Password',
    'confirmPassword': 'Confirm Password',
    'min6Chars': 'At least 6 characters',
    'resetPassword': 'Reset Password',
    'usernameRequired': 'Username is required',
    'unknownUsername': 'Unknown username',
    'passwordRequired': 'Password is required',
    'useAtLeast6': 'Use at least 6 characters',
    'confirmYourPassword': 'Confirm your password',
    'passwordsDoNotMatch': 'Passwords do not match',
    'passwordResetSuccess':
        'Password reset successfully. Please login.',
    'dashboard': 'Dashboard',
    'myTasks': 'My Tasks',
    'enterNewTask': 'Enter a new task...',
    'toDo': 'To Do',
    'completed': 'Completed',
    'noTasksYet': 'No tasks yet. Add one above!',
    'newTask': 'New Task',
    'editTask': 'Edit Task',
    'taskTitle': 'Task Title',
    'descriptionOptional': 'Description (optional)',
    'addTask': 'Add Task',
    'saveChanges': 'Save Changes',
    'pending': 'Pending',
    'description': 'Description',
    'created': 'Created',
    'noDescription': 'No description provided.',
    'markDone': 'Mark Done',
    'markPending': 'Mark Pending',
    'delete': 'Delete',
    'save': 'Save',
    'profile': 'Profile',
    'changeProfilePicture': 'Change Profile Picture',
    'profileUpdated': 'Profile updated',
    'fullName': 'Full Name',
    'email': 'Email',
    'phone': 'Phone',
    'location': 'Location',
    'editProfile': 'Edit Profile',
    'galleryError':
        'Could not open gallery. Rebuild the app and try again.',
    'emailRequired': 'Email is required',
    'validEmail': 'Enter a valid email',
    'phoneRequired': 'Phone is required',
    'locationRequired': 'Location is required',
    'fullNameRequired': 'Full name is required',
    'settings': 'Settings',
    'general': 'General',
    'language': 'Language',
    'darkMode': 'Dark Mode',
    'notifications': 'Notifications',
    'on': 'On',
    'off': 'Off',
    'enabled': 'Enabled',
    'disabled': 'Disabled',
    'account': 'Account',
    'changePassword': 'Change Password',
    'privacy': 'Privacy',
    'about': 'About',
    'version': 'Version 1.0.0',
    'selectLanguage': 'Select Language',
    'privacyBody':
        'Your profile information, profile picture, and settings are stored only on this device. '
        'No data is uploaded or shared with third parties.',
    'aboutDesc': 'A simple task manager app.',
    'builtWithFlutter': 'Built with Flutter.',
    'passwordUpdated': 'Password updated successfully',
    'updatePassword': 'Update Password',
    'logout': 'Logout',
    'changePasswordTitle': 'Change Password',
    'currentPassword': 'Current Password',
    'currentPasswordIncorrect': 'Current password is incorrect',
    'ok': 'OK',
    'cancel': 'Cancel',
    'logoutConfirm': 'Are you sure you want to log out?',
    'notifTaskAdded': 'New task added',
    'notifTaskCompleted': 'Task completed',
    'undo': 'Undo',
    'deleteTaskTitle': 'Delete Task',
    'deleteTaskConfirm': 'You won\'t be able to undo this action.',
    'taskAdded': 'Task added',
    'taskUpdated': 'Task updated',
    'taskCompleted': 'Task completed',
    'taskPending': 'Task marked pending',
    'taskDeleted': 'Task deleted',
    'searchTasks': 'Search tasks...',
    'noResults': 'No tasks match your search.',
    'progress': 'Progress',
    'totalTasks': 'Total',
    'createAccount': 'Create Account',
    'createAccountSubtitle': 'Create your account to start managing your tasks',
    'noAccount': "Don't have an account?",
    'alreadyHaveAccount': 'Already have an account?',
    'usernameTaken': 'This username is already taken',
    'usernameTooShort': 'Username must be at least 3 characters',
    'usernameInvalid': 'Letters, numbers, dots and underscores only',
    'accountCreated': 'Account created successfully. Please log in.',
    'optional': 'Optional',
    'dueDate': 'Due Date',
    'noDueDate': 'No due date',
    'setDueDate': 'Set due date',
    'notifTaskDue': 'Task due date',
    'overdue': 'Overdue',
    'priority': 'Priority',
    'low': 'Low',
    'medium': 'Medium',
    'high': 'High',
    'category': 'Category',
    'categoryOptional': 'Category (optional)',
    'today': 'Today',
    'clearFilter': 'Clear filter',
    'noCompletedTasks': 'No completed tasks yet.',
    'noOverdueTasks': 'Nothing overdue. Great job!',
    'noTodayTasks': 'Nothing due today.',
  };

  static const _filipino = <String, String>{
    'appTitle': 'TaskManager',
    'welcome': 'TaskManager',
    'welcomeSubtitle': 'Mag-login upang ma-access ang iyong dashboard',
    'username': 'Username',
    'password': 'Password',
    'login': 'Mag-login',
    'forgotPassword': 'Nakalimutan ang Password?',
    'fillAllFields': 'Pakilagyan ang lahat ng patlang',
    'invalidCredentials': 'Maling username o password',
    'forgotPasswordTitle': 'Nakalimutang Password',
    'resetPasswordHeader': 'I-reset ang iyong password',
    'resetPasswordSubtitle':
        'Ilagay ang iyong username at magtakda ng bagong password.',
    'newPassword': 'Bagong Password',
    'confirmPassword': 'Kumpirmahin ang Password',
    'min6Chars': 'Hindi bababa sa 6 na character',
    'resetPassword': 'I-reset ang Password',
    'usernameRequired': 'Kailangan ang username',
    'unknownUsername': 'Hindi kilalang username',
    'passwordRequired': 'Kailangan ang password',
    'useAtLeast6': 'Gumamit ng hindi bababa sa 6 na character',
    'confirmYourPassword': 'Kumpirmahin ang iyong password',
    'passwordsDoNotMatch': 'Hindi tugma ang mga password',
    'passwordResetSuccess': 'Na-reset ang password. Mangyaring mag-login.',
    'dashboard': 'Dashboard',
    'myTasks': 'Ang Aking mga Gawain',
    'enterNewTask': 'Maglagay ng bagong gawain...',
    'toDo': 'Gagawin',
    'completed': 'Nakumpleto',
    'noTasksYet': 'Wala pang gawain. Magdagdag sa itaas!',
    'newTask': 'Bagong Gawain',
    'editTask': 'I-edit ang Gawain',
    'taskTitle': 'Pamagat ng Gawain',
    'descriptionOptional': 'Deskripsyon (opsyonal)',
    'addTask': 'Idagdag ang Gawain',
    'saveChanges': 'I-save ang mga Pagbabago',
    'pending': 'Nakabinbin',
    'description': 'Deskripsyon',
    'created': 'Ginawa no',
    'noDescription': 'Walang ibinigay na deskripsyon.',
    'markDone': 'Markahang Tapos',
    'markPending': 'Markahang Nakabinbin',
    'delete': 'Burahin',
    'save': 'I-save',
    'profile': 'Propayl',
    'changeProfilePicture': 'Palitan ang Larawan sa Profayl',
    'profileUpdated': 'Na-update ang profayl',
    'fullName': 'Buong Pangalan',
    'email': 'Email',
    'phone': 'Telepono',
    'location': 'Lokasyon',
    'editProfile': 'I-edit ang Profayl',
    'galleryError':
        'Hindi mabuksan ang gallery. I-rebuild ang app at subukan muli.',
    'emailRequired': 'Kailangan ang email',
    'validEmail': 'Maglagay ng wastong email',
    'phoneRequired': 'Kailangan ang telepono',
    'locationRequired': 'Kailangan ang lokasyon',
    'fullNameRequired': 'Kailangan ang buong pangalan',
    'settings': 'Mga Setting',
    'general': 'Pangkalahatan',
    'language': 'Wika',
    'darkMode': 'Dark Mode',
    'notifications': 'Mga Notipikasyon',
    'on': 'Naka-on',
    'off': 'Naka-off',
    'enabled': 'Pinagana',
    'disabled': 'Hindi pinagana',
    'account': 'Account',
    'changePassword': 'Palitan ang Password',
    'privacy': 'Pribasya',
    'about': 'Tungkol',
    'version': 'Bersyon 1.0.0',
    'selectLanguage': 'Pumili ng Wika',
    'privacyBody':
        'Ang iyong impormasyon sa profayl, larawan, at mga setting ay nakaimbak lamang sa device na ito. '
        'Walang data na ina-upload o ibinabahagi sa mga third party.',
    'aboutDesc': 'Isang simpleng task manager app.',
    'builtWithFlutter': 'Ginawa gamit ang Flutter.',
    'passwordUpdated': 'Matagumpay na na-update ang password',
    'updatePassword': 'I-update ang Password',
    'logout': 'Mag-logout',
    'changePasswordTitle': 'Palitan ang Password',
    'currentPassword': 'Kasalukuyang Password',
    'currentPasswordIncorrect': 'Mali ang kasalukuyang password',
    'ok': 'OK',
    'cancel': 'Kanselahin',
    'logoutConfirm': 'Sigurado ka bang mag-logout?',
    'notifTaskAdded': 'Naidagdag ang bagong gawain',
    'notifTaskCompleted': 'Nakumpleto ang gawain',
    'undo': 'I-undo',
    'deleteTaskTitle': 'Burahin ang Gawain',
    'deleteTaskConfirm': 'Hindi mo na ito maibabalik.',
    'taskAdded': 'Naidagdag ang gawain',
    'taskUpdated': 'Na-update ang gawain',
    'taskCompleted': 'Nakumpleto ang gawain',
    'taskPending': 'Minarkahang nakabinbin ang gawain',
    'taskDeleted': 'Binura ang gawain',
    'searchTasks': 'Maghanap ng mga gawain...',
    'noResults': 'Walang gawaing tugma sa iyong paghahanap.',
    'progress': 'Progreso',
    'totalTasks': 'Kabuuan',
    'createAccount': 'Gumawa ng Account',
    'createAccountSubtitle': 'Gumawa ng account para simulan ang pamamahala ng iyong mga gawain',
    'noAccount': 'Wala ka pang account?',
    'alreadyHaveAccount': 'May account ka na?',
    'usernameTaken': 'Ginamit na ang username na ito',
    'usernameTooShort': 'Ang username ay dapat hindi bababa sa 3 character',
    'usernameInvalid': 'Mga titik, numero, tuldok at underscore lamang',
    'accountCreated': 'Matagumpay na nagawa ang account. Mangyaring mag-login.',
    'optional': 'Opsyonal',
    'dueDate': 'Takdang Petsa',
    'noDueDate': 'Walang takdang petsa',
    'setDueDate': 'Itakda ang takdang petsa',
    'notifTaskDue': 'Takdang petsa ng gawain',
    'overdue': 'Nakaraang takdang petsa',
    'priority': 'Priyoridad',
    'low': 'Mababa',
    'medium': 'Katamtaman',
    'high': 'Mataas',
    'category': 'Kategorya',
    'categoryOptional': 'Kategorya (opsyonal)',
    'today': 'Ngayon',
    'clearFilter': 'Alisin ang filter',
    'noCompletedTasks': 'Wala pang nakumpletong gawain.',
    'noOverdueTasks': 'Walang lumagpas sa takdang petsa. Magaling!',
    'noTodayTasks': 'Walang gawaing dapat gawin ngayon.',
  };

  static const _spanish = <String, String>{
    'appTitle': 'TaskManager',
    'welcome': 'TaskManager',
    'welcomeSubtitle': 'Inicia sesión para acceder a tu panel',
    'username': 'Usuario',
    'password': 'Contraseña',
    'login': 'Iniciar sesión',
    'forgotPassword': '¿Olvidaste tu contraseña?',
    'fillAllFields': 'Por favor completa todos los campos',
    'invalidCredentials': 'Usuario o contraseña inválidos',
    'forgotPasswordTitle': 'Contraseña olvidada',
    'resetPasswordHeader': 'Restablece tu contraseña',
    'resetPasswordSubtitle':
        'Ingresa tu usuario y establece una nueva contraseña.',
    'newPassword': 'Nueva contraseña',
    'confirmPassword': 'Confirmar contraseña',
    'min6Chars': 'Al menos 6 caracteres',
    'resetPassword': 'Restablecer contraseña',
    'usernameRequired': 'El usuario es obligatorio',
    'unknownUsername': 'Usuario desconocido',
    'passwordRequired': 'La contraseña es obligatoria',
    'useAtLeast6': 'Usa al menos 6 caracteres',
    'confirmYourPassword': 'Confirma tu contraseña',
    'passwordsDoNotMatch': 'Las contraseñas no coinciden',
    'passwordResetSuccess':
        'Contraseña restablecida. Por favor inicia sesión.',
    'dashboard': 'Panel',
    'myTasks': 'Mis tareas',
    'enterNewTask': 'Ingresa una nueva tarea...',
    'toDo': 'Por hacer',
    'completed': 'Completadas',
    'noTasksYet': 'No hay tareas aún. ¡Agrega una arriba!',
    'newTask': 'Nueva tarea',
    'editTask': 'Editar tarea',
    'taskTitle': 'Título de la tarea',
    'descriptionOptional': 'Descripción (opcional)',
    'addTask': 'Agregar tarea',
    'saveChanges': 'Guardar cambios',
    'pending': 'Pendiente',
    'description': 'Descripción',
    'created': 'Creado',
    'noDescription': 'No se proporcionó descripción.',
    'markDone': 'Marcar como hecho',
    'markPending': 'Marcar como pendiente',
    'delete': 'Eliminar',
    'save': 'Guardar',
    'profile': 'Perfil',
    'changeProfilePicture': 'Cambiar foto de perfil',
    'profileUpdated': 'Perfil actualizado',
    'fullName': 'Nombre completo',
    'email': 'Correo electrónico',
    'phone': 'Teléfono',
    'location': 'Ubicación',
    'editProfile': 'Editar perfil',
    'galleryError':
        'No se pudo abrir la galería. Reconstruye la app e inténtalo de nuevo.',
    'emailRequired': 'El correo es obligatorio',
    'validEmail': 'Ingresa un correo válido',
    'phoneRequired': 'El teléfono es obligatorio',
    'locationRequired': 'La ubicación es obligatoria',
    'fullNameRequired': 'El nombre completo es obligatorio',
    'settings': 'Ajustes',
    'general': 'General',
    'language': 'Idioma',
    'darkMode': 'Modo oscuro',
    'notifications': 'Notificaciones',
    'on': 'Activado',
    'off': 'Desactivado',
    'enabled': 'Habilitado',
    'disabled': 'Deshabilitado',
    'account': 'Cuenta',
    'changePassword': 'Cambiar contraseña',
    'privacy': 'Privacidad',
    'about': 'Acerca de',
    'version': 'Versión 1.0.0',
    'selectLanguage': 'Seleccionar idioma',
    'privacyBody':
        'Tu información de perfil, foto y ajustes están almacenados solo en este dispositivo. '
        'No se sube ni comparte ningún dato con terceros.',
    'aboutDesc': 'Una aplicación simple de gestión de tareas.',
    'builtWithFlutter': 'Hecha con Flutter.',
    'passwordUpdated': 'Contraseña actualizada exitosamente',
    'updatePassword': 'Actualizar contraseña',
    'logout': 'Cerrar sesión',
    'changePasswordTitle': 'Cambiar contraseña',
    'currentPassword': 'Contraseña actual',
    'currentPasswordIncorrect': 'La contraseña actual es incorrecta',
    'ok': 'Aceptar',
    'cancel': 'Cancelar',
    'logoutConfirm': '¿Seguro que quieres cerrar sesión?',
    'notifTaskAdded': 'Nueva tarea agregada',
    'notifTaskCompleted': 'Tarea completada',
    'undo': 'Deshacer',
    'deleteTaskTitle': 'Eliminar tarea',
    'deleteTaskConfirm': 'No podrás deshacer esta acción.',
    'taskAdded': 'Tarea agregada',
    'taskUpdated': 'Tarea actualizada',
    'taskCompleted': 'Tarea completada',
    'taskPending': 'Tarea marcada como pendiente',
    'taskDeleted': 'Tarea eliminada',
    'searchTasks': 'Buscar tareas...',
    'noResults': 'No hay tareas que coincidan con tu búsqueda.',
    'progress': 'Progreso',
    'totalTasks': 'Total',
    'createAccount': 'Crear cuenta',
    'createAccountSubtitle': 'Crea tu cuenta para empezar a gestionar tus tareas',
    'noAccount': '¿No tienes una cuenta?',
    'alreadyHaveAccount': '¿Ya tienes una cuenta?',
    'usernameTaken': 'Este nombre de usuario ya está en uso',
    'usernameTooShort': 'El usuario debe tener al menos 3 caracteres',
    'usernameInvalid': 'Solo letras, números, puntos y guiones bajos',
    'accountCreated': 'Cuenta creada exitosamente. Inicia sesión.',
    'optional': 'Opcional',
    'dueDate': 'Fecha límite',
    'noDueDate': 'Sin fecha límite',
    'setDueDate': 'Establecer fecha límite',
    'notifTaskDue': 'Fecha límite de la tarea',
    'overdue': 'Atrasada',
    'priority': 'Prioridad',
    'low': 'Baja',
    'medium': 'Media',
    'high': 'Alta',
    'category': 'Categoría',
    'categoryOptional': 'Categoría (opcional)',
    'today': 'Hoy',
    'clearFilter': 'Quitar filtro',
    'noCompletedTasks': 'No hay tareas completadas todavía.',
    'noOverdueTasks': 'Nada atrasado. ¡Buen trabajo!',
    'noTodayTasks': 'Nada pendiente para hoy.',
  };

  static const _french = <String, String>{
    'appTitle': 'TaskManager',
    'welcome': 'TaskManager',
    'welcomeSubtitle': 'Connectez-vous pour accéder à votre tableau de bord',
    'username': "Nom d'utilisateur",
    'password': 'Mot de passe',
    'login': 'Connexion',
    'forgotPassword': 'Mot de passe oublié ?',
    'fillAllFields': 'Veuillez remplir tous les champs',
    'invalidCredentials': 'Nom d\'utilisateur ou mot de passe invalide',
    'forgotPasswordTitle': 'Mot de passe oublié',
    'resetPasswordHeader': 'Réinitialisez votre mot de passe',
    'resetPasswordSubtitle':
        'Saisissez votre nom d’utilisateur et définissez un nouveau mot de passe.',
    'newPassword': 'Nouveau mot de passe',
    'confirmPassword': 'Confirmer le mot de passe',
    'min6Chars': 'Au moins 6 caractères',
    'resetPassword': 'Réinitialiser le mot de passe',
    'usernameRequired': "Le nom d'utilisateur est requis",
    'unknownUsername': 'Nom d\'utilisateur inconnu',
    'passwordRequired': 'Le mot de passe est requis',
    'useAtLeast6': 'Utilisez au moins 6 caractères',
    'confirmYourPassword': 'Confirmez votre mot de passe',
    'passwordsDoNotMatch': 'Les mots de passe ne correspondent pas',
    'passwordResetSuccess':
        'Mot de passe réinitialisé. Veuillez vous connecter.',
    'dashboard': 'Tableau de bord',
    'myTasks': 'Mes tâches',
    'enterNewTask': 'Saisissez une nouvelle tâche...',
    'toDo': 'À faire',
    'completed': 'Terminées',
    'noTasksYet': 'Aucune tâche pour le moment. Ajoutez-en une ci-dessus !',
    'newTask': 'Nouvelle tâche',
    'editTask': 'Modifier la tâche',
    'taskTitle': 'Titre de la tâche',
    'descriptionOptional': 'Description (facultatif)',
    'addTask': 'Ajouter une tâche',
    'saveChanges': 'Enregistrer les modifications',
    'pending': 'En attente',
    'description': 'Description',
    'created': 'Créé le',
    'noDescription': 'Aucune description fournie.',
    'markDone': 'Marquer comme terminé',
    'markPending': 'Marquer comme en attente',
    'delete': 'Supprimer',
    'save': 'Enregistrer',
    'profile': 'Profil',
    'changeProfilePicture': 'Changer la photo de profil',
    'profileUpdated': 'Profil mis à jour',
    'fullName': 'Nom complet',
    'email': 'E-mail',
    'phone': 'Téléphone',
    'location': 'Emplacement',
    'editProfile': 'Modifier le profil',
    'galleryError':
        'Impossible d\'ouvrir la galerie. Reconstruisez l\'app et réessayez.',
    'emailRequired': 'L\'e-mail est requis',
    'validEmail': 'Saisissez un e-mail valide',
    'phoneRequired': 'Le téléphone est requis',
    'locationRequired': 'L\'emplacement est requis',
    'fullNameRequired': 'Le nom complet est requis',
    'settings': 'Paramètres',
    'general': 'Général',
    'language': 'Langue',
    'darkMode': 'Mode sombre',
    'notifications': 'Notifications',
    'on': 'Activé',
    'off': 'Désactivé',
    'enabled': 'Activées',
    'disabled': 'Désactivées',
    'account': 'Compte',
    'changePassword': 'Changer le mot de passe',
    'privacy': 'Confidentialité',
    'about': 'À propos',
    'version': 'Version 1.0.0',
    'selectLanguage': 'Choisir la langue',
    'privacyBody':
        'Vos informations de profil, votre photo et vos paramètres sont stockés uniquement sur cet appareil. '
        'Aucune donnée n\'est téléversée ni partagée avec des tiers.',
    'aboutDesc': 'Une application simple de gestion de tâches.',
    'builtWithFlutter': 'Construit avec Flutter.',
    'passwordUpdated': 'Mot de passe mis à jour avec succès',
    'updatePassword': 'Mettre à jour le mot de passe',
    'logout': 'Déconnexion',
    'changePasswordTitle': 'Changer le mot de passe',
    'currentPassword': 'Mot de passe actuel',
    'currentPasswordIncorrect': 'Le mot de passe actuel est incorrect',
    'ok': 'OK',
    'cancel': 'Annuler',
    'logoutConfirm': 'Êtes-vous sûr de vouloir vous déconnecter ?',
    'notifTaskAdded': 'Nouvelle tâche ajoutée',
    'notifTaskCompleted': 'Tâche terminée',
    'undo': 'Annuler',
    'deleteTaskTitle': 'Supprimer la tâche',
    'deleteTaskConfirm': 'Vous ne pourrez pas annuler cette action.',
    'taskAdded': 'Tâche ajoutée',
    'taskUpdated': 'Tâche mise à jour',
    'taskCompleted': 'Tâche terminée',
    'taskPending': 'Tâche marquée comme en attente',
    'taskDeleted': 'Tâche supprimée',
    'searchTasks': 'Rechercher des tâches...',
    'noResults': 'Aucune tâche ne correspond à votre recherche.',
    'progress': 'Progression',
    'totalTasks': 'Total',
    'createAccount': 'Créer un compte',
    'createAccountSubtitle': 'Créez votre compte pour commencer à gérer vos tâches',
    'noAccount': "Vous n'avez pas de compte ?",
    'alreadyHaveAccount': 'Vous avez déjà un compte ?',
    'usernameTaken': "Ce nom d'utilisateur est déjà pris",
    'usernameTooShort': "Le nom d'utilisateur doit contenir au moins 3 caractères",
    'usernameInvalid': 'Lettres, chiffres, points et tirets bas uniquement',
    'accountCreated': 'Compte créé avec succès. Veuillez vous connecter.',
    'optional': 'Facultatif',
    'dueDate': "Date d'échéance",
    'noDueDate': 'Aucune date limite',
    'setDueDate': 'Définir la date limite',
    'notifTaskDue': "Date d'échéance de la tâche",
    'overdue': 'En retard',
    'priority': 'Priorité',
    'low': 'Basse',
    'medium': 'Moyenne',
    'high': 'Haute',
    'category': 'Catégorie',
    'categoryOptional': 'Catégorie (facultatif)',
    'today': "Aujourd'hui",
    'clearFilter': 'Effacer le filtre',
    'noCompletedTasks': "Aucune tâche terminée pour l'instant.",
    'noOverdueTasks': 'Rien en retard. Beau travail !',
    'noTodayTasks': "Rien à faire aujourd'hui.",
  };
}

class AppTranslationsLocalizationsDelegate
    extends LocalizationsDelegate<AppTranslations> {
  const AppTranslationsLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => const ['en', 'fil', 'es', 'fr']
      .contains(locale.languageCode);

  @override
  Future<AppTranslations> load(Locale locale) async =>
      AppTranslations(locale);

  @override
  bool shouldReload(AppTranslationsLocalizationsDelegate old) => false;
}