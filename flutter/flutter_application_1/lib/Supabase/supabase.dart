import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/AdditionalComponents/add_menu.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabasePage extends StatefulWidget {
  const SupabasePage({super.key});

  @override
  State<SupabasePage> createState() => _SupabasePageState();
}

class _SupabasePageState extends State<SupabasePage> {
  final _usersController =
      StreamController<List<Map<String, dynamic>>>.broadcast();

  final _scrollbarController = ScrollController();

  StreamSubscription<List<Map<String, dynamic>>>? _realtimeSubscription;
  StreamSubscription<List<Map<String, dynamic>>>? _usersControllerSubscription;
  List<Map<String, dynamic>> _users = const [];
  String? _serverError;
  bool _isRealtimeEnabled = false;
  bool _isLoading = false;
  bool _isSaving = false;

  SupabaseClient get _supabase => Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _usersControllerSubscription = _usersController.stream.listen((users) {
      if (!mounted) return;
      setState(() {
        _users = users;
        _isLoading = false;
        _serverError = null;
      });
    });

    final session = _supabase.auth.currentSession;
    if (session == null || session.isExpired) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/supabase/auth');
        }
      });
      return;
    }

    fetchData();
  }

  Future<void> fetchData() async {
    if (_isLoading || _isRealtimeEnabled) return;

    setState(() {
      _isLoading = true;
      _serverError = null;
    });
    try {
      final result = await _supabase.from('Users').select();
      if (!mounted) return;
      _usersController.add(
        result.map((row) => Map<String, dynamic>.from(row)).toList(),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _serverError = error.toString();
      });
    }
  }

  void subscribe() {
    _realtimeSubscription?.cancel();
    _realtimeSubscription = _supabase
        .from('Users')
        .stream(primaryKey: ['id'])
        .eq('owner_id', _supabase.auth.currentUser!.id)
        .listen(
          (users) => _usersController.add(users),
          onError: (Object error) {
            if (!mounted) return;
            setState(() {
              _serverError = error.toString();
              _isLoading = false;
            });
          },
        );
  }

  void toggleRealtime(bool? value) {
    if (value == null) return;

    setState(() {
      _isRealtimeEnabled = value;
      _serverError = null;
    });

    if (value) {
      setState(() {
        _isLoading = true;
      });
      subscribe();
    } else {
      _realtimeSubscription?.cancel();
      _realtimeSubscription = null;
      fetchData();
    }
  }

  Future<bool> _insertIntoTable(String? username, String? passwd) async {
    final trimmedUsername = username?.trim() ?? '';
    final password = passwd ?? '';
    if (trimmedUsername.isEmpty || password.trim().isEmpty || _isSaving) {
      return false;
    }

    setState(() {
      _isSaving = true;
      _serverError = null;
    });
    try {
      // shortcut: SHA-256 is for demo records; use server-side Argon2/bcrypt for real passwords.
      final passwordHash = sha256.convert(utf8.encode(password)).toString();
      await _supabase.from('Users').insert({
        'owner_id': _supabase.auth.currentUser!.id,
        'username': trimmedUsername,
        'password': passwordHash,
      });
      if (mounted && !_isRealtimeEnabled) {
        await fetchData();
      }
      return true;
    } catch (error) {
      if (mounted) {
        setState(() => _serverError = error.toString());
      }
      return false;
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _realtimeSubscription?.cancel();
    _usersControllerSubscription?.cancel();
    _usersController.close();
    _scrollbarController.dispose();
    super.dispose();
  }

  Future<void> logout() async {
    try {
      await Supabase.instance.client.auth.signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/supabase/auth');
      }
    } catch (_) {
      if (mounted) {
        setState(() => _serverError = 'Не удалось выйти. Попробуйте ещё раз.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final username = _supabase.auth.currentUser?.email;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 145, 178, 145),
        title: Row(
          spacing: 40,
          children: [
            Text(username ?? 'Error user', style: TextStyle(fontSize: 15)),
            IconButton(onPressed: logout, icon: Icon(Icons.logout)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(10),
          padding: EdgeInsets.all(10),
          child: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Users',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 300,
                  margin: const EdgeInsets.only(top: 8, bottom: 20),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 222, 222, 222),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _users.isEmpty
                      ? Center(child: Text(_serverError ?? 'List is empty'))
                      : Scrollbar(
                          thumbVisibility: true,
                          controller: _scrollbarController,
                          child: ListView.builder(
                            controller: _scrollbarController,
                            itemCount: _users.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                dense: true,
                                title: Text(
                                  _users[index]['username']?.toString() ??
                                      'Unnamed user',
                                ),
                              );
                            },
                          ),
                        ),
                ),

                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: _isRealtimeEnabled,
                      onChanged: toggleRealtime,
                    ),
                    const Text('Realtime'),
                    const SizedBox(width: 24),
                    ElevatedButton(
                      onPressed: _isRealtimeEnabled || _isLoading
                          ? null
                          : fetchData,
                      child: const Text('Fetch'),
                    ),
                  ],
                ),
                AddMenu(insert: _insertIntoTable),
                if (_serverError != null)
                  Text(
                    _serverError!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
