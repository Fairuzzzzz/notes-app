import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static Database? _db;
  static final DatabaseService instance = DatabaseService._contractor();

  // User Table
  final String _userTablename = "users";
  final String _userID = "id";
  final String _userUsername = "username";

  // Notes Table
  final String _noteTableNames = "notes";
  final String _noteColumnID = "id";
  final String _noteTitleName = "title";
  final String _noteContent = "content";
  final String _noteCategoryName = "category";
  final String _noteSpaceName = "workspace";

  // Workspace Table
  final String _workspaceTableName = "workspaces";
  final String _workspaceID = "id";
  final String _workspaceName = "name";

  DatabaseService._contractor();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await getDatabase();
    return _db!;
  }

  Future<Database> getDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, "master_db.db");
    final database = await openDatabase(
      databasePath,
      onCreate: (db, version) async {
        await db.execute('''
      CREATE TABLE $_userTablename (
        $_userID INTEGER PRIMARY KEY AUTOINCREMENT,
        $_userUsername TEXT NOT NULL UNIQUE
      )
      ''');

        await db.execute('''
      CREATE TABLE $_noteTableNames (
        $_noteColumnID INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        $_noteTitleName TEXT NOT NULL,
        $_noteContent TEXT NOT NULL,
        $_noteCategoryName TEXT NOT NULL,
        $_noteSpaceName TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES $_userTablename ($_userID)
      ) 
      ''');
        await db.execute('''
      CREATE TABLE $_workspaceTableName (
        $_workspaceID INTEGER PRIMARY KEY AUTOINCREMENT,
        $_workspaceName TEXT NOT NULL UNIQUE
      )
      ''');
      },
    );
    return database;
  }

  // Create User
  Future<int> createUser(String username) async {
    final db = await database;
    return await db.insert(_userTablename, {_userUsername: username});
  }

  // Get User
  Future<Map<String, dynamic>?> getUser(String username) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      _userTablename,
      where: '$_userUsername = ?',
      whereArgs: [username],
    );
    return results.isNotEmpty ? results.first : null;
  }

  // Update User
  Future<int> updateUser(String username, int userID) async {
    final db = await database;
    return await db.update(_userTablename, {_userUsername: username},
        where: 'user_id = ?', whereArgs: [userID]);
  }

  // Delete User
  Future<int> deleteUser(int userID) async {
    final db = await database;
    return await db
        .delete(_userTablename, where: 'user_id = ?', whereArgs: [userID]);
  }

  // Add Notes
  Future<void> addNotes({
    required int userID,
    required String title,
    required String content,
    required String category,
    String workspace = "Personal",
  }) async {
    final db = await database;
    await db.insert(_noteTableNames, {
      'user_id': userID,
      _noteTitleName: title,
      _noteContent: content,
      _noteCategoryName: category,
      _noteSpaceName: workspace,
    });
  }

  // Get User Notes
  Future<List<Map<String, dynamic>>> getUserNotes(int userID) async {
    final db = await database;
    return await db.query(
      _noteTableNames,
      where: 'user_id = ?',
      whereArgs: [userID],
    );
  }

  // Udpate User Notes
  Future<int> updateNote({
    required int noteID,
    required int userID,
    String? title,
    String? content,
    String? category,
    String? workspace,
  }) async {
    final db = await database;
    final Map<String, dynamic> updates = {};

    if (title != null) updates[_noteTitleName] = title;
    if (content != null) updates[_noteContent] = content;
    if (category != null) updates[_noteCategoryName] = category;
    if (workspace != null) updates[_noteSpaceName] = workspace;

    return await db.update(_noteTableNames, updates,
        where: '$_noteColumnID = ? AND user_id = ?',
        whereArgs: [noteID, userID]);
  }

  // Delete Notes
  Future<int> deleteNote({
    required int noteID,
    required int userID,
  }) async {
    final db = await database;
    return await db.delete(_noteTableNames,
        where: '$_noteColumnID = ? AND user_id = ?',
        whereArgs: [noteID, userID]);
  }

  // Create Workspaces
  Future<int> createWorkspaces(String workspaceName) async {
    final db = await database;
    return await db
        .insert(_workspaceTableName, {_workspaceName: workspaceName});
  }

  // Get Workspaces
  Future<List<String>> getWorkspaces() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query(_workspaceTableName, columns: [_workspaceName]);
    return List.generate(maps.length, (i) => maps[i][_workspaceName] as String);
  }

  // Get Notes By Workspaces
  Future<List<Map<String, dynamic>>> getNotesByWorkspaces(
      int userID, String workspaces) async {
    final db = await database;
    return await db.query(_noteTableNames,
        where: 'user_id = ? AND $_noteSpaceName = ?',
        whereArgs: [userID, workspaces]);
  }

  // Update Workspaces
  Future<int> updateWorkspaces(String workspaceName, int workspaceID) async {
    final db = await database;
    return await db.update(_workspaceTableName, {_workspaceName: workspaceName},
        where: 'workspace_id = ?', whereArgs: [workspaceID]);
  }

  // Delete Workspaces
  Future<int> deleteWorkspaces(int workspaceID) async {
    final db = await database;
    await db.update(_noteTableNames, {_noteSpaceName: "Personal"},
        where:
            '$_noteSpaceName = (SELECT $_workspaceTableName WHERE $_workspaceID = ?)',
        whereArgs: [workspaceID]);

    return await db.delete(_workspaceTableName,
        where: '$_workspaceID = ?', whereArgs: [workspaceID]);
  }
}
