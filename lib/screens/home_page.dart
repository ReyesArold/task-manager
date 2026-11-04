import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/core/app_colors.dart';
import 'package:myapp/core/app_translations.dart';
import 'package:myapp/core/database_helper.dart';
import 'package:myapp/core/notification_helper.dart';
import 'package:myapp/core/profile_helper.dart';
import 'package:myapp/core/profile_image_helper.dart';
import 'package:myapp/core/task_filter.dart';
import 'package:myapp/widgets/nav_bar.dart';
import 'package:myapp/screens/profile_page.dart';
import 'package:myapp/widgets/interactive.dart';

class HomePage extends StatefulWidget {
  final String username;

  const HomePage({super.key, required this.username});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _taskController = TextEditingController();
  final _descController = TextEditingController();
  final _categoryController = TextEditingController();
  final _searchController = TextEditingController();
  final List<Task> _tasks = [];
  bool _isLoading = true;
  String _searchQuery = '';
  File? _profileImage;
  String _profileName = 'Arold M. Reyes';
  TaskFilter? _filter;

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _loadProfileImage();
    _loadProfileName();
  }

  Future<void> _loadProfileName() async {
    final profile = await ProfileHelper.loadProfile(username: widget.username);
    if (!mounted) return;
    setState(() => _profileName = profile.fullName);
  }

  Future<void> _loadProfileImage() async {
    final file = await ProfileImageHelper.getImageFile(widget.username);
    if (!mounted) return;
    setState(() => _profileImage = file);
  }

  Future<void> _loadTasks() async {
    List<Task> tasks;
    try {
      tasks = await DatabaseHelper.instance.getAllTasks(
        username: widget.username,
      );
    } catch (e) {
      debugPrint('Failed to load tasks: $e');
      tasks = [];
    }
    if (!mounted) return;
    setState(() {
      _tasks
        ..clear()
        ..addAll(tasks);
      _isLoading = false;
    });
    _syncReminders(tasks);
  }

  void _showAddTaskDialog() {
    final tr = AppTranslations.of(context);
    _taskController.clear();
    _descController.clear();
    _categoryController.clear();
    DateTime? dueDate;
    String priority = 'medium';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.outline(ctx),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppTranslations.of(ctx).newTask,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _taskController,
                      decoration: InputDecoration(
                        labelText: tr.taskTitle,
                        prefixIcon: const Icon(Icons.task_outlined),
                      ),
                      autofocus: true,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _descController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: tr.descriptionOptional,
                        alignLabelWithHint: true,
                        prefixIcon: const Icon(Icons.notes_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDueDateField(
                      ctx,
                      dueDate: dueDate,
                      onChanged: (date) => setSheetState(() => dueDate = date),
                    ),
                    const SizedBox(height: 14),
                    _buildPrioritySelector(
                      ctx,
                      value: priority,
                      onChanged: (value) =>
                          setSheetState(() => priority = value),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _categoryController,
                      decoration: InputDecoration(
                        labelText: tr.categoryOptional,
                        prefixIcon: const Icon(Icons.label_outline),
                      ),
                    ),
                    const SizedBox(height: 20),
                    PrimaryButton(
                      label: AppTranslations.of(ctx).addTask,
                      icon: Icons.check,
                      onPressed: () {
                        _addTask(dueDate, priority);
                        Navigator.of(ctx).pop();
                      },
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _syncReminders(List<Task> tasks) async {
    final tr = AppTranslations.of(context);
    final now = DateTime.now();
    for (final task in tasks) {
      if (task.done || task.dueDate == null) continue;
      if (task.dueDate!.isBefore(now)) continue;
      await NotificationHelper.scheduleDueDateReminder(
        id: task.id!,
        title: tr.notifTaskDue,
        body: task.title,
        dueDate: task.dueDate!,
      );
    }
  }

  Future<void> _addTask(DateTime? dueDate, String priority) async {
    final tr = AppTranslations.of(context);
    final text = _taskController.text.trim();
    if (text.isEmpty) return;
    final task = Task(
      username: widget.username,
      title: text,
      description: _descController.text.trim(),
      createdAt: DateTime.now(),
      dueDate: dueDate,
      priority: priority,
      category: _categoryController.text.trim(),
    );
    final id = await DatabaseHelper.instance.insertTask(task);
    task.id = id;
    if (!mounted) return;
    setState(() => _tasks.insert(0, task));
    _taskController.clear();
    _descController.clear();
    _categoryController.clear();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(tr.taskAdded)));
    if (dueDate != null) {
      await NotificationHelper.scheduleDueDateReminder(
        id: id,
        title: tr.notifTaskDue,
        body: task.title,
        dueDate: dueDate,
      );
    }
    await NotificationHelper.show(
      channelId: 'task_added',
      title: tr.notifTaskAdded,
      body: task.title,
      id: 100 + id,
    );
  }

  void _showEditTaskDialog(Task task, int index) {
    final tr = AppTranslations.of(context);
    _taskController.text = task.title;
    _descController.text = task.description;
    _categoryController.text = task.category;
    DateTime? dueDate = task.dueDate;
    String priority = task.priority;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.outline(ctx),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppTranslations.of(ctx).editTask,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _taskController,
                      decoration: InputDecoration(
                        labelText: tr.taskTitle,
                        prefixIcon: const Icon(Icons.task_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _descController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: tr.descriptionOptional,
                        alignLabelWithHint: true,
                        prefixIcon: const Icon(Icons.notes_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDueDateField(
                      ctx,
                      dueDate: dueDate,
                      onChanged: (date) => setSheetState(() => dueDate = date),
                    ),
                    const SizedBox(height: 14),
                    _buildPrioritySelector(
                      ctx,
                      value: priority,
                      onChanged: (value) =>
                          setSheetState(() => priority = value),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _categoryController,
                      decoration: InputDecoration(
                        labelText: tr.categoryOptional,
                        prefixIcon: const Icon(Icons.label_outline),
                      ),
                    ),
                    const SizedBox(height: 20),
                    PrimaryButton(
                      label: AppTranslations.of(ctx).saveChanges,
                      icon: Icons.save_outlined,
                      onPressed: () {
                        _saveTask(task, index, dueDate, priority);
                        Navigator.of(ctx).pop();
                      },
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _saveTask(
    Task task,
    int index,
    DateTime? dueDate,
    String priority,
  ) async {
    final tr = AppTranslations.of(context);
    final text = _taskController.text.trim();
    if (text.isEmpty) return;
    task.title = text;
    task.description = _descController.text.trim();
    task.dueDate = dueDate;
    task.priority = priority;
    task.category = _categoryController.text.trim();
    await DatabaseHelper.instance.updateTask(task);
    if (!mounted) return;
    setState(() {});
    _taskController.clear();
    _descController.clear();
    _categoryController.clear();
    if (dueDate != null) {
      await NotificationHelper.scheduleDueDateReminder(
        id: task.id!,
        title: tr.notifTaskDue,
        body: task.title,
        dueDate: dueDate,
      );
    } else {
      await NotificationHelper.cancel(task.id!);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(tr.taskUpdated)));
  }

  Future<void> _toggleTask(int index) async {
    final tr = AppTranslations.of(context);
    final task = _tasks[index];
    task.done = !task.done;
    await DatabaseHelper.instance.updateTask(task);
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(task.done ? tr.taskCompleted : tr.taskPending)),
      );
    if (task.done) {
      await NotificationHelper.show(
        channelId: 'task_completed',
        title: tr.notifTaskCompleted,
        body: task.title,
        id: 200,
      );
    }
  }

  Future<void> _deleteTask(int index) async {
    final tr = AppTranslations.of(context);
    final task = _tasks[index];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final dtr = AppTranslations.of(ctx);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(dtr.deleteTaskTitle),
          content: Text(dtr.deleteTaskConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(dtr.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(
                dtr.delete,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;
    await NotificationHelper.cancel(task.id!);
    await DatabaseHelper.instance.deleteTask(task.id!);
    if (!mounted) return;
    setState(() => _tasks.removeAt(index));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(tr.taskDeleted),
          action: SnackBarAction(
            label: tr.undo,
            onPressed: () async {
              task.id = null;
              final newId = await DatabaseHelper.instance.insertTask(task);
              if (!mounted) return;
              setState(() {
                task.id = newId;
                _tasks.insert(index.clamp(0, _tasks.length), task);
              });
              if (task.dueDate != null &&
                  task.dueDate!.isAfter(DateTime.now())) {
                await NotificationHelper.scheduleDueDateReminder(
                  id: newId,
                  title: tr.notifTaskDue,
                  body: task.title,
                  dueDate: task.dueDate!,
                );
              }
            },
          ),
        ),
      );
  }

  void _showTaskDetails(int index) {
    final task = _tasks[index];
    final done = task.done;
    final created = task.createdAt;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final tr = AppTranslations.of(ctx);
        return Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.outline(ctx),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: (done ? Colors.green : Colors.orange).withValues(
                          alpha: AppColors.isDark(ctx) ? 0.18 : 0.1,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        done ? tr.completed : tr.pending,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: done
                              ? (AppColors.isDark(ctx)
                                    ? Colors.greenAccent
                                    : Colors.green)
                              : (AppColors.isDark(ctx)
                                    ? Colors.orangeAccent
                                    : Colors.orange),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  tr.description,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary(ctx),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  task.description.isEmpty
                      ? tr.noDescription
                      : task.description,
                  style: const TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 16),
                Text(
                  tr.created,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary(ctx),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${created.month.toString().padLeft(2, '0')}/${created.day.toString().padLeft(2, '0')}/${created.year}  ${created.hour.toString().padLeft(2, '0')}:${created.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 16),
                Text(
                  tr.dueDate,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary(ctx),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      task.dueDate == null ? Icons.event_outlined : Icons.event,
                      size: 18,
                      color: task.dueDate == null
                          ? AppColors.textSecondary(ctx)
                          : (AppColors.isDark(ctx)
                                ? Colors.redAccent
                                : Colors.red),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        task.dueDate == null
                            ? tr.noDueDate
                            : _formatDueDate(task.dueDate!),
                        style: TextStyle(
                          fontSize: 15,
                          color: _isOverdue(task)
                              ? (AppColors.isDark(ctx)
                                    ? Colors.redAccent
                                    : Colors.red)
                              : null,
                        ),
                      ),
                    ),
                    if (_isOverdue(task))
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              (AppColors.isDark(ctx)
                                      ? Colors.redAccent
                                      : Colors.red)
                                  .withValues(
                                    alpha: AppColors.isDark(ctx) ? 0.18 : 0.1,
                                  ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          tr.overdue,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.isDark(ctx)
                                ? Colors.redAccent
                                : Colors.red,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: tr.editTask,
                  icon: Icons.edit_outlined,
                  backgroundColor: Colors.blueAccent,
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _showEditTaskDialog(task, index);
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          _toggleTask(index);
                        },
                        icon: Icon(done ? Icons.undo : Icons.check),
                        label: Text(done ? tr.markPending : tr.markDone),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: done ? Colors.orange : Colors.green,
                          side: BorderSide(
                            color: done ? Colors.orange : Colors.green,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          _deleteTask(index);
                        },
                        icon: const Icon(Icons.delete_outline),
                        label: Text(tr.delete),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _matches(Task task) {
    if (_searchQuery.isEmpty) return true;
    return task.title.toLowerCase().contains(_searchQuery) ||
        task.description.toLowerCase().contains(_searchQuery);
  }

  bool _matchesFilter(Task task) {
    final filter = _filter;
    if (filter == null) return true;
    final now = DateTime.now();
    switch (filter) {
      case TaskFilter.completed:
        return task.done;
      case TaskFilter.overdue:
        return task.dueDate != null &&
            !task.done &&
            task.dueDate!.isBefore(now);
      case TaskFilter.today:
        return task.dueDate != null &&
            !task.done &&
            task.dueDate!.year == now.year &&
            task.dueDate!.month == now.month &&
            task.dueDate!.day == now.day;
    }
  }

  void _selectFilter(TaskFilter? filter) {
    setState(() => _filter = filter);
  }

  @override
  void dispose() {
    _taskController.dispose();
    _descController.dispose();
    _categoryController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String _formatDueDate(DateTime date) =>
      DateFormat('MMM d, yyyy - h:mm a').format(date);

  bool _isOverdue(Task task) =>
      task.dueDate != null &&
      !task.done &&
      task.dueDate!.isBefore(DateTime.now());

  Future<DateTime?> _pickDueDate(BuildContext ctx, DateTime? current) async {
    final tr = AppTranslations.of(ctx);
    final now = DateTime.now();
    final initial = current ?? DateTime(now.year, now.month, now.day, 9, 0);
    final date = await showDatePicker(
      context: ctx,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
      helpText: tr.dueDate,
    );
    if (date == null || !ctx.mounted) return null;
    final time = await showTimePicker(
      context: ctx,
      initialTime: TimeOfDay.fromDateTime(initial),
      helpText: tr.dueDate,
    );
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Widget _buildDueDateField(
    BuildContext ctx, {
    required DateTime? dueDate,
    required ValueChanged<DateTime?> onChanged,
  }) {
    final tr = AppTranslations.of(ctx);
    final isDark = AppColors.isDark(ctx);
    final overdue = dueDate != null && dueDate.isBefore(DateTime.now());
    final color = overdue
        ? (isDark ? Colors.redAccent : Colors.red)
        : Colors.blue;
    return PressableScale(
      onTap: () async {
        final picked = await _pickDueDate(ctx, dueDate);
        if (picked != null) onChanged(picked);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.card(ctx),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.outline(ctx)),
        ),
        child: Row(
          children: [
            Icon(
              dueDate == null ? Icons.event_outlined : Icons.event_available,
              color: color,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr.dueDate,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary(ctx),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dueDate == null ? tr.noDueDate : _formatDueDate(dueDate),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: dueDate == null
                          ? AppColors.textSecondary(ctx)
                          : color,
                    ),
                  ),
                ],
              ),
            ),
            if (dueDate != null)
              IconButton(
                icon: const Icon(Icons.clear, size: 18),
                color: AppColors.textSecondary(ctx),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                onPressed: () => onChanged(null),
              ),
            const Icon(Icons.edit_outlined, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildPrioritySelector(
    BuildContext ctx, {
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppTranslations.of(ctx).priority,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary(ctx),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildPriorityOption(
                ctx,
                level: 'low',
                label: AppTranslations.of(ctx).priorityLow,
                color: Colors.green,
                value: value,
                onChanged: onChanged,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildPriorityOption(
                ctx,
                level: 'medium',
                label: AppTranslations.of(ctx).priorityMedium,
                color: Colors.orange,
                value: value,
                onChanged: onChanged,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildPriorityOption(
                ctx,
                level: 'high',
                label: AppTranslations.of(ctx).priorityHigh,
                color: Colors.red,
                value: value,
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriorityOption(
    BuildContext ctx, {
    required String level,
    required String label,
    required Color color,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    final isDark = AppColors.isDark(ctx);
    final selected = value == level;
    return PressableScale(
      onTap: () => onChanged(level),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: isDark ? 0.25 : 0.14)
              : AppColors.card(ctx),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : AppColors.outline(ctx),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flag_outlined,
              size: 14,
              color: selected ? color : AppColors.textSecondary(ctx),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? color : AppColors.textPrimary(ctx),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _priorityColor(String priority) => switch (priority) {
        'low' => Colors.green,
        'high' => Colors.red,
        _ => Colors.orange,
      };

  Widget _buildChipLabel(BuildContext ctx, String label, Color color) {
    final isDark = AppColors.isDark(ctx);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.20 : 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isDark
              ? Color.alphaBlend(color.withValues(alpha: 0.4), Colors.white)
              : color,
        ),
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context) {
    final tr = AppTranslations.of(context);
    final total = _tasks.length;
    final done = _tasks.where((t) => t.done).length;
    final percent = total == 0 ? 0 : (done / total * 100).round();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow(context),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.insights, size: 20, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                tr.progress,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '$done / $total ${tr.completed.toLowerCase()}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : done / total,
              minHeight: 8,
              backgroundColor: AppColors.outline(context),
              color: done == total ? Colors.green : Colors.blue,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '$percent%',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return PressableScale(
      onTap: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProfilePage(username: widget.username),
          ),
        );
        _loadProfileImage();
        _loadProfileName();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4F46E5).withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              backgroundImage: _profileImage != null
                  ? FileImage(_profileImage!)
                  : null,
              child: _profileImage == null
                  ? Text(
                      ProfileHelper.initials(_profileName),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _profileName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@${widget.username}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.chevron_right,
                color: Colors.white,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    final toDoCount = _tasks.where((t) => !t.done && _matches(t)).length;
    final doneCount = _tasks.where((t) => t.done && _matches(t)).length;
    final tr = AppTranslations.of(context);
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.task_alt,
            label: tr.totalTasks,
            value: _tasks.length,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.pending_actions,
            label: tr.toDo,
            value: toDoCount,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.check_circle_outline,
            label: tr.completed,
            value: doneCount,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int value,
    required Color color,
  }) {
    final isDark = AppColors.isDark(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow(context),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.18 : 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value.toString(),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    int count,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 8),
        AnimatedCounter(value: count, color: color, icon: Icons.circle),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, IconData icon, String message) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: AppColors.outline(context)),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskTile(Task task, int index) {
    final done = task.done;
    return PressableScale(
      onTap: () => _showTaskDetails(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: BorderRadius.circular(14),
          border: Border(
            left: BorderSide(
              color: done ? Colors.green : Colors.orange,
              width: 4,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow(context),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            PressableScale(
              onTap: () => _toggleTask(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: done ? Colors.green : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: done ? Colors.green : AppColors.outline(context),
                    width: 2,
                  ),
                ),
                child: done
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      decoration: done ? TextDecoration.lineThrough : null,
                      color: done
                          ? AppColors.textSecondary(context)
                          : AppColors.textPrimary(context),
                    ),
                  ),
if (task.description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text(
                          task.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                      ),
                    if (task.priority != 'medium' || task.category.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            _buildChipLabel(
                              context,
                              AppTranslations.of(context)
                                  .priorityLabel(task.priority),
                              _priorityColor(task.priority),
                            ),
                            if (task.category.isNotEmpty)
                              _buildChipLabel(
                                context,
                                task.category,
                                Colors.blue,
                              ),
                          ],
                        ),
                      ),
                    if (task.dueDate != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Row(
                        children: [
                          Icon(
                            Icons.event_outlined,
                            size: 13,
                            color: _isOverdue(task)
                                ? (AppColors.isDark(context)
                                      ? Colors.redAccent
                                      : Colors.red)
                                : AppColors.textSecondary(context),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDueDate(task.dueDate!),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: _isOverdue(task)
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: _isOverdue(task)
                                  ? (AppColors.isDark(context)
                                        ? Colors.redAccent
                                        : Colors.red)
                                  : AppColors.textSecondary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            PressableScale(
              onTap: () => _showEditTaskDialog(task, index),
              child: IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                onPressed: null,
                splashRadius: 20,
              ),
            ),
            PressableScale(
              onTap: () => _deleteTask(index),
              child: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: null,
                splashRadius: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppTranslations.of(context);
    final filter = _filter;
    return Scaffold(
      backgroundColor: AppColors.scaffold(context),
      appBar: PrimaryAppBar(
        title: filter == null ? tr.dashboard : tr.filterLabel(filter),
      ),
      drawer: AppDrawer(
        username: widget.username,
        onSelectFilter: _selectFilter,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: filter == null
              ? _dashboardChildren(context, tr)
              : _filteredChildren(context, tr),
        ),
      ),
    );
  }

  List<Widget> _dashboardChildren(BuildContext context, AppTranslations tr) {
    return [
      _buildProfileHeader(context),
      const SizedBox(height: 20),
      _buildStatsRow(context),
      const SizedBox(height: 24),
      Row(
        children: [
          Expanded(
            child: Text(
              tr.myTasks,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          PressableScale(
            onTap: _showAddTaskDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4F46E5).withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add, color: Colors.white, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    tr.newTask,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 14),
      if (_tasks.isNotEmpty) ...[
        _buildSearchField(tr),
        const SizedBox(height: 14),
        _buildProgressCard(context),
        const SizedBox(height: 16),
      ],
      if (_isLoading)
        const Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        )
      else if (_tasks.isEmpty)
        _buildEmptyState(context, Icons.task_alt, tr.noTasksYet),
      if (_tasks.isNotEmpty &&
          _searchQuery.isNotEmpty &&
          _tasks.every((t) => !_matches(t)))
        _buildEmptyState(context, Icons.search_off, tr.noResults),
      if (_tasks.where((t) => !t.done && _matches(t)).isNotEmpty) ...[
        _buildSectionHeader(
          context,
          Icons.pending_actions,
          tr.toDo,
          Colors.orange,
          _tasks.where((t) => !t.done && _matches(t)).length,
        ),
        const SizedBox(height: 10),
        ...List.generate(_tasks.length, (index) {
          final task = _tasks[index];
          if (task.done || !_matches(task)) {
            return const SizedBox.shrink();
          }
          return _buildTaskTile(task, index);
        }),
        const SizedBox(height: 16),
      ],
      if (_tasks.where((t) => t.done && _matches(t)).isNotEmpty) ...[
        _buildSectionHeader(
          context,
          Icons.check_circle_outline,
          tr.completed,
          Colors.green,
          _tasks.where((t) => t.done && _matches(t)).length,
        ),
        const SizedBox(height: 10),
        ...List.generate(_tasks.length, (index) {
          final task = _tasks[index];
          if (!task.done || !_matches(task)) {
            return const SizedBox.shrink();
          }
          return _buildTaskTile(task, index);
        }),
      ],
    ];
  }

  Widget _buildSearchField(AppTranslations tr) {
    return TextField(
      controller: _searchController,
      onChanged: (value) =>
          setState(() => _searchQuery = value.trim().toLowerCase()),
      decoration: InputDecoration(
        hintText: tr.searchTasks,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchQuery.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
              ),
      ),
    );
  }

  List<Widget> _filteredChildren(BuildContext context, AppTranslations tr) {
    final filter = _filter!;
    final filtered = _tasks.where(_matchesFilter).toList();
    return [
      _buildFilterHeader(context, tr),
      const SizedBox(height: 14),
      if (_tasks.isNotEmpty) ...[
        _buildSearchField(tr),
        const SizedBox(height: 14),
      ],
      if (_isLoading)
        const Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        )
      else if (_searchQuery.isNotEmpty && filtered.every((t) => !_matches(t)))
        _buildEmptyState(context, Icons.search_off, tr.noResults)
      else if (filtered.isEmpty)
        _buildEmptyState(context, filter.icon, _emptyFilterMessage(tr)),
      ...List.generate(_tasks.length, (index) {
        final task = _tasks[index];
        if (!_matchesFilter(task) || !_matches(task)) {
          return const SizedBox.shrink();
        }
        return _buildTaskTile(task, index);
      }),
    ];
  }

  Widget _buildFilterHeader(BuildContext context, AppTranslations tr) {
    final filter = _filter!;
    final count = _tasks.where(_matchesFilter).length;
    final isDark = AppColors.isDark(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: filter.color.withValues(alpha: isDark ? 0.18 : 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(filter.icon, color: filter.color, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr.filterLabel(filter),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$count ${tr.myTasks.toLowerCase()}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary(context),
                ),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: () => _selectFilter(null),
          child: Text(tr.clearFilter),
        ),
      ],
    );
  }

  String _emptyFilterMessage(AppTranslations tr) => switch (_filter!) {
        TaskFilter.completed => tr.noCompletedTasks,
        TaskFilter.overdue => tr.noOverdueTasks,
        TaskFilter.today => tr.noTodayTasks,
      };
}
