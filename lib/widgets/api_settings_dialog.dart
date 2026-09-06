import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class ApiSettingsDialog extends StatefulWidget {
  const ApiSettingsDialog({super.key});

  @override
  State<ApiSettingsDialog> createState() => _ApiSettingsDialogState();
}

class _ApiSettingsDialogState extends State<ApiSettingsDialog> {
  late TextEditingController _googleKeyController;
  late TextEditingController _supabaseUrlController;
  late TextEditingController _supabaseKeyController;
  late TextEditingController _firebaseUrlController;

  String? _googleTestResult;
  bool _isTestingGoogle = false;

  String? _cloudTestResult;
  bool _isTestingCloud = false;

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    _googleKeyController = TextEditingController(text: appState.googleMapsService.apiKey ?? '');
    _supabaseUrlController = TextEditingController(text: appState.cloudSyncService.supabaseUrl ?? '');
    _supabaseKeyController = TextEditingController(text: appState.cloudSyncService.supabaseAnonKey ?? '');
    _firebaseUrlController = TextEditingController(text: appState.cloudSyncService.firebaseUrl ?? '');
  }

  @override
  void dispose() {
    _googleKeyController.dispose();
    _supabaseUrlController.dispose();
    _supabaseKeyController.dispose();
    _firebaseUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Dialog(
      backgroundColor: const Color(0xFF141826),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2979FF).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.tune_rounded, color: Color(0xFF2979FF), size: 22),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Developer & API Settings',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Configure Google Maps Platform & Cloud Sync',
                          style: TextStyle(color: Colors.white54, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white60),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(color: Colors.white12, height: 24),

              // 1. Google Maps Platform Settings
              Row(
                children: [
                  const Icon(Icons.map_rounded, color: Color(0xFFFFD600), size: 18),
                  const SizedBox(width: 8),
                  const Text(
                    'GOOGLE MAPS PLATFORM',
                    style: TextStyle(
                      color: Color(0xFFFFD600),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: appState.googleMapsService.isLiveMode
                          ? const Color(0xFF00E676).withValues(alpha: 0.2)
                          : Colors.white10,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      appState.googleMapsService.isLiveMode ? 'LIVE API ACTIVE' : 'SMART MODEL',
                      style: TextStyle(
                        color: appState.googleMapsService.isLiveMode
                            ? const Color(0xFF00E676)
                            : Colors.white60,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter your Google Maps API key (with Routes API enabled) to query live traffic delay:',
                style: TextStyle(color: Colors.white70, fontSize: 11),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _googleKeyController,
                obscureText: true,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'AIzaSy... (or prototype Maps Demo Key)',
                  hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                  filled: true,
                  fillColor: const Color(0xFF1B2233),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _isTestingGoogle
                        ? null
                        : () async {
                            setState(() {
                              _isTestingGoogle = true;
                              _googleTestResult = null;
                            });
                            final result = await appState.googleMapsService
                                .testApiKeyConnection(_googleKeyController.text);
                            setState(() {
                              _isTestingGoogle = false;
                              _googleTestResult = result.isSuccess
                                  ? '✅ ${result.message} (${result.latencyMs}ms)'
                                  : '❌ ${result.message}';
                            });
                            if (result.isSuccess) {
                              appState.setGoogleMapsApiKey(_googleKeyController.text);
                            }
                          },
                    icon: _isTestingGoogle
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                          )
                        : const Icon(Icons.speed_rounded, size: 16),
                    label: const Text('Test Connection'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD600),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (_googleTestResult != null)
                    Expanded(
                      child: Text(
                        _googleTestResult!,
                        style: TextStyle(
                          color: _googleTestResult!.startsWith('✅') ? const Color(0xFF00E676) : const Color(0xFFFF5252),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),

              const Divider(color: Colors.white12, height: 28),

              // 2. Cloud Sync (Supabase / Firebase)
              Row(
                children: [
                  const Icon(Icons.cloud_sync_rounded, color: Color(0xFF00E676), size: 18),
                  const SizedBox(width: 8),
                  const Text(
                    'MULTI-DEVICE CLOUD SYNC',
                    style: TextStyle(
                      color: Color(0xFF00E676),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: appState.cloudSyncService.isLiveCloud
                          ? const Color(0xFF00E676).withValues(alpha: 0.2)
                          : const Color(0xFF2979FF).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      appState.cloudSyncService.backendType.name.toUpperCase(),
                      style: TextStyle(
                        color: appState.cloudSyncService.isLiveCloud ? const Color(0xFF00E676) : const Color(0xFF82B1FF),
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Synchronize real-time snaps, votes, and vibe pings between devices via Supabase or Firebase:',
                style: TextStyle(color: Colors.white70, fontSize: 11),
              ),
              const SizedBox(height: 8),

              // Supabase Inputs
              TextField(
                controller: _supabaseUrlController,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                decoration: InputDecoration(
                  hintText: 'Supabase URL (e.g. https://xyz.supabase.co)',
                  hintStyle: const TextStyle(color: Colors.white38, fontSize: 11),
                  filled: true,
                  fillColor: const Color(0xFF1B2233),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _supabaseKeyController,
                obscureText: true,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                decoration: InputDecoration(
                  hintText: 'Supabase Anon Public Key',
                  hintStyle: const TextStyle(color: Colors.white38, fontSize: 11),
                  filled: true,
                  fillColor: const Color(0xFF1B2233),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _isTestingCloud
                        ? null
                        : () async {
                            setState(() {
                              _isTestingCloud = true;
                              _cloudTestResult = null;
                            });
                            appState.configureSupabaseSync(
                              url: _supabaseUrlController.text,
                              anonKey: _supabaseKeyController.text,
                            );
                            final result = await appState.cloudSyncService.testCloudConnection();
                            setState(() {
                              _isTestingCloud = false;
                              _cloudTestResult = result['success'] == true
                                  ? '✅ ${result['message']}'
                                  : '❌ ${result['message']}';
                            });
                          },
                    icon: _isTestingCloud
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.sync_rounded, size: 16),
                    label: const Text('Save & Test Sync'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E676),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (_cloudTestResult != null)
                    Expanded(
                      child: Text(
                        _cloudTestResult!,
                        style: TextStyle(
                          color: _cloudTestResult!.startsWith('✅') ? const Color(0xFF00E676) : const Color(0xFFFF5252),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Done', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
