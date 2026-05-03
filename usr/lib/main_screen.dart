import 'package:flutter/material.dart';
import 'core_system.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final CoreSystem _core = CoreSystem();
  AppState _appState = AppState.waiting;

  final TextEditingController _abilityNameController = TextEditingController();
  final TextEditingController _abilityDefController = TextEditingController();
  final TextEditingController _chatController = TextEditingController();

  final List<String> _chatLogs = [];
  final ScrollController _scrollController = ScrollController();

  String get _statusText {
    switch (_appState) {
      case AppState.waiting:
        return "待機中";
      case AppState.initializing:
        return "初期化中";
      case AppState.waitingForAbility:
        return "能力入力待機";
      case AppState.confirming:
        return "確定処理中";
      case AppState.running:
        return "動作中";
      case AppState.error:
        return "システムエラー";
    }
  }

  void _addLog(String message) {
    setState(() {
      _chatLogs.add(message);
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleStart() async {
    setState(() {
      _appState = AppState.initializing;
    });
    
    await _core.coreInit();
    
    setState(() {
      _appState = AppState.waitingForAbility;
      _abilityNameController.text = "時間改変";
      _abilityDefController.text = "対象の時間を制御する";
    });
  }

  Future<void> _handleAbilityInput() async {
    setState(() {
      _appState = AppState.confirming;
    });

    _core.abilityRegister(
      name: _abilityNameController.text.isNotEmpty ? _abilityNameController.text : "Unknown",
      definition: _abilityDefController.text.isNotEmpty ? _abilityDefController.text : "None",
      priority: 1,
      permission: "SELF_ONLY",
    );

    await Future.delayed(const Duration(seconds: 1)); // Simulate processing

    final success = _core.systemConfirm();

    setState(() {
      if (success) {
        _appState = AppState.running;
        _addLog("SYSTEM: 起動完了しました。対話機能が有効です。");
      } else {
        _appState = AppState.error;
      }
    });
  }

  void _handleInteraction() {
    final input = _chatController.text.trim();
    if (input.isEmpty) return;

    _chatController.clear();
    _addLog("USER: \$input");

    // Process logic
    final result = _core.decisionProcess(input);
    _core.memoryStore(input);
    _core.memoryStore(result);

    // Simulate Voice Model / Response
    Future.delayed(const Duration(milliseconds: 500), () {
      _core.voiceOutput(result);
      _addLog("SYSTEM: \$result");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        title: const Text('CORE TERMINAL', style: TextStyle(color: Colors.cyanAccent, letterSpacing: 2)),
        centerTitle: true,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
            color: _appState == AppState.error ? Colors.redAccent : Colors.cyanAccent,
            height: 1.0,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildStatusPanel(),
          Expanded(child: _buildMainContent()),
        ],
      ),
    );
  }

  Widget _buildStatusPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: const Color(0xFF161B22),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "STATUS:",
            style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold),
          ),
          Text(
            _statusText,
            style: TextStyle(
              color: _appState == AppState.error ? Colors.redAccent : Colors.cyanAccent,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    switch (_appState) {
      case AppState.waiting:
        return Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              side: const BorderSide(color: Colors.cyanAccent),
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
            ),
            onPressed: _handleStart,
            child: const Text(
              "起動",
              style: TextStyle(color: Colors.cyanAccent, fontSize: 18, letterSpacing: 4),
            ),
          ),
        );
      case AppState.initializing:
      case AppState.confirming:
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.cyanAccent),
          ),
        );
      case AppState.waitingForAbility:
        return _buildAbilityInput();
      case AppState.running:
        return _buildInteractionView();
      case AppState.error:
        return const Center(
          child: Text(
            "INITIALIZATION ERROR",
            style: TextStyle(color: Colors.redAccent, fontSize: 18),
          ),
        );
    }
  }

  Widget _buildAbilityInput() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "初期能力データを入力してください",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _abilityNameController,
            style: const TextStyle(color: Colors.cyanAccent),
            decoration: const InputDecoration(
              labelText: "能力名 (Name)",
              labelStyle: TextStyle(color: Colors.white54),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent)),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _abilityDefController,
            style: const TextStyle(color: Colors.cyanAccent),
            decoration: const InputDecoration(
              labelText: "定義 (Definition)",
              labelStyle: TextStyle(color: Colors.white54),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent)),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyanAccent.withOpacity(0.1),
                side: const BorderSide(color: Colors.cyanAccent),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _handleAbilityInput,
              child: const Text("登録して確定", style: TextStyle(color: Colors.cyanAccent)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionView() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _chatLogs.length,
            itemBuilder: (context, index) {
              final log = _chatLogs[index];
              final isUser = log.startsWith("USER:");
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isUser ? Colors.cyan.withOpacity(0.1) : Colors.white10,
                    border: Border.all(color: isUser ? Colors.cyanAccent.withOpacity(0.3) : Colors.white24),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    log,
                    style: TextStyle(
                      color: isUser ? Colors.cyanAccent : Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          color: const Color(0xFF161B22),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _chatController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "システムへ入力...",
                    hintStyle: const TextStyle(color: Colors.white38),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.black26,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onSubmitted: (_) => _handleInteraction(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.cyanAccent),
                onPressed: _handleInteraction,
              )
            ],
          ),
        )
      ],
    );
  }
}
